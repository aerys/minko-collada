package aerys.minko.type.collada.ressource
{
	import aerys.minko.ns.minko_collada;
	import aerys.minko.type.collada.Document;
	import aerys.minko.type.collada.instance.IInstance;
	import aerys.minko.type.collada.instance.InstanceVisualScene;

	use namespace minko_collada;
	
	public class VisualScene implements IRessource
	{
		private var _document	: Document;
		private var _id			: String;
		private var _childs		: Vector.<IInstance>;
		
		public function get id()		: String				{ return _id; }
		public function get childs()	: Vector.<IInstance>	{ return _childs; }
		public function get instance()	: IInstance				{ return new InstanceVisualScene(_document, _id); }
		
		public static function fillStoreFromXML(xmlDocument	: XML,
												document	: Document,
												store		: Object) : void
		{
			var xmlSceneLibrary	: XML = xmlDocument..library_scenes[0];
		}
		
		public function VisualScene(xmlScene : XML,
									document : Document)
		{
			_document	= document;
			_id			= xmlScene.@id;
			
			for each (var xmlNode : XML in xmlScene.node)
				_childs.push(document.delegateRessourceCreation(xmlNode));
		}
	}
}
