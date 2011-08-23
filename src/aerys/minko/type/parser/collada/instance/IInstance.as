package aerys.minko.type.parser.collada.instance
{
	import aerys.minko.scene.node.IScene;
	import aerys.minko.type.parser.collada.resource.IResource;

	public interface IInstance
	{
		function get resource() : IResource;
		
		function toScene() : IScene;
	}
}
