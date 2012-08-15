package aerys.minko.type.parser.collada.resource.effect.profile
{
	import aerys.minko.render.material.Material;

	public interface IProfile
	{
		function createMaterial(params : Object, setParams : Object) : Material;
	}
}