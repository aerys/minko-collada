package aerys.minko.type.parser.collada.instance
{
	import aerys.minko.ns.minko_collada;
	import aerys.minko.scene.node.IScene;
	import aerys.minko.scene.node.Model;
	import aerys.minko.scene.node.group.Group;
	import aerys.minko.scene.node.group.IGroup;
	import aerys.minko.scene.node.group.StyleGroup;
	import aerys.minko.scene.node.mesh.IMesh;
	import aerys.minko.scene.node.mesh.Mesh;
	import aerys.minko.scene.node.texture.BitmapTexture;
	import aerys.minko.scene.node.texture.ITexture;
	import aerys.minko.type.parser.collada.Document;
	import aerys.minko.type.parser.collada.resource.IResource;
	import aerys.minko.type.parser.collada.resource.geometry.Geometry;
	import aerys.minko.type.parser.collada.resource.geometry.Triangles;
	
	use namespace minko_collada;
	
	public class InstanceGeometry implements IInstance
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _document			: Document;
		private var _sourceId			: String;
		private var _name				: String;
		private var _sid				: String;
		private var _bindMaterial		: Object;
		
		private var _minkoModel			: Model;
		
		public function InstanceGeometry(document			: Document,
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
		
		public static function createFromXML(document	: Document,
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
		
		public static function createFromSourceId(document : Document,
												  sourceId : String) : InstanceGeometry
		{
			return new InstanceGeometry(document, sourceId);
		}
		
		public function toScene() : IScene
		{
			return toStyleGroupedMesh();
//			return toTexturedModelGroup()
//			return toUntexturedModel();
		}
		
		public function toUntexturedModel() : Model
		{
			if (!_minkoModel)
			{
				var geometryResource	: Geometry	= resource as Geometry;
				
				if (geometryResource == null)
					return null;
				
				var mesh				: IMesh		= geometryResource.toMesh();
				var texture				: ITexture	= null;
				
				if (mesh != null)
					_minkoModel = new Model(mesh);
			}
			
			return _minkoModel;
		}
		
		public function toStyleGroupedMesh() : StyleGroup
		{
			var geometry	: Geometry		= resource as Geometry;
			var group		: StyleGroup	= new StyleGroup();

			if (geometry)
			{
				// get the mesh
				var mesh				: IMesh				= geometry.toMesh();
				
				// get the first material
				var triangleStore		: Triangles 		= geometry.triangleStores[0];
				var subMeshMatSymbol	: String			= triangleStore.material;
				var instanceMaterial	: InstanceMaterial	= _bindMaterial[subMeshMatSymbol];
				var texture				: ITexture			= instanceMaterial.toScene() as ITexture;
				
				group.addChild(texture)
					 .addChild(mesh);
			}
			
			return group;
		}
		
		public function toTexturedModelGroup() : Group
		{
			var group		: Group		= new Group();
			var geometry	: Geometry	= resource as Geometry;
			
			for each (var triangleStore : Triangles in geometry.triangleStores)
			{
				if (triangleStore.vertexCount == 0)
					continue;
				
				var subMesh				: IMesh				= geometry.toSubMesh(triangleStore);
				
				var subMeshMatSymbol	: String			= triangleStore.material;
				var instanceMaterial	: InstanceMaterial	= _bindMaterial[subMeshMatSymbol];
				var texture				: ITexture			= instanceMaterial.toScene() as ITexture;
				
				group.addChild(new Model(subMesh, texture));
			}
			
			return group;
		}
		
		public function get resource() : IResource
		{
			return _document.getGeometryById(_sourceId);
		}
	}
}
