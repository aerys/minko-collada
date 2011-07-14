package aerys.minko.type.collada.ressource.image.data
{
	import flash.display.BitmapData;
	import flash.events.IEventDispatcher;

	public interface IImageData extends IEventDispatcher
	{
		function get isLoaded()		: Boolean;
		function get bitmapData()	: BitmapData;
		
		function load() : void;
	}
}