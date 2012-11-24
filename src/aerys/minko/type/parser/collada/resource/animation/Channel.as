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
            
            if (numTimes == 0)
                return null;
            
            var values   : Vector.<Number>   = new Vector.<Number>(numTimes, true);
            
            for (var timeId : uint = 0; timeId < numTimes; ++timeId)
                values[timeId] = getFloatValudByIndex(timeId);
            
            return new ScalarTimeline(propertyPath, times, values, interpolate); 
        }
        
        private function getMatrixTimeline(propertyPath  : String) : MatrixTimeline
        {
            var times    : Vector.<uint>        = getTimes();
            var numTimes : uint                 = times.length;
            
            if (numTimes == 0)
                return null;
            
            var matrices : Vector.<Matrix4x4>   = new Vector.<Matrix4x4>(numTimes, true);
            
            for (var timeId : uint = 0; timeId < numTimes; ++timeId)
                matrices[timeId] = getMatrixValueByIndex(timeId);
            
            return new MatrixTimeline(propertyPath, times, matrices);
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
		
        private function getTimes() : Vector.<uint>
        {
            var inputSourceData			: Array				= Source(_sources['INPUT']).data;
            var inputSourceDataLength	: uint				= inputSourceData.length;
            var times       			: Vector.<uint>	    = new <uint>[];
            
            for (var timeId : uint = 0; timeId < inputSourceDataLength; ++timeId)
                times[timeId] = uint(inputSourceData[timeId] * 1000);
            
            return times;
        }
        
        private function getMatrixValueByIndex(index : uint) : Matrix4x4
        {
            var outputSource	: Source	= _sources['OUTPUT'];
            
            return outputSource.getComponentByParamIndex(index, 0) as Matrix4x4;
        }
	}
}