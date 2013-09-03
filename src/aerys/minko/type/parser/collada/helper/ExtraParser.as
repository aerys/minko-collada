package aerys.minko.type.parser.collada.helper
{
	public class ExtraParser
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		public static function parseExtra(node : XML) : Object
		{
			return XMLDecoder.toObject(node);
		}

		public static function parseUserProperties(node : XML) : Object
		{
			var properties	: XMLList	= node..NS::user_properties;
			
			if (properties.length())
				return XMLDecoder.toObject(properties[0]);
			
			return null;
		}
	}
}