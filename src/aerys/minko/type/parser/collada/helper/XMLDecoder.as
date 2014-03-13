package aerys.minko.type.parser.collada.helper
{
	public class XMLDecoder
	{
		public static function toObject(xmlNode : XML) : Object
		{
			var result 		: Object	= {};
			var attr		: XMLList	= xmlNode.attributes();
			var children	: XMLList	= xmlNode.children();
			var i			: int		= 0;

			if (attr.length())
			{
				result.attr = {};
					
				for (i = 0; i < attr.length(); ++i)
					result.attr[attr[i].localName()] = attr[i].toXMLString();
			}
			
			var textNode	: Boolean	= true;
			
			for (i = 0; i < children.length(); ++i)
				if (children[i].nodeKind() != "text")
					textNode = false;
			
			if (!textNode)
			{
				for (i = 0; i < children.length(); ++i)
					result[children[i].localName()] = toObject(children[i]);
			}
			else if (children.length())
			{
				result = children[0].toString();
			}
			else
			{
				result = xmlNode.toString();
			}
			
			return result;
		}
	}
}