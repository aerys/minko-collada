package aerys.minko.type.parser.collada.resource.effect.technique
{
	import aerys.minko.Minko;
	import aerys.minko.render.effect.basic.BasicProperties;
	import aerys.minko.render.resource.texture.TextureResource;
	import aerys.minko.type.data.DataProvider;
	import aerys.minko.type.log.DebugLevel;
	import aerys.minko.type.math.Vector4;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.resource.effect.CommonColorOrTextureOrParam;

	public class Phong implements ILightedTechnique
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _document			: ColladaDocument;
		
		private var _emission			: CommonColorOrTextureOrParam;
		private var _ambient			: CommonColorOrTextureOrParam;
		private var _diffuse			: CommonColorOrTextureOrParam;
		private var _specular			: CommonColorOrTextureOrParam;
		private var _shininess			: Number;
		private var _reflective			: CommonColorOrTextureOrParam;
		private var _reflectivity		: Number;
		private var _transparent		: CommonColorOrTextureOrParam;
		private var _transparency		: Number;
		private var _indexOfRefraction	: Number;
		
		public function get emission()			: CommonColorOrTextureOrParam	{ return _emission;				}
		public function get ambient()			: CommonColorOrTextureOrParam	{ return _ambient;				}
		public function get diffuse()			: CommonColorOrTextureOrParam	{ return _diffuse;				}
		public function get specular()			: CommonColorOrTextureOrParam	{ return _specular;				}
		public function get shininess()			: Number				{ return _shininess;			}
		public function get reflective()		: CommonColorOrTextureOrParam	{ return _reflective;			}
		public function get reflectivity()		: Number				{ return _reflectivity;			}
		public function get transparent()		: CommonColorOrTextureOrParam	{ return _transparent;			}
		public function get transparency()		: Number				{ return _transparency;			}
		public function get indexOfRefraction()	: Number				{ return _indexOfRefraction;	}
		
		public static function createFromXML(xml : XML, document : ColladaDocument) : Phong
		{
			var emission			: CommonColorOrTextureOrParam	= CommonColorOrTextureOrParam.createFromXML(xml.NS::emission[0], document);
			var ambient				: CommonColorOrTextureOrParam	= CommonColorOrTextureOrParam.createFromXML(xml.NS::ambient[0], document);
			var diffuse				: CommonColorOrTextureOrParam	= CommonColorOrTextureOrParam.createFromXML(xml.NS::diffuse[0], document);
			var specular			: CommonColorOrTextureOrParam	= CommonColorOrTextureOrParam.createFromXML(xml.NS::specular[0], document);
			var shininess			: Number						= parseFloat(xml.NS::shininess[0].NS::float[0]);
			var reflective			: CommonColorOrTextureOrParam	= CommonColorOrTextureOrParam.createFromXML(xml.NS::reflective[0], document);
			var reflectivity		: Number						= parseFloat(xml.NS::reflectivity[0].NS::float[0]);
			var transparent			: CommonColorOrTextureOrParam	= CommonColorOrTextureOrParam.createFromXML(xml.NS::transparent[0], document);
			var transparency		: Number						= parseFloat(xml.NS::transparency[0].NS::float[0]);;
			var indexOfRefraction	: Number						= parseFloat(xml.NS::index_of_refraction[0].NS::float[0]);
			
			return new Phong(emission, ambient, diffuse, specular, shininess, reflective, reflectivity, transparent, transparency, indexOfRefraction, document);
		}
		
		public function Phong(emission			: CommonColorOrTextureOrParam,
							  ambient			: CommonColorOrTextureOrParam,
							  diffuse			: CommonColorOrTextureOrParam,
							  specular			: CommonColorOrTextureOrParam,
							  shininess			: Number,
							  reflective		: CommonColorOrTextureOrParam,
							  reflectivity		: Number,
							  transparent		: CommonColorOrTextureOrParam,
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
			
			_document			= document;
		}
		
		public function createDataProvider(params : Object, setParams : Object) : DataProvider
		{
			var provider		: DataProvider	= new DataProvider();
			var diffuseValue	: Object		= _diffuse.getValue(params, setParams);
			
			if (diffuseValue is Vector4)
			{
				provider.setProperty(BasicProperties.DIFFUSE_COLOR, diffuseValue);
			}
			else if (diffuseValue is TextureResource)
			{
				provider.setProperty(BasicProperties.DIFFUSE_MAP, diffuseValue);
			}
			else
			{
				Minko.log(DebugLevel.PLUGIN_WARNING, 'ColladaPlugin: Could not evaluate Phong in profile_COMMON. ' +
					'It has been replaced by a random color.');
				
				provider.setProperty(
					BasicProperties.DIFFUSE_COLOR, 
					new Vector4(Math.random(), Math.random(), Math.random(), 1)
				);
			}
			
			return provider;
		}
	}
}