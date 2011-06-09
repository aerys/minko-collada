package aerys.minko.type.collada.intermediary
{
	import aerys.minko.data.parser.collada.ColladaParser;
	import aerys.minko.type.math.Matrix4x4;
	
	import flash.geom.Matrix3D;

	public final class Source
	{
//		private static const NS		: Namespace	= ColladaParser.NS;
		private static const TYPES	: Object	= {
			"float"		: Number,
			"Name"		: String,
			"float4x4"	: Matrix4x4
		};
		
		protected var _id			: String;
		protected var _stride		: uint;
		protected var _count		: uint;
		protected var _paramNames	: Vector.<String>;
		protected var _paramTypes	: Vector.<Class>;
		protected var _data			: Array;
		
		public function get id()			: String			{ return _id; }
		public function get stride()		: uint				{ return _stride; }
		public function get count()			: uint				{ return _count; }
		public function get paramNames()	: Vector.<String>	{ return _paramNames; }
		public function get paramTypes()	: Vector.<Class>	{ return _paramTypes; }
		public function get data()			: Array				{ return _data; }
		
		public static function createFromXML(xmlSource : XML) : Source
		{
			// fill the source object.
			var source : Source	= new Source();
			source._id			= String(xmlSource.@id);
			
			var xmlAccessor : XML = xmlSource..accessor[0];
			source._stride		= parseInt(String(xmlAccessor.@stride));
			source._count		= parseInt(String(xmlAccessor.@count));
			
			source._paramNames	= new Vector.<String>();
			source._paramTypes	= new Vector.<Class>();
			for each (var xmlParam : XML in xmlAccessor.param)
			{
				source._paramNames.push(String(xmlParam.@name));
				source._paramTypes.push(TYPES[String(xmlParam.@type)]);
			}
			
			// read data
			var xmlRawData		: XML		= source.(@id == String(xmlAccessor.@source).substr(1))[0];
			var rawData 		: Array		= String(xmlRawData).split(" ");
			var currentOffset	: uint		= 0;
			var currentDatum	: *;
			
			source._data = new Array();
			for (var index : uint = 0; index < source._count; ++index)
				for each (var paramType : Class in source._paramTypes)
			{
				if (paramType == String)
					currentDatum = rawData[currentOffset++];
				else if (paramType == Number)
					currentDatum = parseFloat(rawData[int(currentOffset++)]);
				else if (paramType == Matrix4x4)
					currentDatum = new Matrix4x4(
						parseFloat(rawData[int(currentOffset++)]), parseFloat(rawData[int(currentOffset++)]),
						parseFloat(rawData[int(currentOffset++)]), parseFloat(rawData[int(currentOffset++)]),
						parseFloat(rawData[int(currentOffset++)]), parseFloat(rawData[int(currentOffset++)]),
						parseFloat(rawData[int(currentOffset++)]), parseFloat(rawData[int(currentOffset++)]),
						parseFloat(rawData[int(currentOffset++)]), parseFloat(rawData[int(currentOffset++)]),
						parseFloat(rawData[int(currentOffset++)]), parseFloat(rawData[int(currentOffset++)]),
						parseFloat(rawData[int(currentOffset++)]), parseFloat(rawData[int(currentOffset++)]),
						parseFloat(rawData[int(currentOffset++)]), parseFloat(rawData[int(currentOffset++)])
					);
				else
					throw new Error('Unknown type found');
				source._data.push(currentDatum);
			}
			
			return source;
		}
		
		public function getItem(index : uint) : Object
		{
			var out : Object = new Object();
			
			for each (var paramName : String in _paramNames)
			out[paramName] = getComponentByParamName(index, paramName);
			
			return out;
		}
		
		public function getComponentByParamIndex(index : uint, paramIndex : uint) : Object
		{
			return _data[index * _paramNames.length + paramIndex];
		}
		
		public function getComponentByParamName(index : uint, paramName : String) : Object
		{
			return _data[index * _paramNames.length + _paramNames.indexOf(paramName)];
		}
		
		
	}
}