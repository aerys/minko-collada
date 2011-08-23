package aerys.minko.type.parser.collada.instance
{
	import aerys.minko.scene.node.IScene;
	import aerys.minko.scene.node.group.Joint;
	import aerys.minko.scene.node.group.TransformGroup;
	import aerys.minko.type.error.collada.ColladaError;
	import aerys.minko.type.parser.collada.Document;
	import aerys.minko.type.parser.collada.enum.NodeType;
	import aerys.minko.type.parser.collada.resource.IResource;
	import aerys.minko.type.parser.collada.resource.Node;
	
	public class InstanceNode implements IInstance
	{
		private var _document	: Document;
		
		private var _id			: String;
		private var _name		: String;
		private var _scopedId	: String;
		
		private var _minkoScene	: IScene;
		
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
			switch (Node(resource).type)
			{
				case NodeType.NODE:		return toTransformGroup();
				case NodeType.JOINT:	return toJoint();
				default: throw new ColladaError('Unknown node type ' + Node(resource).type);
			}
		}
		
		public function toTransformGroup() : TransformGroup
		{
			if (!_minkoScene)
				_minkoScene = Node(resource).toTransformGroup();
			
			return TransformGroup(_minkoScene);
		}
		
		public function toJoint() : Joint
		{
			if (!_minkoScene)
				_minkoScene = Node(resource).toJoint();
			
			return Joint(_minkoScene);
		}
		
		public function get resource() : IResource
		{
			return _document.getNodeById(_id);
		}
	}
}