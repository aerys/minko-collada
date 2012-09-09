package aerys.minko.type.parser.collada.helper
{
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.math.Vector4;

	public final class MatrixSanitizer
	{
		public static function sanitize(matrix : Matrix4x4) : void
		{
//			var rawData : Vector.<Number> = matrix.getRawData();
//			
//			rawData[2] *= -1.;
//			rawData[6] *= -1.;
//			rawData[8] *= -1.;
//			rawData[9] *= -1.;
//			rawData[11] *= -1.;
//			rawData[14] *= -1.;
//			
//			matrix.setRawData(rawData);
			
			var scale : Vector4 = matrix.getScale();
			var translation : Vector4 = matrix.getTranslation();
			var update : Boolean = false;
			
			if (scale.x < 0)
			{
				translation.x *= -1;
				scale.x *= -1;
				update = true;
			}
			if (scale.y < 0)
			{
				translation.y *= -1;
				scale.y *= -1;
				update = true;
			}
			if (scale.z < 0)
			{
				translation.z *= -1;
				scale.z *= -1;
				update = true;
			}
			
			if (update)
				matrix.world(translation, matrix.getRotation(), scale);
		}
	}
}