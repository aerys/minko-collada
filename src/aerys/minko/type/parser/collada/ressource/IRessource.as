package aerys.minko.type.parser.collada.ressource
{
	import aerys.minko.type.parser.collada.instance.IInstance;

	public interface IRessource
	{
		function get id()			: String;
		function createInstance()	: IInstance;
	}
}
