package aerys.minko.type.collada.instance
{
	import aerys.minko.scene.node.IScene;
	import aerys.minko.type.collada.Document;
	import aerys.minko.type.collada.ressource.IRessource;
	
	public class InstanceImage implements IInstance
	{
		private var _document	: Document;
		private var _sourceId	: String;
		
		public static function createFromXML(xml		: XML, 
											 document	: Document) : InstanceImage
		{
			throw new Error('not yet implemented');
		}
		
		public static function createFromSourceId(sourceId	: String, 
												  document	: Document) : InstanceImage
		{
			var im : InstanceImage = new InstanceImage();
			im._document = document;
			im._sourceId = sourceId;
			return im;
		}
		
		public function get ressource() : IRessource
		{
			return _document.getImageById(_sourceId);
		}
		
		public function toScene():IScene
		{
			return null;
		}
	}
}