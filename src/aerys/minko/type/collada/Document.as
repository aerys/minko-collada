package aerys.minko.type.collada
{
	import aerys.minko.ns.minko_collada;
	import aerys.minko.scene.node.IScene;
	import aerys.minko.scene.node.group.Group;
	import aerys.minko.scene.node.skeleton.Joint;
	import aerys.minko.scene.node.skeleton.SkinnedMesh;
	import aerys.minko.type.collada.helper.RandomStringGenerator;
	import aerys.minko.type.collada.instance.IInstance;
	import aerys.minko.type.collada.ressource.Controller;
	import aerys.minko.type.collada.ressource.Geometry;
	import aerys.minko.type.collada.ressource.IRessource;
	import aerys.minko.type.collada.ressource.Material;
	import aerys.minko.type.collada.ressource.Node;
	import aerys.minko.type.collada.ressource.VisualScene;
	import aerys.minko.type.collada.ressource.animation.Animation;
	import aerys.minko.type.collada.ressource.effect.Effect;
	import aerys.minko.type.collada.ressource.image.Image;
	
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
		
		public function loadByteArray(data : ByteArray) : void
		{
			loadXml(new XML(data.readUTFBytes(data.length)));
		}
		
		public function loadXml(xmlDocument : XML) : void
		{
			_mainSceneId		= String(xmlDocument.NS::scene[0].NS::instance_visual_scene[0].@url).substr(1);
			
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
//			Image		.fillStoreFromXML(xmlDocument, this, _images);
			Material 	.fillStoreFromXML(xmlDocument, this, _materials);
			Node		.fillStoreFromXML(xmlDocument, this, _nodes);
			VisualScene	.fillStoreFromXML(xmlDocument, this, _visualScenes);
		}
		
		public function toGroup(removeEmptyGroups : Boolean = true) : Group
		{
			var visualScene	: VisualScene	= _visualScenes[_mainSceneId];
			var sceneGraph	: Group			= visualScene.toGroup();
			setSkeletonReferenceNodes(sceneGraph, sceneGraph);
			
			if (removeEmptyGroups)
				this.removeEmptyGroups(sceneGraph, null);
			
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
		
		private function removeEmptyGroups(currentGroup : Group, parentGroup : Group) : void
		{
			if (!(currentGroup is Joint) && currentGroup.numChildren == 0 && parentGroup != null)
			{
				parentGroup.removeChild(currentGroup);
			}
			else
			{
				for each (var el : IScene in currentGroup)
					if (el is Group)
						removeEmptyGroups(Group(el), currentGroup);
			}
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