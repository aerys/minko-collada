package aerys.minko.type.collada.instance
{
	import aerys.minko.scene.node.IScene;
	import aerys.minko.scene.node.group.TransformGroup;
	import aerys.minko.scene.node.skeleton.Joint;
	import aerys.minko.type.collada.Document;
	import aerys.minko.type.collada.ressource.IRessource;
	import aerys.minko.type.collada.ressource.Node;
	
	public class InstanceNode implements IInstance
	{
		private var _document	: Document;
		
		private var _id			: String;
		private var _name		: String;
		private var _scopedId	: String;
		
		public function InstanceNode(document	: Document,
									 sourceId	: String,
									 name		: String = null,
									 scopedId	: String = null)
		{
			_document	= document;
			_id			= sourceId;
			_name		= name;
			_scopedId	= scopedId
		}
		
		public static function createFromXML(document	: Document, 
											 xml		: XML) : InstanceNode
		{
			var sid			: String = xml.@sid;
			var name		: String = xml.@name;
			var sourceId	: String = String(xml.@url).substr(1);
			
			return new InstanceNode(document, sourceId, name, sid);
		}
		
		public static function createFromSourceId(document	: Document, 
												  sourceId	: String) : InstanceNode
		{
			return new InstanceNode(document, sourceId);
		}
		
		public function toScene() : IScene
		{
			return toTransformGroup();
		}
		
		public function toTransformGroup() : TransformGroup
		{
			return Node(ressource).toTransformGroup();
		}
		
		public function toJoint() : Joint
		{
			return Node(ressource).toJoint();
		}
		
		public function get ressource() : IRessource
		{
			return _document.getNodeById(_id);
		}
	}
}