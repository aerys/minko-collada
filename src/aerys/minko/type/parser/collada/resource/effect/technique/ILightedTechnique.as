package aerys.minko.type.parser.collada.resource.effect.technique
{
	import aerys.minko.type.parser.collada.resource.effect.CommonColorOrTexture;

	public interface ILightedTechnique extends ITechnique
	{
		function get ambient()	: CommonColorOrTexture;
		function get diffuse()	: CommonColorOrTexture;
	}
}
