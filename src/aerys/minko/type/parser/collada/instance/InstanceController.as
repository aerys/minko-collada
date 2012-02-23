package aerys.minko.type.parser.collada.instance
{
	import aerys.minko.Minko;
	import aerys.minko.ns.minko_collada;
	import aerys.minko.render.effect.Effect;
	import aerys.minko.scene.controller.AbstractController;
	import aerys.minko.scene.controller.SkinningController;
	import aerys.minko.scene.node.Group;
	import aerys.minko.scene.node.ISceneNode;
	import aerys.minko.scene.node.mesh.Mesh;
	import aerys.minko.type.animation.SkinningMethod;
	import aerys.minko.type.loader.parser.ParserOptions;
	import aerys.minko.type.log.DebugLevel;
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.math.Vector4;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.helper.MeshTemplate;
	import aerys.minko.type.parser.collada.helper.Triangles;
	import aerys.minko.type.parser.collada.resource.Geometry;
	import aerys.minko.type.parser.collada.resource.IResource;
	import aerys.minko.type.parser.collada.resource.controller.Controller;
	import aerys.minko.type.parser.collada.resource.controller.Skin;
	import aerys.minko.type.stream.VertexStream;
	
	public class InstanceController implements IInstance
	{
		use namespace minko_collada;
		
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _document			: ColladaDocument;
		
		private var _sourceId			: String;
		private var _name				: String;
		private var _scopedId			: String;
		private var _bindedSkeletonId	: String;
		private var _bindMaterial		: Object;
		
		public function get resource() : IResource
		{
			return _document.getControllerById(_sourceId);
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
		
		public function InstanceController(document			: ColladaDocument,
										   sourceId			: String,
										   name				: String = null,
										   scopedId			: String = null,
										   bindMaterial		: Object = null,
										   bindedSkeletonId	: String = null)
		{
			_document			= document;
			_sourceId			= sourceId;
			_name				= name;
			_scopedId			= scopedId;
			_bindedSkeletonId	= bindedSkeletonId;
			_bindMaterial		= bindMaterial;
		}
		
		public function createSceneNode(options				: ParserOptions,
										sourceIdToSceneNode	: Object,
										scopedIdToSceneNode	: Object) : ISceneNode
		{
			var skin			: Skin					= Controller(resource).skin;
			skin.computeMeshTemplates(options);
			
			var meshTemplateId	: uint;
			var effect			: Effect				= options.effect;
			var meshTemplates	: Vector.<MeshTemplate>	= skin.meshTemplates;
			var numMeshes		: uint					= meshTemplates != null ? meshTemplates.length : 0;
			var group			: Group					= new Group();
			
			for (meshTemplateId = 0; meshTemplateId < numMeshes; ++meshTemplateId)
			{
				var meshTemplate	: MeshTemplate	= meshTemplates[meshTemplateId];
				
				var diffuseValue	: Object		= 
					getDiffuseValueFromMaterialName(meshTemplate.materialName);
				
				var localMeshes 	: Vector.<Mesh> = 
					meshTemplate.generateMeshes(effect, options.vertexStreamUsage, options.indexStreamUsage);
				
				var i : uint = 0;
				for each (var localMesh : Mesh in localMeshes)
				{
					localMesh.effectData.setProperty('diffuse', diffuseValue);
					localMesh.name = _name + i++;
					group.addChild(localMesh);
				}
			}
			
			var result : ISceneNode;
			if (group.numChildren == 0)
				return null;
			
			if (group.numChildren == 1)
				result = group[0];
			else
				result = group;
			
			result.name = _name;
			
			if (_sourceId != null)
				sourceIdToSceneNode[_sourceId] = result;
			
			if (_scopedId != null)
				scopedIdToSceneNode[_scopedId] = result;
			
			return result;
		}
		
		private function getDiffuseValueFromMaterialName(materialName : String) : Object
		{
			var diffuseValue	 : Object;
			var materialInstance : InstanceMaterial = 
				materialName != null && materialName != '' ? _bindMaterial[materialName] : null;
			
			if (materialInstance == null)
			{
				Minko.log(DebugLevel.PLUGIN_WARNING, 'ColladaPlugin: "' + materialName + '" is ' +
					'not a valid material name. Fallbacking to pure green');
				
				diffuseValue = new Vector4(0, 1, 0, 1);
			}
			else
				diffuseValue = materialInstance.computeDiffuse();
			
			return diffuseValue;
		}
	}
}
