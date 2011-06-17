package aerys.minko.type.collada.instance
{
	import aerys.minko.scene.node.IScene;
	import aerys.minko.type.collada.ressource.IRessource;

	public interface IInstance
	{
		function get ressource() : IRessource;
		
		function toScene() : IScene;
	}
}
