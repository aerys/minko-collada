package aerys.minko.type.parser.collada.helper
{
	public final class StringHelper
	{
		public static function stripLibSuffix(s : String) : String
		{
			var i	: int	= s.indexOf('-lib');
			if (i != -1)
				return s.substr(0, i);
			
			return s;
		}
	}
}