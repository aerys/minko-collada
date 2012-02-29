package aerys.minko.type.parser.collada.resource.effect
{
	import aerys.minko.Minko;
	import aerys.minko.type.log.DebugLevel;
	import aerys.minko.type.math.Vector4;
	import aerys.minko.type.parser.collada.helper.NumberListParser;

	public class CommonColorOrTexture
	{
		private var _color			: uint;
		private var _textureName	: String;
		private var _textureCoord	: String;
		
		public function get color()			: uint		{ return _color;		}
		public function get textureName()	: String	{ return _textureName;	}
		public function get textureCoord()	: String	{ return _textureCoord;	}
		
		public static function createFromXML(xml : XML) : CommonColorOrTexture
		{
			var firstChild		: XML					= xml.children()[0];
			
			var color			: uint					= 0;
			var textureName		: String				= null;
			var textureCoord	: String				= null;
			
			switch (firstChild.localName())
			{
				case 'color':
					var xmlColor : Vector4 = NumberListParser.parseVector4(firstChild);
					color = ((xmlColor.x * 255) << 0) 
						| ((xmlColor.y * 255) << 8) 
						| ((xmlColor.z * 255) << 16) 
						| ((xmlColor.w * 255) << 24)
					
					break;
				
				case 'texture':
					textureName	= firstChild.@texture;
					textureCoord	= firstChild.@texcoord;
					break;
				
				default:
					Minko.log(DebugLevel.PLUGIN_WARNING, 'ColladaPlugin: CommonColorOrTexture' +
						'is neither a color or a texture in XML feed. Fallbacking to a random color.');
					
					color = 0xff000000
						| (uint(Math.random() * 255) << 16)
						| (uint(Math.random() * 255) << 8)
						| uint(Math.random() * 255);
						
					break;
			}
			
			return new CommonColorOrTexture(color, textureName, textureCoord);
		}
		
		public static function createFromColor(color : uint) : CommonColorOrTexture
		{
			return new CommonColorOrTexture(color, null, null);
		}
		
		public function CommonColorOrTexture(color			: uint, 
											 textureName	: String, 
											 textureCoord	: String)
		{
			_color			= color;
			_textureName	= textureName;
			_textureCoord	= textureCoord;
		}
	}
}