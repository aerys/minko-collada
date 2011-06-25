package aerys.minko.type.collada.ressource
{
	import aerys.minko.type.Animation;
	import aerys.minko.type.collada.Document;
	import aerys.minko.type.collada.instance.IInstance;
	import aerys.minko.type.collada.ressource.animation.Channel;
	import aerys.minko.type.collada.store.Source;
	
	public class Animation implements IRessource
	{
		public static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _document	: Document;
		
		private var _id			: String;
		private var _animations	: Vector.<Animation>;
		private var _channels	: Vector.<Channel>;
		
		public function get id()		: String { return _id; }
		public function get target()	: String { return _channels[0].targetId; }
		
		
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
			
			if (!hasSingleTarget())
				throw new Error('Only single target animations are supported');
		}
		
		
		
		
		private function hasSingleTarget() : Boolean
		{
			var targetId : String = _channels[0].targetId;
			for each (var channel : Channel in _channels)
				if (channel.targetId != targetId)
					return false;
			return true;
		}
		
		
		public function createInstance() : IInstance
		{
			return null;
		}
	}
}