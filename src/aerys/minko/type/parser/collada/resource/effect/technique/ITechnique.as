package aerys.minko.type.parser.collada.resource.effect.technique
{
	import aerys.minko.render.material.Material;
	import aerys.minko.type.parser.collada.resource.effect.CommonColorOrTextureOrParam;

	public interface ITechnique
	{
		function get emission()				: CommonColorOrTextureOrParam;
		function get reflective()			: CommonColorOrTextureOrParam;
		function get reflectivity()			: Number;
		function get transparent()			: CommonColorOrTextureOrParam;
		function get transparency()			: Number;
		function get indexOfRefraction()	: Number;
		
		function createMaterial(params : Object, setParams: Object) : Material;
	}
}
