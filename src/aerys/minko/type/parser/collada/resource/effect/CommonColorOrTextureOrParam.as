package aerys.minko.type.parser.collada.resource.effect
{
	import aerys.minko.Minko;
	import aerys.minko.type.log.DebugLevel;
	import aerys.minko.type.math.Vector4;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.helper.NumberListParser;
	import aerys.minko.type.parser.collada.resource.effect.data.Sampler2D;
	import aerys.minko.type.parser.collada.resource.effect.data.Surface;
	import aerys.minko.type.parser.collada.resource.image.Image;

	public class CommonColorOrTextureOrParam
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _document		: ColladaDocument;
		
		// if color
		private var _color			: uint;
		
		// if texture
		private var _textureName	: String;
		private var _textureCoord	: String;
		
		// if param
		private var _paramName		: String;
		
		public static function createFromXML(xml : XML, document : ColladaDocument) : CommonColorOrTextureOrParam
		{
			var firstChild		: XML		= xml.children()[0];
			var color			: uint		= 0;
			var textureName		: String	= null;
			var textureCoord	: String	= null;
			var paramRef		: String	= null;
			
			switch (firstChild.localName())
			{
				case 'color':
					var xmlColor : Vector4 = NumberListParser.parseVector4(firstChild);
					color = ((xmlColor.x * 255) << 24) 
						| ((xmlColor.y * 255) << 16) 
						| ((xmlColor.z * 255) << 8) 
						| ((xmlColor.w * 255))
					
					break;
				
				case 'texture':
					textureName		= firstChild.@texture;
					textureCoord	= firstChild.@texcoord;
					break;
				
				case 'param':
					paramRef = String(firstChild.@ref);
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
			
			return new CommonColorOrTextureOrParam(color, textureName, textureCoord, paramRef, document);
		}
		
		public static function createFromColor(color : uint, document : ColladaDocument) : CommonColorOrTextureOrParam
		{
			return new CommonColorOrTextureOrParam(color, null, null, null, document);
		}
		
		public function CommonColorOrTextureOrParam(color			: uint, 
													textureName		: String, 
													textureCoord	: String,
													paramRef		: String,
													document		: ColladaDocument)
		{
			_color			= color;
			_textureName	= textureName;
			_textureCoord	= textureCoord;
			_document		= document;
		}
		
		public function getValue(params : Object, setParams : Object) : Object
		{
			var image : Image;
			
			if (_paramName != null)
			{
				var param : NewParam = params[_paramName];
				
				if (param.data is Sampler2D)
				{
				}
				else if (param.data is Surface)
				{
				}
			}
			else if (_textureName != null)
			{
				if (params[_textureName])
				{
					var sampler2D : Sampler2D = NewParam(params[_textureName]).data as Sampler2D;
					if (params[sampler2D.source])
					{
						var surface : Surface = NewParam(params[sampler2D.source]).data as Surface;
						if (surface)
						{
							image = _document.getImageById(surface.initFrom);
							if (image.imageData.textureResource)
								return image.imageData.textureResource;
						}
					}
				}
				else if (_document.getImageById(_textureName))
				{
					image = _document.getImageById(_textureName);
					if (image.imageData.textureResource)
						return image.imageData.textureResource;
				}
			}
			else
			{
				return _color;
			}
			
			return null;
		}
	}
}