package aerys.minko.data.parser.collada
{
	import aerys.minko.type.collada.intermediary.Source;

	internal final class ColladaAnimation
	{
		private static const NS				: Namespace	= null//ColladaParser.NS;
		
		private static const INPUT			: String	= "INPUT";
		private static const OUTPUT			: String	= "OUTPUT";
		private static const TIME			: String	= "TIME";
		private static const ANGLE			: String	= "ANGLE";
		private static const INTERPOLATION	: String	= "INTERPOLATION";
		
		private var _input			: Vector.<Number>	= null;
		private var _output			: Vector.<Number>	= null;
		private var _interpolations	: Vector.<String>	= null;
		private var _count			: uint				= 0;
		private var _inputMax		: Number			= Number.MIN_VALUE;
		private var _inputMin		: Number			= Number.MAX_VALUE;
		private var _outputMax		: Number			= Number.MIN_VALUE;
		private var _outputMin		: Number			= Number.MAX_VALUE;
		
		public function get input() 	: Vector.<Number> 	{ return _input; }
		public function get output()	: Vector.<Number>	{ return _output; }
		public function get count()		: uint				{ return _count; }
		public function get inputMax()	: Number			{ return _inputMax; }
		public function get inputMin()	: Number			{ return _inputMin; }
		public function get outputMax()	: Number			{ return _outputMax; }
		public function get outputMin()	: Number			{ return _outputMin; }
		
		public function parse(animation : XML) : void
		{
			_input = parseInput(animation);
			_output = parseOutput(animation);
			_interpolations = parseInterpolations(animation);
			
			_count = _input.length;
			
			for (var i : int = 0; i < _count; ++i)
			{
				if (_input[i] > _inputMax)
					_inputMax = _input[i];
				else if (_input[i] < _inputMin)
					_inputMin = _input[i];
				
				if (_output[i] > _outputMax)
					_outputMax = _output[i];
				else if (_output[i] < _outputMin)
					_outputMin = _output[i];
			}
		}
		
		private function parseInput(animation : XML) : Vector.<Number>
		{
			var sampler : XML = animation.NS::sampler[0];
			var sourceId : String = sampler.NS::input
										   .(@semantic == INPUT)
										   .@source
									  	   .substring(1);
			var xmlSource : XML = animation.NS::source
										   .(@id == sourceId)[0];
			
			var source		: Source = Source.createFromXML(xmlSource);
			
			return Vector.<Number>(source.data);
		}
		
		private function parseOutput(animation : XML) : Vector.<Number>
		{
			var sampler : XML = animation.NS::sampler[0];
			var sourceId : String = sampler.NS::input
										   .(@semantic == OUTPUT)
										   .@source
										   .substring(1);
			var xmlSource : XML = animation.NS::source
										  .(@id == sourceId)[0];
			
			var source		: Source = Source.createFromXML(xmlSource);
			
			return Vector.<Number>(source.data);
		}

		private function parseInterpolations(animation : XML) : Vector.<String>
		{
			var sampler : XML = animation.NS::sampler[0];
			var sourceId : String = sampler.NS::input
										   .(@semantic == INTERPOLATION)
										   .@source
										   .substring(1);
			var xmlSource : XML = animation.NS::source
										  .(@id == sourceId)[0];
			
			var source : Source = Source.createFromXML(xmlSource);
			
			return Vector.<String>(source.data);
		}
	}
}