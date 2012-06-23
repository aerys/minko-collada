package aerys.minko.type.parser.collada.resource.effect.technique
{
	import aerys.minko.type.data.DataProvider;
	import aerys.minko.type.parser.collada.resource.effect.CommonColorOrTexture;

	public class Blinn implements ILightedTechnique
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _defaultProvider	: DataProvider;
		
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
		
		public static function createFromXML(xml : XML) : Blinn
		{
			var emission			: CommonColorOrTexture;
			var ambient				: CommonColorOrTexture;
			var diffuse				: CommonColorOrTexture;
			var specular			: CommonColorOrTexture;
			var shininess			: Number;
			var reflective			: CommonColorOrTexture;
			var reflectivity		: Number;
			var transparent			: CommonColorOrTexture;
			var transparency		: Number;
			var indexOfRefraction	: Number;
			
			for each (var child : XML in xml.children())
			{
				var localName : String = child.localName();
				switch (child.localName())
				{
					case 'emission':			emission			= CommonColorOrTexture.createFromXML(xml.NS::emission[0]);		break;
					case 'ambient':				ambient				= CommonColorOrTexture.createFromXML(xml.NS::ambient[0]);		break;
					case 'diffuse':				diffuse				= CommonColorOrTexture.createFromXML(xml.NS::diffuse[0]);		break;
					case 'specular':			specular			= CommonColorOrTexture.createFromXML(xml.NS::specular[0]);		break;
					case 'shininess':			shininess			= parseFloat(xml.NS::shininess[0].NS::float[0]);				break;
					case 'reflective':			reflective			= CommonColorOrTexture.createFromXML(xml.NS::reflective[0]);	break;
					case 'reflectivity':		reflectivity		= parseFloat(xml.NS::reflectivity[0].NS::float[0]);				break;
					case 'transparent':			transparent			= CommonColorOrTexture.createFromXML(xml.NS::transparent[0]);	break;
					case 'transparency':		transparency		= parseFloat(xml.NS::transparency[0].NS::float[0]);				break;
					case 'index_of_refraction':	indexOfRefraction	= parseFloat(xml.NS::index_of_refraction[0].NS::float[0]);		break;
				}
			}
			
			return new Blinn(emission, ambient, diffuse, specular, shininess, reflective, reflectivity, transparent, transparency, indexOfRefraction);
		}
		
		public function Blinn(emission			: CommonColorOrTexture,
							  ambient			: CommonColorOrTexture,
							  diffuse			: CommonColorOrTexture,
							  specular			: CommonColorOrTexture,
							  shininess			: Number,
							  reflective		: CommonColorOrTexture,
							  reflectivity		: Number,
							  transparent		: CommonColorOrTexture,
							  transparency		: Number,
							  indexOfRefraction	: Number)
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
			// ugly, please read: if (params.numElements > 0)
			for each (var _ : String in params) 
			{
				var provider : DataProvider = DataProvider(_defaultProvider.clone());
				
				for each (var paramName : String in params)
				{
					trace(paramName, params[paramName])
				}
				
				return provider;
			}
			
			return _defaultProvider;
		}

	}
}
