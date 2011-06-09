package aerys.minko.type.collada.ressource
{
	import aerys.minko.render.shader.node.Components;
	import aerys.minko.scene.node.mesh.IMesh;
	import aerys.minko.scene.node.mesh.Mesh;
	import aerys.minko.type.collada.enum.InputType;
	import aerys.minko.type.collada.intermediary.Source;
	import aerys.minko.type.stream.IndexStream;
	import aerys.minko.type.stream.VertexStream;
	import aerys.minko.type.stream.VertexStreamList;
	import aerys.minko.type.vertex.format.VertexComponent;
	import aerys.minko.type.vertex.format.VertexFormat;

	public class Geometry
	{
		private static const POLYGON_NODES : Vector.<String> = Vector.<String>([
			'lines', 'linestrips', 'polygons', 'polylist',
			'triangles', 'trifans', 'tristrips', ]);
		
		private var _verticesDataSemantics	: Vector.<String>;
		private var _verticesDataSources	: Object
		
		private var _triangleStores			: Vector.<TriangleStore>;
		
		public function Geometry(xmlGeometry : XML) 
		{
			var xmlMesh : XML = xmlGeometry.mesh[0];
			
			var xmlVertices : XML = xmlMesh.vertices[0];
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
					_triangleStores.push(new TriangleStore(polygons, xmlMesh));
		}
		
		public function toMesh() : IMesh
		{
			var triangleSemantics		: Vector.<String>	= createTriangleStoreSemanticList();
			var vertexFormat			: VertexFormat		= createVertexFormat(triangleSemantics);
			
			var vertexSources			: Vector.<Source>	= createVertexSourceList();
			
			var indexData				: Vector.<uint>		= new Vector.<Number>();
			var vertexData				: Vector.<Number>	= new Vector.<Number>();
			
			var vertices				: Object			= new Object();
			var currentVertex			: Vector.<Number>	= new Vector.<Number>(vertexFormat.dwordsPerVertex);
			
			for each (var triangleStore : TriangleStore in _triangleStores)
			{
				var vertexCount : uint = triangleStore.vertexCount;
				for (var storeVertexId : uint = 0; storeVertexId < vertexCount; ++storeVertexId)
				{
					var vertexId : uint = triangleStore.getVertexId(storeVertexId);
					
					
					
					
				}
			}
			
			return createMesh(indexData, vertexData, vertexFormat);
		}
		
		private function createTriangleStoreSemanticList() : Vector.<String>
		{
			// intersect semantics binded to the primitives contained in this geometry.
			var semantics	: Vector.<String>	= _triangleStores[0].semantics;
			for each (var triangleStore : TriangleStore in _triangleStores)
				semantics = intersectSemantics(semantics, triangleStore.semantics);
			
			/*	FIXME maybe we should check here that we have no duplicates?
			what should we do if it is the case? raise an exception? */
			return semantics;
		}
		
		/**
		 * Crappy intersection of 2 vectors. Should be improved if too slow, but should not be used very often
		 */
		private function intersectSemantics(semantics1 : Vector.<String>,
											semantics2 : Vector.<String>) : Vector.<String>
		{
			var result : Vector.<String> = new Vector.<String>();
			
			for each (var semanticToMatch : String in semantics1)
				for each (var semanticToTest : String in semantics2)
					if (semanticToMatch == semanticToTest)
						result.push(semanticToMatch);
			
			return result;
		}
		
		private function createVertexFormat(triangleSemantics : Vector.<String>) : VertexFormat
		{
			var vertexSemantics			: Vector.<String>	= _verticesDataSemantics;
			
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
		
		private function createComponentFromSemantic(semantic : String) : VertexComponent
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
		
		private function createVertexSourceList() : Vector.<Source>
		{
			var result : Vector.<Source> = new Vector.<Source>();
			for each (var semantic : String in _verticesDataSemantics)
				result.push(_verticesDataSources[semantic]);
			
			return result;
		}
		
		private function createMesh(indexData		: Vector.<uint>, 
									vertexData		: Vector.<Number>, 
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