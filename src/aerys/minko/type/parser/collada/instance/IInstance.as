package aerys.minko.type.parser.collada.instance
{
	import aerys.minko.scene.node.IScene;
	import aerys.minko.type.parser.collada.ressource.IRessource;

	public interface IInstance
	{
		function get ressource() : IRessource;
		
		function toScene() : IScene;
	}
}
