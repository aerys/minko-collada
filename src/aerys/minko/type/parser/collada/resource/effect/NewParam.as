package aerys.minko.type.parser.collada.resource.effect
{
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.resource.effect.data.IData;
	import aerys.minko.type.parser.collada.resource.effect.data.Sampler2D;
	import aerys.minko.type.parser.collada.resource.effect.data.Surface;

	public class NewParam
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _sid		: String;
		private var _semantic	: String;
		private var _data		: IData;
		
		public function get semantic() : String
		{
			return _semantic;
		}
		
		public function get data() : IData
		{
			return _data;
		}
		
		public static function createFromXML(xml : XML, document : ColladaDocument) : NewParam
		{
			var semantic	: String	= String(xml.NS::semantic[0]);
			var sid			: String	= String(xml.@sid);
			var data		: IData		= null;
			
			for each (var node : XML in xml.children())
				switch (node.localName())
				{
					case 'sampler2D': 
						data = Sampler2D.createFromXML(node, document); 
						break;
					case 'surface':
						data = Surface.createFromXML(node, document); 
						break;
				}
				
			return new NewParam(semantic, sid, data);
		}
		
		public function NewParam(semantic : String, sid : String, data : IData)
		{
			_semantic	= semantic;
			_sid = sid;
			_data		= data;
		}
	}
}