package aerys.minko.type.parser.collada.resource.effect
{
	import aerys.minko.type.error.collada.ColladaError;
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
			var firstChild	: XML					= xml.children()[0];
			var element		: CommonColorOrTexture	= new CommonColorOrTexture();
			
			switch (firstChild.localName())
			{
				case 'color':
					var color : Vector4 = NumberListParser.parseVector4(firstChild);
					element._color = ((color.x * 255) << 0) 
						| ((color.y * 255) << 8) 
						| ((color.z * 255) << 16) 
						| ((color.w * 255) << 24)
					
					break;
				
				case 'texture':
					element._textureName	= firstChild.@texture;
					element._textureCoord	= firstChild.@texcoord;
					break;
				
				default: throw new ColladaError('parse error');
			}
			
			return element;
		}
		
		public static function createFromColor(color : uint) : CommonColorOrTexture
		{
			var element : CommonColorOrTexture = new CommonColorOrTexture();
			element._color = color;
			return element;
		}
		
		public function CommonColorOrTexture()
		{
		}
	}
}