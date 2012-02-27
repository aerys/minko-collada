package aerys.minko.type.parser.collada.instance
{
	import aerys.minko.scene.node.ISceneNode;
	import aerys.minko.type.loader.parser.ParserOptions;
	import aerys.minko.type.parser.collada.resource.IResource;

	public interface IInstance
	{
		function get sourceId() : String;
		function get resource() : IResource;
		function createSceneNode(options	 			: ParserOptions,
								 sourceIdToSceneNode	: Object,
								 scopedIdToSceneNode	: Object) : ISceneNode;
	}
}
