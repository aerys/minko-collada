package aerys.minko.scene.node.group
{
	import aerys.minko.type.animation.Animation;

	public class ColladaGroup extends Group
	{
		private var _animations : Vector.<Animation>;
		
		public function get animations() : Vector.<Animation>
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
			_animations = new Vector.<Animation>();
		}
	}
}