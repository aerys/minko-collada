package aerys.minko.type.parser.collada.instance
{
	import aerys.minko.Minko;
	import aerys.minko.render.material.Material;
	import aerys.minko.scene.node.ISceneNode;
	import aerys.minko.type.loader.parser.ParserOptions;
	import aerys.minko.type.log.DebugLevel;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.resource.IResource;
	import aerys.minko.type.parser.collada.resource.effect.Effect;
	
	public class InstanceEffect implements IInstance
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _sourceId		: String;
		private var _setParams		: Object;
		private var _document		: ColladaDocument;
		
		public function get sourceId () : String
		{
			return _sourceId;
		}
		
		public function get resource() : IResource
		{
			return _document.getEffectById(_sourceId);
		}
		
		public static function createFromXML(xml		: XML, 
											 document	: ColladaDocument) : InstanceEffect
		{
			var sourceId	: String	= String(xml.@url).substr(1);
			
			for each (var setparam : XML in xml.NS::setparam)
				Minko.log(DebugLevel.PLUGIN_WARNING, 'Collada setparam instruction is not supported.');
			
			return new InstanceEffect(sourceId, new Object(), document);
		}
		
		public function InstanceEffect(sourceId		: String,
									   setParams	: Object,
									   document		: ColladaDocument)
		{
			_sourceId	= sourceId;
			_setParams	= setParams;
			_document	= document;
		}
		
		public function createMaterial() : Material
		{
			return Effect(resource).createMaterial(_setParams);
		}
		
		public function createSceneNode(options				: ParserOptions,
										sourceIdToSceneNode	: Object,
										scopedIdToSceneNode	: Object) : ISceneNode
		{
			throw new Error('Effect instances cannot be mapped to scene nodes');
		}
	}
}