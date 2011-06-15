package aerys.minko.type.collada
{
	import aerys.minko.ns.minko_collada;
	import aerys.minko.scene.node.IScene;
	import aerys.minko.type.collada.helper.RandomStringGenerator;
	import aerys.minko.type.collada.instance.IInstance;
	import aerys.minko.type.collada.instance.InstanceController;
	import aerys.minko.type.collada.instance.InstanceGeometry;
	import aerys.minko.type.collada.instance.InstanceNode;
	import aerys.minko.type.collada.instance.InstanceVisualScene;
	import aerys.minko.type.collada.ressource.Controller;
	import aerys.minko.type.collada.ressource.Geometry;
	import aerys.minko.type.collada.ressource.Node;
	import aerys.minko.type.collada.ressource.VisualScene;
	import aerys.minko.type.collada.store.Source;
	
	import flash.utils.flash_proxy;

	use namespace minko_collada;
	
	public class Document
	{
		minko_collada static const NS		: Namespace	= new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _mainSceneId	: String;
		
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
		public function getSceneById		(id	: String) : VisualScene	{ return _visualScenes[id];	}
		
		public function Document(xmlDocument : XML)
		{
			_mainSceneId	= String(xmlDocument.scene.instance_visual_scene.@url).substr(1);
			
			_controllers	= new Object();
			_geometries		= new Object();
			_nodes			= new Object();
			_visualScenes	= new Object();
			
			Controller	.fillStoreFromXML(xmlDocument, this, _controllers);
			Geometry	.fillStoreFromXML(xmlDocument, this, _geometries);
			Node		.fillStoreFromXML(xmlDocument, this, _nodes);
			VisualScene	.fillStoreFromXML(xmlDocument, this, _visualScenes);
		}
		
		minko_collada function delegateRessourceCreation(xmlNode : XML) : IInstance
		{
			var nodeType	: String = xmlNode.localName();
			var	nodeId		: String = xmlNode.@id;
			
			if (!nodeId)
				nodeId = xmlNode.@id = RandomStringGenerator.generateRandomString();
			
			if (nodeType == 'controller')
			{
				_controllers[nodeId] = new Controller(xmlNode, this);
				return InstanceController.createFromSourceId(this, nodeId);
			}
			
			if (nodeType == 'geometry')
			{
				_nodes[nodeId] = new Geometry(xmlNode, this);
				return InstanceGeometry.createFromSourceId(this, nodeId);
			}
			
			if (nodeType == 'node')
			{
				_nodes[nodeId] = new Node(xmlNode, this);
				return InstanceNode.createFromSourceId(this, nodeId);
			}
			
			if (nodeType == 'scene')
			{
				_visualScenes[nodeId] = new VisualScene(xmlNode, this);
				return InstanceVisualScene.createFromSourceId(this, nodeId);
			}
			
			throw new Error('Unknown ressource type.');
		}
		
		
	}
}