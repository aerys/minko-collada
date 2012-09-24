package aerys.minko.type.parser.collada.instance
{
	import aerys.minko.scene.node.Group;
	import aerys.minko.scene.node.ISceneNode;
	import aerys.minko.type.loader.parser.ParserOptions;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.resource.IResource;
	import aerys.minko.type.parser.collada.resource.VisualScene;
	
	public class InstanceVisualScene implements IInstance
	{
		private var _document	: ColladaDocument;
		
		private var _sourceId	: String;
		private var _name		: String;
		private var _sid		: String;
		
		public function get sourceId() : String
		{
			return _sourceId;
		}
		
		public function get resource() : IResource
		{
			return _document.getVisualSceneById(_sourceId);
		}
		
		public function InstanceVisualScene(document	: ColladaDocument, 
											sourceId	: String,
											name		: String = null,
											sid			: String = null)
		{
			_document	= document;
			_sourceId	= sourceId;
			_name		= name;
			_sid		= sid;
		}
		
		
		public function createSceneNode(options			: ParserOptions,
										idToSceneNode	: Object,
										sidToSceneNode	: Object) : ISceneNode
		{
			var visualScene	: VisualScene	= VisualScene(resource);
			var group		: Group			= new Group();
			
			group.name = _sourceId;
			for each (var childInstance : IInstance in visualScene.childs)
			{
				var child : ISceneNode = childInstance.createSceneNode(options, idToSceneNode, sidToSceneNode);
				if (child)
					group.addChild(child);
				else
					throw new Error();
			}
			
			_sid != '' && (sidToSceneNode[_sid] = group);
			_sourceId != ''	&& (idToSceneNode[_sourceId] = group);
			
			return group;
		}
	}
}