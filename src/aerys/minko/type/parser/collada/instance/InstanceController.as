package aerys.minko.type.parser.collada.instance
{
	import aerys.minko.ns.minko_collada;
	import aerys.minko.scene.node.IScene;
	import aerys.minko.scene.node.group.IGroup;
	import aerys.minko.scene.node.group.Joint;
	import aerys.minko.scene.node.group.StyleGroup;
	import aerys.minko.scene.node.mesh.IMesh;
	import aerys.minko.scene.node.mesh.Mesh;
	import aerys.minko.scene.node.mesh.SkinnedMesh;
	import aerys.minko.type.math.Matrix3D;
	import aerys.minko.type.parser.ParserOptions;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.resource.IResource;
	import aerys.minko.type.parser.collada.resource.Node;
	import aerys.minko.type.parser.collada.resource.controller.Controller;
	import aerys.minko.type.parser.collada.resource.geometry.Geometry;
	import aerys.minko.type.parser.collada.resource.geometry.Triangles;
	
	public class InstanceController implements IInstance
	{
		use namespace minko_collada;
		
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _document			: ColladaDocument;
		
		private var _sourceId			: String;
		private var _name				: String;
		private var _sid				: String;
		private var _bindedSkeletonId	: String;
		private var _bindMaterial		: Object;
		
		private var _mesh				: IMesh;
		
		public function InstanceController(document			: ColladaDocument,
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
		
		public static function createFromXML(document	: ColladaDocument, 
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
			return toStyleGroup();
		}
		
		public function toStyleGroup() : StyleGroup
		{
			var sg 					: StyleGroup 		= new StyleGroup(); 
			var options				: ParserOptions		= _document.parserOptions;
			var controller			: Controller		= Controller(resource);
			
			if (!options || options.loadTextures)
			{
				var geometry			: Geometry			= _document.getGeometryById(controller.skinId);			
				var triangleStore		: Triangles 		= geometry.triangleStores[0];
				var subMeshMatSymbol	: String			= triangleStore.material;
				var instanceMaterial	: InstanceMaterial	= _bindMaterial[subMeshMatSymbol];
				
				sg.addChild(instanceMaterial.toScene());
			}
			
			if (!options || options.loadMeshes)
				sg.addChild(getMesh());
			
			return sg;
		}
		
		private function getMesh() : IMesh
		{
			if (!_mesh)
			{
				var controller			: Controller		= Controller(resource);
				
				_mesh = controller.toMesh();
				if (_mesh == null)
					return null;
				
				var options	: ParserOptions	= _document.parserOptions;
				
				if (!options || options.loadSkins)
				{
					var skeletonReference	: IGroup			= null;
					var skeletonRootName	: String			= _bindedSkeletonId;
					
					var bindShapeMatrix		: Matrix3D			= controller.bindShapeMatrix;
					var jointNames			: Vector.<String>	= controller.jointNames;
					var invBindMatrices		: Vector.<Matrix3D>	= controller.invBindMatrices;
					
					_mesh = new SkinnedMesh(_mesh,
						skeletonReference,
						skeletonRootName,
						bindShapeMatrix,
						jointNames,
						invBindMatrices);
					_mesh.name = _sourceId;
				}
			}
			
			return _mesh;
		}
		
		public function get resource() : IResource
		{
			return _document.getControllerById(_sourceId);
		}
		
	}
}
