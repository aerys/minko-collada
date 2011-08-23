package aerys.minko.type.parser.collada.resource
{
	import aerys.minko.type.parser.collada.instance.IInstance;

	public interface IResource
	{
		function get id()			: String;
		function createInstance()	: IInstance;
	}
}
