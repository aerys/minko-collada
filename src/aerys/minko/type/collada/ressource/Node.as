package aerys.minko.type.collada.ressource
{
	import aerys.minko.scene.node.group.TransformGroup;
	import aerys.minko.scene.node.skeleton.Joint;
	import aerys.minko.type.collada.Document;
	import aerys.minko.type.collada.enum.NodeType;
	import aerys.minko.type.collada.helper.TransformParser;
	import aerys.minko.type.collada.instance.IInstance;
	import aerys.minko.type.collada.instance.InstanceNode;
	import aerys.minko.type.math.Matrix4x4;

	public class Node implements IRessource
	{
		private var _document	: Document;
		
		private var _id			: String;
		private var _sid		: String;
		private var _name		: String;
		private var _transform	: Matrix4x4;
		private var _type		: String;
		
		private var _childs		: Vector.<IInstance>;
		
		public function get id()		: String				{ return _id; }
		public function get sid()		: String				{ return _sid; }
		public function get name()		: String				{ return _name; }
		public function get transform()	: Matrix4x4				{ return _transform; }
		public function get type()		: String				{ return _type; }
		public function get childs()	: Vector.<IInstance>	{ return _childs; }
		
		public function get instance()	: IInstance				{ return new InstanceNode(_document, _id); }
		
		public static function fillStoreFromXML(xmlDocument	: XML,
												document	: Document, 
												store		: Object) : void
		{
			var xmlNodeLibrary	: XML = xmlDocument..library_nodes[0];
			var xmlNodes		: XML = xmlNodeLibrary.node;
			
			for each (var xmlNode : XML in xmlNodes)
			{
				var node : Node = new Node(xmlNodes, document);
				store[node.id] = node;
			}
		}
		
		public function Node(xmlNode : XML, document : Document) 
		{
			_document	= document;
			
			_id			= xmlNode.@id;
			_sid		= xmlNode.@sid;
			_name		= xmlNode.@name;
			
			_transform	= TransformParser.parseTransform(xmlNode);
			_type		= xmlNode.@type;
		}
		
		public function getChildAt(index : uint) : IInstance
		{
			return _childs[index];
		}

		public function toTransformGroup() : TransformGroup
		{
			throw new Error('implement me');
		}
		
		public function toJoint() : Joint
		{
			throw new Error('implement me');
		}
	}
}
