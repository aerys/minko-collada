package aerys.minko.type.parser.collada.resource.effect.technique
{
    import aerys.minko.render.material.Material;
    import aerys.minko.type.parser.collada.resource.effect.CommonColorOrTextureOrParam;

    public interface IExtraTechnique
    {
        function applyToMaterial(material   : Material,
                                 params      : Object,
                                 setParams   : Object) : void;
    }
}