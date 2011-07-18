package aerys.minko.type.parser.collada.ressource.effect.technique
{
	import aerys.minko.type.parser.collada.ressource.effect.CommonColorOrTexture;

	public interface ILightedTechnique extends ITechnique
	{
		function get ambient()	: CommonColorOrTexture;
		function get diffuse()	: CommonColorOrTexture;
	}
}
