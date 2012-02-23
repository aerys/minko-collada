package aerys.minko.type.parser.collada.instance
{
	import aerys.minko.scene.node.ISceneNode;
	import aerys.minko.type.loader.parser.ParserOptions;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.helper.ParamParser;
	import aerys.minko.type.parser.collada.resource.IResource;
	
	public class InstanceEffect implements IInstance
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _sourceId	: String;
		private var _params		: Object;
		private var _document	: ColladaDocument;
		
		public function get resource():IResource
		{
			return _document.getEffectById(_sourceId);
		}
		
		public static function createFromXML(xml		: XML, 
											 document	: ColladaDocument) : InstanceEffect
		{
			var sourceId	: String	= String(xml.@url).substr(1);
			var params		: Object	= new Object();
			
			for each (var setparam : XML in xml.NS::setparam)
			{
				var paramName	: String	= setparam.@ref;
				var paramValue	: *			= ParamParser.parseParam(setparam);
				
				params[paramName] = paramValue;
			}
			
			return new InstanceEffect(sourceId, params, document);
		}
		
		public function InstanceEffect(sourceId : String,
									   params	: Object,
									   document	: ColladaDocument)
		{
			_sourceId	= sourceId;
			_params		= params;
			_document	= document;
		}
		
		public function createSceneNode(options				: ParserOptions,
										sourceIdToSceneNode	: Object,
										scopedIdToSceneNode	: Object) : ISceneNode
		{
			throw new Error('Effect instances cannot be mapped to scene nodes');
		}
	}
}