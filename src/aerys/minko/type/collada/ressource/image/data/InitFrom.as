package aerys.minko.type.collada.ressource.image.data
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class InitFrom extends EventDispatcher implements IImageData
	{
		private var _path		: String;
		private var _bitmapData	: BitmapData;
		
		public function get isLoaded()		: Boolean		{ return _bitmapData != null;	}
		public function get bitmapData()	: BitmapData	{ return _bitmapData;			}
		
		public static function createFromXML(xml : XML) : InitFrom
		{
			var initFrom : InitFrom = new InitFrom();
			initFrom._path = xml;
			return initFrom;
		}
		
		public function InitFrom()
		{
		}
		
		public function load() : void
		{
			var r : URLRequest = new URLRequest();
			r.url = _path;
			
			var l : Loader = new Loader();
			l.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			l.load(r);
		}
		
		private function onLoadComplete(e : Event) : void
		{
			_bitmapData = Bitmap(LoaderInfo(e.currentTarget).content).bitmapData;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
	}
}