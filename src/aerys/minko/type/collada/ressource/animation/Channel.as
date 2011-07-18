package aerys.minko.type.collada.ressource.animation
{
	import aerys.minko.type.collada.enum.TransformType;
	import aerys.minko.type.collada.store.Source;
	import aerys.minko.type.math.ConstVector4;
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.math.Transform3D;
	import aerys.minko.type.math.Vector4;

	public class Channel
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private static const TMP_MATRIX		: Transform3D = new Transform3D();
		
		private var _targetId				: String;
		private var _transformType			: String;
		
		private var _sources				: Object;
		
		public function get targetId()		: String { return _targetId; }
		public function get transformType()	: String { return _transformType; }
		
		public function Channel(xmlChannel	: XML, 
								animation	: XML)
		{
			_sources		= new Object();
			
			var target : String = xmlChannel.@target;
			_targetId		= target.substr(0, target.indexOf('/'));
			_transformType	= target.substr(target.indexOf('/') + 1);
			
			var samplerId	: String	= String(xmlChannel.@source).substr(1);
			var xmlSampler	: XML		= animation.NS::sampler.(@id == samplerId)[0];
			
			for each (var xmlInput : XML in xmlSampler.NS::input)
			{
				var sourceId	: String	= String(xmlInput.@source).substr(1);
				var semantic	: String	= String(xmlInput.@semantic);
				
				var xmlSource	: XML		= animation.NS::source.(@id == sourceId)[0];
				var source		: Source	= Source.createFromXML(xmlSource);
				
				_sources[semantic] = source;
			}
		}
		
		public function retrieveTimes(out : Object) : void
		{
			var inputSourceData			: Array				= Source(_sources['INPUT']).data;
			var inputSourceDataLength	: uint				= inputSourceData.length;
			var dest					: Vector.<Number>	= out[_targetId];
			
			if (!dest)
				dest = out[_targetId] = new Vector.<Number>();
			
			for (var timeId : uint = 0; timeId < inputSourceDataLength; ++timeId)
				dest.push(inputSourceData[timeId]);
		}
		
		private function getTimeIndexAt(t : Number) : uint
		{
			// retrieve the time id.
			var times			: Array	= _sources['INPUT'].data;
			var timesLength		: uint	= times.length;
			var i				: uint;
			for (i = 0; i < timesLength; ++i)
				if (times[i] >= t)
					break;
			
			return i;
		}
		
		private function getSimpleValueAt(t : Number) : Number
		{
			var out				: Number;
			var timeIndex		: uint = getTimeIndexAt(t);
			var times			: Array	= _sources['INPUT'].data;
			var timesLength		: uint	= times.length;
			
			var outputSource	: Source = _sources['OUTPUT'];
			
			if (timeIndex == 0)
			{
				out = outputSource.data[0];
			}
			else if (timeIndex == timesLength)
			{
				out = outputSource.data[timesLength - 1];
			}
			else
			{
				var previousTime		: Number	= times[timeIndex - 1];
				var nextTime			: Number	= times[timeIndex];
				var interpolationRatio	: Number	= (t - previousTime) / (nextTime - previousTime);
				
				var previousValue		: Number	= outputSource.data[timeIndex - 1];
				var nextValue			: Number	= outputSource.data[timeIndex];
				
				out = (1 - interpolationRatio) * previousValue + interpolationRatio * nextValue;
			}
			
			return out;
		}
		
		private function getCompoundValueAt(t : Number, out : Object = null) : Object
		{
			out ||= new Object();
			
			// interpolate the output source the get the wanted value.
			// later here we should implement bezier stuff & co, but i'm way too lazy right now.
			
			var timeIndex		: uint		= getTimeIndexAt(t);
			var times			: Array	= _sources['INPUT'].data;
			var timesLength		: uint		= times.length;
			var outputSource	: Source	= _sources['OUTPUT'];
			
			if (timeIndex == 0)
			{
				out = outputSource.getItem(0, out);
			}
			else if (timeIndex == timesLength)
			{
				out = outputSource.getItem(timesLength - 1, out);
			}
			else
			{
				var previousTime		: Number	= times[timeIndex - 1];
				var nextTime			: Number	= times[timeIndex];
				var interpolationRatio	: Number	= (t - previousTime) / (nextTime - previousTime);
				
				var previousValue		: Object	= outputSource.getItem(timeIndex - 1);
				var nextValue			: Object	= outputSource.getItem(timeIndex);
				
				for (var key : String in previousValue)
					out[key] = (1 - interpolationRatio) * previousValue[key] + interpolationRatio * nextValue[key];
			}
			
			return out;
		}
		
		public function setMatrixData(t : Number, data : Vector.<Number>) : void
		{
			switch (_transformType)
			{
				case TransformType.TRANSFORM_0_0:
					data[0] = getSimpleValueAt(t); 
					break;
				
				case TransformType.TRANSFORM_0_1: 
					data[1] = getSimpleValueAt(t); 
					break;
				
				case TransformType.TRANSFORM_0_2:
					data[2] = getSimpleValueAt(t);
					break;
				
				case TransformType.TRANSFORM_0_3:
					data[3] = getSimpleValueAt(t);
					break;
				
				case TransformType.TRANSFORM_1_0:
					data[4] = getSimpleValueAt(t);
					break;
				
				case TransformType.TRANSFORM_1_1:
					data[5] = getSimpleValueAt(t);
					break;
				
				case TransformType.TRANSFORM_1_2:
					data[6] = getSimpleValueAt(t);
					break;
				
				case TransformType.TRANSFORM_1_3:
					data[7] = getSimpleValueAt(t);
					break;
				
				case TransformType.TRANSFORM_2_0:
					data[8] = getSimpleValueAt(t);
					break;
				
				case TransformType.TRANSFORM_2_1:
					data[9] = getSimpleValueAt(t);
					break;
				
				case TransformType.TRANSFORM_2_2:
					data[10] = getSimpleValueAt(t);
					break;
				
				case TransformType.TRANSFORM_2_3:
					data[11] = getSimpleValueAt(t);
					break;
				
				case TransformType.TRANSFORM_3_0:
					data[12] = getSimpleValueAt(t);
					break;
				
				case TransformType.TRANSFORM_3_1:
					data[13] = getSimpleValueAt(t);
					break;
				
				case TransformType.TRANSFORM_3_2:
					data[14] = getSimpleValueAt(t);
					break;
				
				case TransformType.TRANSFORM_3_3:
					data[15] = getSimpleValueAt(t);
					break;
					
				case TransformType.ROTATE_X:
					TMP_MATRIX.setRawData(data);
					TMP_MATRIX.rotation.x = getSimpleValueAt(t) / 180 * Math.PI;
					TMP_MATRIX.appendScale(1);
//					TMP_MATRIX.prependRotation(getSimpleValueAt(t) / 180 * Math.PI, ConstVector4.X_AXIS);
					TMP_MATRIX.getRawData(data);
					break;
				
				case TransformType.ROTATE_Y:
					TMP_MATRIX.setRawData(data);
					TMP_MATRIX.rotation.y = getSimpleValueAt(t) / 180 * Math.PI;
					TMP_MATRIX.appendScale(1);
//					TMP_MATRIX.prependRotation(getSimpleValueAt(t) / 180 * Math.PI, ConstVector4.Y_AXIS);
					TMP_MATRIX.getRawData(data);
					break;
				
				case TransformType.ROTATE_Z:
					TMP_MATRIX.setRawData(data);
					TMP_MATRIX.rotation.z = getSimpleValueAt(t) / 180 * Math.PI;
					TMP_MATRIX.appendScale(1);
//					TMP_MATRIX.prependRotation(getSimpleValueAt(t) / 180 * Math.PI, ConstVector4.Z_AXIS);
					TMP_MATRIX.getRawData(data);
					break;
				
				case TransformType.TRANSLATE:
					var value : Object = getCompoundValueAt(t);
					TMP_MATRIX.setRawData(data);
					TMP_MATRIX.position.set(value.X, value.Y, value.Z);
					TMP_MATRIX.appendScale(1);
//					TMP_MATRIX.prependTranslation(value.X, value.Y, value.Z);
					TMP_MATRIX.getRawData(data);
					break;
				
				default: 
					trace('Unknown animation type', _transformType);
					break;
			}
		}
	}
}