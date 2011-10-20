package aerys.minko.type.parser.collada.instance
{
	import aerys.minko.ns.minko_collada;
	import aerys.minko.scene.node.IScene;
	import aerys.minko.scene.node.Model;
	import aerys.minko.scene.node.group.Group;
	import aerys.minko.scene.node.group.IGroup;
	import aerys.minko.scene.node.group.MaterialGroup;
	import aerys.minko.scene.node.group.StyleGroup;
	import aerys.minko.scene.node.mesh.IMesh;
	import aerys.minko.scene.node.texture.ITexture;
	import aerys.minko.type.parser.ParserOptions;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.resource.IResource;
	import aerys.minko.type.parser.collada.resource.geometry.Geometry;
	import aerys.minko.type.parser.collada.resource.geometry.Triangles;
	
	use namespace minko_collada;
	
	public class InstanceGeometry implements IInstance
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _document		: ColladaDocument;
		private var _sourceId		: String;
		private var _name			: String;
		private var _sid			: String;
		private var _bindMaterial	: Object;
		
		private var _scene			: IScene;
		
		public function InstanceGeometry(document			: ColladaDocument,
										 sourceId			: String,
										 bindMaterial		: Object = null,
										 name				: String = null,
										 sid				: String = null)
		{
			_document		= document;
			_sourceId		= sourceId;
			_name			= name;
			_sid			= sid;
			_bindMaterial	= bindMaterial;
		}
		
		public static function createFromXML(document	: ColladaDocument,
											 xml		: XML) : InstanceGeometry
		{
			var sourceId	: String = String(xml.@url).substr(1);
			var name		: String = xml.@name;
			var sid			: String = xml.@sid;
			
			var bindMaterial : Object = new Object();
			for each (var xmlIm : XML in xml..NS::instance_material)
			{
				var instanceMaterial : InstanceMaterial = InstanceMaterial.createFromXML(xmlIm, document);
				bindMaterial[instanceMaterial.symbol] = instanceMaterial;
			}
			
			return new InstanceGeometry(document, sourceId, bindMaterial, name, sid);
		}
		
		public static function createFromSourceId(document : ColladaDocument,
												  sourceId : String) : InstanceGeometry
		{
			return new InstanceGeometry(document, sourceId);
		}
		
		public function toScene() : IScene
		{
			var geometry	: Geometry		= resource as Geometry;

			if (geometry && !_scene)
			{
				var options	: ParserOptions	= _document.parserOptions;
				var group	: IGroup		= null;
				
				if (!options || options.loadMeshes)
				{
					_scene = geometry.toMesh();
					_scene = options.replaceNodeFunction(_scene);
				}
				
				if (!options || options.loadTextures)
				{
					// get the first material
					var triangleStore		: Triangles 		= geometry.triangleStores[0];
					var subMeshMatSymbol	: String			= triangleStore.material;
					var instanceMaterial	: InstanceMaterial	= _bindMaterial[subMeshMatSymbol];
					var texture				: IScene			= instanceMaterial.toScene();
					
					group = new MaterialGroup(null, texture);
					
					if (_scene)
						group.addChild(_scene);
					_scene = group;
				}

				_scene.name = geometry.id;
			}
			
			return _scene;
		}
		
		public function get resource() : IResource
		{
			return _document.getGeometryById(_sourceId);
		}
	}
}
