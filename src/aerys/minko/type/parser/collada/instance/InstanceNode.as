package aerys.minko.type.parser.collada.instance
{
	import aerys.minko.Minko;
	import aerys.minko.scene.node.Group;
	import aerys.minko.scene.node.ISceneNode;
	import aerys.minko.type.loader.parser.ParserOptions;
	import aerys.minko.type.log.DebugLevel;
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.resource.IResource;
	import aerys.minko.type.parser.collada.resource.Node;
	
	public class InstanceNode implements IInstance
	{
		private var _document	: ColladaDocument;
		
		private var _sourceId	: String;
		private var _name		: String;
		private var _scopedId	: String;
		
		public function get sourceId() : String
		{
			return _sourceId;
		}
		
		public function get resource() : IResource
		{
			return _document.getNodeById(_sourceId);
		}
		
		public static function createFromXML(document	: ColladaDocument, 
											 xml		: XML) : InstanceNode
		{
			var sourceId	: String = String(xml.@url).substr(1);
			var name		: String = xml.@name;
			var scopedId	: String = xml.@sid;
			
			if (sourceId.length == 0)	sourceId = null;
			if (scopedId.length == 0)	scopedId = null;
			if (name.length == 0)		name = null;
			
			return new InstanceNode(document, sourceId, name, scopedId);
		}
		
		public function InstanceNode(document	: ColladaDocument,
									 sourceId	: String,
									 name		: String = null,
									 scopedId	: String = null)
		{
			_document	= document;
			_sourceId	= sourceId;
			_name		= name;
			_scopedId	= scopedId;
		}
		
		public function createSceneNode(options				: ParserOptions,
										sourceIdToSceneNode	: Object,
										scopedIdToSceneNode	: Object) : ISceneNode
		{
			var nodeResource	: Node					= Node(resource);
			var transform		: Matrix4x4				= nodeResource.transform;
			var childs			: Vector.<IInstance>	= nodeResource.childs;
			var numChilds		: uint					= childs.length;
			
			var group : Group = new Group();
			group.transform.copyFrom(transform);
			
			if (_sourceId != null && _sourceId.length != 0)
				group.name = _sourceId;
			
			for (var childId : uint = 0; childId < numChilds; ++childId)
			{
				var child : ISceneNode = 
					childs[childId].createSceneNode(options, sourceIdToSceneNode, scopedIdToSceneNode);
				
				if (child)
					group.addChild(child);
				else
					Minko.log(DebugLevel.PLUGIN_WARNING, 'Dropping unknown node in group: "' + group.name + '"', this);
			}
			
			if (_sourceId != null) sourceIdToSceneNode[_sourceId] = group;
			if (_scopedId != null) scopedIdToSceneNode[_scopedId] = group;
			
			return group;
		}
	}
}
