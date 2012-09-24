package aerys.minko.type.parser.collada.resource.animation
{
	import aerys.minko.Minko;
	import aerys.minko.type.animation.timeline.ITimeline;
	import aerys.minko.type.animation.timeline.MatrixSegmentTimeline;
	import aerys.minko.type.animation.timeline.MatrixTimeline;
	import aerys.minko.type.log.DebugLevel;
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.math.Vector4;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.instance.IInstance;
	import aerys.minko.type.parser.collada.resource.IResource;
	
	public class Animation implements IResource
	{
		public static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _document	: ColladaDocument;
		
		private var _id			: String;
		private var _animations	: Vector.<Animation>;
		private var _channels	: Vector.<Channel>;
		
		public function get id() : String { return _id; }
		public function set id(v : String) : void { _id = v; }
		
		public static function fillStoreFromXML(xmlDocument	: XML,
												document	: ColladaDocument, 
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
											 document		: ColladaDocument) : Animation
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
		
		public function Animation(document		: ColladaDocument,
								  id			: String,
								  channels		: Vector.<Channel>		= null,
								  animations	: Vector.<Animation>	= null)
		{
			_document	= document;
			_id			= id;
			_channels	= channels || new Vector.<Channel>();
			_animations = animations || new Vector.<Animation>();
		}
		
		public function getTimelines(timelines 		: Vector.<ITimeline>,
									 targetNames	: Vector.<String>) : void
		{
			var vector			: Vector.<Number>	= new Vector.<Number>(16);
			var timesCollection	: Object			= retrieveTimes();
			
			for (var targetName : String in timesCollection)
			{
				try
				{
					var times : Vector.<Number> = timesCollection[targetName];
					
					if (times.length == 1 && isNaN(times[0]))
						continue;
					
					var timesLength			: uint					= times.length;
					var minkoTimes			: Vector.<uint>			= new Vector.<uint>();
					var minkoMatrices		: Vector.<Matrix4x4>	= new Vector.<Matrix4x4>();
					
					for (var i : uint = 0; i < timesLength; ++i)
					{
						var time : Number = times[i];
						
						vector[0]	= vector[5]	 = vector[10] = vector[15] = 1;
						vector[1]	= vector[2]	 = vector[3]  = 0;
						vector[4]	= vector[6]  = vector[7]  = 0;
						vector[8]	= vector[9]  = vector[11] = 0;
						vector[12]	= vector[13] = vector[14] = 0;
						
						setMatrixData(time, vector, targetName);
						
						// why do we have to do this? animation data from the collada file is plain wrong.
//						vector[3] = vector[7] = vector[11] = 0
						vector[15] = 1;
						var matrix : Matrix4x4 = new Matrix4x4();
						
						matrix.setRawData(vector);
						
						minkoTimes.push((time * 1000) << 0);
						minkoMatrices.push(matrix);
					}
					
	//				var deltaTime : uint = minkoTimes[1] - minkoTimes[0];
	//				for (i = 1; i < timesLength; ++i)
	//					if (Math.abs(deltaTime - minkoTimes[i] + minkoTimes[i - 1]) > 1)
	//						break;
					
	//				if (i != timesLength)
//						timelines.push(new MatrixTimeline('transform', minkoTimes, minkoMatrices, true));
						timelines.push(new MatrixSegmentTimeline('transform', minkoTimes, minkoMatrices));
	//				else
	//					timelines.push(new MatrixLinearRegularTimeline('transform', deltaTime, minkoMatrices));
					
					targetNames.push(targetName);
				}
				catch (e : Error)
				{
					Minko.log(DebugLevel.PLUGIN_WARNING, 'ColladaPlugin: Droping animation for \'' + targetName + '\' (' + e.message + ')', this);
					continue;
				}
			}
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
		
		public function retrieveTimes(timeCollections : Object = null) : Object
		{
			timeCollections ||= new Object();
			
			var i : uint;
			
			// retrieve times
			var channelCount	: uint	= _channels.length;
			for (i = 0; i < channelCount; ++i)
				_channels[i].retrieveTimes(timeCollections);
			
			var animationCount : uint	= _animations.length;
			for (i = 0; i < animationCount; ++i)
				_animations[i].retrieveTimes(timeCollections);
			
			for each (var times : Vector.<Number> in timeCollections)
			{
				// sort
				times.sort(cmp);
				
				// remove duplicates
				var timeCount	: uint		= times.length;
				var lastTime	: Number	= times[0];
				
				for (i = 1; i < timeCount; ++i)
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
			
			return timeCollections;
		}
		
		public function createInstance() : IInstance
		{
			return null;
		}
	}
}