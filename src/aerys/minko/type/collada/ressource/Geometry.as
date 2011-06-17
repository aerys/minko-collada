package aerys.minko.type.collada.ressource
{
	import aerys.minko.ns.minko_collada;
	import aerys.minko.scene.node.mesh.IMesh;
	import aerys.minko.scene.node.mesh.Mesh;
	import aerys.minko.type.collada.Document;
	import aerys.minko.type.collada.enum.InputType;
	import aerys.minko.type.collada.instance.IInstance;
	import aerys.minko.type.collada.instance.InstanceGeometry;
	import aerys.minko.type.collada.store.Source;
	import aerys.minko.type.collada.store.Triangles;
	import aerys.minko.type.stream.IndexStream;
	import aerys.minko.type.stream.VertexStream;
	import aerys.minko.type.stream.VertexStreamList;
	import aerys.minko.type.vertex.format.VertexComponent;
	import aerys.minko.type.vertex.format.VertexFormat;
	
	use namespace minko_collada;
	
	public class Geometry implements IRessource
	{
		private static const NS : Namespace = 
			new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private static const POLYGON_NODES : Vector.<String> = Vector.<String>([
			'lines', 'linestrips', 'polygons', 'polylist',
			'triangles', 'trifans', 'tristrips', ]);
		
		private var _document				: Document;
		
		private var _id						: String;
		private var _verticesDataSemantics	: Vector.<String>;
		private var _verticesDataSources	: Object
		private var _triangleStores			: Vector.<Triangles>;
		
		public function get id()		: String	{ return _id; }
		public function get instance()	: IInstance	{ return new InstanceGeometry(_document, _id); }
		
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
			var xmlGeometryLibrary	: XML = xmlDocument..library_geometries[0];
			var xmlGeometries		: XML = xmlGeometryLibrary.geometry;
			
			for each (var xmlGeometry : XML in xmlGeometries)
			{
				var geometry : Geometry = new Geometry(xmlGeometry, document);
				store[geometry.id] = geometry;
			}
		}
		
		public function Geometry(xmlGeometry : XML, document : Document) 
		{
			_document = document;
			
			var xmlMesh		: XML = xmlGeometry.mesh[0];
			var xmlVertices	: XML = xmlMesh.vertices[0];
			
			for each (var input : XML in xmlVertices.input)
			{
				var semantic	: String = String(input.@semantic);
				var sourceId	: String = String(input.@source).substr(1);
				var source		: Source = Source.createFromXML(xmlMesh..source.(@id == sourceId)[0]);
				
				_verticesDataSemantics.push(semantic);
				_verticesDataSources[semantic] = source;
			}
			
			for each (var polygonNode : String in POLYGON_NODES)
				for each (var polygons : XML in xmlMesh.(polygonNode))
					_triangleStores.push(new Triangles(polygons, xmlMesh));
		}
		
		public function toMesh() : IMesh
		{
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
			var vertexSemanticsLength	: uint = vertexSemantics.length;
			var triangleSemanticsLength	: uint = triangleSemantics.length;
			
			var vertexId				: uint = triangleStore.getVertexId(storeVertexId);
			
			// push components from vertices definition
			for (var vertexSemanticId : uint = 0; vertexSemanticId < vertexSemanticsLength; ++vertexSemanticId)
			{
				var source : Source = _verticesDataSources[vertexSemantics[vertexSemanticId]];
				source.pushVertexComponent(vertexId, resultVertex);
			}
			
			// push components from triangle definition
			for (var triangleSemanticId : uint = 0; triangleSemanticId < triangleSemanticsLength; ++triangleSemanticId)
			{
				triangleStore.pushVertexComponents(storeVertexId, triangleSemantics, resultVertex);
			}
			
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
		 * Crappy intersection of 2 vectors. Should be improved if too slow, but should not be used very often
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
			
			for each (semantic in vertexSemantics)
			{
				vertexComponent = createComponentFromSemantic(semantic);
				if (vertexComponent)
					vertexFormat.addComponent(vertexComponent);
				else
					trace('Dropping unknown vertex semantic:', semantic);
			}
			
			for each (semantic in triangleSemantics)
			{
				vertexComponent = createComponentFromSemantic(semantic);
				if (vertexComponent)
					vertexFormat.addComponent(vertexComponent);
				else
					trace('Dropping unknown triangle semantic:', semantic);
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