package aerys.minko.type.parser.collada.resource.image.data
{
	import aerys.minko.type.error.collada.ColladaError;
	
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;

	public class CreateCube extends AbstractImageData
	{
		public static function createFromXML(xml : XML) : CreateCube
		{
			return new CreateCube();
		}
		
		public function CreateCube()
		{
			super(null);
			
			throw new Error('The \'create_cube\' collada token is not yet ' +
				'supported. Minko is open-source! Feel free to improve it.');
		}
	}
}