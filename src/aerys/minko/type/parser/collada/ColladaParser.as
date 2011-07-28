package aerys.minko.type.parser.collada
{
	import aerys.minko.scene.node.IScene;
	import aerys.minko.type.parser.IParser;
	
	import flash.utils.ByteArray;
	
	public class ColladaParser implements IParser
	{
		public static const DROP_EMPTY_GROUPS	: uint = 1;
		public static const DROP_SKINNING		: uint = 2;
		
		private var _flags		: uint;
		private var _textures	: Object;
		private var _data		: Vector.<IScene>;
		
		public function get data() : Vector.<IScene> { return _data; }
		
		public function ColladaParser(flags		: uint		= 0,
									  textures	: Object	= null)
		{
			_flags		= flags;
			_textures	= textures;
			_data		= new Vector.<IScene>();
		}
		
		public function parse(data : ByteArray) : Boolean
		{
			var xmlDocument			: XML		= null;
			var localName			: String	= null;
			
			try {
				data.position = 0;
				
				xmlDocument = new XML(data.readUTFBytes(data.length));
				if (!xmlDocument)
					return false;
				
				localName = xmlDocument.localName();
				
				if (localName.toLowerCase() != 'collada')
					return false;
			}
			catch (e : Error)
			{
				return false;
			}
			
			var dropEmptyGroups : Boolean	= (_flags & DROP_EMPTY_GROUPS) != 0;
			var dropSkinning	: Boolean	= (_flags & DROP_SKINNING) != 0;
			var document		: Document	= new Document();
			document.loadXML(xmlDocument, _textures);
			
			_data.push(document.toGroup(dropEmptyGroups, dropSkinning));
			
			return true;
		}
	}
}
