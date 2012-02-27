package aerys.minko.type.parser.collada.resource.image.data
{
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
