package aerys.minko.type.parser.collada.resource.effect.profile
{
	import aerys.minko.type.data.DataProvider;

	public interface IProfile
	{
		function createDataProvider(params : Object, setParams : Object) : DataProvider;
	}
}