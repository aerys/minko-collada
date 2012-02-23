package aerys.minko.type.parser.collada.resource
{
	import aerys.minko.Minko;
	import aerys.minko.ns.minko_collada;
	import aerys.minko.ns.minko_stream;
	import aerys.minko.scene.node.AbstractSceneNode;
	import aerys.minko.scene.node.mesh.Mesh;
	import aerys.minko.type.loader.parser.GeometrySanitizer;
	import aerys.minko.type.loader.parser.ParserOptions;
	import aerys.minko.type.log.DebugLevel;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.enum.InputType;
	import aerys.minko.type.parser.collada.helper.MeshTemplate;
	import aerys.minko.type.parser.collada.helper.Source;
	import aerys.minko.type.parser.collada.helper.Triangles;
	import aerys.minko.type.parser.collada.instance.IInstance;
	import aerys.minko.type.parser.collada.instance.InstanceGeometry;
	import aerys.minko.type.stream.IVertexStream;
	import aerys.minko.type.stream.IndexStream;
	import aerys.minko.type.stream.VertexStream;
	import aerys.minko.type.stream.format.VertexComponent;
	import aerys.minko.type.stream.format.VertexFormat;
	
	public class Geometry implements IResource
	{
		use namespace minko_collada;
		
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _document				: ColladaDocument;
		
		private var _id						: String;
		private var _name					: String;
		private var _verticesDataSemantics	: Vector.<String>;
		private var _verticesDataSources	: Object;
		private var _triangleStores			: Vector.<Triangles>;
		
		private var _meshTemplates			: Vector.<MeshTemplate>;
		
		public function get id() : String
		{
			return _id;
		}
		
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
		
		public function get meshTemplates() : Vector.<MeshTemplate>
		{
			return _meshTemplates;
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
		
		/**
		 * Generates a vector of MeshTemplate. One instance per triangle store under
		 * this geometry.
		 * 
		 * @param options
		 */
		public function computeMeshTemplates(options : ParserOptions) : void
		{
			if (_meshTemplates != null)
				return;
			
			_meshTemplates = new Vector.<MeshTemplate>();
			
			for each (var triangleStore : Triangles in _triangleStores)
			{
				var materialName	: String		= triangleStore.material;
				var indexStream		: IndexStream	= triangleStore.computeIndexStream();
				var vertexStream	: VertexStream	= 
					triangleStore.computeVertexStream(_verticesDataSemantics, _verticesDataSources);
				
				var vertexData		: Vector.<Number>	= new Vector.<Number>();
				var indexData		: Vector.<uint>		= new Vector.<uint>();
				
				GeometrySanitizer.sanitizeBuffers(
					vertexStream.minko_stream::_data,
					indexStream.minko_stream::_data,
					vertexData,
					indexData,
					vertexStream.format.dwordsPerVertex);
				
				var meshTemplate	: MeshTemplate	= new MeshTemplate(
					_name, 
					vertexData,
					indexData,
					materialName,
					vertexStream.format);
				
				_meshTemplates.push(meshTemplate);
			}
		}
	}
}