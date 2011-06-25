package aerys.minko.type.collada.ressource.animation
{
	import aerys.minko.type.collada.store.Source;

	public class Channel
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
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
				var semantic	: String	= String(xmlInput.@source).substr(1);
				
				var xmlSource	: XML		= animation.NS::source.(@id == sourceId)[0];
				var source		: Source	= Source.createFromXML(xmlSource);
				
				_sources[semantic] = source;
			}
		}
	}
}