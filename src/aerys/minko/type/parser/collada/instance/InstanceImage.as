package aerys.minko.type.parser.collada.instance
{
	import aerys.minko.scene.node.ISceneNode;
	import aerys.minko.type.error.collada.ColladaError;
	import aerys.minko.type.loader.parser.ParserOptions;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.resource.IResource;
	
	public class InstanceImage implements IInstance
	{
		private var _document	: ColladaDocument;
		private var _sourceId	: String;
		
		public function get sourceId() : String
		{
			return _sourceId;
		}
		
		public function get resource() : IResource
		{
			return _document.getImageById(_sourceId);
		}
		
		public static function createFromXML(xml		: XML, 
											 document	: ColladaDocument) : InstanceImage
		{
			throw new ColladaError('not yet implemented');
		}
		
		public function InstanceImage(sourceId : String, document : ColladaDocument)
		{
			_sourceId = sourceId;
			_document = document;
		}
		
		public function createSceneNode(options				: ParserOptions,
										sourceIdToSceneNode	: Object,
										scopedIdToSceneNode	: Object) : ISceneNode
		{
			throw new Error('Images cannot be mapped to sceneNodes');
		}
	}
}
