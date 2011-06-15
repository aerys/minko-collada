package aerys.minko.type.collada.instance
{
	import aerys.minko.scene.node.skeleton.SkinnedMesh;
	import aerys.minko.type.collada.Document;
	import aerys.minko.type.collada.ressource.IRessource;
	
	public class InstanceController implements IInstance
	{
		private var _document			: Document;
		
		private var _sourceId			: String;
		private var _bindedMaterialId	: String;
		private var _bindedSkeletonId	: String;
		
		public function InstanceController(document			: Document,
										   sourceId			: String,
										   bindedMaterialId : String = null,
										   bindedSkeletonId	: String = null)
		{
			_document			= document;
			_sourceId			= sourceId;
			_bindedMaterialId	= bindedMaterialId;
			_bindedSkeletonId	= bindedSkeletonId;
		}
		
		public static function createFromSourceId(document : Document, 
												  sourceId : String) : InstanceController
		{
			return new InstanceController(document, sourceId);
		}
		
		public static function createFromXML(document	: Document, 
											 xml		: XML) : InstanceController
		{
			throw new Error('Implement me');
		}
		
		public function toSkinnedMesh() : SkinnedMesh 
		{
			throw new Error('Implement me');
		}
		
		public function get ressource() : IRessource
		{
			return _document.getControllerById(_sourceId);
		}
	}
}
