package aerys.minko.type.parser.collada.resource.image.data
{
	import aerys.minko.ns.minko_collada;

	use namespace minko_collada
	
	public class InitFrom implements IImageData
	{
		private var _path		: String;
		
		public function get path()	: String	{ return _path;	}
		
		public static function createFromXML(xml : XML) : InitFrom
		{
			var path		: String 	= xml;
			var filename	: String 	= path.substr(path.lastIndexOf('/') + 1);
			var initFrom 	: InitFrom 	= new InitFrom();
			
			initFrom._path	= path;
			
			return initFrom;
		}
		
	}
}