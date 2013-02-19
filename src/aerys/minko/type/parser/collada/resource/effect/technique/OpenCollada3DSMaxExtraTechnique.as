package aerys.minko.type.parser.collada.resource.effect.technique
{
    import aerys.minko.render.material.Material;
    import aerys.minko.render.material.phong.PhongProperties;
    import aerys.minko.render.resource.texture.ITextureResource;
    import aerys.minko.type.enum.NormalMappingType;
    import aerys.minko.type.parser.collada.ColladaDocument;
    import aerys.minko.type.parser.collada.resource.effect.CommonColorOrTextureOrParam;
    
    public class OpenCollada3DSMaxExtraTechnique implements IExtraTechnique
    {
        private static const NS : Namespace = new Namespace(
            'http://www.collada.org/2005/11/COLLADASchema'
        );
        
        private var _specularMap    : CommonColorOrTextureOrParam;
        private var _normalMap      : CommonColorOrTextureOrParam;
        
        public static function fromXML(xml      : XML,
                                       document : ColladaDocument) : OpenCollada3DSMaxExtraTechnique
        {
			if (xml.NS::specularLevel[0] == null || xml.NS::bump[0] == null)
			{
				return null;
			}
			
            var technique : OpenCollada3DSMaxExtraTechnique = new OpenCollada3DSMaxExtraTechnique();
			
			technique._specularMap = CommonColorOrTextureOrParam.createFromXML(
                xml.NS::specularLevel[0], document
            );
            technique._normalMap = CommonColorOrTextureOrParam.createFromXML(
                xml.NS::bump[0], document
            );
            
            return technique;
        }
        
        public function OpenCollada3DSMaxExtraTechnique()
        {
        }
        
        public function applyToMaterial(material    : Material,
                                        params      : Object,
                                        setParams   : Object) : void
        {
            var specularMapValue : ITextureResource = _specularMap.getValue(params, setParams)
                as ITextureResource;
            var normalMapValue : ITextureResource = _normalMap.getValue(params, setParams)
                as ITextureResource;

            if (specularMapValue)
                material.setProperty(PhongProperties.SPECULAR_MAP, specularMapValue);
            
            if (normalMapValue)
            {
                material.setProperty(PhongProperties.NORMAL_MAP, normalMapValue);
                material.setProperty(PhongProperties.NORMAL_MAPPING_TYPE, NormalMappingType.NORMAL);
            }
        }
    }
}