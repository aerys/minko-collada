package aerys.minko.type.parser.collada.resource.image.data
{
	import aerys.minko.render.resource.texture.TextureResource;
	
	import flash.display.BitmapData;
	import flash.events.IEventDispatcher;

	public class AbstractImageData
	{
		protected var _path				: String;
		protected var _textureResource	: TextureResource
		
		public function get path() : String
		{
			return _path;
		}
		
		public function get textureResource() : TextureResource
		{
			return _textureResource;
		}
		
		public function set textureResource(v : TextureResource) : void
		{
			_textureResource = v;
		}
		
		public function AbstractImageData(path : String)
		{
			_path = path;
		}
	}
}