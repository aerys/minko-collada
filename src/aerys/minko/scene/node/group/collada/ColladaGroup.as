package aerys.minko.scene.node.group.collada
{
	import aerys.minko.scene.node.group.Group;
	import aerys.minko.type.animation.Animation;

	public class ColladaGroup extends Group
	{
		private var _animations : Object;
		
		public function get animations() : Object
		{
			return _animations;
		}
		
		public function getAnimationById(id : String) : Animation
		{
			return _animations[id];
		}
		
		public function ColladaGroup(...parameters)
		{
			super(parameters);
			_animations = new Object();
		}
	}
}
