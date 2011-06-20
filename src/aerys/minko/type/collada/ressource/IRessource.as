package aerys.minko.type.collada.ressource
{
	import aerys.minko.type.collada.instance.IInstance;

	public interface IRessource
	{
		function get id()			: String;
		function createInstance()	: IInstance;
	}
}
