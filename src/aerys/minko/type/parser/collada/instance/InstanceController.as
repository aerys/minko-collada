package aerys.minko.type.parser.collada.instance
{
	import aerys.minko.scene.node.IScene;
	import aerys.minko.scene.node.group.IGroup;
	import aerys.minko.scene.node.group.Joint;
	import aerys.minko.scene.node.mesh.Mesh;
	import aerys.minko.scene.node.mesh.SkinnedMesh;
	import aerys.minko.type.math.Matrix3D;
	import aerys.minko.type.parser.collada.Document;
	import aerys.minko.type.parser.collada.resource.IResource;
	import aerys.minko.type.parser.collada.resource.Node;
	import aerys.minko.type.parser.collada.resource.controller.Controller;
	
	public class InstanceController implements IInstance
	{
		private static const NS : Namespace = 
			new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _document			: Document;
		
		private var _sourceId			: String;
		private var _name				: String;
		private var _sid				: String;
		private var _bindedSkeletonId	: String;
		private var _bindMaterial		: Object;
		
		private var _minkoSkinnedMesh	: SkinnedMesh;
		
		public function InstanceController(document			: Document,
										   sourceId			: String,
										   name				: String = null,
										   sid				: String = null,
										   bindMaterial		: Object = null,
										   bindedSkeletonId	: String = null)
		{
			_document			= document;
			_sourceId			= sourceId;
			_name				= name;
			_sid				= sid;
			_bindedSkeletonId	= bindedSkeletonId;
			_bindMaterial		= bindMaterial;
		}
		
		public static function createFromXML(document	: Document, 
											 xml		: XML) : InstanceController
		{
			var sourceId			: String	= String(xml.@url).substr(1);
			var name				: String	= xml.@name;
			var sid					: String	= xml.@sid;
			
			var xmlSkeletonId		: XML		= xml.NS::skeleton[0];
			var bindedSkeletonId	: String	= xmlSkeletonId != null ? String(xmlSkeletonId).substr(1) : null;
			
			var bindMaterial : Object = new Object();
			for each (var xmlIm : XML in xml..NS::instance_material)
			{
				var instanceMaterial : InstanceMaterial = InstanceMaterial.createFromXML(xmlIm, document);
				bindMaterial[instanceMaterial.symbol] = instanceMaterial;
			}
			
			return new InstanceController(document, sourceId, name, sid, bindMaterial, bindedSkeletonId);
		}
		
		public function toScene() : IScene
		{
			return toSkinnedMesh();
		}
		
		public function toSkinnedMesh() : SkinnedMesh
		{
			if (!_minkoSkinnedMesh)
			{
				var controller			: Controller		= Controller(resource);
				
				var skeletonReference	: IGroup			= null;
				var skeletonRootName	: String			= _bindedSkeletonId;
				
				var mesh				: Mesh				= controller.toMesh();
				var bindShapeMatrix		: Matrix3D			= controller.bindShapeMatrix;
				var jointNames			: Vector.<String>	= controller.jointNames;
				var invBindMatrices		: Vector.<Matrix3D>	= controller.invBindMatrices;
				
				if (mesh == null)
					return null;
				
				_minkoSkinnedMesh		= new SkinnedMesh(mesh, skeletonReference, skeletonRootName, bindShapeMatrix, jointNames, invBindMatrices);
				_minkoSkinnedMesh.name	= _sourceId;
			}
			
			return _minkoSkinnedMesh;
		}
		
		public function get resource() : IResource
		{
			return _document.getControllerById(_sourceId);
		}
		
	}
}
