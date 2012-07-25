package aerys.minko.type.parser.collada.helper
{
	import aerys.minko.render.Effect;
	import aerys.minko.scene.node.mesh.Mesh;
	import aerys.minko.scene.node.mesh.geometry.Geometry;
	import aerys.minko.scene.node.mesh.geometry.GeometrySanitizer;
	import aerys.minko.type.stream.IVertexStream;
	import aerys.minko.type.stream.IndexStream;
	import aerys.minko.type.stream.VertexStream;
	import aerys.minko.type.stream.format.VertexFormat;

	public class MeshTemplate
	{
		private var _meshName		: String;
		private var _vertexData		: Vector.<Number>;
		private var _indexData		: Vector.<uint>;
		private var _materialName	: String;
		private var _vertexFormat	: VertexFormat;
		
		public function get meshName() : String
		{
			return _meshName;
		}
		
		public function get materialName() : String
		{
			return _materialName;
		}
		
		public function get vertexFormat() : VertexFormat
		{
			return _vertexFormat;
		}
		
		public function get indexData() : Vector.<uint>
		{
			return _indexData;
		}
		
		public function get vertexData() : Vector.<Number>
		{
			return _vertexData;
		}
		
		public function MeshTemplate(meshName		: String,
									 vertexData		: Vector.<Number>,
									 indexData		: Vector.<uint>,
									 materialName	: String,
									 vertexFormat	: VertexFormat)
		{
			_meshName		= meshName;
			_vertexData		= vertexData;
			_indexData		= indexData;
			_materialName	= materialName;
			_vertexFormat	= vertexFormat;
		}
		
		public function clone() : MeshTemplate
		{
			return new MeshTemplate(_meshName, _vertexData, _indexData, _materialName, _vertexFormat);
		}
		
		public function generateMeshes(effect				: Effect, 
									   vertexStreamUsage	: uint,
									   indexStreamUsage		: uint) : Vector.<Mesh>
		{
			var indexDatas	: Vector.<Vector.<uint>>	= new Vector.<Vector.<uint>>();
			var vertexDatas	: Vector.<Vector.<Number>>	= new Vector.<Vector.<Number>>();
			
			GeometrySanitizer.splitBuffers(_vertexData, _indexData, vertexDatas, indexDatas, _vertexFormat.size);
			
			var numBuffers : uint = indexDatas.length;
			
			var meshes : Vector.<Mesh> = new Vector.<Mesh>(numBuffers);
			
			for (var bufferId : uint = 0; bufferId < numBuffers; ++bufferId)
			{
				var vertexStream : VertexStream = new VertexStream(
					vertexStreamUsage, 
					_vertexFormat, 
					vertexDatas[bufferId]
				);
				
				var indexStream	: IndexStream = new IndexStream(
					indexStreamUsage,
					indexDatas[bufferId]
				);
				
				var subMesh : Mesh = new Mesh(
					new Geometry(new <IVertexStream>[vertexStream], indexStream),
					null,
					effect
				);
				
				subMesh.name = _meshName + bufferId;
				
				meshes[bufferId] = subMesh;
			}
			
			return meshes;
		}
	}
}
