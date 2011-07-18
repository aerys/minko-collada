package aerys.minko.type.parser.collada.ressource
{
	import aerys.minko.ns.minko_collada;
	import aerys.minko.scene.node.group.Group;
	import aerys.minko.scene.node.group.IGroup;
	import aerys.minko.scene.node.mesh.IMesh;
	import aerys.minko.scene.node.mesh.Mesh;
	import aerys.minko.type.parser.collada.Document;
	import aerys.minko.type.parser.collada.enum.InputType;
	import aerys.minko.type.parser.collada.instance.IInstance;
	import aerys.minko.type.parser.collada.instance.InstanceGeometry;
	import aerys.minko.type.parser.collada.store.Source;
	import aerys.minko.type.parser.collada.store.Triangles;
	import aerys.minko.type.stream.IndexStream;
	import aerys.minko.type.stream.VertexStream;
	import aerys.minko.type.stream.VertexStreamList;
	import aerys.minko.type.vertex.format.VertexComponent;
	import aerys.minko.type.vertex.format.VertexFormat;
	
	use namespace minko_collada;
	
	public class Geometry implements IRessource
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _document				: Document;
		
		private var _id						: String;
		private var _name					: String;
		private var _verticesDataSemantics	: Vector.<String>;
		private var _verticesDataSources	: Object;
		private var _triangleStores			: Vector.<Triangles>;
		
		public function get id()		: String	{ return _id; }
		
		minko_collada function get verticesDataSemantics() : Vector.<String>
		{
			return _verticesDataSemantics;
		}
		
		minko_collada function get verticesDataSources() : Object
		{ 
			return _verticesDataSources; 
		}
		
		minko_collada function get triangleStores() : Vector.<Triangles>
		{
			return _triangleStores; 
		}
		
		public static function fillStoreFromXML(xmlDocument	: XML,
												document	: Document, 
												store		: Object) : void
		{
			var xmlGeometryLibrary	: XML		= xmlDocument..NS::library_geometries[0];
			if (xmlGeometryLibrary == null)
				return;
			
			var xmlGeometries		: XMLList	= xmlGeometryLibrary.NS::geometry;
			
			for each (var xmlGeometry : XML in xmlGeometries)
			{
				var geometry : Geometry = Geometry.createFromXML(xmlGeometry, document);
				store[geometry.id] = geometry;
			}
		}
		
		public static function createFromXML(xmlGeometry : XML, document : Document) : Geometry
		{
			var newGeometry : Geometry = new Geometry();
			
			newGeometry._document				= document;
			newGeometry._id						= xmlGeometry.@id;
			newGeometry._name					= xmlGeometry.@name;
			
			newGeometry._verticesDataSemantics	= new Vector.<String>();
			newGeometry._verticesDataSources	= new Object();
			newGeometry._triangleStores			= new Vector.<Triangles>();
			
			var xmlMesh		: XML = xmlGeometry.NS::mesh[0];
			var xmlVertices	: XML = xmlMesh.NS::vertices[0];
			
			for each (var input : XML in xmlVertices.NS::input)
			{
				var semantic	: String	= String(input.@semantic);
				var sourceId	: String	= String(input.@source).substr(1);
				var xmlSource	: XML		= xmlMesh..NS::source.(@id == sourceId)[0];
				
				var source		: Source	= Source.createFromXML(xmlSource);
				source.semantic = semantic;
				
				newGeometry._verticesDataSemantics.push(semantic);
				newGeometry._verticesDataSources[semantic] = source;
			}
			
			for each (var child : XML in xmlMesh.children())
				switch (child.localName())
				{
					case 'lines':		case 'linestrips':		case 'polygons':
					case 'polylist':	case 'triangles':		case 'trifans':
					case 'tristrips':
						newGeometry._triangleStores.push(new Triangles(child, xmlMesh));
						break;
				}
				
			return newGeometry;
		}
		
		public function createInstance() : IInstance
		{
			return new InstanceGeometry(_document, _id); 
		}
		
		public function toMesh() : IMesh
		{
			if (_triangleStores.length == 0)
				return null;
			
			// create semantic list for vertices and triangles
			var vertexSemantics			: Vector.<String>	= _verticesDataSemantics;
			var triangleSemantics		: Vector.<String>	= createTriangleStoreSemanticList();
			
			// create vertexformat with semantics
			var vertexFormat			: VertexFormat		= createVertexFormat(vertexSemantics, triangleSemantics);
			
			// fill buffers with semantics
			var indexData				: Vector.<uint>		= new Vector.<uint>();
			var vertexData				: Vector.<Number>	= new Vector.<Number>();
			fillBuffers(vertexSemantics, triangleSemantics, indexData, vertexData);
			
			// merge it all
			return createMesh(indexData, vertexData, vertexFormat);
		}
		
		minko_collada function toSubMesh(triangleStore : Triangles) : IMesh
		{
			// create mesh using the same process that this.toMesh()
			var vertexSemantics		: Vector.<String>	= _verticesDataSemantics;
			var triangleSemantics	: Vector.<String>	= triangleStore.semantics;
			var vertexFormat		: VertexFormat		= createVertexFormat(vertexSemantics, triangleSemantics);
			var indexData			: Vector.<uint>		= new Vector.<uint>();
			var vertexData			: Vector.<Number>	= new Vector.<Number>();
			fillBuffers(vertexSemantics, triangleSemantics, indexData, vertexData);
			var mesh				: IMesh				= createMesh(indexData, vertexData, vertexFormat);
			
			return mesh;
		}
		
		minko_collada function fillBuffers(vertexSemantics		: Vector.<String>, 
										   triangleSemantics	: Vector.<String>,
										   indexData			: Vector.<uint>, 
										   vertexData			: Vector.<Number>) : void
		{
			var verticesHashMap			: Object			= new Object();
			var currentVertex			: Vector.<Number>	= new Vector.<Number>;
			
			for each (var triangleStore : Triangles in _triangleStores)
			{
				var storeVertexCount : uint = triangleStore.vertexCount;
				
				for (var storeVertexId : uint = 0; storeVertexId < storeVertexCount; ++storeVertexId)
				{
					currentVertex = buildVertex(storeVertexId, vertexSemantics, triangleSemantics, triangleStore, currentVertex);
					pushVertexIfNotExistent(verticesHashMap, currentVertex, indexData, vertexData);
				}
			}
		}
		
		minko_collada function buildVertex(storeVertexId		: uint,
										   vertexSemantics		: Vector.<String>,
										   triangleSemantics	: Vector.<String>,
										   triangleStore		: Triangles,
										   resultVertex			: Vector.<Number> = null) : Vector.<Number>
		{
			resultVertex.length = 0;
			
			var vertexSemanticsLength	: uint = vertexSemantics.length;
			var triangleSemanticsLength	: uint = triangleSemantics.length;
			
			var vertexId				: uint = triangleStore.getVertexId(storeVertexId);
			
			var semanticId				: uint;
			var semanticName			: String;
			
			// push components from vertices definition
			for (semanticId = 0; semanticId < vertexSemanticsLength; ++semanticId)
			{
				semanticName = vertexSemantics[semanticId];
				
				var source : Source = _verticesDataSources[semanticName];
				source.pushVertexComponent(vertexId, resultVertex);
			}
			
			// push components from triangle definition
			triangleStore.pushVertexComponents(storeVertexId, triangleSemantics, resultVertex);
			
			return resultVertex;
		}
		
		minko_collada function pushVertexIfNotExistent(verticesHashMap	: Object,
													   currentVertex	: Vector.<Number>,
													   indexData		: Vector.<uint>,
													   vertexData		: Vector.<Number>) : void
		{
			// check if we declarated the exact same vertex before, and use it if that is the case
			var vertexHash		: String	= currentVertex.join('|');
			var finalVertexId	: uint;
			if (verticesHashMap.hasOwnProperty(vertexHash))
			{
				finalVertexId = verticesHashMap[vertexHash];
			}
			else
			{
				// create a new vertex
				finalVertexId = verticesHashMap[vertexHash] = vertexData.length / currentVertex.length;
				for each (var i : Number in currentVertex)
				vertexData.push(i);
			}
			
			indexData.push(finalVertexId);
		}
		
		minko_collada function createTriangleStoreSemanticList() : Vector.<String>
		{
			// intersect semantics binded to the primitives contained in this geometry.
			var semantics	: Vector.<String>	= _triangleStores[0].semantics;
			for each (var triangleStore : Triangles in _triangleStores)
				semantics = intersectSemantics(semantics, triangleStore.semantics);
			
			/*	FIXME maybe we should check here that we have no duplicates?
			what should we do if it is the case? raise an exception? */
			
			return semantics;
		}
		
		/**
		 * Crappy intersection of 2 vectors.
		 */
		minko_collada function intersectSemantics(semantics1 : Vector.<String>,
												  semantics2 : Vector.<String>) : Vector.<String>
		{
			var result : Vector.<String> = new Vector.<String>();
			
			for each (var semanticToMatch : String in semantics1)
				for each (var semanticToTest : String in semantics2)
					if (semanticToMatch == semanticToTest)
						result.push(semanticToMatch);
			
			return result;
		}
		
		minko_collada function createVertexFormat(vertexSemantics	: Vector.<String>,
												  triangleSemantics	: Vector.<String>) : VertexFormat
		{
			// create vertexFormat from the semantics vector we just created.
			var vertexFormat		: VertexFormat = new VertexFormat();
			var semantic			: String;
			var vertexComponent		: VertexComponent;
			
			var semanticId			: uint;
			var semanticLength		: uint;
			for (semanticId = 0, semanticLength = vertexSemantics.length; 
				 semanticId < semanticLength; 
				 ++semanticId)
			{
				semantic = vertexSemantics[semanticId];
				vertexComponent = createComponentFromSemantic(semantic);
				
				if (vertexComponent)
				{
					vertexFormat.addComponent(vertexComponent);
				}
				else
				{
						trace('Dropping unknown vertex semantic:', semantic);
					vertexSemantics.splice(semanticId, 1);
					--semanticId;
					--semanticLength;
				}
			}
			
			for (semanticId = 0, semanticLength = triangleSemantics.length; 
				 semanticId < semanticLength; 
				 ++semanticId)
			{
				semantic = triangleSemantics[semanticId];
				
				vertexComponent = createComponentFromSemantic(semantic);
				if (vertexComponent)
					vertexFormat.addComponent(vertexComponent);
				else
				{
						trace('Dropping unknown triangle semantic:', semantic);
					triangleSemantics.splice(semanticId, 1);
					--semanticId;
					--semanticLength;
				}
			}
			
			return vertexFormat;
		}
		
		minko_collada function createComponentFromSemantic(semantic : String) : VertexComponent
		{
			if (semantic == InputType.POSITION)
				return VertexComponent.XYZ;
			
			if (semantic == InputType.COLOR)
				return VertexComponent.RGB;
			
			if (semantic == InputType.TEXCOORD)
				return VertexComponent.UV;
			
			if (semantic == InputType.NORMAL)
				return VertexComponent.NORMAL;
			
			return null;
		}
		
		minko_collada function createMesh(indexData		: Vector.<uint>, 
										  vertexData	: Vector.<Number>, 
										  vertexFormat	: VertexFormat) : Mesh
		{
			var vertexStream		: VertexStream		= new VertexStream(vertexData, vertexFormat, true);
			var vertexStreamList	: VertexStreamList	= new VertexStreamList(vertexStream);
			var indexStream			: IndexStream		= new IndexStream(indexData);
			var mesh				: Mesh				= new Mesh(vertexStreamList, indexStream);
			
			return mesh
		}
	}
}