package aerys.minko.type.parser.collada.resource.controller
{
	import aerys.minko.type.parser.collada.ColladaDocument;

	public class Morph
	{
		public static function createFromXML(xmlMorph : XML, 
											 document : ColladaDocument) : Morph
		{
			throw new Error('Collada morphing is not yet supported.');
		}
	}
}
