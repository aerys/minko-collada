package aerys.minko.type.parser.collada.resource.camera
{
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.instance.IInstance;
	import aerys.minko.type.parser.collada.instance.InstanceCamera;
	import aerys.minko.type.parser.collada.resource.IResource;

	public final class Camera implements IResource
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _document		: ColladaDocument;
		
		private var _id				: String;
		private var _name			: String;
		private var _perspective	: Perspective;
		private var _sid			: String;
		
		public function get id()	: String { return _id; }
		public function get name()	: String { return _name; }
		
		public function get perspective() : Perspective { return _perspective; }

		public function Camera(document 	: ColladaDocument,
							   id			: String,
							   name			: String,
							   sid			: String,
							   perspective 	: Perspective)
		{
			_document		= document;
			_id				= id;
			_name			= name;
			_sid			= sid;
			_perspective	= perspective;
		}
		
		public static function fillStoreFromXML(xmlDocument	: XML,
												document	: ColladaDocument, 
												store		: Object) : void
		{
			var xmlCameraLibrary	: XML		= xmlDocument..NS::library_cameras[0];
			if (!xmlCameraLibrary)
				return;
			
			var xmlCameras 			: XMLList	= xmlCameraLibrary.NS::camera;
			
			for each (var xmlCamera : XML in xmlCameras)
			{
				var camera : Camera = Camera.createFromXML(xmlCamera, document);
				store[camera.id] = camera;
			}
		}
		
		public function createInstance() : IInstance
		{
			return new InstanceCamera(_document, _id, _name, _sid); 
		}
		
		public static function createFromXML(xmlCamera : XML, document : ColladaDocument) : Camera
		{
			var id					: String		= xmlCamera.@id;
			var sid					: String		= xmlCamera.@sid;
			var name				: String		= xmlCamera.@name;
			var perspective			: Perspective	= null;
			
			var opticsXml			: XML			= xmlCamera.NS::optics[0];
			if (!opticsXml)
				throw new Error();
			
			var techniqueXml		: XML			= opticsXml.NS::technique_common[0];
			if (!techniqueXml)
				throw new Error();
			
			var perspectiveXmlList	: XMLList		= techniqueXml.NS::perspective;
			if (perspectiveXmlList)
			{
				perspective = Perspective.createFromXml(perspectiveXmlList[0]);
			}
			
			return new Camera(document, id, name, sid, perspective);
		}
	}
}