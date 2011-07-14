package aerys.minko.type.collada.ressource.effect.technique
{
	import aerys.minko.type.collada.store.CommonColorOrTexture;

	public interface ITechnique
	{
		function get emission()				: CommonColorOrTexture;
		function get reflective()			: CommonColorOrTexture;
		function get reflectivity()			: Number;
		function get transparent()			: CommonColorOrTexture;
		function get transparency()			: Number;
		function get indexOfRefraction()	: Number;
	}
}