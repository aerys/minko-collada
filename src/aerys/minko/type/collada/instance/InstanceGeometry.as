package aerys.minko.type.collada.instance
{
	import aerys.minko.scene.node.IScene;
	import aerys.minko.scene.node.Model;
	import aerys.minko.type.collada.Document;
	import aerys.minko.type.collada.ressource.Geometry;
	import aerys.minko.type.collada.ressource.IRessource;
	
	public class InstanceGeometry implements IInstance
	{
		private var _document			: Document;
		
		private var _sourceId			: String;
		private var _name				: String;
		private var _sid				: String;
		
		public function InstanceGeometry(document			: Document,
										 sourceId			: String,
										 name				: String = null,
										 sid				: String = null)
		{
			_document	= document;
			
			_sourceId	= sourceId;
			_name		= name;
			_sid		= sid;
		}
		
		public static function createFromXML(document	: Document,
											 xml		: XML) : InstanceGeometry
		{
			var sourceId	: String = String(xml.@url).substr(1);
			var name		: String = xml.@name;
			var sid			: String = xml.@sid;
			
			return new InstanceGeometry(document, sourceId, name, sid);
		}
		
		public static function createFromSourceId(document : Document,
												  sourceId : String) : InstanceGeometry
		{
			return new InstanceGeometry(document, sourceId);
		}
		
		public function toScene() : IScene
		{
			return toModel();
		}
		
		public function toModel() : Model
		{
			var geometryRessource	: Geometry	= ressource as Geometry;
			var model				: Model		= new Model();
			
			model.mesh			= geometryRessource.toMesh();
			
			return model
		}
		
		public function get ressource() : IRessource
		{
			return _document.getGeometryById(_sourceId);
		}
	}
}
