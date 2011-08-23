package aerys.minko.type.parser.collada.resource.effect.technique
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
			var node		: XML		= xml.children()[0];
			var nodeName	: String	= node.localName();
			return NAME_TO_TECHNIQUE[nodeName].createFromXML(node);
		}
	}
}
