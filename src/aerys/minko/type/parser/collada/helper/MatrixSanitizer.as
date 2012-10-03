package aerys.minko.type.parser.collada.helper
{
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.math.Vector4;

	public final class MatrixSanitizer
	{
		public static function sanitize(matrix : Matrix4x4) : void
		{
			var scale 	: Vector4 	= matrix.getScale();
//			
//			if (scale.x < 0)
//				numNegativeScales++;
//			if (scale.y < 0)
//				numNegativeScales++;
			if (scale.z < 0)
				matrix.scaleZ *= -1;
			
//			if (matrix.determinant < 0)
//			{
//				matrix.scaleZ *= -1;
//				matrix.setColumn(2, matrix.getColumn(2).scaleBy(-1));
//				matrix.translationX *= -1;
//			}
		}
	}
}