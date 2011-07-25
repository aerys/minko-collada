package aerys.minko.type.parser.collada.instance
{
	import aerys.minko.scene.node.IScene;
	import aerys.minko.scene.node.texture.BitmapTexture;
	import aerys.minko.scene.node.texture.ColorTexture;
	import aerys.minko.type.error.collada.ColladaError;
	import aerys.minko.type.parser.collada.Document;
	import aerys.minko.type.parser.collada.ressource.IRessource;
	import aerys.minko.type.parser.collada.ressource.Material;
	import aerys.minko.type.parser.collada.ressource.effect.CommonColorOrTexture;
	import aerys.minko.type.parser.collada.ressource.effect.Effect;
	import aerys.minko.type.parser.collada.ressource.effect.profile.IProfile;
	import aerys.minko.type.parser.collada.ressource.effect.profile.ProfileCommon;
	import aerys.minko.type.parser.collada.ressource.effect.technique.Blinn;
	import aerys.minko.type.parser.collada.ressource.effect.technique.Constant;
	import aerys.minko.type.parser.collada.ressource.effect.technique.ILightedTechnique;
	import aerys.minko.type.parser.collada.ressource.effect.technique.ITechnique;
	import aerys.minko.type.parser.collada.ressource.effect.technique.Lambert;
	import aerys.minko.type.parser.collada.ressource.effect.technique.Phong;
	import aerys.minko.type.parser.collada.ressource.image.Image;
	import aerys.minko.type.parser.collada.ressource.image.data.InitFrom;
	
	import flash.display.BitmapData;
	
	public class InstanceMaterial implements IInstance
	{
		private var _document	: Document;
		private var _sourceId	: String;
		private var _symbol		: String;
		
		public function get sourceId()	: String { return _sourceId;	}
		public function get symbol()	: String { return _symbol;		}
		
		public static function createFromXML(xml : XML, document : Document) : InstanceMaterial
		{
			var im : InstanceMaterial = new InstanceMaterial();
			im._document	= document;
			im._sourceId	= String(xml.@target).substr(1);
			im._symbol		= xml.@symbol;
			return im;
		}
		
		public function InstanceMaterial()
		{
		}
		
		public function get ressource() : IRessource
		{
			return _document.getMaterialById(_sourceId);
		}
		
		public function toScene() : IScene
		{
			// Retrieve all objects that defines a material.
			// We assume the defaut profile is the first one and it is a ProfileCommon
			
			var material		: Material			= ressource as Material;
			var instanceEffect	: InstanceEffect	= material.instanceEffect;
			var effect			: Effect			= instanceEffect.ressource as Effect;
			var profile			: ProfileCommon		= effect.profiles[0] as ProfileCommon;
			var technique		: ITechnique		= profile.technique;
			
			// override parameters.
			var key					: String;
			var profileParameters	: Object = profile.params;
			var effectParameters	: Object = effect.params;
			var finalParameters		: Object = new Object();
			for (key in profileParameters)	finalParameters[key] = profileParameters[key];
			for (key in effectParameters)	finalParameters[key] = effectParameters[key];
			
			// retrieve diffuse color/texture
			var diffuse : CommonColorOrTexture;
			if (technique is Constant)
			{
				diffuse = CommonColorOrTexture.createFromColor(0xffffffff);
			}
			else if (technique is ILightedTechnique)
			{
				diffuse = ILightedTechnique(technique).diffuse;
			}
			else throw new ColladaError('Unknown technique type');
			
			var textureName : String = diffuse.textureName;
			if (textureName)
			{
				var image : Image = _document.getImageById(textureName);
				if (image == null)
				{
					return new ColorTexture(0x00FF00);
				}
				else if (image.imageData.isLoaded)
				{
					return new BitmapTexture(image.imageData.bitmapData);
				}
				else
				{
					return new ColorTexture(0x0000FF);
				}
			}
			else
			{
				return new ColorTexture(diffuse.color & 0xffffff);
			}
		}
	}
}