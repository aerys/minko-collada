package aerys.minko.type.collada.ressource.effect
{
	import aerys.minko.type.collada.Document;
	import aerys.minko.type.collada.helper.ParamParser;
	import aerys.minko.type.collada.instance.IInstance;
	import aerys.minko.type.collada.instance.InstanceEffect;
	import aerys.minko.type.collada.ressource.IRessource;
	import aerys.minko.type.collada.ressource.effect.profile.IProfile;
	import aerys.minko.type.collada.ressource.effect.profile.ProfileFactory;
	
	public class Effect implements IRessource
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _document	: Document;
		
		private var _id			: String;
		private var _name		: String;
		private var _params		: Object;
		private var _profiles	: Vector.<IProfile>;
		
		
		public function get id()	: String { return _id;		}
		public function get name()	: String { return _name;	}
		
		public static function fillStoreFromXML(xmlDocument	: XML,
												document	: Document, 
												store		: Object) : void
		{
			var xmlEffectLibrary	: XML		= xmlDocument..NS::library_effects[0];
			if (!xmlEffectLibrary)
				return;
			
			var xmlEffects 			: XMLList	= xmlEffectLibrary.NS::effect;
			
			for each (var xmlEffect : XML in xmlEffects)
			{
				var effect : Effect = createFromXML(xmlEffect, document);
				store[effect.id] = effect;
			}
		}
		
		public static function createFromXML(xml		: XML, 
											 document	: Document) : Effect
		{
			var xmlProfile	: XML;
			var effect		: Effect = new Effect();
			
			effect._document	= document;
			effect._id			= xml.@id;
			effect._name		= xml.@name;
			
			effect._profiles	= new Vector.<IProfile>();
			for each (xmlProfile in xml.NS::profile_BRIDGE)
				effect._profiles.push(ProfileFactory.createProfile(xmlProfile));
			
			for each (xmlProfile in xml.NS::profile_CG)
				effect._profiles.push(ProfileFactory.createProfile(xmlProfile));
			
			for each (xmlProfile in xml.NS::profile_COMMON)
				effect._profiles.push(ProfileFactory.createProfile(xmlProfile));
			
			for each (xmlProfile in xml.NS::profile_GLES)
				effect._profiles.push(ProfileFactory.createProfile(xmlProfile));
			
			for each (xmlProfile in xml.NS::profile_GLES2)
				effect._profiles.push(ProfileFactory.createProfile(xmlProfile));
			
			for each (xmlProfile in xml.NS::profile_GLSL)
				effect._profiles.push(ProfileFactory.createProfile(xmlProfile));
			
			effect._params		= new Object();
			for each (var newparam : XML in xml.NS::newparam)
			{
				var paramName	: String	= newparam.@sid;
				var paramValue	: *			= ParamParser.parseParam(newparam);
				effect._params[paramName]	= paramValue;
			}
			
			return effect;
		}
		
		public function createInstance():IInstance
		{
			return InstanceEffect.createFromSourceId(_id, _document);
		}
	}
}