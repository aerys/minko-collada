package aerys.minko.type.parser.collada.resource.animation
{
	import aerys.minko.type.animation.timeline.ITimeline;
	import aerys.minko.type.animation.timeline.MatrixLinearTimeline;
	import aerys.minko.type.math.Matrix3D;
	import aerys.minko.type.parser.collada.Document;
	import aerys.minko.type.parser.collada.instance.IInstance;
	import aerys.minko.type.parser.collada.resource.IResource;
	
	import flash.utils.getTimer;
	
	public class Animation implements IResource
	{
		public static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _document	: Document;
		
		private var _id			: String;
		private var _animations	: Vector.<Animation>;
		private var _channels	: Vector.<Channel>;
		
		public function get id() : String { return _id; }
		public function set id(v : String) : void { _id = v; }
		
		public static function fillStoreFromXML(xmlDocument	: XML,
												document	: Document, 
												store		: Object) : void
		{
			var xmlAnimationLibrary	: XML					= xmlDocument..NS::library_animations[0];
			if (!xmlAnimationLibrary || xmlAnimationLibrary.children().length() == 0)
				return;
			
			var xmlAnimations 		: XMLList				= xmlAnimationLibrary.NS::animation;
			var mergedSubAnimations : Vector.<Animation>	= new Vector.<Animation>();
			
			for each (var xmlAnimation : XML in xmlAnimations)
			{
				var animation : Animation = Animation.createFromXML(xmlAnimation, document);
				store[animation.id] = animation;
				mergedSubAnimations.push(animation);
			}
			
			store['mergedAnimations'] = new Animation(document, 'mergedAnimations', null, mergedSubAnimations);
		}
		
		public static function createFromXML(xmlAnimation	: XML,
											 document		: Document) : Animation
		{
			var id			: String				= xmlAnimation.@id;
			var channels	: Vector.<Channel>		= new Vector.<Channel>();
			var animations	: Vector.<Animation>	= new Vector.<Animation>();
			
			for each (var xmlChannel : XML in xmlAnimation.NS::channel)
				channels.push(new Channel(xmlChannel, xmlAnimation));
				
			for each (var xmlSubAnimation : XML in xmlAnimation.NS::animation)
				animations.push(Animation.createFromXML(xmlSubAnimation, document));
			
			return new Animation(document, id, channels, animations);
		}
		
		public function Animation(document		: Document,
								  id			: String,
								  channels		: Vector.<Channel>		= null,
								  animations	: Vector.<Animation>	= null)
		{
			_document	= document;
			_id			= id;
			_channels	= channels || new Vector.<Channel>();
			_animations = animations || new Vector.<Animation>();
		}
		
		public function computeTimelines() : Vector.<ITimeline>
		{
			var times			: Vector.<Number>;
			var timesCollection	: Object				= new Object();
			var vector			: Vector.<Number>		= new Vector.<Number>(16);
			var timelines		: Vector.<ITimeline>	= new Vector.<ITimeline>();
			
//			var timer : uint = getTimer();
			retrieveTimes(timesCollection);
			for each (times in timesCollection)
				times.sort(cmp);
			removeDuplicateTimes(timesCollection);
//			trace('computeTimelines step1', getTimer() - timer);
			
//			timer = getTimer();
			
			for (var targetId : String in timesCollection)
			{
				times = timesCollection[targetId];
				
				if (times.length == 1 && isNaN(times[0]))
					continue;
				
				var timesLength			: uint					= times.length;
				
				var minkoTimes			: Vector.<uint>			= new Vector.<uint>();
				var minkoMatrices		: Vector.<Matrix3D>	= new Vector.<Matrix3D>();
				
				for (var i : uint = 0; i < timesLength; ++i)
				{
					var time : Number = times[i];
					
					vector[0]	= vector[5]	 = vector[10] = vector[15] = 1;
					vector[1]	= vector[2]	 = vector[3]  = 0;
					vector[4]	= vector[6]  = vector[7]  = 0;
					vector[8]	= vector[9]  = vector[11] = 0;
					vector[12]	= vector[13] = vector[14] = 0;
					
					setMatrixData(time, vector, targetId);
					
					// why do we have to do this? animation data from the collada file is plain wrong.
					vector[3] = vector[7] = vector[11] = 0
					vector[15] = 1;
					var matrix : Matrix3D = new Matrix3D();
					matrix.setRawData(vector, 0, false);
					
					minkoTimes.push((time * 1000) << 0);
					minkoMatrices.push(matrix);
				}
				
				
				timelines.push(new MatrixLinearTimeline(targetId, 'transform', minkoTimes, minkoMatrices));
			}
//			trace('computeTimelines step2', getTimer() - timer);
			
			return timelines;
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
			var channelCount	: uint	= _channels.length;
			for (var i : uint = 0; i < channelCount; ++i)
				_channels[i].retrieveTimes(out);
			
			var animationCount : uint	= _animations.length;
			for (i = 0; i < animationCount; ++i)
				_animations[i].retrieveTimes(out);
		}
		
		private function removeDuplicateTimes(timesContainer : Object) : void
		{
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