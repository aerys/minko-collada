package aerys.minko.type.parser.collada.resource.light
{
	import aerys.minko.type.math.Vector4;
	import aerys.minko.type.parser.collada.helper.NumberListParser;

	public final class Ambient
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");

		private var _color		: Vector4;
		public function get color():Vector4
		{
			return _color;
		}

		public function set color(value:Vector4):void
		{
			_color = value;
		}
		
		public function Ambient(color : Vector4)
		{
			_color = color;
		}

		public static function createFromXML(xml : XML) : Ambient
		{
			return new Ambient(NumberListParser.parseVector3(xml.NS::color[0]));
		}
	}
}