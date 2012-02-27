package aerys.minko.type.parser.collada.resource.controller
{
	import aerys.minko.ns.minko_collada;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.instance.IInstance;
	import aerys.minko.type.parser.collada.instance.InstanceController;
	import aerys.minko.type.parser.collada.resource.IResource;
	
	use namespace minko_collada;
	
	public class Controller implements IResource
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _document	: ColladaDocument;
		
		private var _id			: String;
		private var _name		: String;
		private var _skin		: Skin;
		private var _morph		: Morph;
		
		public function get id()	: String	{ return _id;	 }
		public function get name()	: String	{ return _name;	 }
		public function get skin()	: Skin		{ return _skin;	 }
		public function get morph()	: Morph		{ return _morph; }
		
		public static function fillStoreFromXML(xmlDocument	: XML,
												document	: ColladaDocument, 
												store		: Object) : void
		{
			var xmlControllerLibrary	: XML		= xmlDocument..NS::library_controllers[0];
			if (!xmlControllerLibrary)
				return;
			
			var xmlControllers 			: XMLList	= xmlControllerLibrary.NS::controller;
			
			for each (var xmlController : XML in xmlControllers)
			{
				var controller : Controller = Controller.createFromXML(xmlController, document);
				store[controller.id] = controller;
			}
		}
		
		public static function createFromXML(xmlController	: XML,
											 document		: ColladaDocument) : Controller
		{
			var id		: String = xmlController.@id;
			var name	: String = xmlController.@name;
			var skin	: Skin	 = null;
			var morph	: Morph	 = null;
			
			if (xmlController.NS::skin.length() == 1)
				skin = Skin.createFromXML(xmlController.NS::skin[0], document);
			else if (xmlController.NS::morph.length() == 1)
				morph = Morph.createFromXML(xmlController.NS::morph[0], document);
			else
				throw new Error('Invalid Controller');
			
			return new Controller(id, name, skin, morph, document);
		}
		
		public function Controller(id		: String,
								   name		: String,
								   skin		: Skin,
								   morph	: Morph, 
								   document	: ColladaDocument)
		{
			_id			= id;
			_name		= name;
			_skin		= skin;
			_morph		= morph;
			_document	= document;
		}
		
		public function createInstance() : IInstance
		{ 
			return new InstanceController(_document, _id); 
		}
	}
}