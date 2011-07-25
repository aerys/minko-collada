package aerys.minko.type.parser.collada
{
	import aerys.minko.ns.minko_collada;
	import aerys.minko.scene.node.IScene;
	import aerys.minko.scene.node.group.ColladaGroup;
	import aerys.minko.scene.node.group.Group;
	import aerys.minko.scene.node.group.Joint;
	import aerys.minko.scene.node.mesh.IMesh;
	import aerys.minko.scene.node.mesh.SkinnedMesh;
	import aerys.minko.type.parser.collada.helper.RandomStringGenerator;
	import aerys.minko.type.parser.collada.instance.IInstance;
	import aerys.minko.type.parser.collada.ressource.controller.Controller;
	import aerys.minko.type.parser.collada.ressource.IRessource;
	import aerys.minko.type.parser.collada.ressource.Material;
	import aerys.minko.type.parser.collada.ressource.Node;
	import aerys.minko.type.parser.collada.ressource.VisualScene;
	import aerys.minko.type.parser.collada.ressource.animation.Animation;
	import aerys.minko.type.parser.collada.ressource.effect.Effect;
	import aerys.minko.type.parser.collada.ressource.geometry.Geometry;
	import aerys.minko.type.parser.collada.ressource.image.Image;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	use namespace minko_collada;
	
	public class Document extends EventDispatcher
	{
		private static const NS	: Namespace	= new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private static const NODENAME_TO_LIBRARY	: Object = {
			'animation'		: '_animations',
			'controller'	: '_controllers',
			'effect'		: '_effects',
			'geometry'		: '_geometries',
			'image'			: '_images',
			'material'		: '_materials',
			'node'			: '_nodes',
			'visual_scene'	: '_visualScenes'
		};
		
		private static const NODENAME_TO_CLASS		: Object = {
			'animation'				: Animation,
			'controller'			: Controller,
			'effect'				: Effect,
			'geometry'				: Geometry,
			'image'					: Image,
			'material'				: Material,
			'node'					: Node,
			'visual_scene'			: VisualScene
		};
		
		private var _url			: String;
		private var _textureFeed	: Object;
		
		private var _mainSceneId	: String;
		
		private var _animations		: Object;
		private var _controllers	: Object;
		private var _effects		: Object;
		private var _geometries		: Object;
		private var _images			: Object;
		private var _materials		: Object;
		private var _nodes			: Object;
		private var _visualScenes	: Object;
		
		public function get mainSceneId()		: String	{ return _mainSceneId;	}
		
		public function get animations()		: Object	{ return _animations;	}
		public function get controllers()		: Object 	{ return _controllers;	}
		public function get effects()			: Object	{ return _effects;		}
		public function get geometries()		: Object 	{ return _geometries;	}
		public function get images()			: Object	{ return _images;		}
		public function get materials()			: Object	{ return _materials;	}
		public function get nodes()				: Object	{ return _nodes;		}
		public function get visualScenes()		: Object 	{ return _visualScenes;	}
		
		public function getAnimationById	(id : String) : Animation	{ return _animations[id];	}
		public function getControllerById	(id : String) : Controller	{ return _controllers[id];	}
		public function getEffectById		(id : String) : Effect		{ return _effects[id];		}
		public function getGeometryById		(id : String) : Geometry	{ return _geometries[id];	}
		public function getImageById		(id : String) : Image		{ return _images[id];		}
		public function getMaterialById		(id : String) : Material	{ return _materials[id];	}
		public function getNodeById			(id	: String) : Node		{ return _nodes[id];		}
		public function getVisualSceneById	(id	: String) : VisualScene	{ return _visualScenes[id];	}
		
		public function Document()
		{
		}
		
		public function loadURL(url : String) : void
		{
			var r : URLRequest = new URLRequest();
			r.url = url;
			
			var l : URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, onColladaLoadComplete);
			l.load(r);
		}
		
		private function onColladaLoadComplete(e : Event) : void
		{
			var data : XML = XML(URLLoader(e.currentTarget).data);
			loadXML(data);
			
			for each (var image : Image in _images)
			{
				image.imageData.addEventListener(Event.COMPLETE, onImageLoadComplete);
				image.imageData.load();
			}
		}
		
		private function onImageLoadComplete(e : Event) : void
		{
			for each (var image : Image in _images)
				if (!image.imageData.isLoaded)
					return;
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function loadByteArray(data : ByteArray, textures : Object = null) : void
		{
			_textureFeed = textures;
			loadXML(new XML(data.readUTFBytes(data.length)));
		}
		
		public function loadXML(xmlDocument : XML) : void
		{
			_mainSceneId	= String(xmlDocument.NS::scene[0].NS::instance_visual_scene[0].@url).substr(1);
			
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
			Material 	.fillStoreFromXML(xmlDocument, this, _materials);
			Node		.fillStoreFromXML(xmlDocument, this, _nodes);
			VisualScene	.fillStoreFromXML(xmlDocument, this, _visualScenes);
		}
		
		public function toGroup(dropEmptyGroups : Boolean = true, dropSkinning : Boolean = false) : Group
		{
			var visualScene	: VisualScene	= _visualScenes[_mainSceneId];
			var sceneGraph	: Group			= visualScene.toGroup();
			var wrapper		: ColladaGroup	= new ColladaGroup(sceneGraph);
			
			setSkeletonReferenceNodes(sceneGraph, sceneGraph);
			
			if (dropEmptyGroups)
				removeEmptyGroups(sceneGraph, null);
			
			if (dropSkinning)
				removeSkinning(sceneGraph);
			
			for each (var anim : Animation in _animations)
				wrapper.animations.push(anim.toMinkoAnimation());
			
			return sceneGraph;
		}
		
		private function setSkeletonReferenceNodes(currentGroup : Group, referenceNode : Group) : void
		{
			for each (var el : IScene in currentGroup)
			{
				if (el is SkinnedMesh)
					SkinnedMesh(el).skeletonReference = referenceNode;
				
				else if (el is Group)
					 setSkeletonReferenceNodes(Group(el), referenceNode);
			}
		}
		
		private function removeEmptyGroups(currentGroup : Group, parentGroup : Group) : Boolean
		{
			var childCount : uint = currentGroup.numChildren;
			for (var childIndex : uint = 0; childIndex < childCount; ++childIndex)
			{
				var el : Group = currentGroup.getChildAt(childIndex) as Group;
				if (el != null && removeEmptyGroups(Group(el), currentGroup))
				{
					--childIndex;
					--childCount;
				}
			}
			
			if (!(currentGroup is Joint) && currentGroup.numChildren == 0 && parentGroup != null)
			{
				parentGroup.removeChild(currentGroup);
				return true;
			}
			
			return false;
		}
		
		private function removeSkinning(currentGroup : Group) : void
		{
			var childCount : uint = currentGroup.numChildren;
			for (var childIndex : uint = 0; childIndex < childCount; ++childIndex)
			{
				var el : IScene = currentGroup.getChildAt(childIndex);
				if (el is Group)
				{
					removeSkinning(el as Group);
				}
				else if (el is SkinnedMesh)
				{
					var mesh : IMesh = SkinnedMesh(el).mesh;
					currentGroup.removeChildAt(childIndex);
					currentGroup.addChildAt(mesh, childIndex);
				}
			}
		}
		
		minko_collada function getTextureFromFeed(filename : String) : BitmapData
		{
			return _textureFeed[filename];
		}
		
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