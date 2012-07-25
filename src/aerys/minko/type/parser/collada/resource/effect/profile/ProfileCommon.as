package aerys.minko.type.parser.collada.resource.effect.profile
{
	import aerys.minko.render.material.Material;
	import aerys.minko.render.material.basic.BasicMaterial;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.resource.effect.NewParam;
	import aerys.minko.type.parser.collada.resource.effect.technique.Blinn;
	import aerys.minko.type.parser.collada.resource.effect.technique.Constant;
	import aerys.minko.type.parser.collada.resource.effect.technique.ITechnique;
	import aerys.minko.type.parser.collada.resource.effect.technique.Lambert;
	import aerys.minko.type.parser.collada.resource.effect.technique.Phong;

	public class ProfileCommon implements IProfile
	{
		public static const NS					: Namespace		= new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		public static const DEFAULT_MATERIAL	: Material		= new BasicMaterial({ diffuseColor: 0x00ff00ff });
		
		private var _id			: String;
		private var _params		: Object;
		private var _technique	: ITechnique;
		private var _document	: ColladaDocument;
		
		public function get id()		: String		{ return _id; }
		public function get params()	: Object		{ return _params; }
		public function get technique()	: ITechnique	{ return _technique; }
		
		public static function createFromXML(xml : XML, document : ColladaDocument) : ProfileCommon
		{
			var id				: String		= xml.@id;
			
			// parse technique.
			var xmlTechnique	: XML			= xml.NS::technique[0].children()[0];
			var technique		: ITechnique	= null;
			switch (xmlTechnique.localName())
			{
				case 'blinn':		
					technique = Blinn.createFromXML(xmlTechnique, document);  
					break;
				case 'constant':	
					technique = Constant.createFromXML(xmlTechnique, document);  
					break;
				case 'lambert':		
					technique = Lambert.createFromXML(xmlTechnique, document);  
					break;
				case 'phong':		
					technique = Phong.createFromXML(xmlTechnique, document);  
					break;
			}
			
			// parse parameters.
			var params : Object = new Object();
			for each (var xmlNewParam : XML in xml.NS::newparam)
				params[xmlNewParam.@sid] = NewParam.createFromXML(xmlNewParam, document);
			
			return new ProfileCommon(id, params, technique, document);
		}
		
		public function ProfileCommon(id		: String,
									  params	: Object,
									  technique	: ITechnique,
									  document	: ColladaDocument)
		{
			_id			= id;
			_params		= params;
			_technique	= technique;
			
			_document	= document;
		}
		
		public function createMaterial(params : Object, setParams : Object) : Material
		{
			var key			: String;
			var localParams : Object = new Object();
			
			for (key in params)
				localParams[key] = params[key];
			for (key in _params)
				localParams[key] = _params[key];
			
			return _technique.createMaterial(localParams, setParams);
		}
	}
}
