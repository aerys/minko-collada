package aerys.minko.type.parser.collada.instance
{
	import aerys.minko.Minko;
	import aerys.minko.ns.minko_collada;
	import aerys.minko.render.effect.Effect;
	import aerys.minko.scene.node.Group;
	import aerys.minko.scene.node.ISceneNode;
	import aerys.minko.scene.node.mesh.Mesh;
	import aerys.minko.type.loader.parser.ParserOptions;
	import aerys.minko.type.log.DebugLevel;
	import aerys.minko.type.math.Vector4;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.helper.MeshTemplate;
	import aerys.minko.type.parser.collada.resource.Geometry;
	import aerys.minko.type.parser.collada.resource.IResource;
	
	public class InstanceGeometry implements IInstance
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		use namespace minko_collada;
		
		private var _document		: ColladaDocument;
		private var _sourceId		: String;
		private var _scopedId		: String;
		private var _name			: String;
		private var _bindMaterial	: Object;
		
		private var _scene			: ISceneNode;
		
		public function get sourceId() : String
		{
			return _sourceId;
		}
		
		public function get resource() : IResource
		{
			return _document.getGeometryById(_sourceId);
		}
		
		public static function createFromXML(document	: ColladaDocument,
											 xml		: XML) : InstanceGeometry
		{
			var sourceId	: String = String(xml.@url).substr(1);
			var name		: String = xml.@name;
			var sid			: String = xml.@sid;
			
			var bindMaterial : Object = new Object();
			for each (var xmlIm : XML in xml..NS::instance_material)
			{
				var instanceMaterial : InstanceMaterial = InstanceMaterial.createFromXML(xmlIm, document);
				
				bindMaterial[instanceMaterial.symbol] = instanceMaterial;
			}
			
			return new InstanceGeometry(document, sourceId, bindMaterial, name, sid);
		}
		
		public function InstanceGeometry(document		: ColladaDocument,
										 sourceId		: String,
										 bindMaterial	: Object = null,
										 name			: String = null,
										 scopedId		: String = null)
		{
			_document		= document;
			_sourceId		= sourceId;
			_name			= name;
			_scopedId		= scopedId;
			_bindMaterial	= bindMaterial;
		}
		
		public function createSceneNode(options				: ParserOptions,
										sourceIdToSceneNode	: Object,
										scopedIdToSceneNode	: Object) : ISceneNode
		{
			var geometry			: Geometry				= Geometry(resource);
			geometry.computeMeshTemplates(options);
			
			var effect				: Effect				= options.effect;
			var subMeshTemplates	: Vector.<MeshTemplate>	= geometry.meshTemplates;
			var numMeshes			: uint					= subMeshTemplates != null ? subMeshTemplates.length : 0;
			var group				: Group					= new Group();
			
			for (var meshTemplateId : uint = 0; meshTemplateId < numMeshes; ++meshTemplateId)
			{
				var meshTemplate : MeshTemplate = subMeshTemplates[meshTemplateId];
				
				var diffuseValue : Object = 
					getDiffuseValueFromMaterialName(meshTemplate.materialName);
				
				var localMeshes : Vector.<Mesh> = 
					meshTemplate.generateMeshes(effect, options.vertexStreamUsage, options.indexStreamUsage);
				
				var i : uint = 0;
				for each (var localMesh : Mesh in localMeshes)
				{
					if (diffuseValue is Vector4)
						localMesh.bindings.setProperty('diffuse color', diffuseValue);
					else
						localMesh.bindings.setProperty('diffuse map', diffuseValue);
					
					localMesh.name = _sourceId + '_' + meshTemplateId + '_' + i;
					
					group.addChild(localMesh);
					
					++i;
				}
			}
			
			if (group.numChildren == 0)
				return null;
			
			var result : ISceneNode;
			if (group.numChildren == 1)
				result = group[0];
			else
				result = group;
			
			result.name = _sourceId;
			
			if (_scopedId != null)
				scopedIdToSceneNode[_scopedId] = result;
			
			if (_sourceId != null)
				sourceIdToSceneNode[_sourceId] = result;
			
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
					'not a valid material name. Fallbacking to random color');
				
				diffuseValue = new Vector4(Math.random(), Math.random(), Math.random(), 1);
			}
			else
				diffuseValue = materialInstance.computeDiffuse();
			
			return diffuseValue;
		}
	}
}
