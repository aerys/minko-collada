package aerys.minko.type.parser.collada.helper
{
	import aerys.minko.render.Effect;
	import aerys.minko.render.geometry.Geometry;
	import aerys.minko.render.geometry.GeometrySanitizer;
	import aerys.minko.render.geometry.stream.IVertexStream;
	import aerys.minko.render.geometry.stream.IndexStream;
	import aerys.minko.render.geometry.stream.VertexStream;
	import aerys.minko.render.geometry.stream.format.VertexFormat;
	import aerys.minko.scene.node.Mesh;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class MeshTemplate
	{
		private var _meshName		: String;
		private var _vertexData		: ByteArray;
		private var _indexData		: Vector.<uint>;
		private var _materialName	: String;
		private var _vertexFormat	: VertexFormat;
		
		private var _geometries		: Vector.<Geometry>;
		
		public function get geometries():Vector.<Geometry>
		{
			return _geometries;
		}

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
		
		public function get vertexData() : ByteArray
		{
			return _vertexData;
		}
		
		public function MeshTemplate(meshName		: String,
									 vertexData		: ByteArray,
									 indexData		: Vector.<uint>,
									 materialName	: String,
									 vertexFormat	: VertexFormat)
		{
			_meshName		= meshName;
			_vertexData		= vertexData;
			_indexData		= indexData;
			_materialName	= materialName;
			_vertexFormat	= vertexFormat;
			
			if (vertexData.bytesAvailable % _vertexFormat.numBytesPerVertex != 0)
				throw new Error();
		}
		
		public function clone() : MeshTemplate
		{
			return new MeshTemplate(_meshName, _vertexData, _indexData, _materialName, _vertexFormat);
		}
		
		private function generateMeshesAndGeometries(result				: Vector.<Mesh>,
													 vertexDatas 		: Vector.<ByteArray>,
													 indexDatas 		: Vector.<ByteArray>,
													 vertexStreamUsage	: uint,
													 indexStreamUsage	: uint,
													 numBuffers 		: uint = 0) : void
		{
			numBuffers = numBuffers || result.length;
			_geometries = new Vector.<Geometry>(numBuffers);
			for (var bufferId : uint = 0; bufferId < numBuffers; ++bufferId)
			{
				var vertices 	: ByteArray	= vertexDatas[bufferId] as ByteArray;
				var indices 	: ByteArray = indexDatas[bufferId] as ByteArray;
				var verticesPos	: uint		= vertices.position;
				var indicesPos 	: uint		= indices.position;
				
				GeometrySanitizer.removeDuplicatedVertices(
					vertices, indices, _vertexFormat.numBytesPerVertex
				);
				
				if (!GeometrySanitizer.isValid(indices, vertices, _vertexFormat.numBytesPerVertex))
					throw new Error();
				
				var vertexStream : VertexStream = new VertexStream(
					vertexStreamUsage,
					_vertexFormat,
					vertices
				);
				
				var indexStream	: IndexStream = new IndexStream(
					indexStreamUsage,
					indices
				);
				
				var geom : Geometry = new Geometry(new <IVertexStream>[vertexStream], indexStream);
				_geometries[bufferId] = geom;
				var subMesh : Mesh = new Mesh(geom);
				geom.name = _meshName + bufferId
				subMesh.name = geom.name.slice();
				
				result[bufferId] = subMesh;
				
				vertices.position = verticesPos;
				indices.position = indicesPos;
			}
		}
		
		public function generateMeshes(vertexStreamUsage	: uint,
									   indexStreamUsage		: uint) : Vector.<Mesh>
		{
			var vertexDatas	: Vector.<ByteArray>	= new <ByteArray>[];
			var indexDatas	: Vector.<ByteArray>	= new <ByteArray>[];
			
			GeometrySanitizer.splitBuffers(
				_vertexData, _indexData, vertexDatas, indexDatas, _vertexFormat.numBytesPerVertex
			);
			
			var numBuffers 	: uint 			= indexDatas.length;
			var meshes 		: Vector.<Mesh> = new Vector.<Mesh>(numBuffers);
			if (!_geometries)
			{
				generateMeshesAndGeometries(meshes, vertexDatas, indexDatas, vertexStreamUsage, indexStreamUsage, numBuffers);
			}
			else
			{
				for (var bufferId : uint = 0; bufferId < numBuffers; ++bufferId)
				{
					var geom : Geometry = _geometries[bufferId];
					var mesh : Mesh = new Mesh(geom);
					
					mesh.name = _meshName + bufferId;
					
					meshes[bufferId] = mesh;
				}
			}
			
			return meshes;
		}
	}
}
