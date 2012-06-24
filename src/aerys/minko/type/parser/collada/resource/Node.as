package aerys.minko.type.parser.collada.resource
{
	import aerys.minko.Minko;
	import aerys.minko.ns.minko_collada;
	import aerys.minko.type.log.DebugLevel;
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.parser.collada.ColladaDocument;
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
		
		private var _document	: ColladaDocument;
		
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
		
		public static function fillStoreFromXML(xmlDocument	: XML,
												document	: ColladaDocument, 
												store		: Object) : void
		{
			var xmlNodeLibrary : XML = xmlDocument..NS::library_nodes[0];
			if (xmlNodeLibrary == null)
				return;
			
			var xmlNodes : XMLList = xmlNodeLibrary.NS::node;
			for each (var xmlNode : XML in xmlNodes)
			{
				var node : Node = Node.createFromXML(xmlNode, document);
				store[node.id] = node;
			}
		}
		
		public static function createFromXML(xmlNode : XML, document : ColladaDocument) : Node
		{
			var id			: String	= xmlNode.@id;
			var sid			: String	= xmlNode.@sid;
			var name		: String	= xmlNode.@name;
			var transform	: Matrix4x4	= TransformParser.parseTransform(xmlNode);
			
			if (id != null && id.length == 0)
				id = null;
			
			if (sid != null && sid.length == 0)
				sid = null;
			
			if (name != null && name.length == 0)
				name = null;
			
			var type : String = String(xmlNode.@type).toUpperCase();
			if (type.length == 0)
				type = NodeType.NODE;
			
			var childs : Vector.<IInstance> = new Vector.<IInstance>();
			for each (var child : XML in xmlNode.children())
			{
				switch (child.localName())
				{
					case 'node':
						childs.push(document.delegateResourceCreation(child));
						break;
					
					case 'instance_controller':
						childs.push(InstanceController.createFromXML(document, child));
						break;
					
					case 'instance_geometry':
						childs.push(InstanceGeometry.createFromXML(document, child));
						break;
					
					case 'instance_node':
						childs.push(InstanceNode.createFromXML(document, child));
					
					case 'instance_camera':
					case 'instance_light':
						Minko.log(DebugLevel.PLUGIN_NOTICE, 'ColladaPlugin: Dropping ' + 
							child.localName() + ' declaration in node ' + [id, sid, name].join());
						break;
					
					// ignore transformation, it's parsed in a helper function
					case 'lookat':
					case 'matrix':
					case 'rotate':
					case 'scale':
					case 'skew':
					case 'translate':
					case 'extra':
						break;
					
					default:
						Minko.log(DebugLevel.PLUGIN_WARNING, 'ColladaPlugin: Found unknown ' + 
							child.localName() + ' declaration in node ' + [id, sid, name].join());
						break;
					
				}
			}
			
			return new Node(id, sid, name, transform, type, childs, document);
		}
		
		public function Node(id			: String, 
							 sid		: String, 
							 name		: String, 
							 transform	: Matrix4x4, 
							 type		: String, 
							 childs		: Vector.<IInstance>,
							 document	: ColladaDocument)
		{
			_id			= id;
			_sid		= sid;
			_name		= name;
			_transform	= transform;
			_type		= type;
			_childs		= childs;
			_document	= document;
		}
		
		public function getChildAt(index : uint) : IInstance
		{
			return _childs[index];
		}
		
		public function createInstance() : IInstance				
		{
			return new InstanceNode(_document, _id, _name, _sid); 
		}
		
	}
}
