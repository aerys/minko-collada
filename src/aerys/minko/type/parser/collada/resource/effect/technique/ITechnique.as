package aerys.minko.type.parser.collada.resource.effect.technique
{
	import aerys.minko.type.data.DataProvider;
	import aerys.minko.type.parser.collada.resource.effect.CommonColorOrTexture;

	public interface ITechnique
	{
		function get emission()				: CommonColorOrTexture;
		function get reflective()			: CommonColorOrTexture;
		function get reflectivity()			: Number;
		function get transparent()			: CommonColorOrTexture;
		function get transparency()			: Number;
		function get indexOfRefraction()	: Number;
		
		function createDataProvider(params : Object) : DataProvider;
	}
}
