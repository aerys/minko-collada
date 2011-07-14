package aerys.minko.type.collada.ressource.effect.technique
{
	import aerys.minko.type.collada.store.CommonColorOrTexture;

	public interface ILightedTechnique extends ITechnique
	{
		function get ambient()	: CommonColorOrTexture;
		function get diffuse()	: CommonColorOrTexture;
	}
}
