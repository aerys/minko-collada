package aerys.minko.type.parser.collada.resource.light
{
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.instance.IInstance;
	import aerys.minko.type.parser.collada.instance.InstanceLight;
	import aerys.minko.type.parser.collada.resource.IResource;
	
	public final class Light implements IResource
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _document		: ColladaDocument;
		
		private var _id				: String;
		private var _name			: String;
		private var _sid			: String;
		
		private var _ambient		: Ambient;
		private var _point			: Point;
		private var _spot			: Spot;
		private var _directional	: Directional;

		public function Light(document 		: ColladaDocument,
							  id			: String,
							  name			: String,
							  sid			: String,
							  ambient		: Ambient,
							  directional	: Directional,
							  spot			: Spot,
							  point			: Point)
		{
			_document		= document;
			_id				= id;
			_name			= name;
			_sid			= sid;
			
			_ambient		= ambient;
			_directional	= directional;
			_spot			= spot;
			_point			= point;
		}
		
		public function get ambient():Ambient
		{
			return _ambient;
		}

		public function get directional():Directional
		{
			return _directional;
		}

		public function get spot():Spot
		{
			return _spot;
		}

		public function get point():Point
		{
			return _point;
		}

		public function get name():String
		{
			return _name;
		}

		public function get id() : String
		{
			return _id;
		}
		
		public function createInstance() : IInstance
		{
			return new InstanceLight(_document, _id, _name, _sid);
		}
		
		public static function fillStoreFromXML(xmlDocument	: XML,
												document	: ColladaDocument,
												store		: Object) : void
		{
			var xmlLightLibrary		: XML		= xmlDocument..NS::library_lights[0];
			if (!xmlLightLibrary)
				return;
			
			var xmlLights			: XMLList	= xmlLightLibrary.NS::light;
			var xmlLight			: XML		= null;
			
			for each (xmlLight in xmlLights)
			{
				var light	: Light	= Light.createFromXML(xmlLight, document);
				store[light.id] = light;
			}
		}
		
		public static function createFromXML(xmlLight : XML, document : ColladaDocument) : Light
		{
			var id					: String		= xmlLight.@id;
			var sid					: String		= xmlLight.@sid;
			var name				: String		= xmlLight.@name;
			var ambient				: Ambient		= null;
			var directional			: Directional	= null;
			var spot				: Spot			= null;
			var point				: Point			= null;
			
			var techniqueXml		: XML			= xmlLight.NS::technique_common[0];
			if (!techniqueXml)
				throw new Error();
			
			var ambientXml			: XML			= techniqueXml.NS::ambient[0];
			if (ambientXml)
				ambient = Ambient.createFromXML(ambientXml);
			
			var directionalXml		: XML			= techniqueXml.NS::directional[0];
			if (directionalXml)
				directional = Directional.createFromXML(directionalXml);

			var spotXml				: XML			= techniqueXml.NS::spot[0];
			if (spotXml)
				spot = Spot.createFromXML(spotXml);
			
			var pointXml			: XML			= techniqueXml.NS::point[0];
			if (pointXml)
				point = Point.createFromXML(pointXml);
			
			return new Light(document, id, name, sid, ambient, directional, spot, point);
		}
	}
}