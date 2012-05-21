package aerys.minko.type.parser.collada.resource.controller
{
	import aerys.minko.ns.minko_collada;
	import aerys.minko.type.loader.parser.ParserOptions;
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.helper.MeshTemplate;
	import aerys.minko.type.parser.collada.helper.NumberListParser;
	import aerys.minko.type.parser.collada.helper.Source;
	import aerys.minko.type.parser.collada.resource.Geometry;
	import aerys.minko.type.stream.format.VertexComponent;
	import aerys.minko.type.stream.format.VertexFormat;

	public class Skin
	{
		use namespace minko_collada;
		
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _document			: ColladaDocument;
		private var _sourceId			: String;
		private var _bindShapeMatrix	: Matrix4x4;
		private var _jointNames			: Vector.<String>;
		private var _invBindMatrices	: Vector.<Matrix4x4>;
		
		private var _boneWeights		: Vector.<Number>
		private var _numBonesPerVertex	: uint;
		
		private var _meshTemplates		: Vector.<MeshTemplate>;
		
		public function get sourceId()			: String				{ return _sourceId; }
		public function get bindShapeMatrix()	: Matrix4x4				{ return _bindShapeMatrix; }
		public function get jointNames()		: Vector.<String>		{ return _jointNames; }
		public function get invBindMatrices()	: Vector.<Matrix4x4>	{ return _invBindMatrices; }
		public function get boneWeights()		: Vector.<Number>		{ return _boneWeights; }
		public function get numBonesPerVertex()	: uint					{ return _numBonesPerVertex; }
		
		public function get meshTemplates() : Vector.<MeshTemplate>
		{
			return _meshTemplates;
		}
		
		public static function createFromXML(xmlNode	: XML,
											 document	: ColladaDocument) : Skin
		{
			var sourceId : String	= String(xmlNode.@source).substr(1);
			
			// retrieve bind shape matrix
			var xmlBindShapeMatrix	: XML		= xmlNode.NS::bind_shape_matrix[0];
			var bindShapeMatrix		: Matrix4x4 = xmlBindShapeMatrix != null ? 
				NumberListParser.parseMatrix3D(xmlBindShapeMatrix) : new Matrix4x4();;
			
			// retrieve joints
			var jointSourceId		: String				= xmlNode..NS::joints.NS::input.(@semantic == 'JOINT').@source.substring(1);
			var jointSource			: XML					= xmlNode..NS::source.(@id == jointSourceId)[0];
			var jointNames			: Vector.<String>		= Vector.<String>(Source.createFromXML(jointSource).data);
			
			// retrieve inverse bind matrices
			var invBindSourceId		: String				= xmlNode..NS::joints.NS::input.(@semantic == 'INV_BIND_MATRIX').@source.substring(1);
			var invBindSource		: XML					= xmlNode..NS::source.(@id == invBindSourceId)[0];			
			var invBindMatrices		: Vector.<Matrix4x4>	= Vector.<Matrix4x4>(Source.createFromXML(invBindSource).data);
			
			// retrieve weights
			var boneWeights			: Vector.<Number>		= new Vector.<Number>();
			var numBonesPerVertex	: uint					= 0;
			numBonesPerVertex = parseBoneData(xmlNode, jointNames.length, boneWeights);
			
			var optimizedNumBonesPerVertex : uint			= computeMinBonesPerVertex(boneWeights, numBonesPerVertex);
			if (optimizedNumBonesPerVertex != numBonesPerVertex)
			{
				var optimizedBoneWeights : Vector.<Number> = new Vector.<Number>();
				optimizeBonesWeights(boneWeights, numBonesPerVertex, optimizedNumBonesPerVertex, optimizedBoneWeights);
				
				boneWeights			= optimizedBoneWeights;
				numBonesPerVertex	= optimizedNumBonesPerVertex;
			}
			
			return new Skin(sourceId, bindShapeMatrix, jointNames, invBindMatrices, boneWeights, numBonesPerVertex, document);
		}
		
		public function Skin(sourceId			: String,
							 bindShapeMatrix	: Matrix4x4,
							 jointNames			: Vector.<String>,
							 invBindMatrices	: Vector.<Matrix4x4>,
							 boneWeight			: Vector.<Number>,
							 boneCountPerVertex	: uint,
							 document			: ColladaDocument)
		{
			_sourceId			= sourceId;
			_bindShapeMatrix	= bindShapeMatrix;
			_jointNames			= jointNames;
			_invBindMatrices	= invBindMatrices;
			_boneWeights		= boneWeight;
			_numBonesPerVertex	= boneCountPerVertex;
			_document			= document;
		}
		
		private static function parseBoneData(xmlSkin	: XML,
											  boneCount	: uint,
											  bonesData	: Vector.<Number>) : uint
		{
			var weightsSourceId	: String			= xmlSkin..NS::vertex_weights.NS::input.(@semantic == 'WEIGHT').@source.substring(1);
			var weightsSource	: XML				= xmlSkin..NS::source.(@id == weightsSourceId)[0];
			var weights			: Vector.<Number>	= Vector.<Number>(Source.createFromXML(weightsSource).data);
			var vcount 			: Vector.<int> 		= NumberListParser.parseIntList(xmlSkin.NS::vertex_weights.NS::vcount[0]);
			var v 				: Vector.<int> 		= NumberListParser.parseIntList(xmlSkin.NS::vertex_weights.NS::v[0]);
			var offsetJoint		: int 				= xmlSkin.NS::vertex_weights.NS::input.(@semantic == 'JOINT').@offset;
			var offsetWeight 	: int 				= xmlSkin.NS::vertex_weights.NS::input.(@semantic == 'WEIGHT').@offset;
			var numInputs 		: int 				= xmlSkin..NS::vertex_weights.NS::input.length();
			var vCountLength	: uint				= vcount.length;
			var maxVcount		: uint				= 0;
			var i				: int				= 0;
			var k 				: int 				= 0;
			
			for (i = 0; i < vCountLength; i++)
				if (maxVcount < vcount[i])
					maxVcount = vcount[i];
			
			for (i = 0; i < vCountLength; i++)
			{
				var vc : int = vcount[i];
				
				for (var j : int = 0; j < vc; j++)
				{
					// in collada, the bone numbered -1 references to the bind shape matrix
					// we push boneId | boneWeight
					
					if (v[int(k + offsetJoint)] != -1)
						bonesData.push(v[int(k + offsetJoint)], weights[v[int(k + offsetWeight)]]);
					else
						bonesData.push(boneCount, 0);
						// bonesData.push(boneCount, weights[v[int(k + offsetWeight)]]);
					
					k += numInputs;
				}
				
				for (; j < maxVcount; j++)
					bonesData.push(0, 0); // boneId, weight
			}
			
			return maxVcount;
		}
		
		/**
		 * Given a bone weights vector, and the numBonesPerVertex value, determine 
		 * if it is possible to optimize it (have a lower numBonesPerVertexValue).
		 * 
		 * Some collada exporters are (very) lazy, and put weights for all bones on 
		 * all vertices, so that numBonesPerVertex == numBones.
		 * 
		 * This is not OK with minko, which is limited by agal to have 
		 * at most 8 vertex attribute on shaders (hence the need for this method).
		 */
		private static function computeMinBonesPerVertex(inBoneWeights 			: Vector.<Number>,
														 inBoneCountPerVertex	: uint) : uint
		{
			var vertexCount				: uint = inBoneWeights.length / inBoneCountPerVertex / 2;
			var newBoneCountPerVertex	: uint = 0;
			var vertexIndex 			: uint;		
			var boneIndex				: uint;		// iterators
			var	boneInfluenceIndex		: uint;		// indexes in boneWeights vector
			var	boneInfluence			: Number;	// values
			var localBoneCount			: uint;
			
			// start counting how must bones we need in each vertex.
			for (vertexIndex = 0; vertexIndex < vertexCount; ++vertexIndex)
			{
				localBoneCount = 0;
				for (boneIndex = 0; boneIndex < inBoneCountPerVertex; ++boneIndex)
				{
					boneInfluenceIndex	= 2 * (vertexIndex * inBoneCountPerVertex + boneIndex) + 1;
					boneInfluence		= inBoneWeights[boneInfluenceIndex];
					
					if (boneInfluence > 0)
						++localBoneCount;
				}
				
				if (localBoneCount > newBoneCountPerVertex)
					newBoneCountPerVertex = localBoneCount;
			}
			
			return newBoneCountPerVertex;
		}
		
		/**
		 * When the computeMinBonesPerVertex method indicates that it is possible to
		 * optimize the bone weights vector, this method does the work. 
		 */		
		private static function optimizeBonesWeights(inBoneWeights 			: Vector.<Number>,
												     inBoneCountPerVertex	: uint,
												     newBoneCountPerVertex	: uint,
												     outBoneWeights			: Vector.<Number>) : void
		{
			var vertexCount		: uint = inBoneWeights.length / inBoneCountPerVertex / 2;
			
			var vertexIndex 	: uint,		boneIndex			: uint;		// iterators
			var boneIdIndex 	: uint,		boneInfluenceIndex	: uint;		// indexes in boneWeights vector
			var boneId			: Number,	boneInfluence		: Number;	// values
			var localBoneCount	: uint;
			
			// rewrite a new boneWeights vector
			for (vertexIndex = 0; vertexIndex < vertexCount; ++vertexIndex)
			{
				localBoneCount = 0;
				for (boneIndex = 0; boneIndex < inBoneCountPerVertex; ++boneIndex)
				{
					boneIdIndex			= 2 * (vertexIndex * inBoneCountPerVertex + boneIndex)
					boneInfluenceIndex	= boneIdIndex + 1;
					
					boneId				= inBoneWeights[boneIdIndex];
					boneInfluence		= inBoneWeights[boneInfluenceIndex];
					
					if (boneInfluence > 0)
					{
						outBoneWeights.push(boneId, boneInfluence);
						++localBoneCount;
					}
				}
				
				for (; localBoneCount < newBoneCountPerVertex; ++localBoneCount)
					outBoneWeights.push(0, 0);
			}
		}
		
		/**
		 * Does the same thing that Geometry.computeMeshTemplates, but add bone weights
		 */		
		public function computeMeshTemplates(options : ParserOptions) : void
		{
			if (_meshTemplates != null)
				return;
			
			var geometry			: Geometry				= _document.getGeometryById(_sourceId);
			geometry.computeMeshTemplates(options);
			
			var meshTemplates		: Vector.<MeshTemplate> = geometry.meshTemplates;
			var numMeshTemplates	: uint					= meshTemplates.length;
			
			_meshTemplates = new Vector.<MeshTemplate>(numMeshTemplates, true);
			for (var meshId : uint = 0; meshId < numMeshTemplates; ++meshId)
			{
				var meshTemplate : MeshTemplate = meshTemplates[meshId];
				
				var oldVertexData	: Vector.<Number>	= meshTemplate.vertexData;
				var oldFormat		: VertexFormat		= meshTemplate.vertexFormat;
				
				// create vertex format
				var vertexFormat : VertexFormat = oldFormat.clone();

				// check if loadSkin option is available
				if (options.loadSkin)
				{
					for (var k : uint = 0; k < _numBonesPerVertex; ++k)
						vertexFormat.addComponent(VertexComponent.BONES[k]);

					_meshTemplates[meshId] = new MeshTemplate(
						_sourceId + 'skin',
						addBoneData(oldVertexData, oldFormat),
						meshTemplate.indexData,
						meshTemplate.materialName,
						vertexFormat
					);
				}
				// otherwise, we use the old vertex data instead of the bone vertex data
				else {
					_meshTemplates[meshId] = new MeshTemplate(
						_sourceId + 'skin',
						oldVertexData,
						meshTemplate.indexData,
						meshTemplate.materialName,
						vertexFormat
					);
				}
			}
		}
		
		private function addBoneData(oldBuffer	: Vector.<Number>,
									 oldFormat	: VertexFormat) : Vector.<Number>
		{
			var oldDwordPerVertex	: uint = oldFormat.dwordsPerVertex;
			var boneDwordPerVertex	: uint = 2 * _numBonesPerVertex;
			
			var newDwordPerVertex	: uint = oldDwordPerVertex + boneDwordPerVertex;
			
			var numVertices			: uint = oldBuffer.length / oldDwordPerVertex;
			var newBuffer			: Vector.<Number>	= new Vector.<Number>(numVertices * newDwordPerVertex, true);
			
			var oldReadOffset		: uint = 0;
			var oldVertexIdOffset	: uint = oldFormat.getOffsetForComponent(VertexComponent.ID);
			var newWriteOffset		: uint = 0;
			
			var oldReadLimit		: uint = oldDwordPerVertex;
			
			for (var i : uint = 0; i < numVertices; ++i)
			{
				// copy old vertex to new one
				for (; oldReadOffset < oldReadLimit; ++oldReadOffset)
					newBuffer[newWriteOffset++] = oldBuffer[oldReadOffset];
				
				// read from old buffer where to read the new bone
				var boneReadOffset	: uint = boneDwordPerVertex * oldBuffer[oldVertexIdOffset];
				var boneReadLimit	: uint = boneReadOffset + boneDwordPerVertex;
				
				for (; boneReadOffset < boneReadLimit; ++boneReadOffset)
					newBuffer[newWriteOffset++] = _boneWeights[boneReadOffset];
				
				// increment iterators
				oldVertexIdOffset	+= oldDwordPerVertex;
				oldReadLimit		+= oldDwordPerVertex;
				boneReadLimit		+= boneDwordPerVertex;
			}
			
			return newBuffer;
		}
	}
}