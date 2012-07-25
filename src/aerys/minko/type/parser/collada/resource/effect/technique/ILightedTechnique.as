package aerys.minko.type.parser.collada.resource.effect.technique
{
	import aerys.minko.type.parser.collada.resource.effect.CommonColorOrTextureOrParam;

	public interface ILightedTechnique extends ITechnique
	{
		function get ambient()	: CommonColorOrTextureOrParam;
		function get diffuse()	: CommonColorOrTextureOrParam;
	}
}
