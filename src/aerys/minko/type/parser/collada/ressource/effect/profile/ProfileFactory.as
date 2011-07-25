package aerys.minko.type.parser.collada.ressource.effect.profile
{
	import aerys.minko.type.parser.collada.ressource.effect.technique.ITechnique;

	public class ProfileFactory
	{
		private static const NAME_TO_PROFILE : Object = {
			'profile_BRIDGE'	: NotYetImplemented,
			'profile_CG'		: NotYetImplemented,
			'profile_COMMON'	: ProfileCommon,
			'profile_GLES'		: NotYetImplemented,
			'profile_GLES2'		: NotYetImplemented,
			'profile_GLSL'		: NotYetImplemented
		};
		
		public static function createProfile(xml : XML) : IProfile
		{
			var firstSonName : String = xml.localName();
			return NAME_TO_PROFILE[firstSonName].createFromXML(xml);
		}
	}
}

import aerys.minko.type.error.collada.ColladaError;
import aerys.minko.type.parser.collada.ressource.effect.profile.IProfile;

class NotYetImplemented implements IProfile
{
	public static function createFromXML(xml : XML) : NotYetImplemented
	{
		throw new ColladaError('Not yet implemented');
	}
}
