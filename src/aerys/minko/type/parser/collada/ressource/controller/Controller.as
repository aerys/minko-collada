package aerys.minko.type.parser.collada.ressource.controller
{
	import aerys.minko.ns.minko_collada;
	import aerys.minko.scene.node.mesh.IMesh;
	import aerys.minko.scene.node.mesh.Mesh;
	import aerys.minko.type.parser.collada.Document;
	import aerys.minko.type.parser.collada.helper.NumberListParser;
	import aerys.minko.type.parser.collada.instance.IInstance;
	import aerys.minko.type.parser.collada.instance.InstanceController;
	import aerys.minko.type.parser.collada.helper.Source;
	import aerys.minko.type.parser.collada.ressource.geometry.Triangles;
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.vertex.format.VertexComponent;
	import aerys.minko.type.vertex.format.VertexFormat;
	import aerys.minko.type.parser.collada.ressource.geometry.Geometry;
	import aerys.minko.type.parser.collada.ressource.IRessource;
	
	use namespace minko_collada;
	
	public class Controller implements IRessource
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _document			: Document;
		
		// morph related data
		/* not yet implemented */
		
		// skin related data
		private var _id					: String;
		private var _name				: String;
		private var _skinId				: String;
		private var _bindShapeMatrix	: Matrix4x4;
		
		/**
		 * if weightCountPerVertex == 2
		 * weights per vertex == [ 
		 * 		boneid1forvertex1, bonevalue1forvertex1, boneid2forvertex1, bonevalue2forvertex1, 
		 * 		boneid1forvertex2, bonevalue1forvertex2, boneid2forvertex2, bonevalue2forvertex2
		 * ]
		 */
		private var _jointNames			: Vector.<String>;
		private var _invBindMatrices	: Vector.<Matrix4x4>;
		private var _boneWeights		: Vector.<Number>
		private var _boneCountPerVertex	: uint;
		
		public function get id()				: String				{ return _id; }
		public function get name()				: String				{ return _name; }
		public function get jointNames()		: Vector.<String>		{ return _jointNames; }
		public function get bindShapeMatrix()	: Matrix4x4				{ return _bindShapeMatrix; }
		public function get invBindMatrices()	: Vector.<Matrix4x4>	{ return _invBindMatrices; }
		public function get skin()				: Geometry				{ return _document.getGeometryById(_skinId); }
		public function get skinId()			: String				{ return _skinId; }
		
		public static function fillStoreFromXML(xmlDocument	: XML,
												document	: Document, 
												store		: Object) : void
		{
			var xmlControllerLibrary	: XML		= xmlDocument..NS::library_controllers[0];
			if (!xmlControllerLibrary)
				return;
			
			var xmlControllers 			: XMLList	= xmlControllerLibrary.NS::controller;
			
			for each (var xmlController : XML in xmlControllers)
			{
				var controller : Controller = new Controller(xmlController, document);
				store[controller.id] = controller;
			}
		}
		
		public function Controller(xmlController	: XML, 
								   document			: Document)
		{
			_document				= document;
			
			_id						= xmlController.@id;
			_name					= xmlController.@name;
			_skinId					= String(xmlController.NS::skin[0].@source).substr(1);
			
			_bindShapeMatrix		= parseBindShapeMatrix(xmlController);
			
			_boneWeights			= new Vector.<Number>();
			_jointNames				= parseJoints(xmlController);
			
			_invBindMatrices		= parseInvBindMatrix(xmlController);

			_boneCountPerVertex		= parseBoneData(xmlController, _boneWeights);
			optimizeBones();
		}
		
		private function optimizeBones() : void
		{
			var boneWeights				: Vector.<Number>	= _boneWeights;
			var boneCountPerVertex		: uint				= _boneCountPerVertex;
			var vertexCount				: uint				= _boneWeights.length / boneCountPerVertex / 2;
			
			var newBoneWeights			: Vector.<Number>	= new Vector.<Number>();
			var newBoneCountPerVertex	: uint				= 0;
			
			var vertexIndex 	: uint,		boneIndex			: uint;		// iterators
			var boneIdIndex 	: uint,		boneInfluenceIndex	: uint;		// indexes in boneWeights vector
			var boneId			: Number,	boneInfluence		: Number;	// values
			var localBoneCount	: uint;
			
			// start counting how must bones we need in each vertex.
			for (vertexIndex = 0; vertexIndex < vertexCount; ++vertexIndex)
			{
				localBoneCount = 0;
				for (boneIndex = 0; boneIndex < boneCountPerVertex; ++boneIndex)
				{
					boneInfluenceIndex	= 2 * (vertexIndex * boneCountPerVertex + boneIndex) + 1;
					boneInfluence		= boneWeights[boneInfluenceIndex];
					
					if (boneInfluence > 0)
						++localBoneCount;
				}
				
				if (localBoneCount > newBoneCountPerVertex)
					newBoneCountPerVertex = localBoneCount;
			}
			
			if (boneCountPerVertex != newBoneCountPerVertex)
			{
				// rewrite a new boneWeights vector
				for (vertexIndex = 0; vertexIndex < vertexCount; ++vertexIndex)
				{
					localBoneCount = 0;
					for (boneIndex = 0; boneIndex < boneCountPerVertex; ++boneIndex)
					{
						boneIdIndex			= 2 * (vertexIndex * boneCountPerVertex + boneIndex)
						boneInfluenceIndex	= boneIdIndex + 1;
						
						boneId				= boneWeights[boneIdIndex];
						boneInfluence		= boneWeights[boneInfluenceIndex];
						
						if (boneInfluence > 0)
						{
							newBoneWeights.push(boneId, boneInfluence);
							++localBoneCount;
						}
					}
					
					for (; localBoneCount < newBoneCountPerVertex; ++localBoneCount)
						newBoneWeights.push(0, 0);
				}
				
				_boneWeights		= newBoneWeights;
				_boneCountPerVertex	= newBoneCountPerVertex;
			}
		}
		
		private function parseBindShapeMatrix(xmlController : XML) : Matrix4x4
		{
			var xmlSkin				: XML = xmlController.NS::skin[0];
			var xmlBindShapeMatrix	: XML = xmlSkin.NS::bind_shape_matrix[0];
			
			return xmlBindShapeMatrix != null ? NumberListParser.parseMatrix4x4(xmlBindShapeMatrix) : new Matrix4x4();
		}
		
		private function parseBoneData(xmlController	: XML, 
									   bonesData		: Vector.<Number>) : uint
		{
			var skin 			: XML 					= xmlController.NS::skin[0];
			var boneCount		: uint					= _jointNames.length;
			
			var weights			: Vector.<Number> 		= parseWeights(xmlController);
			
			var vcount 			: Vector.<int> 			= NumberListParser.parseIntList(skin.NS::vertex_weights.NS::vcount[0]);
			var v 				: Vector.<int> 			= NumberListParser.parseIntList(skin.NS::vertex_weights.NS::v[0]);
			
			var offsetJoint		: int 					= skin.NS::vertex_weights.NS::input.(@semantic == 'JOINT').@offset;
			var offsetWeight 	: int 					= skin.NS::vertex_weights.NS::input.(@semantic == 'WEIGHT').@offset;
			
			var numInputs 		: int 					= xmlController..NS::vertex_weights.NS::input.length();
			
			var k 				: int 					= 0;
			
			var maxVcount		: uint					= 0;
			
			for (var i : int = 0; i < vcount.length; i++)
			{
				var vc : int = vcount[i];
				
				if (maxVcount < vc)
					maxVcount = vc;
			}
			
			var vCountLength : uint = vcount.length;
			for (i = 0; i < vCountLength; i++)
			{
				vc = vcount[i];
				
				for (var j : int = 0; j < vc; j++)
				{
					// in collada, the bone numbered -1 does reference the bind shape matrix
					
					if (v[int(k + offsetJoint)] != -1)
					{
						bonesData.push(
							v[int(k + offsetJoint)],			// bone id
							weights[v[int(k + offsetWeight)]]	// weight
						);
					}
					else
					{
						bonesData.push(
							boneCount,							// bone id
							0//weights[v[int(k + offsetWeight)]]	// weight
						);
					}
					
					k += numInputs;
				}
				
				for (; j < maxVcount; j++)
				{
					bonesData.push(0, 0);	// boneId, weight
				}
			}
			
			return maxVcount;
		}
		
		private static function parseInvBindMatrix(controller : XML) : Vector.<Matrix4x4>
		{
			var sourceId	: String	= controller..NS::joints.NS::input.(@semantic == 'INV_BIND_MATRIX').@source.substring(1);
			var xmlSource	: XML		= controller..NS::source.(@id == sourceId)[0];			
			
			var source		: Source	= Source.createFromXML(xmlSource);
			
			return Vector.<Matrix4x4>(source.data);
		}
		
		private static function parseJoints(controller : XML) : Vector.<String>
		{
			var sourceId	: String	= controller..NS::joints.NS::input.(@semantic == 'JOINT').@source.substring(1);
			var xmlSource	: XML		= controller..NS::source.(@id == sourceId)[0];
			
			var source		: Source	= Source.createFromXML(xmlSource);
			
			return Vector.<String>(source.data);
		}
		
		private static function parseWeights(controller : XML) : Vector.<Number>
		{
			var sourceId	: String			= controller..NS::vertex_weights.NS::input.(@semantic == 'WEIGHT').@source.substring(1);
			var xmlSource	: XML				= controller..NS::source.(@id == sourceId)[0];
			
			var source		: Source			= Source.createFromXML(xmlSource);
			
			return Vector.<Number>(source.data);
		}
		
		public function createInstance() : IInstance
		{ 
			return new InstanceController(_document, _id); 
		}
		
		public function toMesh() : Mesh
		{
			// get geometry, as most tasks are going to be delegated to it
			var geometry			: Geometry			= _document.getGeometryById(_skinId);
			if (geometry == null)
				return null;
			
			// create semantic list for vertices and triangles
			var vertexSemantics		: Vector.<String>	= geometry.verticesDataSemantics;
			var triangleSemantics	: Vector.<String>	= geometry.createTriangleStoreSemanticList();
			
			// create vertexformat with semantics
			var vertexFormat		: VertexFormat		= 
				createVertexFormat(geometry, vertexSemantics, triangleSemantics);
			
			// fill buffers with semantics
			var indexData			: Vector.<uint>		= new Vector.<uint>();
			var vertexData			: Vector.<Number>	= new Vector.<Number>();
			fillBuffers(geometry, vertexSemantics, triangleSemantics, indexData, vertexData);
			
			// merge it all
			return geometry.createMesh(indexData, vertexData, vertexFormat);
		}
		
		private function createVertexFormat(geometry			: Geometry,
											vertexSemantics		: Vector.<String>, 
											triangleSemantics	: Vector.<String>) : VertexFormat
		{
			var vertexFormat : VertexFormat = geometry.createVertexFormat(vertexSemantics, triangleSemantics);
			
			for (var k : uint = 0; k < _boneCountPerVertex; ++k)
				vertexFormat.addComponent(VertexComponent.BONES[k]);
			
			return vertexFormat;
		}
		
		private function fillBuffers(geometry			: Geometry,
									 vertexSemantics	: Vector.<String>,
									 triangleSemantics	: Vector.<String>,
									 indexData			: Vector.<uint>,
									 vertexData			: Vector.<Number>) : void
		{
			var verticesHashMap			: Object			= new Object();
			var currentVertex			: Vector.<Number>	= new Vector.<Number>;
			
			for each (var triangleStore : Triangles in geometry.triangleStores)
			{
				var storeVertexCount : uint = triangleStore.vertexCount;
				
				for (var storeVertexId : uint = 0; storeVertexId < storeVertexCount; ++storeVertexId)
				{
					currentVertex = buildVertex(geometry, storeVertexId, vertexSemantics, triangleSemantics, triangleStore, currentVertex);
					geometry.pushVertexIfNotExistent(verticesHashMap, currentVertex, indexData, vertexData);
				}
			}
		}
		
		private function buildVertex(geometry			: Geometry,
									 storeVertexId		: uint,
									 vertexSemantics	: Vector.<String>,
									 triangleSemantics	: Vector.<String>,
									 triangleStore		: Triangles,
									 resultVertex		: Vector.<Number> = null) : Vector.<Number>
		{
			resultVertex.length = 0;
			
			var vertexId : uint = triangleStore.getVertexId(storeVertexId);
			
			// let the geometry build its vertex
			geometry.buildVertex(storeVertexId, vertexSemantics, triangleSemantics, triangleStore, resultVertex);
			
			// add bone components
			for (var i : uint = 2 * _boneCountPerVertex * vertexId; i < 2 * _boneCountPerVertex * (vertexId + 1); ++i)
				resultVertex.push(_boneWeights[i]);
			
			return resultVertex;
		}
	}
}