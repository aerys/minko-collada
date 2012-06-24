package aerys.minko.type.parser.collada.resource.effect.data
{
	import aerys.minko.type.parser.collada.ColladaDocument;

	public class Surface implements IData
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _type		: String;
		private var _initFrom	: String;
		private var _format		: String;
		
		public function get type() : String
		{
			return _type;
		}
		
		public function get initFrom() : String
		{
			return _initFrom;
		}
		
		public function get format() : String
		{
			return _format;
		}
		
		public static function createFromXML(xml : XML, document : ColladaDocument) : Surface
		{
			var type		: String = String(xml.@type);
			var initFrom	: String = String(xml.NS::init_from[0]);
			var format		: String = String(xml.NS::format[0]);
			
			return new Surface(type, initFrom, format);
		}
		
		public function Surface(type : String, initFrom : String, format : String)
		{
			_type = type;
			_initFrom = initFrom;
			_format = format;
		}
	}
}