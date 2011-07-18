package aerys.minko.type.parser.collada.ressource.image.data
{
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;

	public class Create3D extends EventDispatcher implements IImageData
	{
		public function get isLoaded() : Boolean { return false; }
		public function get bitmapData() : BitmapData { return null; }
		
		public function Create3D()
		{
			throw new Error('3D textures are not supported');
		}
		
		public function load() : void
		{
			throw new Error('3D textures are not supported');
		}
	}
}