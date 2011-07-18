package aerys.minko.type.parser.collada.ressource.image
{
	import aerys.minko.type.parser.collada.Document;
	import aerys.minko.type.parser.collada.instance.IInstance;
	import aerys.minko.type.parser.collada.instance.InstanceImage;
	import aerys.minko.type.parser.collada.ressource.IRessource;
	import aerys.minko.type.parser.collada.ressource.image.data.IImageData;
	import aerys.minko.type.parser.collada.ressource.image.data.ImageDataFactory;
	
	public class Image implements IRessource
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _document	: Document;
		
		private var _id			: String;
		private var _sid		: String;
		private var _name		: String;
		private var _imageData	: IImageData;
		
		public function get id()		: String		{ return _id; }
		public function get sid()		: String		{ return _sid; }
		public function get name()		: String		{ return _name; }
		public function get imageData()	: IImageData	{ return _imageData; }
		
		public static function fillStoreFromXML(xmlDocument	: XML,
												document	: Document, 
												store		: Object) : void
		{
			var xmlImageLibrary	: XML		= xmlDocument..NS::library_images[0];
			if (!xmlImageLibrary)
				return;
			
			var xmlImages 			: XMLList	= xmlImageLibrary.NS::image;
			
			for each (var xmlImage : XML in xmlImages)
			{
				var image : Image = createFromXML(xmlImage, document);
				store[image.id] = image;
			}
		}
		
		public static function createFromXML(xmlImage : XML, document : Document) : Image
		{
			var image : Image = new Image();
			image._document = document;
			
			image._id			= xmlImage.@id;
			image._sid			= xmlImage.@sid;
			image._name			= xmlImage.@name;
			image._imageData	= ImageDataFactory.createImageData(xmlImage.children()[0]);
			
			return image;
		}
		
		public function createInstance():IInstance
		{
			return InstanceImage.createFromSourceId(_id, _document);
		}
	}
}