package aerys.minko.type.parser.collada.resource.effect.data
{
	import aerys.minko.type.parser.collada.ColladaDocument;

	public class Sampler2D implements IData
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _source 	: String;
		private var _wrapS		: String;
		private var _wrapT		: String;
		private var _minfilter	: String;
		private var _magfilter	: String;
		private var _mipfilter	: String;
		
		public function get source() : String
		{
			return _source;
		}
		
		public function get wrapS() : String
		{
			return _wrapS;
		}
		
		public function get wrapT() : String
		{
			return _wrapT;
		}
		
		public function get minfilter() : String
		{
			return _minfilter;
		}
		
		public function get magfilter() : String
		{
			return _magfilter;
		}
		
		public function get mipfilter() : String
		{
			return _mipfilter;
		}
		
		public static function createFromXML(xml : XML, document : ColladaDocument) : Sampler2D
		{
			var source		: String = String(xml.NS::source[0]);
			var wrapS		: String = String(xml.NS::wrap_s[0]);
			var wrapT		: String = String(xml.NS::wrap_t[0]);
			var minfilter	: String = String(xml.NS::minfilter[0]);
			var magfilter	: String = String(xml.NS::magfilter[0]);
			var mipfilter	: String = String(xml.NS::mipfilter[0]);
			
			return new Sampler2D(source, wrapS, wrapT, minfilter, magfilter, mipfilter);
		}
		
		public function Sampler2D(source	: String, 
								  wrapS		: String, 
								  wrapT		: String, 
								  minfilter	: String, 
								  magfilter	: String, 
								  mipfilter	: String)
		{
			_source		= source;
			_wrapS		= wrapS;
			_wrapT		= wrapT;
			_minfilter	= minfilter;
			_magfilter	= magfilter;
			_mipfilter	= mipfilter;
		}
	}
}