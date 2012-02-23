package aerys.minko.type.parser.collada.resource.effect
{
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.helper.ParamParser;
	import aerys.minko.type.parser.collada.instance.IInstance;
	import aerys.minko.type.parser.collada.instance.InstanceEffect;
	import aerys.minko.type.parser.collada.resource.IResource;
	import aerys.minko.type.parser.collada.resource.effect.profile.IProfile;
	import aerys.minko.type.parser.collada.resource.effect.profile.ProfileFactory;
	
	public class Effect implements IResource
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _document	: ColladaDocument;
		private var _id			: String;
		private var _name		: String;
		private var _params		: Object;
		private var _profiles	: Vector.<IProfile>;
		
		public function get id()		: String 			{ return _id;		}
		public function get name()		: String 			{ return _name;		}
		public function get params()	: Object 			{ return _params;	}
		public function get profiles()	: Vector.<IProfile>	{ return _profiles; }
		
		public static function fillStoreFromXML(xmlDocument	: XML,
												document	: ColladaDocument, 
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
											 document	: ColladaDocument) : Effect
		{
			var id			: String			= xml.@id;
			var name		: String			= xml.@name;
			var profiles	: Vector.<IProfile>	= new Vector.<IProfile>();
			var params		: Object			= new Object();
			
			for each (var child : XML in xml.children())
			{
				switch (child.localName())
				{
					case 'profile_BRIDGE':
					case 'profile_CG':
					case 'profile_COMMON':
					case 'profile_GLES':
					case 'profile_GLES2':
					case 'profile_GLSL':
						profiles.push(ProfileFactory.createProfile(child));
						break;
					
					case 'newparam':
						var paramName	: String	= child.@sid;
						var paramValue	: *			= ParamParser.parseParam(child);
						
						params[paramName]	= paramValue;
						break;
				}
			}
			
			return new Effect(id, name, params, profiles, document);
		}
		
		public function Effect(id		: String,
							   name		: String,
							   params	: Object,
							   profiles	: Vector.<IProfile>,
							   document	: ColladaDocument)
		{
			_id			= id;
			_name		= name;
			_params		= params;
			_profiles	= profiles;
			_document	= document;
		}
		
		public function createInstance() : IInstance
		{
			return new InstanceEffect(_id, {}, _document);
		}
	}
}