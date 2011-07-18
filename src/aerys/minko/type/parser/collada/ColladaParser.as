package aerys.minko.type.parser.collada
{
	import aerys.minko.scene.node.IScene;
	import aerys.minko.scene.node.group.Group;
	import aerys.minko.type.parser.IParser3D;
	import aerys.minko.type.parser.collada.ressource.animation.Animation;
	
	import flash.utils.ByteArray;
	
	public class ColladaParser implements IParser3D
	{
		public static const DROP_EMPTY_GROUPS	: uint = 1;
		public static const DROP_SKINNING		: uint = 2;
		
		private var _flags		: uint;
		private var _data		: Vector.<IScene>;
		private var _animations	: Object;
		
		public function get data() : Vector.<IScene> { return _data; }
		
		public function get animations() : Object
		{
			return _animations;
		}
		
		public function ColladaParser(flags : uint = 0)
		{
			_flags	= flags;
			_data	= new Vector.<IScene>();
		}
		
		public function parse(data : ByteArray) : Boolean
		{
			var dropEmptyGroups : Boolean = (_flags & DROP_EMPTY_GROUPS) != 0;
			var dropSkinning	: Boolean = (_flags & DROP_SKINNING) != 0;
			
			try {
				var document : Document = new Document();
				document.loadByteArray(data);
				
				var scene : Group = document.toGroup(dropEmptyGroups, dropSkinning);
				_data.push(scene);
				
				_animations = new Object();
				for each (var colladaAnim : Animation in document.animations)
				{
					var animId : String = colladaAnim.id;
					_animations[animId] = colladaAnim.toMinkoAnimation();
				}
			}
			catch (e : Error)
			{
				return false;
			}
			
			return true;
		}
		
	}
}