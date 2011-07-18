package aerys.minko.type.collada.ressource.image.data
{
	public class ImageDataFactory
	{
		private static const NAME_TO_IMGDATA : Object = {
			'init_from'		: InitFrom,
			'create_2d'		: Create2D,
			'create_3d'		: Create3D,
			'create_cube'	: CreateCube
		};
		
		public static function createImageData(xml : XML) : IImageData
		{
			var firstSonName : String = xml.localName();
			return NAME_TO_IMGDATA[firstSonName].createFromXML(xml);
		}
	}
}