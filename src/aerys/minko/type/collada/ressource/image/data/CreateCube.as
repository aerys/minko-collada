package aerys.minko.type.collada.ressource.image.data
{
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;

	public class CreateCube extends EventDispatcher implements IImageData
	{
		public function get isLoaded() : Boolean { return false; }
		public function get bitmapData() : BitmapData { return null; }
		
		public function CreateCube()
		{
			throw new Error('Cubemaps are not supported');
		}
		
		public function load() : void
		{
			throw new Error('Cubemaps are not supported');
		}
	}
}