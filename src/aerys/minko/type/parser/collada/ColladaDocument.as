package aerys.minko.type.parser.collada
{
	import flash.events.EventDispatcher;
	
	import aerys.minko.Minko;
	import aerys.minko.ns.minko_animation;
	import aerys.minko.ns.minko_collada;
	import aerys.minko.scene.controller.AbstractController;
	import aerys.minko.scene.controller.animation.AnimationController;
	import aerys.minko.scene.controller.animation.IAnimationController;
	import aerys.minko.scene.controller.animation.MasterAnimationController;
	import aerys.minko.scene.controller.mesh.skinning.SkinningController;
	import aerys.minko.scene.node.Group;
	import aerys.minko.scene.node.ISceneNode;
	import aerys.minko.scene.node.Mesh;
	import aerys.minko.scene.node.camera.AbstractCamera;
	import aerys.minko.type.animation.timeline.ITimeline;
	import aerys.minko.type.animation.timeline.MatrixTimeline;
	import aerys.minko.type.error.collada.ColladaError;
	import aerys.minko.type.loader.parser.ParserOptions;
	import aerys.minko.type.log.DebugLevel;
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.math.Vector4;
	import aerys.minko.type.parser.collada.helper.RandomStringGenerator;
	import aerys.minko.type.parser.collada.instance.IInstance;
	import aerys.minko.type.parser.collada.instance.InstanceController;
	import aerys.minko.type.parser.collada.resource.ColladaMaterial;
	import aerys.minko.type.parser.collada.resource.Geometry;
	import aerys.minko.type.parser.collada.resource.IResource;
	import aerys.minko.type.parser.collada.resource.Node;
	import aerys.minko.type.parser.collada.resource.VisualScene;
	import aerys.minko.type.parser.collada.resource.animation.Animation;
	import aerys.minko.type.parser.collada.resource.camera.Camera;
	import aerys.minko.type.parser.collada.resource.controller.Controller;
	import aerys.minko.type.parser.collada.resource.controller.Skin;
	import aerys.minko.type.parser.collada.resource.effect.Effect;
	import aerys.minko.type.parser.collada.resource.image.Image;
	import aerys.minko.type.parser.collada.resource.light.Light;

	use namespace minko_collada;
	
	public final class ColladaDocument extends EventDispatcher
	{
		use namespace minko_animation;
		
		private static const NS	: Namespace	= new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private static const NODENAME_TO_LIBRARY : Object = {
			'animation'		: '_animations',
			'controller'	: '_controllers',
			'effect'		: '_effects',
			'geometry'		: '_geometries',
			'image'			: '_images',
			'material'		: '_materials',
			'node'			: '_nodes',
			'visual_scene'	: '_visualScenes',
			'camera'		: '_cameras',
			'light'			: '_lights'
		};
		
		private static const NODENAME_TO_CLASS : Object = {
			'animation'		: Animation,
			'controller'	: Controller,
			'effect'		: Effect,
			'geometry'		: Geometry,
			'image'			: Image,
			'material'		: ColladaMaterial,
			'node'			: Node,
			'visual_scene'	: VisualScene,
			'camera'		: Camera,
			'light'			: Light
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
        private var _matrices       : Object;
		private var _cameras		: Object;
		private var _lights			: Object;
		
		public function get mainSceneId() : String
        {
            return _mainSceneId;
        }
		
		public function get animations() : Object
        {
            return _animations;
        }
        
		public function get controllers() : Object
        {
            return _controllers;
        }
        
		public function get effects() : Object
        {
            return _effects;
        }
        
		public function get geometries() : Object
        {
            return _geometries;
        }
        
		public function get images() : Object
        {
            return _images;
        }
        
		public function get materials() : Object
        {
            return _materials;
        }
        
		public function get nodes() : Object
        {
            return _nodes;
        }
        
		public function get visualScenes() : Object
        {
            return _visualScenes;
        }
		
		public function get cameras() : Object
		{
			return _cameras;
		}
		
		public function get lights() : Object
		{
			return _lights;
		}
		
		public function ColladaDocument()
		{
		}
		
		public function loadFromXML(xmlDocument : XML) : void
		{
			_mainSceneId	= String(xmlDocument.NS::scene[0].NS::instance_visual_scene[0].@url).substr(1);
			
			_metaData		= createMetaDataFromXML(xmlDocument.NS::asset[0]);
			
			_animations		= {};
			_controllers	= {};
			_effects		= {};
			_geometries		= {};
			_images			= {};
			_materials		= {};
			_nodes			= {};
			_visualScenes	= {};
            _matrices       = {};
			_cameras		= {};
			_lights			= {};
			
			Animation.fillStoreFromXML(xmlDocument, this, _animations);
			Controller.fillStoreFromXML(xmlDocument, this, _controllers);
			Effect.fillStoreFromXML(xmlDocument, this, _effects);
			Geometry.fillStoreFromXML(xmlDocument, this, _geometries);
			Image.fillStoreFromXML(xmlDocument, this, _images);
			ColladaMaterial.fillStoreFromXML(xmlDocument, this, _materials);
			Camera.fillStoreFromXML(xmlDocument, this, _cameras);
			Light.fillStoreFromXML(xmlDocument, this, _lights);
			Node.fillStoreFromXML(xmlDocument, this, _nodes);
			VisualScene.fillStoreFromXML(xmlDocument, this, _visualScenes);
            
            var matrixNodes : XMLList = xmlDocument..NS::matrix.(hasOwnProperty('@sid'));
            
            for each (var matrixNode : XML in matrixNodes)
                _matrices[matrixNode.@sid] = matrixNode;
		}
        
        public function getMatrixXMLNodeBySid(sid : String) : XML
        {
            return  _matrices[sid];
        }
		
		private function createMetaDataFromXML(xmlMetaData : XML) : Object
		{
			var metaData : Object = {}
			
			metaData.contributor	= new <Object>[];
			metaData.unit			= {};
			
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
				var contributor : Object = {};
				
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
			var sourceIdToScene	: Object		= {};
			var scopedIdToScene	: Object		= {};
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
				var timelines   : Vector.<ITimeline>				= new <ITimeline>[];
				var targetNames	: Vector.<String>					= new <String>[];
				var animations	: Vector.<IAnimationController>		= new <IAnimationController>[];
				
				animationStore.getTimelines(timelines, targetNames);
				
				var numTimelines		: uint		= timelines.length;
				var timeLinesByNodeName	: Object	= {};
				
				for (var timelineId : uint = 0; timelineId < numTimelines; ++timelineId)
				{
					var timeline	: ITimeline	= timelines[timelineId];
					var targetName	: String	= targetNames[timelineId];
					
					timeLinesByNodeName[targetName] ||= new <ITimeline>[];
					timeLinesByNodeName[targetName].push(timeline);
				}
				
				for (var targetName_ : String in timeLinesByNodeName)
				{
					var sceneNode : ISceneNode	= sourceIdToScene[targetName_] as ISceneNode;
					timelines 	= timeLinesByNodeName[targetName_];
					
					if (sceneNode is AbstractCamera)
					{
						var nbTimelines	: uint	= timelines.length;
						var tlId		: uint	= 0;
						var tl			: MatrixTimeline = null;
						for (tlId = 0; tlId < nbTimelines; ++tlId)
						{
							tl = timelines[tlId] as MatrixTimeline;
							if (!tl)
								continue;
							var matrices	: Vector.<Matrix4x4>	= tl.minko_animation::matrices
							var nbMatrices	: uint					= matrices.length;
							var matrixId	: uint					= 0;
							var matrix		: Matrix4x4				= null;
							
							for (matrixId = 0; matrixId < nbMatrices; ++matrixId)
							{
								matrix = matrices[matrixId];
								var xaxis	: Vector4	= matrix.getColumn(0);
								var zaxis	: Vector4	= matrix.getColumn(2);
								xaxis.scaleBy(-1);
								zaxis.scaleBy(-1);
								matrix.setColumn(0, xaxis).setColumn(2, zaxis);
							}
						}
					}

					if (sceneNode)
					{
						var animationController : IAnimationController = new AnimationController(timelines);
						sceneNode.addController(animationController as AnimationController);
						animations.push(animationController);
					}
				}
			}
			
			// check if loadSkin is available
			if (options.loadSkin)
			{
				var skinningAnimationControllers : Vector.<AnimationController> = new Vector.<AnimationController>();
				
				// add skinning controllers.

				// @fixme
				// We iterate on controllers, because we have no easy way to find instances without performing a depth search.
				// This is a kludge and will break if multiple instances of the same controller are present in the scene.
				for each (var controller : Controller in _controllers)
				{
					var controllerInstance	: InstanceController = findInstanceById(controller.id)
                            as InstanceController;

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
										
					for(var i : int = 0; i < skin.jointNames.length; ++i)
					{
						// handle collada 1.4 "ID_REF"
						var jointName		: String	= skin.jointNames[i];
						var realJointName	: String	= "";
						var joint			: Group		= null;
						
						if (scopedIdToScene[jointName] || sourceIdToScene[jointName])
						{
							joint = scopedIdToScene[jointName] || sourceIdToScene[jointName];
							realJointName = jointName;
						}
						
						for(var j : int = i + 1; j < skin.jointNames.length; j++)
						{
							jointName = jointName + " " + skin.jointNames[j];
							
							if (scopedIdToScene[jointName] || sourceIdToScene[jointName])
							{
								joint = scopedIdToScene[jointName] || sourceIdToScene[jointName];
								realJointName = jointName;
								i = j;
							}
						}
						
						if (joint == null)
						{
							Minko.log(
								DebugLevel.PLUGIN_WARNING, 'Unable to find bone named \''
								+ jointName + '\'. Dropping skin for mesh named \'' + scene.name
								+ '\'.'
							);
							continue;
						}
												
						for (var jointOrAncestor : ISceneNode = joint; jointOrAncestor != null; jointOrAncestor = jointOrAncestor.parent)
						{
							var jointAnimations : Vector.<AbstractController> = jointOrAncestor.getControllersByType(
								AnimationController
							);
							
							for each (var jointAnimation : AnimationController in jointAnimations)
							{
								if (skinningAnimationControllers.indexOf(jointAnimation) == -1)
									skinningAnimationControllers.push(jointAnimation);
								if (animations.indexOf(jointAnimation) != -1)
									animations.splice(animations.indexOf(jointAnimation), 1);
							}
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
							skin.invBindMatrices,
							options.flattenSkinning,
							options.skinningNumFps
						);
						
						for each (var mesh : ISceneNode in meshes)
                        {
							mesh.addController(skinController);
                        }
					}
				}
				if (skinningAnimationControllers.length)
				{
					var masterAnimationController : MasterAnimationController = new MasterAnimationController(skinningAnimationControllers);
					mainScene.addController(masterAnimationController);
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
        
        public function getAnimationById(id : String) : Animation
        {
            return _animations[id];
        }
        
        public function getControllerById(id : String) : Controller
        {
            return _controllers[id];
        }
        
        public function getEffectById(id : String) : Effect
        {
            return _effects[id];
        }
        
        public function getGeometryById(id : String) : Geometry
        {
            return _geometries[id];
        }
        
        public function getImageById(id : String) : Image
        {
            return _images[id];
        }
        
        public function getMaterialById(id : String) : ColladaMaterial
        {
            return _materials[id];
        }
        
        public function getNodeById(id	: String) : Node
        {
            return _nodes[id];
        }
        
        public function getVisualSceneById(id : String) : VisualScene
        {
            return _visualScenes[id];
        }
		
		public function getCameraById(id : String) : aerys.minko.type.parser.collada.resource.camera.Camera
		{
			return _cameras[id];
		}
		
		public function getLightbyId(id : String) : Light
		{
			return _lights[id];
		}
	}
}
