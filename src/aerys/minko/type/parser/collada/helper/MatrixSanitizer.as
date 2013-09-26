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
		
		public static function changeHandedness(matrix : Matrix4x4) : Matrix4x4
		{
			matrix.getRawData(TMP_NUMBERS);
			
			// affine part
			TMP_NUMBERS[1]	*= -1.0;
			TMP_NUMBERS[2]	*= -1.0;
			TMP_NUMBERS[4]	*= -1.0;
			TMP_NUMBERS[8]	*= -1.0;
			
			// translational part
			TMP_NUMBERS[12]	*= -1.0;
			
			matrix.setRawData(TMP_NUMBERS);
			
			return matrix;
		}
	}
}