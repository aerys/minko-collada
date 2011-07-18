package aerys.minko.type.parser.collada
{
	import aerys.minko.scene.node.IScene;
	import aerys.minko.scene.node.group.Group;
	import aerys.minko.type.parser.IParser3D;
	
	import flash.utils.ByteArray;
	
	public class ColladaParser implements IParser3D
	{
		private var _data		: Vector.<IScene>;
		
		public function ColladaParser()
		{
			_data = new Vector.<IScene>();
		}
		
		public function get data() : Vector.<IScene>
		{
			
			return _data;
		}
		
		public function parse(data : ByteArray) : Boolean
		{
			try {
				var document : Document = new Document();
				document.loadByteArray(data);
				
				var scene : Group = document.toGroup(false, false);
				_data.push(scene);
			}
			catch (e : Error)
			{
				return false;
			}
			
			return true;
		}
	}
}