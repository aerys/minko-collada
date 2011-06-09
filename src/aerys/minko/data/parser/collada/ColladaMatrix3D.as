package aerys.minko.data.parser.collada
{
	import aerys.minko.type.math.Matrix4x4;

	internal class ColladaMatrix3D extends Matrix4x4
	{
		private var _time 		: Number					= 0.;
		private var _children	: Vector.<ColladaMatrix3D>	= new Vector.<ColladaMatrix3D>();
		
		public function get children() : Vector.<ColladaMatrix3D>
		{
			return _children;
		}
		
		public function get time() : Number
		{
			return _time;
		}
		
		public function ColladaMatrix3D(time	: Number = 0.)
		{
			super();
			
			_time = time;
		}
		
		public function flatten() : Vector.<Matrix4x4>
		{
			// TODO
			
			return null;
		}
		
	}
}