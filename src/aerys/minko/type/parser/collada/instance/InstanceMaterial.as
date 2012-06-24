package aerys.minko.type.parser.collada.instance
{
	import aerys.minko.Minko;
	import aerys.minko.scene.node.ISceneNode;
	import aerys.minko.type.data.DataProvider;
	import aerys.minko.type.loader.parser.ParserOptions;
	import aerys.minko.type.log.DebugLevel;
	import aerys.minko.type.math.Vector4;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.resource.IResource;
	import aerys.minko.type.parser.collada.resource.Material;
	import aerys.minko.type.parser.collada.resource.effect.CommonColorOrTextureOrParam;
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
		
		public function get sourceId() : String
		{
			return _sourceId;
		}
		
		public function get symbol() : String
		{
			return _symbol;
		}
		
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
		
	}
}