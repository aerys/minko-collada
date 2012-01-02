package aerys.minko.type.parser.collada.resource.geometry
{
	import aerys.minko.Minko;
	import aerys.minko.ns.minko_collada;
	import aerys.minko.scene.node.group.IGroup;
	import aerys.minko.scene.node.mesh.IMesh;
	import aerys.minko.scene.node.mesh.Mesh;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.enum.InputType;
	import aerys.minko.type.parser.collada.helper.Source;
	import aerys.minko.type.parser.collada.instance.IInstance;
	import aerys.minko.type.parser.collada.instance.InstanceGeometry;
	import aerys.minko.type.parser.collada.resource.IResource;
	import aerys.minko.type.stream.IndexStream;
	import aerys.minko.type.stream.VertexStream;
	import aerys.minko.type.stream.format.VertexComponent;
	import aerys.minko.type.stream.format.VertexFormat;
	
	public class Geometry implements IResource
	{
		use namespace minko_collada;
		
		private static const NS 			: Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		private static const INDEX_LIMIT	: uint 		= 524287;
		private static const VERTEX_LIMIT	: uint 		= 65536;
		
		private var _document				: ColladaDocument;
		
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
												document	: ColladaDocument, 
												store		: Object) : void
		{
			var xmlGeometryLibrary	: XML		= xmlDocument..NS::library_geometries[0];
			
			if (xmlGeometryLibrary == null)
				return;
			
			var xmlGeometries		: XMLList	= xmlGeometryLibrary.NS::geometry;
			
			for each (var xmlGeometry : XML in xmlGeometries)
			{
				var geometry : Geometry = Geometry.createFromXML(xmlGeometry, document);
				
				if (geometry)
					store[geometry.id] = geometry;
			}
		}
		
		public static function createFromXML(xmlGeometry : XML, document : ColladaDocument) : Geometry
		{
			var newGeometry : Geometry = new Geometry();
			
			newGeometry._document				= document;
			newGeometry._id						= xmlGeometry.@id;
			newGeometry._name					= xmlGeometry.@name;
			
			newGeometry._verticesDataSemantics	= new Vector.<String>();
			newGeometry._verticesDataSources	= new Object();
			newGeometry._triangleStores			= new Vector.<Triangles>();
			
			var xmlMesh		: XML = xmlGeometry.NS::mesh[0];
			
			if (!xmlMesh)
			{
				Minko.log(0, "Unsupported geometry: '" + newGeometry._name + "'.");
				
				return null;
			}
			
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
					case 'lines':
					case 'linestrips':
					case 'polygons':
					case 'polylist':
					case 'triangles':
					case 'trifans':
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
			
			fillBuffers(vertexSemantics, triangleSemantics, _triangleStores, indexData, vertexData);
			
			// merge it all
			return createMesh(indexData, vertexData, vertexFormat);
		}
		
		minko_collada function toSubMeshes(triangleStore : Triangles, group : IGroup) : void
		{
			var triangleStores		: Vector.<Triangles> = Vector.<Triangles>([triangleStore]);
			
			// create mesh using the same process that this.toMesh()
			var vertexSemantics		: Vector.<String>		= _verticesDataSemantics;
			var triangleSemantics	: Vector.<String>		= triangleStore.semantics;
			var vertexFormat		: VertexFormat			= createVertexFormat(vertexSemantics, triangleSemantics);
			var indexData			: Vector.<uint>			= new Vector.<uint>();
			var vertexData			: Vector.<Number>		= new Vector.<Number>();
			var mesh				: IMesh					= null;
			
			fillBuffers(vertexSemantics, triangleSemantics, triangleStores, indexData, vertexData);
			
			if (indexData.length <= INDEX_LIMIT && vertexData.length / vertexFormat.dwordsPerVertex <= VERTEX_LIMIT)
			{
				mesh = createMesh(indexData, vertexData, vertexFormat);
				
				if (mesh)
					group.addChild(mesh);
			}
			else
			{
				while (indexData.length != 0)
				{
					var dwordsPerVertex		: uint				= vertexFormat.dwordsPerVertex;
					var indexDataLength		: uint				= indexData.length;
					
					// new buffers
					var partialVertexData	: Vector.<Number>	= new Vector.<Number>();
					var partialIndexData	: Vector.<uint>		= new Vector.<uint>();
					
					// local variables
					var oldVertexIds		: Vector.<int>		= new Vector.<int>(3, true);
					var newVertexIds		: Vector.<int>		= new Vector.<int>(3, true);
					var newVertexNeeded		: Vector.<Boolean>	= new Vector.<Boolean>(3, true);
					
					var usedVertices		: Vector.<uint>		= new Vector.<uint>();	// tableau de correspondance entre anciens et nouveaux indices
					var usedVerticesCount	: uint				= 0;					// taille du tableau ci dessus
					var usedIndicesCount	: uint				= 0;					// quantitee d'indices utilises pour l'instant
					var neededVerticesCount	: uint;
					
					// iterators & limits
					var localVertexId		: uint;
					var dwordId				: uint;
					var dwordIdLimit		: uint;
					
					while (usedIndicesCount < indexDataLength)
					{
						// check si le triangle suivant rentrera dans l'index buffer
						var remainingIndexes	: uint		= INDEX_LIMIT - usedIndicesCount;
						if (remainingIndexes < 3)
							break;
						
						// check si le triangle suivant rentre dans le vertex buffer
						var remainingVertices	: uint		= VERTEX_LIMIT - usedVerticesCount;
						
						neededVerticesCount = 0;
						for (localVertexId = 0; localVertexId < 3; ++localVertexId)
						{
							oldVertexIds[localVertexId]		= indexData[uint(usedIndicesCount + localVertexId)];
							newVertexIds[localVertexId]		= usedVertices.indexOf(oldVertexIds[localVertexId]);
							newVertexNeeded[localVertexId]	= newVertexIds[localVertexId] == -1;
							
							if (newVertexNeeded[localVertexId])
								++neededVerticesCount;
						}
						
						if (remainingVertices < neededVerticesCount)
							break;
						
						// ca rentre, on insere le triangle avec les donnees qui vont avec
						for (localVertexId = 0; localVertexId < 3; ++localVertexId)
						{
							
							if (newVertexNeeded[localVertexId])
							{
								// on copie le vertex dans le nouveau tableau
								dwordId			= oldVertexIds[localVertexId] * dwordsPerVertex;
								dwordIdLimit	= dwordId + dwordsPerVertex;
								for (; dwordId < dwordIdLimit; ++dwordId)
									partialVertexData.push(vertexData[dwordId]);
								
								// on met a jour l'id dans notre variable temporaire pour remplir le nouvel indexData
								newVertexIds[localVertexId] = usedVerticesCount;
								
								// on note son ancien id dans le tableau temporaire
								usedVertices[usedVerticesCount++] = oldVertexIds[localVertexId];
							}
							
							partialIndexData.push(newVertexIds[localVertexId]);
						}
						
						// ... on incremente le compteur
						usedIndicesCount += 3;
						
						// on fait des assertions, sinon ca marchera jamais
						if (usedIndicesCount != partialIndexData.length)
							throw new Error('');
						
						if (usedVerticesCount != usedVertices.length)
							throw new Error('');
						
						if (usedVerticesCount != partialVertexData.length / dwordsPerVertex)
							throw new Error('');
					}
					
					mesh = createMesh(partialIndexData, partialVertexData, vertexFormat);
					
					if (mesh)
						group.addChild(mesh);
					
					indexData.splice(0, usedIndicesCount);
				}
			}
		}
		
		minko_collada function fillBuffers(vertexSemantics		: Vector.<String>, 
										   triangleSemantics	: Vector.<String>,
										   triangleStores		: Vector.<Triangles>,
										   indexData			: Vector.<uint>, 
										   vertexData			: Vector.<Number>) : void
		{
			var verticesHashMap			: Object			= new Object();
			var currentVertex			: Vector.<Number>	= new Vector.<Number>;
			
			for each (var triangleStore : Triangles in triangleStores)
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
					Minko.log(0, 'Dropping unknown vertex semantic:' + semantic);
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
					if (semantic != 'VERTEX')
						Minko.log(0, 'Dropping unknown triangle semantic:' + semantic);
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
				return VertexComponent.RGBA;
			
			if (semantic == InputType.TEXCOORD)
				return VertexComponent.UV;
			
			if (semantic == InputType.NORMAL)
				return VertexComponent.NORMAL;
			
			if (semantic == InputType.TANGENT)
				return VertexComponent.TANGENT;
			
			return null;
		}
		
		minko_collada function createMesh(indexData		: Vector.<uint>, 
										  vertexData	: Vector.<Number>, 
										  vertexFormat	: VertexFormat) : Mesh
		{
			var mesh : Mesh	= new Mesh(
				new VertexStream(_document.parserOptions.defaultVertexStreamUsage, vertexFormat, vertexData),
				new IndexStream(_document.parserOptions.defaultIndexStreamUsage, indexData, 0)
			);
			
			mesh = _document.parserOptions.replaceNodeFunction(mesh);
			
			return mesh;
		}
	}
}