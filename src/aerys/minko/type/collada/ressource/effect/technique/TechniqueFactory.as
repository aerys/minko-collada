package aerys.minko.type.collada.ressource.effect.technique
{
	public class TechniqueFactory
	{
		private static const NAME_TO_TECHNIQUE : Object = {
			'blinn'		: Blinn,
			'constant'	: Constant,
			'lambert'	: Lambert,
			'phong'		: Phong
		};
		
		public static function createTechnique(xml : XML) : ITechnique
		{
			var firstSonName : String = xml.children()[0].localName();
			return NAME_TO_TECHNIQUE[firstSonName].createFromXML(xml);
		}
	}
}
