package aerys.minko.type.collada.ressource.effect.profile
{
	import aerys.minko.type.collada.helper.ParamParser;
	import aerys.minko.type.collada.ressource.effect.technique.Blinn;
	import aerys.minko.type.collada.ressource.effect.technique.Constant;
	import aerys.minko.type.collada.ressource.effect.technique.ITechnique;
	import aerys.minko.type.collada.ressource.effect.technique.Lambert;
	import aerys.minko.type.collada.ressource.effect.technique.Phong;
	import aerys.minko.type.collada.ressource.effect.technique.TechniqueFactory;

	public class ProfileCommon implements IProfile
	{
		public static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _id			: String;
		private var _params		: Object;
		private var _technique	: ITechnique;
		
		public static function createFromXML(xml : XML) : ProfileCommon
		{
			var profileCommon : ProfileCommon = new ProfileCommon();
			profileCommon._id			= xml.@id;
			profileCommon._technique	= TechniqueFactory.createTechnique(xml.NS::technique[0]);
			profileCommon._params		= new Object();
			
			for each (var newparam : XML in xml.NS::newparam)
			{
				var paramName	: String	= newparam.@sid;
				var paramValue	: *			= ParamParser.parseParam(newparam);
				profileCommon._params[paramName] = paramValue;
			}
			
			return profileCommon;
		}
		
	}
}