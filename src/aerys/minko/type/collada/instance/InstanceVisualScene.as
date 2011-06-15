package aerys.minko.type.collada.instance
{
	import aerys.minko.type.collada.Document;
	import aerys.minko.type.collada.ressource.IRessource;
	
	public class InstanceVisualScene implements IInstance
	{
		public static function createFromSourceId(document	: Document, 
												  nodeId	: String) : InstanceVisualScene
		{
			throw new Error('must be implemented');
		}
		
		public function InstanceVisualScene(document : Document, sourceId : String)
		{
		}
		
		public function get ressource():IRessource
		{
			return null;
		}
	}
}