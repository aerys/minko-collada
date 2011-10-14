package aerys.minko.type.parser.collada
{
	import aerys.minko.scene.node.IScene;
	import aerys.minko.scene.node.group.Group;
	import aerys.minko.scene.node.group.IGroup;
	import aerys.minko.scene.node.group.LoaderGroup;
	import aerys.minko.type.parser.IParser;
	import aerys.minko.type.parser.ParserOptions;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	public class ColladaParser extends EventDispatcher implements IParser
	{
		public static const DROP_EMPTY_GROUPS	: uint = 1;
		public static const DROP_SKINNING		: uint = 2;
		
		private var _flags				: uint				= 0;
		private var _data				: Vector.<IScene>	= null;
		
		private var _numTextureToLoad	: uint				= 0;
		private var _numLoadedTextures	: uint				= 0;
		
		public function get data() : Vector.<IScene> { return _data; }
		
		public function ColladaParser(flags		: uint		= 0)
		{
			_flags		= flags;
			_data		= new Vector.<IScene>();
		}
		
		public function parse(data : ByteArray, options : ParserOptions) : Boolean
		{
			var xmlDocument	: XML		= null;
			var localName	: String	= null;
			
			try
			{
				data.position = 0;
				
				xmlDocument = new XML(data.readUTFBytes(data.length));
				if (!xmlDocument)
					return false;
				
				localName = xmlDocument.localName();
				
				if (localName.toLowerCase() != 'collada')
					return false;
			}
			catch (e : Error)
			{
				return false;
			}
			
			var dropEmptyGroups : Boolean			= (_flags & DROP_EMPTY_GROUPS) != 0;
			var dropSkinning	: Boolean			= (_flags & DROP_SKINNING) != 0;
			var document		: ColladaDocument	= new ColladaDocument(options);
			
			document.loadXML(xmlDocument);
			
			var group 	: Group				= document.toGroup(dropEmptyGroups, dropSkinning);
			var loaders : Vector.<IScene> 	= group.getDescendantsByType(LoaderGroup);
			
			_data.push(group);
			
			// handle asynchronous loaders
			_numTextureToLoad = loaders.length;
			if (_numTextureToLoad != 0)
			{
				var numItems : int = _numTextureToLoad;
				
				for (var loaderIndex : int = 0; loaderIndex < numItems; ++loaderIndex)
				{
					var loader : LoaderGroup	= loaders[loaderIndex] as LoaderGroup;
					
					if (loader.numChildren != 0)
						--_numTextureToLoad;
					else
						loader.addEventListener(Event.COMPLETE, loaderCompleteHandler);
				}
			}
			
			if (_numTextureToLoad == 0)
				dispatchEvent(new Event(Event.COMPLETE));
			
			return true;
		}
		
		public function loaderCompleteHandler(event : Event) : void
		{
			++_numLoadedTextures;
			
			if (_numLoadedTextures == _numTextureToLoad)
				dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}
