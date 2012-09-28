 package aerys.minko.type.parser.collada.resource.effect.technique
{
	import aerys.minko.Minko;
	import aerys.minko.render.material.Material;
	import aerys.minko.render.material.basic.BasicMaterial;
	import aerys.minko.render.material.basic.BasicProperties;
	import aerys.minko.render.resource.texture.TextureResource;
	import aerys.minko.type.log.DebugLevel;
	import aerys.minko.type.math.Vector4;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.resource.effect.CommonColorOrTextureOrParam;

	public class Lambert implements ILightedTechnique
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _emission			: CommonColorOrTextureOrParam;
		private var _ambient			: CommonColorOrTextureOrParam;
		private var _diffuse			: CommonColorOrTextureOrParam;
		private var _reflective			: CommonColorOrTextureOrParam;
		private var _reflectivity		: Number;
		private var _transparent		: CommonColorOrTextureOrParam;
		private var _transparency		: Number;
		private var _indexOfRefraction	: Number;
		
		public function get emission()			: CommonColorOrTextureOrParam	{ return _emission;				}
		public function get ambient()			: CommonColorOrTextureOrParam	{ return _ambient;				}
		public function get diffuse()			: CommonColorOrTextureOrParam	{ return _diffuse;				}
		public function get reflective()		: CommonColorOrTextureOrParam	{ return _reflective;			}
		public function get reflectivity()		: Number						{ return _reflectivity;			}
		public function get transparent()		: CommonColorOrTextureOrParam	{ return _transparent;			}
		public function get transparency()		: Number						{ return _transparency;			}
		public function get indexOfRefraction()	: Number						{ return _indexOfRefraction;	}
		
		public static function createFromXML(xml : XML, document : ColladaDocument) : Lambert
		{
			var lambert : Lambert = new Lambert();
			for each (var child : XML in xml.children())
			{
				var localName : String = child.localName();
				switch (child.localName())
				{
					case 'emission':
						lambert._emission		= CommonColorOrTextureOrParam.createFromXML(xml.NS::emission[0], document);
						break;
					
					case 'ambient':
						lambert._ambient		= CommonColorOrTextureOrParam.createFromXML(xml.NS::ambient[0], document);
						break;
					
					case 'diffuse':
						lambert._diffuse		= CommonColorOrTextureOrParam.createFromXML(xml.NS::diffuse[0], document);
						break;
					
					case 'reflective':
						lambert._reflective		= CommonColorOrTextureOrParam.createFromXML(xml.NS::reflective[0], document);
						break;
					
					case 'reflectivity':
						lambert._reflectivity	= parseFloat(xml.NS::reflectivity[0].NS::float[0]);
						break;
					
					case 'transparent':
						lambert._transparent	= CommonColorOrTextureOrParam.createFromXML(xml.NS::transparent[0], document);
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
		
		public function createMaterial(params : Object, setParams : Object) : Material
		{
			var material		: Material	= new BasicMaterial();
			var diffuseValue	: Object	= _diffuse.getValue(params, setParams);
			
			if (diffuseValue is Vector4)
			{
				material.setProperty(BasicProperties.DIFFUSE_COLOR, diffuseValue);
			}
			else if (diffuseValue is uint)
			{
				material.setProperty(BasicProperties.DIFFUSE_COLOR, diffuseValue);
			}
			else if (diffuseValue is TextureResource)
			{
				material.setProperty(BasicProperties.DIFFUSE_MAP, diffuseValue);
			}
			else
			{
				Minko.log(DebugLevel.PLUGIN_WARNING, 'ColladaPlugin: Could not evaluate Phong in profile_COMMON. ' +
					'It has been replaced by a random color.');
				
				material.setProperty(
					BasicProperties.DIFFUSE_COLOR, 
					(0xFFFFFF * Math.random()) << 8 | 0xFF
				);
			}
			
			return material;
		}
	}
}