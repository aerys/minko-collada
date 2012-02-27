package aerys.minko.type.parser.collada.instance
{
	import aerys.minko.Minko;
	import aerys.minko.scene.node.ISceneNode;
	import aerys.minko.type.loader.parser.ParserOptions;
	import aerys.minko.type.log.DebugLevel;
	import aerys.minko.type.math.Vector4;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.resource.IResource;
	import aerys.minko.type.parser.collada.resource.Material;
	import aerys.minko.type.parser.collada.resource.effect.CommonColorOrTexture;
	import aerys.minko.type.parser.collada.resource.effect.Effect;
	import aerys.minko.type.parser.collada.resource.effect.profile.ProfileCommon;
	import aerys.minko.type.parser.collada.resource.effect.technique.Constant;
	import aerys.minko.type.parser.collada.resource.effect.technique.ILightedTechnique;
	import aerys.minko.type.parser.collada.resource.effect.technique.ITechnique;
	import aerys.minko.type.parser.collada.resource.image.Image;
	import aerys.minko.type.parser.collada.resource.image.data.AbstractImageData;
	
	import flash.events.EventDispatcher;
	
	public class InstanceMaterial extends EventDispatcher implements IInstance
	{
		private var _document	: ColladaDocument	= null;
		private var _sourceId	: String	= null;
		private var _symbol		: String	= null;
		
		public function get sourceId()	: String { return _sourceId;	}
		public function get symbol()	: String { return _symbol;		}
		
		public function get resource() : IResource
		{
			return _document.getMaterialById(_sourceId);
		}
		
		public static function createFromXML(xml : XML, document : ColladaDocument) : InstanceMaterial
		{
			var sourceId	: String = String(xml.@target).substr(1);
			var symbol		: String = xml.@symbol;;
			
			return new InstanceMaterial(sourceId, symbol, document);
		}
		
		public function InstanceMaterial(sourceId : String, 
										 symbol : String, 
										 document : ColladaDocument)
		{
			_document	= document;
			_symbol		= symbol;
			_sourceId	= sourceId;
		}
		
		public function createSceneNode(options				: ParserOptions,
										sourceIdToSceneNode	: Object,
										scopedIdToSceneNode	: Object) : ISceneNode
		{
			throw new Error('Materials cannot be mapped to sceneNodes');
		}
		
		/**
		 * FIXME: This must be refactored ASAP
		 */		
		public function computeDiffuse() : Object
		{
			// Retrieve all objects that defines a material.
			// Let's assume the defaut profile is the first one and it is a ProfileCommon
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
			{
				Minko.log(DebugLevel.PLUGIN_WARNING, 'ColladaPlugin: The profile ' 
					+ profile.id + ' uses an invalid, or not supported technique. ' +
					'Its diffuse value cannot be read, and will be replaced by ' +
					'pure green.');
				
				return new Vector4(0, 1, 0, 1);
			}
			
			var textureName : String = diffuse.textureName;
			
			if (textureName)
			{
				var image 	: Image = _document.getImageById(textureName);
				
				// try to find the texture name in the (effect) parameters
				while (!image && finalParameters.hasOwnProperty(textureName))
				{
					var parameterValue : Object = finalParameters[textureName];
					
					if (parameterValue is AbstractImageData)
						textureName = (parameterValue as AbstractImageData).path;
					else
						textureName = parameterValue as String;
					
					image = _document.getImageById(textureName);
				}
				
				if (image && image.imageData.textureResource)
					return image.imageData.textureResource;
				else
				{
					Minko.log(DebugLevel.PLUGIN_WARNING, 'ColladaPlugin: The texture '
						+ image.name + ' could not be loaded. It has beed replaced' +
						' by pure green.');
					
					return new Vector4(0, 1, 0, 1);
				}
			}
			else
			{
				var color : uint = diffuse.color;
				
				return new Vector4(
					(color & 0xff) / 255,
					((color >> 8) & 0xff) / 255,
					((color >> 16) & 0xff) / 255,
					((color >> 24) & 0xff) / 255
				);
			}
		}
	}
}