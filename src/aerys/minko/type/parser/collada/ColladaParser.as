package aerys.minko.type.parser.collada
{
	import aerys.minko.scene.node.IScene;
	import aerys.minko.scene.node.group.Group;
	import aerys.minko.type.parser.IParser3D;
	import aerys.minko.type.parser.collada.ressource.animation.Animation;
	
	import flash.utils.ByteArray;
	
	public class ColladaParser implements IParser3D
	{
		public static const DROP_EMPTY_GROUPS	: uint = 1;
		public static const DROP_SKINNING		: uint = 2;
		
		private var _flags		: uint;
		private var _data		: Vector.<IScene>;
		
		public function get data() : Vector.<IScene> { return _data; }
		
		public function ColladaParser(flags : uint = 0)
		{
			_flags	= flags;
			_data	= new Vector.<IScene>();
		}
		
		public function parse(data : ByteArray) : Boolean
		{
			if (!isColladaDocument(data))
				return false;
			
			var dropEmptyGroups : Boolean	= (_flags & DROP_EMPTY_GROUPS) != 0;
			var dropSkinning	: Boolean	= (_flags & DROP_SKINNING) != 0;
			var document		: Document	= new Document();
			document.loadByteArray(data);
			
			_data.push(document.toGroup(dropEmptyGroups, dropSkinning));
			
			return true;
		}
		
		private function isColladaDocument(data : ByteArray) : Boolean
		{
			try {
				data.position = 0;
				
				var xmlDocument : XML		= new XML(data.readUTFBytes(data.length));
				var localName	: String	= xmlDocument.localName();
				
				return localName.toLowerCase() == 'collada';
			}
			catch (e : Error)
			{
				return false;
			}
			
			return false;
		}
	}
}
