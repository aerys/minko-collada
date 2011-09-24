package aerys.minko.type.parser.collada.instance
{
	import aerys.minko.scene.node.IScene;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.helper.ParamParser;
	import aerys.minko.type.parser.collada.resource.IResource;
	
	public class InstanceEffect implements IInstance
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _document : ColladaDocument;
		
		private var _sourceId	: String;
		private var _params		: Object;
		
		public static function createFromXML(xml		: XML, 
											 document	: ColladaDocument) : InstanceEffect
		{
			var instanceEffect : InstanceEffect = new InstanceEffect();
			
			instanceEffect._document	= document;
			instanceEffect._sourceId	= String(xml.@url).substr(1);
			instanceEffect._params		= new Object();
			
			for each (var setparam : XML in xml.NS::setparam)
			{
				var paramName	: String	= setparam.@ref;
				var paramValue	: *			= ParamParser.parseParam(setparam);
				
				instanceEffect._params[paramName] = paramValue;
			}
			
			return instanceEffect;
		}
		
		public static function createFromSourceId(sourceId	: String, 
												  document	: ColladaDocument) : InstanceEffect
		{
			var instanceEffect : InstanceEffect = new InstanceEffect();
			
			instanceEffect._document = document;
			instanceEffect._sourceId = sourceId;
			
			return instanceEffect;
		}
		
		public function get resource():IResource
		{
			return _document.getEffectById(_sourceId);
		}
		
		public function toScene():IScene
		{
			return null;
		}
	}
}