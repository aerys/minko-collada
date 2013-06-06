package aerys.minko.type.parser.collada.instance
{
	import aerys.minko.ns.minko_collada;
	import aerys.minko.scene.node.ISceneNode;
	import aerys.minko.scene.node.camera.Camera;
	import aerys.minko.type.loader.parser.ParserOptions;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.resource.IResource;
	import aerys.minko.type.parser.collada.resource.camera.Camera;
	import aerys.minko.type.parser.collada.resource.camera.Perspective;
	
	public final class InstanceCamera implements IInstance
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		use namespace minko_collada;
		
		private var _document		: ColladaDocument;
		private var _sourceId		: String;
		private var _sid			: String;
		private var _name			: String;

		public function InstanceCamera(document		: ColladaDocument,
									   sourceId		: String,
									   name			: String,
									   sid			: String)
		{
			_document	= document;
			_sourceId	= sourceId;
			_name		= name;
			_sid		= sid;
		}
		
		public function get sourceId() : String
		{
			return _sourceId;
		}
		
		public function get resource() : IResource
		{
			return _document.getCameraById(_sourceId);
		}
		
		public function createSceneNode(options				: ParserOptions,
										sourceIdToSceneNode	: Object,
										scopedIdToSceneNode : Object) : ISceneNode
		{
			var cameraResource		: aerys.minko.type.parser.collada.resource.camera.Camera
				= aerys.minko.type.parser.collada.resource.camera.Camera(resource);
			if (!cameraResource)
				throw new Error();
			
			var camera				: aerys.minko.scene.node.camera.Camera
				= null;
			var perspective			: Perspective	= cameraResource.perspective;
			if (perspective)
			{
				var fov				: Number		= (Math.PI * perspective.fov) / 180.;
				camera = new aerys.minko.scene.node.camera.Camera(
					fov,
					perspective.zNear,
					perspective.zFar
				);
			}
			
			return camera;
		}
		
		public static function createFromXml(document : ColladaDocument, xml : XML) : InstanceCamera
		{
			var sourceId	: String	= String(xml.@url).substr(1);
			var name		: String	= xml.@name;
			var sid			: String	= xml.@sid;
			
			return new InstanceCamera(document, sourceId, name, sid);
		}
	}
}