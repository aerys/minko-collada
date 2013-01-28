package aerys.minko.type.parser.collada.resource.effect.profile
{
	import aerys.minko.render.material.Material;
	import aerys.minko.type.loader.parser.ParserOptions;

	public interface IProfile
	{
		function createMaterial(parserOptions 	: ParserOptions,
								params 			: Object,
								setParams 		: Object) : Material;
	}
}