package aerys.minko.type.collada.ressource
{
	import aerys.minko.scene.node.group.TransformGroup;
	import aerys.minko.scene.node.skeleton.Joint;
	import aerys.minko.type.math.Matrix4x4;

	public class Node implements IRessource
	{
		private var _id			: String;
		private var _name		: String;
		private var _transform	: Matrix4x4;
		private var _type		: uint;
		
		public static function createFromXML(xmlNode : XML) : Node
		{
			throw new Error('implement me');
		}
		
		public function toTransformGroup() : TransformGroup
		{
			return new TransformGroup();
		}
		
		public function toJoint() : Joint
		{
			return new Joint();
		}
		
	}
}