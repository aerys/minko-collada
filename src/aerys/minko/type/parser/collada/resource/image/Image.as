package aerys.minko.type.parser.collada.resource.image
{
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.instance.IInstance;
	import aerys.minko.type.parser.collada.instance.InstanceImage;
	import aerys.minko.type.parser.collada.resource.IResource;
	import aerys.minko.type.parser.collada.resource.image.data.AbstractImageData;
	import aerys.minko.type.parser.collada.resource.image.data.ImageDataFactory;
	
	public class Image implements IResource
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _document	: ColladaDocument;
		
		private var _id			: String;
		private var _sid		: String;
		private var _name		: String;
		private var _imageData	: AbstractImageData;
		
		public function get id()		: String			{ return _id; }
		public function get sid()		: String			{ return _sid; }
		public function get name()		: String			{ return _name; }
		public function get imageData()	: AbstractImageData	{ return _imageData; }
		
		public static function fillStoreFromXML(xmlDocument	: XML,
												document	: ColladaDocument, 
												store		: Object) : void
		{
			var xmlImageLibrary	: XML	= xmlDocument..NS::library_images[0];
			if (!xmlImageLibrary)
				return;
			
			var xmlImages	: XMLList	= xmlImageLibrary.NS::image;
			
			for each (var xmlImage : XML in xmlImages)
			{
				var image : Image = createFromXML(xmlImage, document);
				
				store[image.id] = image;
			}
		}
		
		public static function createFromXML(xmlImage : XML, document : ColladaDocument) : Image
		{
			var image : Image = new Image();
			
			image._document 	= document;
			image._id			= xmlImage.@id;
			image._sid			= xmlImage.@sid;
			image._name			= xmlImage.@name;
			image._imageData	= ImageDataFactory.createImageData(xmlImage.children()[0], document);
			
			return image;
		}
		
		public function createInstance() : IInstance
		{
			return new InstanceImage(_id, _document);
		}
	}
}