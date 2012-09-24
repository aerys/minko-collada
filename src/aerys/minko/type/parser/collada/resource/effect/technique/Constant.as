package aerys.minko.type.parser.collada.resource.effect.technique
{
	import aerys.minko.render.material.Material;
	import aerys.minko.render.material.basic.BasicMaterial;
	import aerys.minko.render.material.basic.BasicProperties;
	import aerys.minko.render.resource.texture.TextureResource;
	import aerys.minko.type.math.Vector4;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.resource.effect.CommonColorOrTextureOrParam;

	public class Constant implements ITechnique
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _emission			: CommonColorOrTextureOrParam;
		private var _reflective			: CommonColorOrTextureOrParam;
		private var _reflectivity		: Number;
		private var _transparent		: CommonColorOrTextureOrParam;
		private var _transparency		: Number;
		private var _indexOfRefraction	: Number;
		
		public function get emission()			: CommonColorOrTextureOrParam	{ return _emission;				}
		public function get reflective()		: CommonColorOrTextureOrParam	{ return _reflective;			}
		public function get reflectivity()		: Number						{ return _reflectivity;			}
		public function get transparent()		: CommonColorOrTextureOrParam	{ return _transparent;			}
		public function get transparency()		: Number						{ return _transparency;			}
		public function get indexOfRefraction()	: Number						{ return _indexOfRefraction;	}
		
		public static function createFromXML(xml : XML, document : ColladaDocument) : Constant
		{
			var constant : Constant = new Constant();
			
			constant._emission			= CommonColorOrTextureOrParam.createFromXML(xml.NS::emission[0], document);
			constant._reflective		= CommonColorOrTextureOrParam.createFromXML(xml.NS::reflective[0], document);
			constant._reflectivity		= parseFloat(xml.NS::reflectivity[0].NS::float[0]);
			constant._transparent		= CommonColorOrTextureOrParam.createFromXML(xml.NS::transparent[0], document);
			constant._transparency		= parseFloat(xml.NS::transparency[0].NS::float[0]);
			constant._indexOfRefraction	= parseFloat(xml.NS::index_of_refraction[0].NS::float[0]);
			
			return constant;
		}
		
		public function createMaterial(params : Object, setParams : Object) : Material
		{
			var material : Material	= new BasicMaterial();
			
			material.setProperty(BasicProperties.DIFFUSE_COLOR, 0xFFFFFFFF);
			
			return material;
		}

	}
}