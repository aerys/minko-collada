 package aerys.minko.type.parser.collada.resource.effect.technique
{
	import aerys.minko.type.data.DataProvider;
	import aerys.minko.type.parser.collada.resource.effect.CommonColorOrTexture;

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
			for each (var child : XML in xml.children())
			{
				var localName : String = child.localName();
				switch (child.localName())
				{
					case 'emission':
						lambert._emission		= CommonColorOrTexture.createFromXML(xml.NS::emission[0]);
						break;
					
					case 'ambient':
						lambert._ambient		= CommonColorOrTexture.createFromXML(xml.NS::ambient[0]);
						break;
					
					case 'diffuse':
						lambert._diffuse		= CommonColorOrTexture.createFromXML(xml.NS::diffuse[0]);
						break;
					
					case 'reflective':
						lambert._reflective	= CommonColorOrTexture.createFromXML(xml.NS::reflective[0]);
						break;
					
					case 'reflectivity':
						lambert._reflectivity	= parseFloat(xml.NS::reflectivity[0].NS::float[0]);
						break;
					
					case 'transparent':
						lambert._transparent	= CommonColorOrTexture.createFromXML(xml.NS::transparent[0]);
						break;
					
					case 'transparency':
						lambert._transparency	= parseFloat(xml.NS::transparency[0].NS::float[0]);
						break;
					
					case 'index_of_refraction':
						lambert._indexOfRefraction	= parseFloat(xml.NS::index_of_refraction[0].NS::float[0]);
						break;
				}
			}
			return lambert;
		}
		
		public function createDataProvider(params : Object) : DataProvider
		{
			throw new Error();
		}
	}
}