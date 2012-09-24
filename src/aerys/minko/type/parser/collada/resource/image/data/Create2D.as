package aerys.minko.type.parser.collada.resource.image.data
{
	public class Create2D extends AbstractImageData
	{
		public static function createFromXML(xml : XML) : Create2D
		{
			return new Create2D();
		}
		
		public function Create2D()
		{
			super(null);
			
			throw new Error('The \'create_2d\' collada token is not yet ' +
				'supported. Minko is open-source! Feel free to improve it.');
		}
	}
}
