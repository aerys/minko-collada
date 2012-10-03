package aerys.minko.type.parser.collada
{
	import aerys.minko.type.Signal;
	import aerys.minko.type.loader.ILoader;
	import aerys.minko.type.loader.TextureLoader;
	import aerys.minko.type.loader.parser.IParser;
	import aerys.minko.type.loader.parser.ParserOptions;
	import aerys.minko.type.parser.collada.resource.image.Image;
	
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
		
		private var _lastData			: ByteArray;
		private var _lastXML			: XML;
		
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
			_progress			= new Signal('ColladaParser.progress');
			_complete			= new Signal('ColladaParser.complete');
			_error				= new Signal('ColladaParser.error');
			_loaderToDependency	= new Dictionary();
		}
		
		public function isParsable(data : ByteArray) : Boolean
		{
			var isCollada : Boolean;
			
			try
			{
				XML.prettyPrinting = false;
				
				_lastData			= data;
				_lastData.position	= 0;
				_lastXML			= new XML(_lastData);
				
				isCollada = _lastXML != null && _lastXML.localName().toLowerCase() == 'collada';
			}
			catch (e : Error)
			{
				isCollada = false;
			}
			
			if (!isCollada)
			{
				_lastData	= null;
				_lastXML	= null;
			}
			
			return isCollada;
		}
		
		public function getDependencies(data : ByteArray) : Vector.<ILoader>
		{
			if (_lastData !== data)
			{
				XML.prettyPrinting = false;
				
				_lastData			= data;
				_lastData.position	= 0;
				_lastXML			= new XML(_lastData);
			}
			
			_document = new ColladaDocument();
			_document.loadFromXML(_lastXML);
			
			if (_options.dependencyLoaderFunction == null)
				return null;
			
			var dependencies : Vector.<ILoader> = new <ILoader>[];
			for each (var image : Image in _document.images)
			{
				var imageURL	: String	= image.imageData.path;
				var loader		: ILoader	= _options.dependencyLoaderFunction(imageURL, true, _options);
				
				if (loader)
				{
					dependencies.push(loader);
					_loaderToDependency[loader] = image;
				}
			}
			
			return dependencies;
		}
		
		public function parse() : void
		{
			for (var l : Object in _loaderToDependency)
			{
				var loader	: TextureLoader	= TextureLoader(l);
				var image	: Image			= _loaderToDependency[loader];
				
				if (loader.isComplete)
					image.imageData.textureResource = loader.textureResource;
			}
			
			_complete.execute(this, _document.generateScene(_options));
		}
		
	}
}
