package aerys.minko.type.collada.ressource.effect.technique
{
	import aerys.minko.render.shader.node.leaf.Constant;
	import aerys.minko.type.collada.store.CommonColorOrTexture;

	public class Constant implements ITechnique
	{
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
			return null;
		}
	}
}