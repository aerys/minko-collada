package aerys.minko.type.parser.collada.resource.animation
{
	import aerys.minko.Minko;
	import aerys.minko.type.animation.timeline.ITimeline;
	import aerys.minko.type.log.DebugLevel;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.instance.IInstance;
	import aerys.minko.type.parser.collada.resource.IResource;
	
	public class Animation implements IResource
	{
		public static const NS : Namespace = new Namespace('http://www.collada.org/2005/11/COLLADASchema');
		
		private var _document	: ColladaDocument;
		
		private var _id			: String;
		private var _animations	: Vector.<Animation>;
		private var _channels	: Vector.<Channel>;
		
		public function get id() : String
        {
            return _id;
        }
		
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
			
			store['mergedAnimations'] = new Animation(
                document,
                'mergedAnimations',
                null,
                mergedSubAnimations
            );
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
		
        public function getTimelines(timelines      : Vector.<ITimeline>,
                                     targetNames    : Vector.<String>) : void
        {
                for each (var channel : Channel in _channels)
                {
                    try
                    {
                        var timeline : ITimeline = channel.getTimeline(_document);
                        
                        if (timeline)
                        {
                            timelines.push(timeline);
                            targetNames.push(channel.targetId);
                            
                            Minko.log(
                                DebugLevel.PLUGIN_NOTICE,
                                'ColladaPlugin: Loaded \'' + channel.transformType
                                + '\' animation for \'' + channel.targetId + '\'',
                                this
                            );
                        }
                        else
                        {
                            Minko.log(
                                DebugLevel.PLUGIN_WARNING,
                                'ColladaPlugin: Dropped animation for \'' + channel.targetId
                                + '\': no animation data.',
                                this
                            );  
                        }
                    }
                    catch (e : Error)
                    {
                        Minko.log(
                            DebugLevel.PLUGIN_WARNING,
                            'ColladaPlugin: Dropped animation for \'' + channel.targetId
                            + '\': ' + e.message,
                            this
                        );
                    }
                }
                
                for each (var animation : Animation in _animations)
                    animation.getTimelines(timelines, targetNames);
        }
        
		public function createInstance() : IInstance
		{
			return null;
		}
	}
}