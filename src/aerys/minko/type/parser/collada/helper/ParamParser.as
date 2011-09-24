package aerys.minko.type.parser.collada.helper
{
	import aerys.minko.type.error.collada.ColladaError;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.resource.image.data.InitFrom;

	public class ParamParser
	{
		private static const NS	: Namespace	= new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
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
			'sampler2D'			: sampler2DParser,
			'sampler_image'		: notYetImplemented,
			'sampler_states'	: notYetImplemented,
			
			'surface'			: surfaceParser
		};
		
		public static function parseParam(xml : XML) : *
		{
			var valueNode		: XML		= xml.children()[0];
			var localName 		: String 	= valueNode.localName();
			var parserFunction	: Function	= _PARSERS[localName];
			
			// FIXME: throw the exception but handle it properly
			if (parserFunction == null || parserFunction == notYetImplemented)
				return null;
			
			return parserFunction(valueNode);
		}
		
		private static function surfaceParser(param : XML) : Object
		{
			if (param.@type != "2D")
				notYetImplemented(param);
			
			return InitFrom.createFromXML(param.NS::init_from[0]);
		}
		
		private static function sampler2DParser(param : XML) : Object
		{
			// FIXME: what should we store if there is more than <source> ?
			
			return param.NS::source[0].toString();
		}
		
		private static function notYetImplemented(xml : XML) : *
		{
			throw new ColladaError('Not yet implemented');
		}
	}
}