package aerys.minko.type.parser.collada.instance
{
	import aerys.minko.Minko;
	import aerys.minko.ns.minko_collada;
	import aerys.minko.render.Effect;
	import aerys.minko.render.material.Material;
	import aerys.minko.scene.node.Group;
	import aerys.minko.scene.node.ISceneNode;
	import aerys.minko.scene.node.Mesh;
	import aerys.minko.type.loader.parser.ParserOptions;
	import aerys.minko.type.log.DebugLevel;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.helper.MeshTemplate;
	import aerys.minko.type.parser.collada.resource.ColladaMaterial;
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
			
			try
			{
				geometry.computeMeshTemplates(options);
			}
			catch (e : Error)
			{
				Minko.log(
					DebugLevel.PLUGIN_ERROR,
					'ColladaPlugin: Error evaluating geometry node \'' + _name + '\'.'
				);
			}
			
			var group				: Group					= new Group();
			var effect				: Effect				= options.effect;
			var subMeshTemplates	: Vector.<MeshTemplate>	= geometry.meshTemplates;
			var numMeshes			: uint					= subMeshTemplates != null
				? subMeshTemplates.length
				: 0;
			
			for (var meshTemplateId : uint = 0; meshTemplateId < numMeshes; ++meshTemplateId)
			{
				var meshTemplate : MeshTemplate = subMeshTemplates[meshTemplateId];
				
				if (meshTemplate.indexData.length != 0)
				{
					var localMeshes : Vector.<Mesh> = meshTemplate.generateMeshes(
						effect, options.vertexStreamUsage, options.indexStreamUsage
					);
					
					var i : uint = 0;
					for each (var localMesh : Mesh in localMeshes)
					{
						localMesh.material = getMaterial(meshTemplate.materialName);
						
						if (options.effect)
							localMesh.material.effect = options.effect;
						
						localMesh.name = _sourceId + '_' + meshTemplateId + '_' + i;
						
						group.addChild(localMesh);
						
						++i;
					}
				}
			}
			
			var result : ISceneNode = sanitize(group);
			
			if (_scopedId != null)	scopedIdToSceneNode[_scopedId] = result;
			if (_sourceId != null)	sourceIdToSceneNode[_sourceId] = result;
			
			return result;
		}
		
		private function sanitize(group : Group) : ISceneNode
		{
			var result : ISceneNode;
			
			if (group.numChildren == 0)
				return null;
			else if (group.numChildren == 1)
				result = group.getChildAt(0);
			else
				result = group;
			
			if (_sourceId != null && _sourceId.length != 0)
				result.name = _sourceId;
			
			return result;
		}
		
		private function getMaterial(materialName : String) : Material
		{
			if (materialName == null || materialName == '')
				return ColladaMaterial.DEFAULT_MATERIAL;
			else
			{
				var materialInstance : InstanceMaterial = _bindMaterial[materialName];
				
				return materialInstance != null ? 
					ColladaMaterial(materialInstance.resource).material :
					ColladaMaterial.DEFAULT_MATERIAL;
			}
		}
	}
}
