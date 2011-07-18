package aerys.minko.type.parser.collada.helper
{
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.math.Vector4;
	
	public class NumberListParser
	{
		public static function parseIntList(xml : XML) : Vector.<int>
		{
			var data		: Array			= String(xml).replace(/[ \t\n\r]+/g, ' ').split(' ');
			var dataLength	: uint			= data.length;
			var result		: Vector.<int>	= new Vector.<int>();
			
			for (var i : uint = 0; i < dataLength; ++i)
				result.push(parseInt(data[i]));
			
			return result;
		}
		
		public static function parseUintList(xml : XML) : Vector.<uint>
		{
			var data		: Array			= String(xml).replace(/[ \t\n\r]+/g, ' ').split(' ');
			var dataLength	: uint			= data.length;
			var result		: Vector.<uint>	= new Vector.<uint>();
			
			for (var i : uint = 0; i < dataLength; ++i)
				result.push(parseInt(data[i]));
			
			return result;
		}
		
		public static function parseNumberList(xml : XML) : Vector.<Number>
		{
			var data		: Array				= String(xml).replace(/[ \t\n\r]+/g, ' ').split(' ');
			var dataLength	: uint				= data.length;
			var result		: Vector.<Number>	= new Vector.<Number>();
			
			for (var i : uint = 0; i < dataLength; ++i)
				result.push(parseFloat(data[i]));
			
			return result;
		}
		
		public static function parseVector3List(xml : XML) : Vector.<Vector4>
		{
			var data		: Array				= String(xml).replace(/[ \t\n\r]+/g, ' ').split(' ');
			var dataLength	: uint				= data.length;
			var result		: Vector.<Vector4>	= new Vector.<Vector4>();
			
			if (dataLength % 3 != 0)
				throw new Error('Invalid data length');
			
			for (var i : uint = 0; i < dataLength; i += 3)
			{
				var float1	: Number = parseFloat(data[i]);
				var float2	: Number = parseFloat(data[uint(i + 1)]);
				var float3	: Number = parseFloat(data[uint(i + 2)]);
				
				var vector	: Vector4 = new Vector4(float1, float2, float3);
				
				result.push(vector);
			}
			
			return result;
		}
		
		public static function parseVector4List(xml : XML) : Vector.<Vector4>
		{
			var data		: Array				= String(xml).replace(/[ \t\n\r]+/g, ' ').split(' ');
			var dataLength	: uint				= data.length;
			var result		: Vector.<Vector4>	= new Vector.<Vector4>();
			
			if (dataLength % 4 != 0)
				throw new Error('Invalid data length');
			
			for (var i : uint = 0; i < dataLength; i += 4)
			{
				var float1	: Number = parseFloat(data[i]);
				var float2	: Number = parseFloat(data[uint(i + 1)]);
				var float3	: Number = parseFloat(data[uint(i + 2)]);
				var float4	: Number = parseFloat(data[uint(i + 3)]);
				
				var vector	: Vector4 = new Vector4(float1, float2, float3, float4);
				
				result.push(vector);
			}
			
			return result;
		}
		
		public static function parseMatrix3x3List(xml : XML) : Vector.<Matrix4x4>
		{
			var data		: Array					= String(xml).replace(/[ \t\n\r]+/g, ' ').split(' ');
			var dataLength	: uint					= data.length;
			var result		: Vector.<Matrix4x4>	= new Vector.<Matrix4x4>();
			
			if (dataLength % 9 != 0)
				throw new Error('Invalid data length');
			
			for (var i : uint = 0; i < dataLength; i += 9)
			{
				var matrix	: Matrix4x4	= new Matrix4x4(
					parseFloat(data[i]),		parseFloat(data[i + 1]),	parseFloat(data[i + 2]),	0,
					parseFloat(data[i + 3]),	parseFloat(data[i + 4]),	parseFloat(data[i + 5]),	0,
					parseFloat(data[i + 6]),	parseFloat(data[i + 7]),	parseFloat(data[i + 8]),	0,
					0,							0,							0,							1
				).transpose();
				
				result.push(matrix);
			}
			
			return result;
		}
		
		public static function parseMatrix4x4List(xml : XML) : Vector.<Matrix4x4>
		{
			var data		: Array					= String(xml).replace(/[ \t\n\r]+/g, ' ').split(' ');
			var dataLength	: uint					= data.length;
			var result		: Vector.<Matrix4x4>	= new Vector.<Matrix4x4>();
			
			if (dataLength % 16 != 0)
				throw new Error('Invalid data length');
			
			for (var i : uint = 0; i < dataLength; i += 16)
			{
				var matrix	: Matrix4x4	= new Matrix4x4(
					parseFloat(data[i]),		parseFloat(data[i + 1]),	parseFloat(data[i + 2]),	parseFloat(data[i + 3]),
					parseFloat(data[i + 4]),	parseFloat(data[i + 5]),	parseFloat(data[i + 6]),	parseFloat(data[i + 7]),
					parseFloat(data[i + 8]),	parseFloat(data[i + 9]),	parseFloat(data[i + 10]),	parseFloat(data[i + 11]),
					parseFloat(data[i + 12]),	parseFloat(data[i + 13]),	parseFloat(data[i + 14]), parseFloat(data[i + 15])
				).transpose();
				
				result.push(matrix);
			}
			
			return result;
		}
		
		public static function parseVector3(xml : XML) : Vector4
		{
			var data		: Array		= String(xml).replace(/[ \t\n\r]+/g, ' ').split(' ');
			var dataLength	: uint		= data.length;
			
			var float1		: Number	= parseFloat(data[0]);
			var float2		: Number	= parseFloat(data[1]);
			var float3		: Number	= parseFloat(data[2]);
			
			if (dataLength != 3)
				throw new Error('Invalid data length');
			
			return new Vector4(float1, float2, float3);
		}
		
		public static function parseVector4(xml : XML) : Vector4
		{
			var data		: Array		= String(xml).replace(/[ \t\n\r]+/g, ' ').split(' ');
			var dataLength	: uint		= data.length;
			
			var float1		: Number	= parseFloat(data[0]);
			var float2		: Number	= parseFloat(data[1]);
			var float3		: Number	= parseFloat(data[2]);
			var float4		: Number	= parseFloat(data[3]);
			
			if (dataLength != 4)
				throw new Error('Invalid data length');
			
			return new Vector4(float1, float2, float3, float4);
		}
		
		public static function parseMatrix3x3(xml : XML) : Matrix4x4
		{
			var data		: Array	= String(xml).replace(/[ \t\n\r]+/g, ' ').split(' ');
			var dataLength	: uint	= data.length;
			
			if (dataLength != 9)
				throw new Error('Invalid data length');
			
			return new Matrix4x4(
				parseFloat(data[0]),	parseFloat(data[1]),	parseFloat(data[2]),	0,
				parseFloat(data[3]),	parseFloat(data[4]),	parseFloat(data[5]),	0,
				parseFloat(data[6]),	parseFloat(data[7]),	parseFloat(data[8]),	0,
				0,						0,						0,						1
			).transpose();
		}
		
		public static function parseMatrix4x4(xml : XML) : Matrix4x4
		{
			var data		: Array	= String(xml).replace(/[ \t\n\r]+/g, ' ').split(' ');
			var dataLength	: uint	= data.length;
			
			if (dataLength != 16)
				throw new Error('Invalid data length');
			
			var matrix : Matrix4x4 = matrix = new Matrix4x4(
				parseFloat(data[0]),	parseFloat(data[1]),	parseFloat(data[2]),	parseFloat(data[3]),
				parseFloat(data[4]),	parseFloat(data[5]),	parseFloat(data[6]),	parseFloat(data[7]),
				parseFloat(data[8]),	parseFloat(data[9]),	parseFloat(data[10]),	parseFloat(data[11]),
				parseFloat(data[12]),	parseFloat(data[13]),	parseFloat(data[14]),	parseFloat(data[15])
			).transpose();
			
			return matrix;
		}
		
	}
}