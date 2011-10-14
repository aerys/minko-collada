package aerys.minko.type.parser.collada.instance
{
	import aerys.minko.scene.node.IScene;
	import aerys.minko.scene.node.group.Group;
	import aerys.minko.scene.node.group.LoaderGroup;
	import aerys.minko.scene.node.texture.BitmapTexture;
	import aerys.minko.scene.node.texture.ColorTexture;
	import aerys.minko.scene.node.texture.ITexture;
	import aerys.minko.type.error.collada.ColladaError;
	import aerys.minko.type.parser.ParserOptions;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.resource.IResource;
	import aerys.minko.type.parser.collada.resource.Material;
	import aerys.minko.type.parser.collada.resource.effect.CommonColorOrTexture;
	import aerys.minko.type.parser.collada.resource.effect.Effect;
	import aerys.minko.type.parser.collada.resource.effect.profile.IProfile;
	import aerys.minko.type.parser.collada.resource.effect.profile.ProfileCommon;
	import aerys.minko.type.parser.collada.resource.effect.technique.Blinn;
	import aerys.minko.type.parser.collada.resource.effect.technique.Constant;
	import aerys.minko.type.parser.collada.resource.effect.technique.ILightedTechnique;
	import aerys.minko.type.parser.collada.resource.effect.technique.ITechnique;
	import aerys.minko.type.parser.collada.resource.effect.technique.Lambert;
	import aerys.minko.type.parser.collada.resource.effect.technique.Phong;
	import aerys.minko.type.parser.collada.resource.image.Image;
	import aerys.minko.type.parser.collada.resource.image.data.IImageData;
	import aerys.minko.type.parser.collada.resource.image.data.InitFrom;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	
	public class InstanceMaterial extends EventDispatcher implements IInstance
	{
		private static const DEFAULT_TEXTURE	: ITexture	= new ColorTexture(0xffffffff);
		
		private var _document	: ColladaDocument	= null;
		private var _sourceId	: String	= null;
		private var _symbol		: String	= null;
		
		public function get sourceId()	: String { return _sourceId;	}
		public function get symbol()	: String { return _symbol;		}
		
		public static function createFromXML(xml : XML, document : ColladaDocument) : InstanceMaterial
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
		
		public function get resource() : IResource
		{
			return _document.getMaterialById(_sourceId);
		}
		
		public function toScene() : IScene
		{
			// Retrieve all objects that defines a material.
			// We assume the defaut profile is the first one and it is a ProfileCommon
			
			var material		: Material			= resource as Material;
			var instanceEffect	: InstanceEffect	= material.instanceEffect;
			var effect			: Effect			= instanceEffect.resource as Effect;
			var profile			: ProfileCommon		= effect.profiles[0] as ProfileCommon;
			var technique		: ITechnique		= profile.technique;
			
			// override parameters.
			var key					: String;
			var profileParameters	: Object = profile.params;
			var effectParameters	: Object = effect.params;
			var finalParameters		: Object = new Object();
			
			for (key in profileParameters)
				finalParameters[key] = profileParameters[key];
			for (key in effectParameters)
				finalParameters[key] = effectParameters[key];
			
			// retrieve diffuse color/texture
			var diffuse : CommonColorOrTexture;
			
			if (technique is Constant)
				diffuse = CommonColorOrTexture.createFromColor(0xffffffff);
			else if (technique is ILightedTechnique)
				diffuse = ILightedTechnique(technique).diffuse;
			else
				throw new ColladaError('Unknown technique type');
			
			var textureName : String = diffuse.textureName;
			
			if (textureName)
			{
				var image 	: Image = _document.getImageById(textureName);
				
				// try to find the texture name in the (effect) parameters
				while (!image && finalParameters.hasOwnProperty(textureName))
				{
					var parameterValue : Object = finalParameters[textureName];
					
					if (parameterValue is IImageData)
						textureName = (parameterValue as IImageData).path;
					else
						textureName = parameterValue as String;
					
					image = _document.getImageById(textureName);
				}
				
				if (image && image.imageData.path)
				{
					var texture : IScene = getTextureFromPath(image.imageData.path);
					
					if (texture)
						return texture;
				}
				
				return DEFAULT_TEXTURE;
			}
			else
			{
				return new ColorTexture(diffuse.color & 0xffffff);
			}
		}
		
		private function getTextureFromPath(textureFilename : String) : IScene
		{
			var options	: ParserOptions	= _document.parserOptions;
			var result	: IScene		= null;
			
			if (options.loadTextures)
			{
				if (textureFilename != null)
					textureFilename = options.replaceDependencyPathFunction(textureFilename);
				
				if (textureFilename)
				{
					if (options.loadDependencyFunction != null)
					{
						result = options.loadDependencyFunction(textureFilename);
						result = options.replaceNodeFunction(result);
					}
					else
						return LoaderGroup.load(new URLRequest(textureFilename), options);
				}
			}
			
			return result;
		}
	}
}