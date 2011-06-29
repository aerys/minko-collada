package aerys.minko.type.collada.ressource
{
	import aerys.minko.type.animation.Animation;
	import aerys.minko.type.animation.timeline.ITimeline;
	import aerys.minko.type.animation.timeline.LinearTimeline;
	import aerys.minko.type.collada.Document;
	import aerys.minko.type.collada.instance.IInstance;
	import aerys.minko.type.collada.ressource.animation.Channel;
	import aerys.minko.type.math.Matrix4x4;
	
	public class Animation implements IRessource
	{
		public static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _document	: Document;
		
		private var _id			: String;
		private var _animations	: Vector.<Animation>;
		private var _channels	: Vector.<Channel>;
		
		public function get id() : String { return _id; }
		
		public static function fillStoreFromXML(xmlDocument	: XML,
												document	: Document, 
												store		: Object) : void
		{
			var xmlAnimationLibrary	: XML		= xmlDocument..NS::library_animations[0];
			
			if (!xmlAnimationLibrary)
				return;
			
			var xmlAnimations 		: XMLList	= xmlAnimationLibrary.NS::animation;
			for each (var xmlAnimation : XML in xmlAnimations)
			{
				var animation : Animation = new Animation(xmlAnimation, document);
				store[animation.id] = animation;
			}
		}
		
		public function Animation(xmlAnimation	: XML,
								  document		: Document)
		{
			_animations = new Vector.<Animation>();
			_channels	= new Vector.<Channel>();
			
			_id = xmlAnimation.@id;
			
			for each (var xmlSubAnimation : XML in xmlAnimation.NS::animation)
				_animations.push(new Animation(xmlSubAnimation, document));
			
			for each (var xmlChannel : XML in xmlAnimation.NS::channel)
				_channels.push(new Channel(xmlChannel, xmlAnimation));
		}
		
		public function toMinkoAnimation() : aerys.minko.type.animation.Animation
		{
			var times			: Vector.<Number>;
			var timesCollection	: Object				= new Object();
			var vector			: Vector.<Number>		= new Vector.<Number>(16);
			var timelines		: Vector.<ITimeline>	= new Vector.<ITimeline>();
			
			retrieveTimes(timesCollection);
			for each (times in timesCollection)
				times.sort(cmp);
			removeDuplicateTimes(timesCollection);
			
			for (var targetId : String in timesCollection)
			{
				times = timesCollection[targetId];
				
				var timesLength		: uint					= times.length;
				
				var minkoTimes		: Vector.<uint>			= new Vector.<uint>();
				var minkoMatrices	: Vector.<Matrix4x4>	= new Vector.<Matrix4x4>();
				
				for (var i : uint = 0; i < timesLength; ++i)
				{
					var time : Number = times[i];
					
					vector[0]	= vector[5]	 = vector[10] = vector[15] = 1;
					vector[1]	= vector[2]	 = vector[3]  = 0;
					vector[4]	= vector[6]  = vector[7]  = 0;
					vector[8]	= vector[9]  = vector[11] = 0;
					vector[12]	= vector[13] = vector[13] = 0;
					
					setMatrixData(time, vector, targetId);
					
					minkoTimes.push((time * 1000) << 0);
					minkoMatrices.push(Matrix4x4.fromRawData(vector, 0, true));
				}
				timelines.push(new LinearTimeline(_id, targetId, minkoTimes, minkoMatrices));
			}
			
			return new aerys.minko.type.animation.Animation(_id, timelines);
		}
		
		public function setMatrixData(time : Number, vector : Vector.<Number>, targetId : String) : void
		{
			for each (var channel : Channel in _channels)
				if (channel.targetId == targetId)
					channel.setMatrixData(time, vector);
			
			for each (var animation : Animation in _animations)
				animation.setMatrixData(time, vector, targetId);
		}
		
		private function cmp(v1 : Number, v2 : Number) : int
		{
			return 100000 * (v1 - v2);
		}
		
		public function retrieveTimes(out : Object) : void
		{
			// on recup toutes les modifications que fait l'animation.
			var channelCount	: uint	= _channels.length;
			for (var i : uint = 0; i < channelCount; ++i)
				_channels[i].retrieveTimes(out);
			
			var animationCount : uint	= _animations.length;
			for (i = 0; i < animationCount; ++i)
				_animations[i].retrieveTimes(out);
		}
		
		private function removeDuplicateTimes(timesContainer : Object) : void
		{
			// on retire les doublons
			
			for each (var times : Vector.<Number> in timesContainer)
			{
				var timeCount	: uint		= times.length;
				var lastTime	: Number	= times[0];
				
				for (var i : uint = 1; i < timeCount; ++i)
				{
					if (times[i] == lastTime)
					{
						times.splice(i, 1);
						--i; --timeCount;
					}
					else
						lastTime = times[i];
				}
			}
		}
		
		public function createInstance() : IInstance
		{
			return null;
		}
	}
}