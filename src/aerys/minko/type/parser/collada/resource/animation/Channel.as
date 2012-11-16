package aerys.minko.type.parser.collada.resource.animation
{
	import aerys.minko.type.animation.timeline.ITimeline;
	import aerys.minko.type.animation.timeline.MatrixTimeline;
	import aerys.minko.type.animation.timeline.ScalarTimeline;
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.parser.collada.enum.TransformType;
	import aerys.minko.type.parser.collada.helper.Source;

	public final class Channel
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private static const TMP_MATRIX		: Matrix4x4 = new Matrix4x4();
		
		private var _targetId				: String;
		private var _transformType			: String;
		
		private var _sources				: Object;
		
		public function get targetId() : String
		{
			return _targetId;
		}
		public function get transformType()	: String
		{
			return _transformType;
		}
		
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
        
        public function getTimes() : Vector.<uint>
        {
            var inputSourceData			: Array				= Source(_sources['INPUT']).data;
            var inputSourceDataLength	: uint				= inputSourceData.length;
            var times       			: Vector.<uint>	    = new <uint>[];
            
            for (var timeId : uint = 0; timeId < inputSourceDataLength; ++timeId)
                times[timeId] = uint(inputSourceData[timeId] * 1000);
            
            return times;
        }
        
        public function getTimeline() : ITimeline
        {
            switch (_transformType)
            {
                case TransformType.MATRIX:
                case TransformType.TRANSFORM:
                    return getMatrixTimeline('transform');
                    break ;
                case TransformType.VISIBILITY:
                    return getScalarTimeline('visible', false);
                    break ;
                case TransformType.TRANSFORM_0_0:
                case TransformType.TRANSFORM_0_1:
                case TransformType.TRANSFORM_0_2:
                case TransformType.TRANSFORM_0_3:
                case TransformType.TRANSFORM_1_0:
                case TransformType.TRANSFORM_1_1:
                case TransformType.TRANSFORM_1_2:
                case TransformType.TRANSFORM_1_3:
                case TransformType.TRANSFORM_2_0:
                case TransformType.TRANSFORM_2_1:
                case TransformType.TRANSFORM_2_2:
                case TransformType.TRANSFORM_2_3:
                case TransformType.TRANSFORM_3_0:
                case TransformType.TRANSFORM_3_1:
                case TransformType.TRANSFORM_3_2:
                case TransformType.TRANSFORM_3_3:
                case TransformType.ROTATE_X:
                case TransformType.ROTATE_Y:
                case TransformType.ROTATE_Z:
                case TransformType.TRANSLATE:
                default: 
                    throw new Error('Unknown animation type: \'' + _transformType + '\'.');
                    break;
            }

            return null;
        }
        
        private function getScalarTimeline(propertyPath : String,
                                           interpolate  : Boolean) : ScalarTimeline
        {
            var times    : Vector.<uint>     = getTimes();
            var numTimes : uint              = times.length;
            var values   : Vector.<Number>   = new Vector.<Number>(numTimes, true);
            
            for (var timeId : uint = 0; timeId < numTimes; ++timeId)
                values[timeId] = getFloatValudByIndex(timeId);
            
            trace(values);
            
            return new ScalarTimeline(propertyPath, times, values, interpolate); 
        }
        
        private function getMatrixTimeline(propertyPath  : String) : MatrixTimeline
        {
            var times    : Vector.<uint>        = getTimes();
            var numTimes : uint                 = times.length;
            var matrices : Vector.<Matrix4x4>   = new Vector.<Matrix4x4>(numTimes, true);
            
            for (var timeId : uint = 0; timeId < numTimes; ++timeId)
                matrices[timeId] = getMatrixValueByIndex(timeId);
            
            return new MatrixTimeline(propertyPath, times, matrices);
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
		
		/**
		 * Dichotomy to find the time immediatly superior to a given value.
		 * 
		 * @param t
		 * @return 
		 */		
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
        
        public function getFloatValudByIndex(index : uint) : Number
        {
            var outputSource : Source = _sources['OUTPUT'];
            
            return outputSource.data[index];
        }
		
		public function getFloatValueAt(t : Number) : Number
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
			var times			: Array		= _sources['INPUT'].data;
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
		
        private function getMatrixValueByIndex(index : uint) : Matrix4x4
        {
            var outputSource	: Source	= _sources['OUTPUT'];
            
            return outputSource.getComponentByParamIndex(index, 0) as Matrix4x4;
        }
        
		private function getMatrixValueAt(t : Number, out : Matrix4x4 = null) : Matrix4x4
		{
			out ||= new Matrix4x4();
			
			// interpolate the output source the get the wanted value.
			// later here we should implement bezier stuff & co, but i'm way too lazy right now.
			
			var timeIndex		: uint		= getTimeIndexAt(t);
			var times			: Array		= _sources['INPUT'].data;
			var timesLength		: uint		= times.length;
			var outputSource	: Source	= _sources['OUTPUT'];
			
			if (timeIndex == 0)
			{
				out = outputSource.getComponentByParamIndex(0, 0) as Matrix4x4;
			}
			else if (timeIndex == timesLength)
			{
				out = outputSource.getComponentByParamIndex(timesLength - 1, 0) as Matrix4x4;
			}
			else
			{
				var previousTime		: Number	= times[timeIndex - 1];
				var nextTime			: Number	= times[timeIndex];
				var interpolationRatio	: Number	= (t - previousTime) / (nextTime - previousTime);
				
				var previousValue		: Matrix4x4	= outputSource.getComponentByParamIndex(timeIndex - 1, 0) as Matrix4x4;
				var nextValue			: Matrix4x4	= outputSource.getComponentByParamIndex(timeIndex, 0) as Matrix4x4;
				
				out.copyFrom(previousValue);
				out.interpolateTo(nextValue, 1 - interpolationRatio, true);
			}
			
			return out;
		}
        
		public function getMatrixData(t : Number, data : Vector.<Number>) : void
		{
 			switch (_transformType)
			{
				case TransformType.MATRIX:
				case TransformType.TRANSFORM:
					var matrix : Matrix4x4 = getMatrixValueAt(t);
					matrix.getRawData(data, 0, false);
					break;
				
				case TransformType.TRANSFORM_0_0:
					data[0] = getFloatValueAt(t); 
					break;
				
				case TransformType.TRANSFORM_0_1: 
					data[1] = getFloatValueAt(t); 
					break;
				
				case TransformType.TRANSFORM_0_2:
					data[2] = getFloatValueAt(t);
					break;
				
				case TransformType.TRANSFORM_0_3:
					data[3] = getFloatValueAt(t);
					break;
				
				case TransformType.TRANSFORM_1_0:
					data[4] = getFloatValueAt(t);
					break;
				
				case TransformType.TRANSFORM_1_1:
					data[5] = getFloatValueAt(t);
					break;
				
				case TransformType.TRANSFORM_1_2:
					data[6] = getFloatValueAt(t);
					break;
				
				case TransformType.TRANSFORM_1_3:
					data[7] = getFloatValueAt(t);
					break;
				
				case TransformType.TRANSFORM_2_0:
					data[8] = getFloatValueAt(t);
					break;
				
				case TransformType.TRANSFORM_2_1:
					data[9] = getFloatValueAt(t);
					break;
				
				case TransformType.TRANSFORM_2_2:
					data[10] = getFloatValueAt(t);
					break;
				
				case TransformType.TRANSFORM_2_3:
					data[11] = getFloatValueAt(t);
					break;
				
				case TransformType.TRANSFORM_3_0:
					data[12] = getFloatValueAt(t);
					break;
				
				case TransformType.TRANSFORM_3_1:
					data[13] = getFloatValueAt(t);
					break;
				
				case TransformType.TRANSFORM_3_2:
					data[14] = getFloatValueAt(t);
					break;
				
				case TransformType.TRANSFORM_3_3:
					data[15] = getFloatValueAt(t);
					break;
					
				case TransformType.ROTATE_X:
				case TransformType.ROTATE_Y:
				case TransformType.ROTATE_Z:
				case TransformType.TRANSLATE:
				default: 
					throw new Error("Unknown animation type: '" + _transformType + "'.");
					break;
			}
		}
	}
}