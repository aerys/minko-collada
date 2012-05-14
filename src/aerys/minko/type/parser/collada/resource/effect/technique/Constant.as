package aerys.minko.type.parser.collada.resource.effect.technique
{
	import aerys.minko.type.parser.collada.resource.effect.CommonColorOrTexture;

	public class Constant implements ITechnique
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _emission			: CommonColorOrTexture;
		private var _reflective			: CommonColorOrTexture;
		private var _reflectivity		: Number;
		private var _transparent		: CommonColorOrTexture;
		private var _transparency		: Number;
		private var _indexOfRefraction	: Number;
		
		public function get emission()			: CommonColorOrTexture	{ return _emission;				}
		public function get reflective()		: CommonColorOrTexture	{ return _reflective;			}
		public function get reflectivity()		: Number				{ return _reflectivity;			}
		public function get transparent()		: CommonColorOrTexture	{ return _transparent;			}
		public function get transparency()		: Number				{ return _transparency;			}
		public function get indexOfRefraction()	: Number				{ return _indexOfRefraction;	}
		
		public static function createFromXML(xml : XML) : Constant
		{
			var constant : Constant = new Constant();

			    constant._emission			= CommonColorOrTexture.createFromXML(xml.NS::emission[0]);
                constant._reflective		= CommonColorOrTexture.createFromXML(xml.NS::reflective[0]);
                constant._reflectivity		= parseFloat(xml.NS::reflectivity[0].NS::float[0]);
                constant._transparent		= CommonColorOrTexture.createFromXML(xml.NS::transparent[0]);
                constant._transparency		= parseFloat(xml.NS::transparency[0].NS::float[0]);
                constant._indexOfRefraction	= parseFloat(xml.NS::index_of_refraction[0].NS::float[0]);

			return constant;
		}
	}
}