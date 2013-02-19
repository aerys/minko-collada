package aerys.minko.type.parser.collada.resource.light
{
	import aerys.minko.type.math.Vector4;
	import aerys.minko.type.parser.collada.helper.NumberListParser;

	public final class Spot
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");

		private var _color					: Vector4;
		private var _constantAttenunation	: Number;
		private var _linearAttenuation		: Number;
		private var _quadraticAttenuation	: Number;
		private var _falloffAngle			: Number;
		private var _falloffExp				: Number;

		public function get falloffExp():Number
		{
			return _falloffExp;
		}

		public function set falloffExp(value:Number):void
		{
			_falloffExp = value;
		}

		public function get falloffAngle():Number
		{
			return _falloffAngle;
		}

		public function set falloffAngle(value:Number):void
		{
			_falloffAngle = value;
		}

		public function get quadraticAttenuation():Number
		{
			return _quadraticAttenuation;
		}

		public function set quadraticAttenuation(value:Number):void
		{
			_quadraticAttenuation = value;
		}

		public function get linearAttenuation():Number
		{
			return _linearAttenuation;
		}

		public function set linearAttenuation(value:Number):void
		{
			_linearAttenuation = value;
		}

		public function get constantAttenunation():Number
		{
			return _constantAttenunation;
		}

		public function set constantAttenunation(value:Number):void
		{
			_constantAttenunation = value;
		}

		public function get color():Vector4
		{
			return _color;
		}
		
		public function set color(value:Vector4):void
		{
			_color = value;
		}

		public function Spot(color			: Vector4,
							 constantAtt	: Number,
							 linearAtt		: Number,
							 quadraticAtt	: Number,
							 falloffAngle	: Number,
							 falloffExp		: Number)
		{
			_color					= color;
			_constantAttenunation	= constantAtt;
			_linearAttenuation		= linearAtt;
			_quadraticAttenuation	= quadraticAtt;
			_falloffAngle			= falloffAngle;
			_falloffExp				= falloffExp;
		}
		
		public static function createFromXML(xml : XML) : Spot
		{
			var color			: Vector4	= NumberListParser.parseVector3(xml.NS::color[0]);
			var constantAtt		: Number	= 1.;
			var linearAtt		: Number	= .0;
			var quadraticAtt	: Number	= .0;
			var falloffAngle	: Number	= 180.;
			var falloffExponent	: Number	= .0;
			
			var constantAttXml		: XML		= xml.NS::constant_attenuation[0];
			if (constantAttXml)
				constantAtt = parseFloat(constantAttXml);
			var linearAttXml		: XML		= xml.NS::linear_attenuation[0];
			if (linearAttXml)
				linearAtt = parseFloat(linearAttXml);
			var quadraticAttXml		: XML		= xml.NS::quadratic_attenuation[0];
			if (quadraticAttXml)
				quadraticAtt = parseFloat(quadraticAttXml);
			var falloffAngleXml		: XML		= xml.NS::falloff_angle[0];
			if (falloffAngleXml)
				falloffAngle = parseFloat(falloffAngleXml);
			var falloffExponentXml	: XML		= xml.NS::falloff_exponent[0];
			if (falloffExponentXml)
				falloffExponent = parseFloat(falloffExponentXml);
			
			return new Spot(
				color, constantAtt, linearAtt, quadraticAtt, falloffAngle, falloffExponent
			);
		}
	}
}