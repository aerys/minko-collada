package aerys.minko.type.parser.collada
{
	import aerys.minko.Minko;
	import aerys.minko.ns.minko_collada;
	import aerys.minko.scene.controller.AbstractController;
	import aerys.minko.scene.controller.AnimationController;
	import aerys.minko.scene.controller.mesh.skinning.SkinningController;
	import aerys.minko.scene.node.Group;
	import aerys.minko.scene.node.ISceneNode;
	import aerys.minko.scene.node.Mesh;
	import aerys.minko.type.animation.SkinningMethod;
	import aerys.minko.type.animation.timeline.ITimeline;
	import aerys.minko.type.error.collada.ColladaError;
	import aerys.minko.type.loader.parser.ParserOptions;
	import aerys.minko.type.log.DebugLevel;
	import aerys.minko.type.parser.collada.helper.RandomStringGenerator;
	import aerys.minko.type.parser.collada.instance.IInstance;
	import aerys.minko.type.parser.collada.instance.InstanceController;
	import aerys.minko.type.parser.collada.resource.ColladaMaterial;
	import aerys.minko.type.parser.collada.resource.Geometry;
	import aerys.minko.type.parser.collada.resource.IResource;
	import aerys.minko.type.parser.collada.resource.Node;
	import aerys.minko.type.parser.collada.resource.VisualScene;
	import aerys.minko.type.parser.collada.resource.animation.Animation;
	import aerys.minko.type.parser.collada.resource.controller.Controller;
	import aerys.minko.type.parser.collada.resource.controller.Skin;
	import aerys.minko.type.parser.collada.resource.effect.Effect;
	import aerys.minko.type.parser.collada.resource.image.Image;
	
	import flash.events.EventDispatcher;

	use namespace minko_collada;
	
	public final class ColladaDocument extends EventDispatcher
	{
		private static const NS	: Namespace	= new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private static const NODENAME_TO_LIBRARY : Object = {
			'animation'		: '_animations',
			'controller'	: '_controllers',
			'effect'		: '_effects',
			'geometry'		: '_geometries',
			'image'			: '_images',
			'material'		: '_materials',
			'node'			: '_nodes',
			'visual_scene'	: '_visualScenes'
		};
		
		private static const NODENAME_TO_CLASS : Object = {
			'animation'		: Animation,
			'controller'	: Controller,
			'effect'		: Effect,
			'geometry'		: Geometry,
			'image'			: Image,
			'material'		: ColladaMaterial,
			'node'			: Node,
			'visual_scene'	: VisualScene
		};
		
		private var _mainSceneId	: String;
		
		private var _metaData		: Object;
		
		private var _animations		: Object;
		private var _controllers	: Object;
		private var _effects		: Object;
		private var _geometries		: Object;
		private var _images			: Object;
		private var _materials		: Object;
		private var _nodes			: Object;
		private var _visualScenes	: Object;
		
		public function get mainSceneId()	: String { return _mainSceneId;		}
		
		public function get animations()	: Object { return _animations;		}
		public function get controllers()	: Object { return _controllers;		}
		public function get effects()		: Object { return _effects;			}
		public function get geometries()	: Object { return _geometries;		}
		public function get images()		: Object { return _images;			}
		public function get materials()		: Object { return _materials;		}
		public function get nodes()			: Object { return _nodes;			}
		public function get visualScenes()	: Object { return _visualScenes;	}
		
		public function getAnimationById	(id : String) : Animation	{ return _animations[id];	}
		public function getControllerById	(id : String) : Controller	{ return _controllers[id];	}
		public function getEffectById		(id : String) : Effect		{ return _effects[id];		}
		public function getGeometryById		(id : String) : Geometry	{ return _geometries[id];	}
		public function getImageById		(id : String) : Image		{ return _images[id];		}
		public function getMaterialById		(id : String) : ColladaMaterial	{ return _materials[id];	}
		public function getNodeById			(id	: String) : Node		{ return _nodes[id];		}
		public function getVisualSceneById	(id	: String) : VisualScene	{ return _visualScenes[id];	}
		
		public function ColladaDocument()
		{
		}
		
		public function loadFromXML(xmlDocument : XML) : void
		{
			_mainSceneId	= String(xmlDocument.NS::scene[0].NS::instance_visual_scene[0].@url).substr(1);
			
			_metaData		= createMetaDataFromXML(xmlDocument.NS::asset[0]);
			
			_animations		= new Object();
			_controllers	= new Object();
			_effects		= new Object();
			_geometries		= new Object();
			_images			= new Object();
			_materials		= new Object();
			_nodes			= new Object();
			_visualScenes	= new Object();
			
			Animation	.fillStoreFromXML(xmlDocument, this, _animations);
			Controller	.fillStoreFromXML(xmlDocument, this, _controllers);
			Effect		.fillStoreFromXML(xmlDocument, this, _effects);
			Geometry	.fillStoreFromXML(xmlDocument, this, _geometries);
			Image		.fillStoreFromXML(xmlDocument, this, _images);
			ColladaMaterial 	.fillStoreFromXML(xmlDocument, this, _materials);
			Node		.fillStoreFromXML(xmlDocument, this, _nodes);
			VisualScene	.fillStoreFromXML(xmlDocument, this, _visualScenes);
		}
		
		private function createMetaDataFromXML(xmlMetaData : XML) : Object
		{
			var metaData : Object = new Object();
			
			metaData.contributor	= new Vector.<Object>();
			metaData.unit			= new Object();
			
			//FIXME!
			metaData.unit.meter		= 1;//parseFloat(String(xmlMetaData.NS::unit[0].@meter));
			metaData.unit.name		= "meter";//String(xmlMetaData.NS::unit[0].@name);
			metaData.created		= new Date();
			metaData.modified		= new Date();
			metaData.upAxis			= String(xmlMetaData.NS::up_axis[0]);
			metaData.created.time	= Date.parse(String(xmlMetaData.NS::created[0]));
			metaData.modified.time	= Date.parse(String(xmlMetaData.NS::modified[0]));
			
			for each (var xmlContributor : XML in xmlMetaData.NS::contributor)
			{
				var contributor : Object = new Object();
				
				if (xmlContributor.NS::author.length() != 0)
					contributor.author = String(xmlContributor.NS::author);
				
				if (xmlContributor.NS::author_email.length() != 0)
					contributor.authorEmail = String(xmlContributor.NS::author_email);
				
				if (xmlContributor.NS::author_website.length() != 0)
					contributor.authorWebsite = String(xmlContributor.NS::author_website);
				
				if (xmlContributor.NS::authoring_tool.length() != 0)
					contributor.authoringTool = String(xmlContributor.NS::authoring_tool);
				
				if (xmlContributor.NS::comments.length() != 0)
					contributor.comments = String(xmlContributor.NS::comments);
				
				if (xmlContributor.NS::copyright.length() != 0)
					contributor.copyright = String(xmlContributor.NS::copyright);
				
				if (xmlContributor.NS::source_data.length() != 0)
					contributor.sourceData = String(xmlContributor.NS::source_data);
				
				metaData.contributor.push(contributor);
			}
			
			return metaData;
		}
		
		minko_collada function delegateResourceCreation(xmlNode : XML) : IInstance
		{
			var nodeType	: String = xmlNode.localName();
			var	nodeId		: String = xmlNode.@id;
			
			if (!nodeId)
				nodeId = xmlNode.@id = RandomStringGenerator.generateRandomString();
			
			if (!NODENAME_TO_LIBRARY.hasOwnProperty(nodeType))
				throw new ColladaError('No such handled resource type');
			
			var library			: Object	= this[NODENAME_TO_LIBRARY[nodeType]];
			var resourceClass	: Class		= NODENAME_TO_CLASS[nodeType];
			var resource		: IResource	= resourceClass['createFromXML'](xmlNode, this);
			
			library[resource.id] = resource;
			
			return resource.createInstance();
		}
		
		public function generateScene(options : ParserOptions) : ISceneNode
		{
			var instance		: IInstance		= getVisualSceneById(_mainSceneId).createInstance();
			var sourceIdToScene	: Object		= new Object();
			var scopedIdToScene	: Object		= new Object();
			var mainScene		: Group			= Group(instance.createSceneNode(options, sourceIdToScene, scopedIdToScene));
			var wrapper			: Group			= new Group(mainScene);
			
			wrapper.name = 'colladaWrapper' + uint(Math.random() * 1000);
			
			// scale depending on collada unit, and switch from right to left handed
			var unit : Number = _metaData.unit.meter;
			if (!isNaN(unit) && unit != 0)
				wrapper.transform.setScale(unit, unit, unit);
			
			// change up axis
			var upAxis : String = _metaData.upAxis;
			if (upAxis == 'Z_UP')
				wrapper.transform.setRotation(-Math.PI / 2, 0, 0);
			else if (upAxis == 'X_UP')
				wrapper.transform.setRotation(0, 0, Math.PI / 2);
			
			// add animation controllers
			var animationStore : Animation = _animations['mergedAnimations'];
			if (animationStore)
			{
				var timelines			: Vector.<ITimeline>	= new <ITimeline>[];
				var targetNames			: Vector.<String>		= new <String>[];
				
				animationStore.getTimelines(timelines, targetNames);
				
				var numTimelines		: uint		= timelines.length;
				var timeLinesByNodeName	: Object	= {};
				
				for (var timelineId : uint = 0; timelineId < numTimelines; ++timelineId)
				{
					var timeline	: ITimeline	= timelines[timelineId];
					var targetName	: String	= targetNames[timelineId];
					
					if (timeLinesByNodeName[targetName] == undefined)
						timeLinesByNodeName[targetName] = new <ITimeline>[];
					
					timeLinesByNodeName[targetName].push(timeline);
				}
				
				for (var targetName_ : String in timeLinesByNodeName)
				{
					var sceneNode : ISceneNode	= sourceIdToScene[targetName_] as ISceneNode;
					
					timelines 	= timeLinesByNodeName[targetName_];
					
					if (sceneNode && timelines)
						sceneNode.addController(new AnimationController(timelines));
				}
			}
			
			// check if loadSkin is available
			if (options.loadSkin)
			{
				// add skinning controllers.

				// @fixme
				// We iterate on controllers, because we have no easy way to find instances without performing a depth search.
				// This is a kludge and will break if multiple instances of the same controller are present in the scene.
				for each (var controller : Controller in _controllers)
				{
					var controllerInstance	: InstanceController = findInstanceById(controller.id) as InstanceController;
					if (!controllerInstance)
						continue;

					var skin	: Skin			= controller.skin;
					var scene	: ISceneNode	= sourceIdToScene[controllerInstance.sourceId];
					if (scene == null)
					{
						Minko.log(
							DebugLevel.PLUGIN_WARNING,
							'Unable to find instance linked to controller ' +
							'named \'' + controllerInstance.sourceId + '\': dropping skin.'
						);
						continue;
					}

					var meshes : Vector.<ISceneNode> = scene is Group
						? Group(scene).getDescendantsByType(Mesh)
						: new <ISceneNode>[scene];

					var joints : Vector.<Group>	= new <Group>[];
					for each (var jointName : String in skin.jointNames)
					{
						// handle collada 1.4 "ID_REF"
						var joint : Group = scopedIdToScene[jointName] || sourceIdToScene[jointName];

						if (joint == null)
						{
							Minko.log(
								DebugLevel.PLUGIN_WARNING, 'Unable to find bone named \''
								+ jointName + '\'. Dropping skin for mesh named \'' + scene.name
								+ '\'.'
							);
							continue;
						}

						joints.push(joint);
					}
					
					if (joints.length)
					{
						var skinController : AbstractController = new SkinningController(
							options.skinningMethod,
							mainScene,
							joints,
							skin.bindShapeMatrix,
							skin.invBindMatrices
						);
						
						for each (var mesh : ISceneNode in meshes)
							Mesh(mesh).addController(skinController);
					}
				}
			}
			
			return wrapper;
		}
		
		private function findInstanceById(sourceId : String, parent : IInstance = null) : IInstance
		{
			if (parent == null)
				parent = getVisualSceneById(_mainSceneId).createInstance();
			
			if (parent.sourceId == sourceId)
				return parent;
			
			var resource	: IResource = parent.resource;
			var childs		: Vector.<IInstance>;
			
			if (resource is Node)
				childs = Node(resource).childs
			else if (resource is VisualScene)
				childs = VisualScene(resource).childs;
			else return null;
			
			for each (var child : IInstance in childs)
			{
				var result : IInstance = findInstanceById(sourceId, child);
				
				if (result != null)
					return result;
			}
			
			return null;
		}
	}
}
