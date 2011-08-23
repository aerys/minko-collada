package aerys.minko.type.parser.collada.resource.image.data
{
	import aerys.minko.type.error.collada.ColladaError;
	
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;

	public class CreateCube extends EventDispatcher implements IImageData
	{
		public function get isLoaded() : Boolean { return false; }
		public function get bitmapData() : BitmapData { return null; }
		
		public function CreateCube()
		{
			throw new ColladaError('Cubemaps are not supported');
		}
		
		public function load() : void
		{
			throw new ColladaError('Cubemaps are not supported');
		}
	}
}