package aerys.minko.type.parser.collada.ressource.effect.technique
{
	import aerys.minko.type.parser.collada.store.CommonColorOrTexture;

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