package aerys.minko.type.parser.collada.resource.effect.technique
{
	import aerys.minko.Minko;
	import aerys.minko.render.material.Material;
	import aerys.minko.render.material.basic.BasicMaterial;
	import aerys.minko.render.material.basic.BasicProperties;
	import aerys.minko.render.material.environment.EnvironmentMappingProperties;
	import aerys.minko.render.material.phong.PhongProperties;
	import aerys.minko.render.resource.texture.TextureResource;
	import aerys.minko.type.enum.EnvironmentMappingType;
	import aerys.minko.type.loader.parser.ParserOptions;
	import aerys.minko.type.log.DebugLevel;
	import aerys.minko.type.math.Vector4;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.resource.effect.CommonColorOrTextureOrParam;

	public class PhongTechnique implements ILightingTechnique
	{
		private static const NS : Namespace = new Namespace('http://www.collada.org/2005/11/COLLADASchema');
		
		private var _document			: ColladaDocument;
        
        private var _material           : Material;
		
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
        
        private var _normalMap          : CommonColorOrTextureOrParam;
        
		public function get emission() : CommonColorOrTextureOrParam
        {
            return _emission;
        }
		public function get ambient() : CommonColorOrTextureOrParam
        {
            return _ambient;
        }
		public function get diffuse() : CommonColorOrTextureOrParam
        {
            return _diffuse;
        }
		public function get specular() : CommonColorOrTextureOrParam
        {
            return _specular;
        }
		public function get shininess() : Number
        {
            return _shininess;
        }
		public function get reflective() : CommonColorOrTextureOrParam
        {
            return _reflective;
        }
		public function get reflectivity() : Number
        {
            return _reflectivity;
        }
		public function get transparent() : CommonColorOrTextureOrParam
        {
            return _transparent;
        }
		public function get transparency() : Number
        {
            return _transparency;
        }
		public function get indexOfRefraction()	: Number
        {
            return _indexOfRefraction;
        }
		
		public static function createFromXML(xml : XML, document : ColladaDocument) : PhongTechnique
		{
			var emission			: CommonColorOrTextureOrParam;
			var ambient				: CommonColorOrTextureOrParam;
			var diffuse				: CommonColorOrTextureOrParam;
			var specular			: CommonColorOrTextureOrParam;
			var shininess			: Number = 0;
			var reflective			: CommonColorOrTextureOrParam;
			var reflectivity		: Number = 0;
			var transparent			: CommonColorOrTextureOrParam;
			var transparency		: Number = 0;
			var indexOfRefraction	: Number = 0;
			
			for each (var child : XML in xml.children())
			{
				var localName : String = child.localName();
				switch (child.localName())
				{
					case 'emission':
                        emission = CommonColorOrTextureOrParam.createFromXML(
                            xml.NS::emission[0], document
                        );
                        break;
					case 'ambient':
                        ambient	= CommonColorOrTextureOrParam.createFromXML(
                            xml.NS::ambient[0], document
                        );
                        break;
					case 'diffuse':
                        diffuse	= CommonColorOrTextureOrParam.createFromXML(
                            xml.NS::diffuse[0], document
                        );
                        break;
					case 'specular':
                        specular = CommonColorOrTextureOrParam.createFromXML(
                            xml.NS::specular[0], document
                        );
                        break;
					case 'shininess':
                        shininess = parseFloat(xml.NS::shininess[0].NS::float[0]);
                        break;
					case 'reflective':
                        reflective = CommonColorOrTextureOrParam.createFromXML(
                            xml.NS::reflective[0], document
                        );
                        break;
					case 'reflectivity':
                        reflectivity = parseFloat(xml.NS::reflectivity[0].NS::float[0]);
                        break;
					case 'transparent':
                        transparent	= CommonColorOrTextureOrParam.createFromXML(
                            xml.NS::transparent[0], document
                        );
                        break;
					case 'transparency':
                        transparency = parseFloat(xml.NS::transparency[0].NS::float[0]);
                        break;
					case 'index_of_refraction':
                        indexOfRefraction = parseFloat(xml.NS::index_of_refraction[0].NS::float[0]);
                        break;
				}
			}
			
			return new PhongTechnique(
                emission,
                ambient,
                diffuse,
                specular,
                shininess,
                reflective,
                reflectivity,
                transparent,
                transparency,
                indexOfRefraction,
                document
            );
		}
		
		public function PhongTechnique(emission	    		: CommonColorOrTextureOrParam,
                                       ambient		    	: CommonColorOrTextureOrParam,
                                       diffuse		    	: CommonColorOrTextureOrParam,
                                       specular		    	: CommonColorOrTextureOrParam,
                                       shininess	    	: Number,
                                       reflective	    	: CommonColorOrTextureOrParam,
                                       reflectivity	    	: Number,
                                       transparent	    	: CommonColorOrTextureOrParam,
                                       transparency	    	: Number,
                                       indexOfRefraction	: Number,
                                       document			    : ColladaDocument)
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
		
		public function createMaterial(parserOptions 	: ParserOptions,
									   params 			: Object,
									   setParams 		: Object) : Material
		{
            if (_material)
                return _material;
			            
			_material = parserOptions.material.clone() as Material;
            
			if (!isNaN(_shininess))
            	_material.setProperty(PhongProperties.SHININESS, _shininess);
			if (_diffuse)
            	setDiffuse(params, setParams);
			if (_specular)
            	setSpecular(params, setParams);
			if (_reflective)
				setReflective(params, setParams);
            			
			return _material;
		}
        
        private function setDiffuse(params : Object, setParams : Object) : void
        {
            var diffuseValue	: Object	= _diffuse.getValue(params, setParams);
            
            if (diffuseValue is Vector4)
                _material.setProperty(BasicProperties.DIFFUSE_COLOR, diffuseValue);
            else if (diffuseValue is uint)
                _material.setProperty(BasicProperties.DIFFUSE_COLOR, diffuseValue);
            else if (diffuseValue is TextureResource)
                _material.setProperty(BasicProperties.DIFFUSE_MAP, diffuseValue);
            else
            {
                Minko.log(
                    DebugLevel.PLUGIN_WARNING,
                    'Collada: Could not evaluate diffuse in profile_COMMON. '
                    + 'It has been replaced by a random color.'
                );
                
                _material.setProperty(
                    BasicProperties.DIFFUSE_COLOR, 
                    (uint(0xFFFFFF * Math.random())) << 8 | 0xFF
                );
            }   
        }
        
        private function setSpecular(params : Object, setParams : Object) : void
        {
            var specularValue : Object = _specular.getValue(params, setParams);
            
            if (specularValue is Vector4)
            {
                var specularValueVector : Vector4 = specularValue as Vector4;
                
                _material.setProperty(
                    PhongProperties.SPECULAR,
                    new Vector4(specularValueVector.x, specularValueVector.y, specularValueVector.z)
                );
            }
            else if (specularValue is uint)
            {
                _material.setProperty(
                    PhongProperties.SPECULAR,
                    ((specularValue as uint) >>> 24) / 255.
                );
            }
            else if (specularValue is Number)
            {
                _material.setProperty(PhongProperties.SPECULAR, specularValue);
            }
        }
		
		private function setReflective(params : Object, setParams : Object) : void
		{
			var reflectiveValue 	: Object	= _reflective.getValue(params, setParams);
			
			if (reflectiveValue is TextureResource)
			{
				_material.setProperty(
					EnvironmentMappingProperties.ENVIRONMENT_MAP,
					reflectiveValue
				);
				_material.setProperty(
					EnvironmentMappingProperties.REFLECTIVITY,
					_reflectivity
				);
				_material.setProperty(
					EnvironmentMappingProperties.ENVIRONMENT_MAPPING_TYPE,
					EnvironmentMappingType.BLINN_NEWELL
				);
			}
		}
	}
}