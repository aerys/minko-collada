package aerys.minko.type.parser.collada.resource.camera
{
	public final class Perspective
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");

		private static const DEFAULT_RATIO	: Number	= 4/3;
		
		private var _fov	: Number;
		private var _zNear	: Number;
		private var _zFar	: Number;
		private var _aspect	: Number;
		
		public function get aspect():Number
		{
			return _aspect;
		}

		public function set aspect(value:Number):void
		{
			_aspect = value;
		}

		public function get fov():Number
		{
			return _fov;
		}

		public function set fov(value:Number):void
		{
			_fov = value;
		}

		public function get zNear():Number
		{
			return _zNear;
		}

		public function set zNear(value:Number):void
		{
			_zNear = value;
		}

		public function get zFar():Number
		{
			return _zFar;
		}

		public function set zFar(value:Number):void
		{
			_zFar = value;
		}

		public static function createFromXml(xmlPerspective : XML) : Perspective
		{
			var xFovXml			: XML		= xmlPerspective.NS::xfov[0];
			var yFovXml			: XML		= xmlPerspective.NS::yfov[0];
			var zNearXml		: XML		= xmlPerspective.NS::znear[0];
			var zFarXml			: XML		= xmlPerspective.NS::zfar[0];
			var aspectXml		: XML		= xmlPerspective.NS::aspect_ratio[0];
			
			var xFov			: Number	= xFovXml ? parseFloat(String(xFovXml)) : .0;
			var yFov			: Number	= yFovXml ? parseFloat(String(xFovXml)) : .0;
			var aspect			: Number	= aspectXml ? parseFloat(String(aspectXml)) : .0;
			if (xFov != .0 && yFov != .0 && aspect == .0)
				aspect = xFov / yFov;	
			if (aspect != .0 && xFov == .0)
				xFov = yFov * aspect;
			if (aspect == .0)
				aspect = DEFAULT_RATIO;
			var zNear			: Number	= zNearXml ? parseFloat(String(zNearXml[0])) : .0;
			var zFar			: Number	= zFarXml ? parseFloat(String(zFarXml[0])) : .0;
			
			return new Perspective(xFov, aspect, zNear, zFar);
		}
		
		public function Perspective(xfov : Number, aspect : Number, zNear : Number, zFar : Number)
		{
			_fov	= xfov;
			_aspect	= aspect;
			_zNear	= zNear;
			_zFar	= zFar;
		}
	}
}