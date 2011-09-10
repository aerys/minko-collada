package aerys.minko.type.parser.collada.resource
{
	import aerys.minko.ns.minko_collada;
	import aerys.minko.scene.node.IScene;
	import aerys.minko.scene.node.group.Joint;
	import aerys.minko.scene.node.group.TransformGroup;
	import aerys.minko.type.error.collada.ColladaError;
	import aerys.minko.type.math.Matrix3D;
	import aerys.minko.type.math.Vector4;
	import aerys.minko.type.parser.collada.Document;
	import aerys.minko.type.parser.collada.enum.NodeType;
	import aerys.minko.type.parser.collada.helper.TransformParser;
	import aerys.minko.type.parser.collada.instance.IInstance;
	import aerys.minko.type.parser.collada.instance.InstanceController;
	import aerys.minko.type.parser.collada.instance.InstanceGeometry;
	import aerys.minko.type.parser.collada.instance.InstanceNode;

	use namespace minko_collada;
	
	public class Node implements IResource
	{
		private static const NS	: Namespace = 
			new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _document	: Document;
		
		private var _id			: String;
		private var _sid		: String;
		private var _name		: String;
		private var _transform	: Matrix3D;
		private var _type		: String;
		
		private var _childs		: Vector.<IInstance>;
		
		public function get id()		: String				{ return _id; }
		public function get sid()		: String				{ return _sid; }
		public function get name()		: String				{ return _name; }
		public function get transform()	: Matrix3D				{ return _transform; }
		public function get type()		: String				{ return _type; }
		public function get childs()	: Vector.<IInstance>	{ return _childs; }
		
		public static function fillStoreFromXML(xmlDocument	: XML,
												document	: Document, 
												store		: Object) : void
		{
			var xmlNodeLibrary	: XML		= xmlDocument..NS::library_nodes[0];
			if (xmlNodeLibrary == null)
				return;
			
			var xmlNodes		: XMLList	= xmlNodeLibrary.NS::node;
			
			for each (var xmlNode : XML in xmlNodes)
			{
				var node : Node = new Node(xmlNode, document);
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
			
			_type		= String(xmlNode.@type).toUpperCase();
			if (_type.length == 0)
				_type = NodeType.NODE;
			
			_childs		= new Vector.<IInstance>();
			for each (var child : XML in xmlNode.children())
			{
				
				var localName : String = child.localName();
				
				if (localName == 'node')
					_childs.push(document.delegateResourceCreation(child));
					
				else if (localName == 'instance_camera')
					0; // do nothing
					
				else if (localName == 'instance_controller')
					_childs.push(InstanceController.createFromXML(document, child));
				
				else if (localName == 'instance_geometry')
					_childs.push(InstanceGeometry.createFromXML(document, child));
				
				else if (localName == 'instance_light')
					0; // do nothing
				
				else if (localName == 'instance_node')
					_childs.push(InstanceNode.createFromXML(document, child));
			}
		}
		
		public function getChildAt(index : uint) : IInstance
		{
			return _childs[index];
		}
		
		public function createInstance() : IInstance				
		{
			return new InstanceNode(_document, _id); 
		}
		
		/**
		 * to be fixed
		 * child.toScene will instanciate every time a new minko object
		 * 
		 * what happens for a scene with many times the same mesh?
		 * 
		 * @return 
		 */		
		public function toTransformGroup() : TransformGroup
		{
			if (_type != NodeType.NODE)
				throw new ColladaError('Cannot convert joint node to TransformGroup');
			
			var tf : TransformGroup = new TransformGroup();
			tf.name = _id;
			
			Matrix3D.copy(_transform, tf.transform);
			tf.transform.appendScale(1);				// used to invalidate the matrix
			
			for each (var child : IInstance in _childs)
			{
				var minkoChild : IScene = child.toScene();
				if (minkoChild != null)
					tf.addChild(minkoChild);
			}
			
			return tf;
		}
		
		public function toJoint() : Joint
		{
			if (_type != NodeType.JOINT)
				throw new ColladaError('Cannot convert standard node to joint');
			
			var joint : Joint = new Joint();
			joint.name = _id;
			joint.boneName = _sid && _sid.length != 0 ? _sid : _id;
			
			Matrix3D.copy(_transform, joint.transform);
			joint.transform.appendScale(1);				// used to invalidate the matrix
			
			for each (var child : IInstance in _childs)
			{
				var minkoChild : IScene = child.toScene();
				if (minkoChild != null)
					joint.addChild(minkoChild);
			}
			
			return joint;
		}
	}
}
