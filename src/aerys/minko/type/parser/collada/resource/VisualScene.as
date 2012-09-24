package aerys.minko.type.parser.collada.resource
{
	import aerys.minko.ns.minko_collada;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.instance.IInstance;
	import aerys.minko.type.parser.collada.instance.InstanceVisualScene;
	
	use namespace minko_collada;
	
	public class VisualScene implements IResource
	{
		private static const NS	: Namespace = 
			new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _document	: ColladaDocument;
		private var _id			: String;
		private var _name		: String;
		private var _childs		: Vector.<IInstance>;
		
		public function get id()		: String				{ return _id; }
		public function get childs()	: Vector.<IInstance>	{ return _childs; }
		
		public static function fillStoreFromXML(xmlDocument	: XML,
												document	: ColladaDocument,
												store		: Object) : void
		{
			var xmlSceneLibrary	: XML		= xmlDocument..NS::library_visual_scenes[0];
			if (xmlSceneLibrary == null)
				return;
			
			var xmlScenes		: XMLList	= xmlSceneLibrary.NS::visual_scene;
			for each (var xmlScene : XML in xmlScenes)
			{
				var scene : VisualScene = new VisualScene(xmlScene, document);
				store[scene.id] = scene;
			}
		}
		
		public function VisualScene(xmlScene : XML,
									document : ColladaDocument)
		{
			_document	= document;
			_id			= xmlScene.@id;
			_name		= xmlScene.@name;
			_childs		= new Vector.<IInstance>();
			
			for each (var xmlNode : XML in xmlScene.NS::node)
				_childs.push(document.delegateResourceCreation(xmlNode));
		}
		
		public function createInstance() : IInstance
		{
			return new InstanceVisualScene(_document, _id); 
		}
	}
}
