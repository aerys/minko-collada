package aerys.minko.type.parser.collada.resource.image.data
{
	public class Create3D extends AbstractImageData
	{
		public static function createFromXML(xml : XML) : Create3D
		{
			return new Create3D();
		}
		
		public function Create3D()
		{
			super(null);
			
			throw new Error('The \'create_3d\' collada token is not yet ' +
				'supported. Minko is open-source! Feel free to improve it.');
		}
	}
}
