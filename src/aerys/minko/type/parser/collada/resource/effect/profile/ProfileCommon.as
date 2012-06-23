package aerys.minko.type.parser.collada.resource.effect.profile
{
	import aerys.minko.type.data.DataProvider;
	import aerys.minko.type.parser.collada.helper.ParamParser;
	import aerys.minko.type.parser.collada.resource.effect.technique.ITechnique;
	import aerys.minko.type.parser.collada.resource.effect.technique.TechniqueFactory;

	public class ProfileCommon implements IProfile
	{
		public static const NS					: Namespace		= new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		public static const DEFAULT_PROVIDER	: DataProvider	= new DataProvider({ diffuseColor: 0x00ff00ff });
		
		private var _id			: String;
		private var _params		: Object;
		private var _technique	: ITechnique;
		
		public function get id()		: String		{ return _id; }
		public function get params()	: Object		{ return _params; }
		public function get technique()	: ITechnique	{ return _technique; }
		
		public static function createFromXML(xml : XML) : ProfileCommon
		{
			var id			: String		= xml.@id;
			var technique	: ITechnique	= TechniqueFactory.createTechnique(xml.NS::technique[0]);
			var params		: Object		= new Object();
			
			for each (var newparam : XML in xml.NS::newparam)
			{
				var paramName	: String	= newparam.@sid;
				var paramValue	: *			= ParamParser.parseParam(newparam);
				params[paramName] = paramValue;
			}
			
			return new ProfileCommon(id, params, technique);
		}
		
		public function ProfileCommon(id		: String,
									  params	: Object,
									  technique	: ITechnique)
		{
			_id			= id;
			_params		= params;
			_technique	= technique;
		}
		
		public function createDataProvider(params : Object) : DataProvider
		{
			return _technique.createDataProvider(params);
		}
	}
}
