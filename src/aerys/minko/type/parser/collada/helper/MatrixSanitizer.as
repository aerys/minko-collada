package aerys.minko.type.parser.collada.helper
{
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.math.Vector4;

	public final class MatrixSanitizer
	{
		public static function sanitize(matrix : Matrix4x4) : void
		{
//			var raw	: Vector.<Number> 	= matrix.getRawData();
//
//			raw[2] *= -1.;
//			raw[6] *= -1.;
//			raw[8] *= -1.;
//			raw[9] *= -1.;
//			raw[11] *= -1.;
//			raw[14] *= -1.;
//			
//			matrix.setRawData(raw);
			
			var scale 				: Vector4 	= matrix.getScale();
			var numNegativeScales 	: uint 		= 0;
			
			if (scale.x < 0)
				numNegativeScales++;
			if (scale.y < 0)
				numNegativeScales++;
			if (scale.z < 0)
				numNegativeScales++;
			
			if (numNegativeScales % 2)
			{
//				var translation : Vector4 	= matrix.getTranslation();
//				var rotation	: Vector4	= matrix.getRotation();
				
				matrix.setColumn(2, matrix.getColumn(2).scaleBy(-1));
				
//				rotation.z *= -1;
//				scale.z *= -1;
//				translation.z *= -1;
				
//				matrix.world(translation, rotation, scale);
			}
		}
	}
}