package aerys.minko.type.parser.collada.resource.effect.technique
{
	import aerys.minko.type.data.DataProvider;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.resource.effect.CommonColorOrTexture;
	import aerys.minko.type.parser.collada.resource.image.Image;

	public class Phong implements ILightedTechnique
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _emission			: CommonColorOrTexture;
		private var _ambient			: CommonColorOrTexture;
		private var _diffuse			: CommonColorOrTexture;
		private var _specular			: CommonColorOrTexture;
		private var _shininess			: Number;
		private var _reflective			: CommonColorOrTexture;
		private var _reflectivity		: Number;
		private var _transparent		: CommonColorOrTexture;
		private var _transparency		: Number;
		private var _indexOfRefraction	: Number;
		
		public function get emission()			: CommonColorOrTexture	{ return _emission;				}
		public function get ambient()			: CommonColorOrTexture	{ return _ambient;				}
		public function get diffuse()			: CommonColorOrTexture	{ return _diffuse;				}
		public function get specular()			: CommonColorOrTexture	{ return _specular;				}
		public function get shininess()			: Number				{ return _shininess;			}
		public function get reflective()		: CommonColorOrTexture	{ return _reflective;			}
		public function get reflectivity()		: Number				{ return _reflectivity;			}
		public function get transparent()		: CommonColorOrTexture	{ return _transparent;			}
		public function get transparency()		: Number				{ return _transparency;			}
		public function get indexOfRefraction()	: Number				{ return _indexOfRefraction;	}
		
		public static function createFromXML(xml : XML, document : ColladaDocument) : Phong
		{
			var phong : Phong = new Phong();
			
			for each (var child : XML in xml.children())
			{
				var localName : String = child.localName();
				switch (child.localName())
				{
					case 'emission':
						phong._emission		= CommonColorOrTexture.createFromXML(xml.NS::emission[0]);
						break;
					
					case 'ambient':
						phong._ambient		= CommonColorOrTexture.createFromXML(xml.NS::ambient[0]);
						break;
					
					case 'diffuse':
						phong._diffuse		= CommonColorOrTexture.createFromXML(xml.NS::diffuse[0]);
						break;
					
					case 'specular':
						phong._specular		= CommonColorOrTexture.createFromXML(xml.NS::specular[0]);
						break;
					
					case 'shininess':
						phong._shininess	= parseFloat(xml.NS::shininess[0].NS::float[0]);
						break;
					
					case 'reflective':
						phong._reflective	= CommonColorOrTexture.createFromXML(xml.NS::reflective[0]);
						break;
					
					case 'reflectivity':
						phong._reflectivity	= parseFloat(xml.NS::reflectivity[0].NS::float[0]);
						break;
					
					case 'transparent':
						phong._transparent	= CommonColorOrTexture.createFromXML(xml.NS::transparent[0]);
						break;
					
					case 'transparency':
						phong._transparency	= parseFloat(xml.NS::transparency[0].NS::float[0]);
						break;
					
					case 'index_of_refraction':
						phong._indexOfRefraction	= parseFloat(xml.NS::index_of_refraction[0].NS::float[0]);
						break;
				}
			}
			
			return phong;
		}
		
		public function Phong(emission			: CommonColorOrTexture,
							  ambient			: CommonColorOrTexture,
							  diffuse			: CommonColorOrTexture,
							  specular			: CommonColorOrTexture,
							  shininess			: Number,
							  reflective		: CommonColorOrTexture,
							  reflectivity		: Number,
							  transparent		: CommonColorOrTexture,
							  transparency		: Number,
							  indexOfRefraction	: Number,
							  document			: ColladaDocument)
		{
			_emission			= emission;
			_ambient			= ambient;
			_diffuse			= diffuse;
			_specular			= specular;
			_shininess			= shininess;
			_reflective			= reflective;
			_reflectivity		= reflectivity;
			_transparent		= transparent;
			_transparency		= transparency;
			_indexOfRefraction	= indexOfRefraction;
		}
		
		public function createDataProvider(params : Object) : DataProvider
		{
			var provider : DataProvider = new DataProvider();
			
			if (_diffuse.textureName != null)
			{
				var image : Image = _document.getImageById(_diffuse.textureName);
//				
//				// try to find the texture name in the (effect) parameters
//				while (!image && finalParameters.hasOwnProperty(textureName))
//				{
//					var parameterValue : Object = finalParameters[textureName];
//					
//					if (parameterValue is AbstractImageData)
//						textureName = (parameterValue as AbstractImageData).path;
//					else
//						textureName = parameterValue as String;
//					
//					image = _document.getImageById(textureName);
//				}
//				
//				if (image && image.imageData.textureResource)
//					return image.imageData.textureResource;
//				else
//				{
//					Minko.log(DebugLevel.PLUGIN_WARNING, 'ColladaPlugin: The texture '
//						+ image.name + ' could not be loaded. It has beed replaced' +
//						' by a random color.');
//					
//					return new Vector4(Math.random(), Math.random(), Math.random(), 1);
//				}
			}
			else
			{
				provider.diffuseColor = _diffuse.color;
			}
			
			return provider;
		}
	}
}