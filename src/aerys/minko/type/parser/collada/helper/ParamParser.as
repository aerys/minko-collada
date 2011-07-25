package aerys.minko.type.parser.collada.helper
{
	import aerys.minko.type.error.collada.ColladaError;

	public class ParamParser
	{
		private static const _PARSERS : Object = {
			'bool'				: notYetImplemented,
			'bool2'				: notYetImplemented,
			'bool3'				: notYetImplemented,
			'bool4'				: notYetImplemented,
			
			'int'				: notYetImplemented,
			'int2'				: notYetImplemented,
			'int3'				: notYetImplemented,
			'int4'				: notYetImplemented,
			
			'float'				: notYetImplemented,
			'float2'			: notYetImplemented,
			'float3'			: notYetImplemented,
			'float4'			: notYetImplemented,
			
			'float2x1'			: notYetImplemented,
			'float2x2'			: notYetImplemented,
			'float2x3'			: notYetImplemented,
			'float2x4'			: notYetImplemented,
			
			'float3x1'			: notYetImplemented,
			'float3x2'			: notYetImplemented,
			'float3x3'			: notYetImplemented,
			'float3x4'			: notYetImplemented,
			
			'float4x1'			: notYetImplemented,
			'float4x2'			: notYetImplemented,
			'float4x3'			: notYetImplemented,
			'float4x4'			: notYetImplemented,
			
			'enum'				: notYetImplemented,
			'sampler_image'		: notYetImplemented,
			'sampler_states'	: notYetImplemented
		};
		
		public static function parseParam(xml : XML) : *
		{
			return null;
			
			var localName : String = xml.localName();
			return _PARSERS[localName](xml);
		}
		
		private static function notYetImplemented(xml : XML) : *
		{
			throw new ColladaError('Not yet implemented');
		}
	}
}