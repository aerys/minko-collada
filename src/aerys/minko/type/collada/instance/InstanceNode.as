package aerys.minko.type.collada.instance
{
	import aerys.minko.scene.node.group.TransformGroup;
	import aerys.minko.scene.node.skeleton.Joint;
	import aerys.minko.type.collada.Document;
	import aerys.minko.type.collada.ressource.IRessource;
	
	public class InstanceNode implements IInstance
	{
		private var _document : Document;
		private var _sourceId : String;
		private var _scopedId : String;
		
		public function InstanceNode(document	: Document,
									 sourceId	: String,
									 scopedId	: String = null)
		{
			_document = document;
			_sourceId = sourceId;
			_scopedId = scopedId
		}
		
		public static function createFromXML(document	: Document, 
											 xml		: XML) : InstanceNode
		{
			throw new Error('implement me');
		}
		
		public static function createFromSourceId(document	: Document, 
												  sourceId	: String) : InstanceNode
		{
			return new InstanceNode(document, sourceId);
		}
		
		public function toTransformGroup() : TransformGroup
		{
			throw new Error('implement me');
		}
		
		public function toJoint() : Joint
		{
			throw new Error('implement me');
		}
		
		public function get ressource() : IRessource
		{
			return null;
		}
	}
}