package aerys.minko.type.parser.collada.helper
{
	import aerys.minko.type.math.Vector4;

	public final class Color
	{
		public static function toRGB(r : Number, g : Number, b : Number) : uint
		{
			var color : uint = 0;
			
			color = (color) + (r * 255);
			color = (color << 8) + (g * 255);
			color = (color << 8) + (b * 255);
			color = (color << 8) + 255;
			
			return color;
		}
		
		public static function vectorToRGB(v : Vector4) : uint
		{
			return toRGB(v.x, v.y, v.z);
		}

	}
}