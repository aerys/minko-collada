package aerys.minko.type.parser.collada.resource.image.data
{
	import aerys.minko.ns.minko_collada;

	use namespace minko_collada
	
	public class InitFrom extends AbstractImageData
	{
		public static function createFromXML(xml : XML) : InitFrom
		{
			return new InitFrom(String(xml));
		}
		
		public function InitFrom(path : String)
		{
			super(path);
		}
	}
}
