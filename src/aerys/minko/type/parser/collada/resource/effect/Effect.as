package aerys.minko.type.parser.collada.resource.effect
{
	import aerys.minko.Minko;
	import aerys.minko.render.material.Material;
	import aerys.minko.type.loader.parser.ParserOptions;
	import aerys.minko.type.log.DebugLevel;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.instance.IInstance;
	import aerys.minko.type.parser.collada.instance.InstanceEffect;
	import aerys.minko.type.parser.collada.resource.IResource;
	import aerys.minko.type.parser.collada.resource.effect.profile.CommonProfile;
	import aerys.minko.type.parser.collada.resource.effect.profile.IProfile;
	
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
					case 'profile_COMMON':
						profiles.push(CommonProfile.createFromXML(child, document));
						break;
					
					case 'profile_BRIDGE':
					case 'profile_CG':
					case 'profile_GLES':
					case 'profile_GLES2':
					case 'profile_GLSL':
						Minko.log(DebugLevel.PLUGIN_WARNING,
							'Skipping profile "' + child.localName() + '" on effect "' + name + '". ' + 
							'Only profile_COMMON is supported, please check your export settings.'
						);
						break;
					
					case 'newparam':
						params[child.@sid] = NewParam.createFromXML(child, document);
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
		
		public function createMaterial(parserOptions : ParserOptions, setParams : Object) : Material
		{
			var profileCommon : CommonProfile = null;
			
			for each (var profile : IProfile in _profiles)
				if (profile is CommonProfile)
					profileCommon = CommonProfile(profile);
			
			if (!profileCommon)
			{
				Minko.log(DebugLevel.PLUGIN_WARNING, 'No valid profile was found for effect: ' + _name);
				return CommonProfile.DEFAULT_MATERIAL;
			}
			else
			{
				return profile.createMaterial(parserOptions, params, setParams);
			}
		}
		
		public function createInstance() : IInstance
		{
			return new InstanceEffect(_id, {}, _document);
		}
	}
}