package aerys.minko.type.collada.ressource.effect.technique
{
	import aerys.minko.type.collada.store.CommonColorOrTexture;

	public class Lambert implements ILightedTechnique
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _emission			: CommonColorOrTexture;
		private var _ambient			: CommonColorOrTexture;
		private var _diffuse			: CommonColorOrTexture;
		private var _reflective			: CommonColorOrTexture;
		private var _reflectivity		: Number;
		private var _transparent		: CommonColorOrTexture;
		private var _transparency		: Number;
		private var _indexOfRefraction	: Number;
		
		public function get emission()			: CommonColorOrTexture	{ return _emission;				}
		public function get ambient()			: CommonColorOrTexture	{ return _ambient;				}
		public function get diffuse()			: CommonColorOrTexture	{ return _diffuse;				}
		public function get reflective()		: CommonColorOrTexture	{ return _reflective;			}
		public function get reflectivity()		: Number				{ return _reflectivity;			}
		public function get transparent()		: CommonColorOrTexture	{ return _transparent;			}
		public function get transparency()		: Number				{ return _transparency;			}
		public function get indexOfRefraction()	: Number				{ return _indexOfRefraction;	}
		
		public static function createFromXML(xml : XML) : Lambert
		{
			var lambert : Lambert = new Lambert();
			lambert._emission			= CommonColorOrTexture.createFromXML(xml.NS::emission[0]);
			lambert._ambient			= CommonColorOrTexture.createFromXML(xml.NS::ambient[0]);
			lambert._diffuse			= CommonColorOrTexture.createFromXML(xml.NS::diffuse[0]);
			lambert._reflective			= CommonColorOrTexture.createFromXML(xml.NS::reflective[0]);
			lambert._reflectivity		= parseFloat(xml.NS::reflectivity[0].NS::float[0]);
			lambert._transparent		= CommonColorOrTexture.createFromXML(xml.NS::transparent[0]);
			lambert._transparency		= parseFloat(xml.NS::transparency[0].NS::float[0]);
			lambert._indexOfRefraction	= parseFloat(xml.NS::index_of_refraction[0].NS::float[0]);
			
			return lambert;
		}
	}
}