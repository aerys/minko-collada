package aerys.minko.type.parser.collada.helper
{
	import aerys.minko.type.math.Matrix4x4;

	public final class MatrixSanitizer
	{
        private static const TMP_NUMBERS    : Vector.<Number> = new <Number>[];
        
		public static function sanitize(matrix : Matrix4x4) : void
		{
            // why do we have to do this? animation data from the collada file is plain wrong
            matrix.getRawData(TMP_NUMBERS);
            TMP_NUMBERS[3] = TMP_NUMBERS[7] = TMP_NUMBERS[11] = 0.;
            TMP_NUMBERS[15] = 1.;
            matrix.setRawData(TMP_NUMBERS);
		}
	}
}