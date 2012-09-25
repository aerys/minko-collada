package aerys.minko.type.parser.collada.helper
{
	public class ColorModifier
	{
		public static function argbToRbga(color : uint) : uint
		{
			var a : uint = ((color & 0xFF000000) >> 24);
			color = color << 8 | a;
			
			return color;
		}
	}
}