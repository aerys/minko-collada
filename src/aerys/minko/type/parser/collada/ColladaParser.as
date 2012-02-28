package aerys.minko.type.parser.collada
{
	import aerys.minko.type.Signal;
	import aerys.minko.type.loader.ILoader;
	import aerys.minko.type.loader.TextureLoader;
	import aerys.minko.type.loader.parser.IParser;
	import aerys.minko.type.loader.parser.ParserOptions;
	import aerys.minko.type.parser.collada.resource.image.Image;
	
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	public class ColladaParser implements IParser
	{
		private var _document			: ColladaDocument;
		private var _options			: ParserOptions;
		
		private var _error				: Signal;
		private var _progress			: Signal;
		private var _complete			: Signal;
		private var _loaderToDependency	: Dictionary;
		
		public function get error() : Signal
		{
			return _error;
		}
		
		public function get progress()	: Signal
		{
			return _progress;
		}
		
		public function get complete() : Signal
		{
			return _complete;
		}
		
		public function ColladaParser(options : ParserOptions)
		{
			_options			= options || new ParserOptions();
			_progress			= new Signal();
			_complete			= new Signal();
			_error				= new Signal();
			_loaderToDependency	= new Dictionary();
		}
		
		public function isParsable(data : ByteArray) : Boolean
		{
			// optimize this!!!!
			
			try
			{
				data.position = 0;
				
				var xmlDocument	: XML = new XML(data.readUTFBytes(data.length));
				if (!xmlDocument)
					return false;
				
				return xmlDocument.localName().toLowerCase() == 'collada';
			}
			catch (e : Error)
			{
			}
			
			return false;
		}
		
		public function getDependencies(data : ByteArray) : Vector.<ILoader>
		{
			data.position = 0;
			
			var xmlDocument : XML = new XML(data.readUTFBytes(data.length));
			
			_document = new ColladaDocument();
			_document.loadFromXML(xmlDocument);
			
			var dependencies : Vector.<ILoader> = new Vector.<ILoader>();
			for each (var image : Image in _document.images)
			{
				var imageURL : String;
				imageURL = image.imageData.path;
				imageURL = _options.dependencyURLRewriter(imageURL);
				
				var loader : ILoader = new TextureLoader(_options.mipmapTextures);
				loader.load(new URLRequest(imageURL));
				
				dependencies.push(loader);
				_loaderToDependency[loader] = image;
			}
			
			return dependencies;
		}
		
		public function parse() : void
		{
			for (var l : Object in _loaderToDependency)
			{
				var loader	: TextureLoader	= TextureLoader(l);
				var image	: Image			= _loaderToDependency[loader];
				
				image.imageData.textureResource = loader.textureResource;
			}
			
			_complete.execute(this, _document.generateScene(_options));
		}
		
	}
}
