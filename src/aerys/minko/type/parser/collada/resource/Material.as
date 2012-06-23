package aerys.minko.type.parser.collada.resource
{
	import aerys.minko.type.data.DataProvider;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.instance.IInstance;
	import aerys.minko.type.parser.collada.instance.InstanceEffect;
	import aerys.minko.type.parser.collada.instance.InstanceMaterial;
	import aerys.minko.type.parser.collada.resource.effect.Effect;
	import aerys.minko.type.parser.collada.resource.effect.profile.ProfileCommon;
	import aerys.minko.type.parser.collada.resource.effect.technique.ITechnique;
	
	public class Material implements IResource
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		private static const DEFAULT_PROVIDER : DataProvider = new DataProvider({diffuseColor: 0x00ff00ff});
		
		public static function get defaultProvider() : DataProvider
		{
			return DEFAULT_PROVIDER;
		}
		
		private var _document		: ColladaDocument;
		private var _id				: String;
		private var _name			: String;
		private var _instanceEffect : InstanceEffect;
		
		public function get id() : String
		{
			return _id;
		}
		
		public function get name() : String
		{
			return _name;
		}
		
		public function get instanceEffect() : InstanceEffect
		{
			return _instanceEffect;
		}
		
		public function get dataProvider() : DataProvider
		{
			return _instanceEffect.dataProvider;
		}
		
		public static function fillStoreFromXML(xmlDocument	: XML,
												document	: ColladaDocument, 
												store		: Object) : void
		{
			var xmlMaterialLibrary	: XML		= xmlDocument..NS::library_materials[0];
			if (!xmlMaterialLibrary)
				return;
			
			var xmlMaterials 		: XMLList	= xmlMaterialLibrary.NS::material;
			
			for each (var xmlMaterial : XML in xmlMaterials)
			{
				var material : Material = createFromXML(xmlMaterial, document);
				store[material.id] = material;
			}
		}
		
		public static function createFromXML(xmlMaterial : XML, document : ColladaDocument) : Material
		{
			var id					: String			= xmlMaterial.@id;
			var name				: String			= xmlMaterial.@name;
			var instanceEffect		: InstanceEffect	= InstanceEffect.createFromXML(
				xmlMaterial.NS::instance_effect[0], 
				document
			);
			
			return new Material(id, name, instanceEffect, document);
		}
		
		public function Material(id				: String,
								 name			: String, 
								 instanceEffect	: InstanceEffect,
								 document		: ColladaDocument)
		{
			_id				= id;
			_name			= name;
			_instanceEffect	= instanceEffect;
			_document		= document;
		}
		
		public function createInstance() : IInstance
		{
			return new InstanceMaterial(_id, null, _document); 
		}
		
//		/**
//		 * FIXME: This must be refactored ASAP
//		 */		
//		public function computeDiffuse() : Object
//		{
//			// Retrieve all objects that defines a material.
//			// Let's assume the defaut profile is the first one and it is a ProfileCommon
//			var instanceEffect	: InstanceEffect	= this.instanceEffect;
//			var effect			: Effect			= instanceEffect.resource as Effect;
//			var profile			: ProfileCommon		= effect.profiles[0] as ProfileCommon;
//			var technique		: ITechnique		= profile.technique;
//			
//			// override parameters.
//			var key					: String;
//			var profileParameters	: Object = profile.params;
//			var effectParameters	: Object = effect.params;
//			var finalParameters		: Object = new Object();
//			
//			for (key in profileParameters)
//				finalParameters[key] = profileParameters[key];
//			for (key in effectParameters)
//				finalParameters[key] = effectParameters[key];
//			
//			// retrieve diffuse color/texture
//			var diffuse : CommonColorOrTexture;
//			
//			if (technique is Constant)
//				diffuse = CommonColorOrTexture.createFromColor(0xffffffff);
//			else if (technique is ILightedTechnique)
//				diffuse = ILightedTechnique(technique).diffuse;
//			else
//			{
//				Minko.log(DebugLevel.PLUGIN_WARNING, 'ColladaPlugin: The profile ' 
//					+ profile.id + ' uses an invalid, or not supported technique. ' +
//					'Its diffuse value cannot be read, and will be replaced by ' +
//					'a random color.');
//				
//				return new Vector4(Math.random(), Math.random(), Math.random(), 1);
//			}
//			
//			var textureName : String = diffuse.textureName;
//			
//			if (textureName)
//			{
//				var image 	: Image = _document.getImageById(textureName);
//				
//				// try to find the texture name in the (effect) parameters
//				while (!image && finalParameters.hasOwnProperty(textureName))
//				{
//					var parameterValue : Object = finalParameters[textureName];
//					
//					if (parameterValue is AbstractImageData)
//						textureName = (parameterValue as AbstractImageData).path;
//					else
//						textureName = parameterValue as String;
//					
//					image = _document.getImageById(textureName);
//				}
//				
//				if (image && image.imageData.textureResource)
//					return image.imageData.textureResource;
//				else
//				{
//					Minko.log(DebugLevel.PLUGIN_WARNING, 'ColladaPlugin: The texture '
//						+ image.name + ' could not be loaded. It has beed replaced' +
//						' by a random color.');
//					
//					return new Vector4(Math.random(), Math.random(), Math.random(), 1);
//				}
//			}
//			else
//			{
//				var color : uint = diffuse.color;
//				
//				return new Vector4(
//					(color & 0xff) / 255,
//					((color >> 8) & 0xff) / 255,
//					((color >> 16) & 0xff) / 255,
//					((color >> 24) & 0xff) / 255
//				);
//			}
//		}
	}
}