package aerys.minko.type.parser.collada.instance
{
	import aerys.minko.scene.node.IScene;
	import aerys.minko.scene.node.group.Group;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.resource.IResource;
	import aerys.minko.type.parser.collada.resource.VisualScene;
	
	public class InstanceVisualScene implements IInstance
	{
		private var _document	: ColladaDocument;
		
		private var _sourceId	: String;
		private var _name		: String;
		private var _sid		: String;
		
		private var _minkoGroup	: Group;
		
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
		
		public function toScene() : IScene
		{
			return toGroup();
		}
		
		public function toGroup() : Group
		{
			if (!_minkoGroup)
				_minkoGroup = VisualScene(resource).toGroup();
			
			return _minkoGroup;
		}
		
		public function get resource() : IResource
		{
			return _document.getVisualSceneById(_sourceId);
		}
	}
}