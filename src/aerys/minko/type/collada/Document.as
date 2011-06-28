package aerys.minko.type.collada
{
	import aerys.minko.ns.minko_collada;
	import aerys.minko.type.animation.Animation;
	import aerys.minko.type.collada.helper.RandomStringGenerator;
	import aerys.minko.type.collada.instance.IInstance;
	import aerys.minko.type.collada.ressource.Animation;
	import aerys.minko.type.collada.ressource.Controller;
	import aerys.minko.type.collada.ressource.Geometry;
	import aerys.minko.type.collada.ressource.IRessource;
	import aerys.minko.type.collada.ressource.Node;
	import aerys.minko.type.collada.ressource.VisualScene;
	
	import flash.utils.ByteArray;

	use namespace minko_collada;
	
	public class Document
	{
		private static const NS	: Namespace	= new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private static const NODENAME_TO_LIBRARY	: Object = {
			'controller'	: '_controllers',
			'geometry'		: '_geometries',
			'node'			: '_nodes',
			'visual_scene'	: '_visualScenes'
		};
		
		private static const NODENAME_TO_CLASS		: Object = {
			'controller'			: Controller,
			'geometry'				: Geometry,
			'node'					: Node,
			'visual_scene'			: VisualScene
		};
		
		private var _mainSceneId	: String;
		
		private var _animations		: Object;
		private var _controllers	: Object;
		private var _geometries		: Object;
		private var _nodes			: Object;
		private var _visualScenes	: Object;
		
		public function get mainScene()		: VisualScene	{ return _visualScenes[_mainSceneId]; }
		public function get mainSceneId()	: String		{ return _mainSceneId; }
		public function get nodes()			: Object	 	{ return _nodes; }
		public function get geometries()	: Object 		{ return _geometries; }
		public function get controllers()	: Object 		{ return _controllers; }
		public function get visualScenes()	: Object 		{ return _visualScenes; }
		
		public function getGeometryById		(id : String) : Geometry	{ return _geometries[id];	}
		public function getControllerById	(id : String) : Controller	{ return _controllers[id];	}
		public function getNodeById			(id	: String) : Node		{ return _nodes[id];		}
		public function getVisualSceneById	(id	: String) : VisualScene	{ return _visualScenes[id];	}
		
		public function Document()
		{
		}
		
		public function loadByteArray(data : ByteArray) : void
		{
			loadXml(new XML(data.readUTFBytes(data.length)));
		}
		
		public function loadXml(xmlDocument : XML) : void
		{
			_mainSceneId	= String(xmlDocument.NS::scene[0].NS::instance_visual_scene[0].@url).substr(1);
			
			_animations		= new Object();
			_controllers	= new Object();
			_geometries		= new Object();
			_nodes			= new Object();
			_visualScenes	= new Object();
			
			aerys.minko.type.collada.ressource.Animation	.fillStoreFromXML(xmlDocument, this, _animations);
			Controller	.fillStoreFromXML(xmlDocument, this, _controllers);
			Geometry	.fillStoreFromXML(xmlDocument, this, _geometries);
			Node		.fillStoreFromXML(xmlDocument, this, _nodes);
			VisualScene	.fillStoreFromXML(xmlDocument, this, _visualScenes);
			
			var colladaMergedAnim	: aerys.minko.type.collada.ressource.Animation	= new aerys.minko.type.collada.ressource.Animation(xmlDocument.NS::library_animations[0], this)
			minkoAnim			= colladaMergedAnim.toMinkoAnimation();
			
			
		}
		public var minkoAnim			: aerys.minko.type.animation.Animation
		minko_collada function delegateRessourceCreation(xmlNode : XML) : IInstance
		{
			var nodeType	: String = xmlNode.localName();
			var	nodeId		: String = xmlNode.@id;
			
			if (!nodeId)
				nodeId = xmlNode.@id = RandomStringGenerator.generateRandomString();
			
			if (!NODENAME_TO_LIBRARY.hasOwnProperty(nodeType))
				throw new Error('No such handled ressource type');
			
			var library			: Object		= this[NODENAME_TO_LIBRARY[nodeType]];
			var ressourceClass	: Class			= NODENAME_TO_CLASS[nodeType];
			
			var ressource		: IRessource	= new ressourceClass(xmlNode, this); 
			library[ressource.id] = ressource;
			
			return ressource.createInstance();
		}
	}
}