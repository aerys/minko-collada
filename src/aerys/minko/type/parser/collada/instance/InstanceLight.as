package aerys.minko.type.parser.collada.instance
{
	import aerys.minko.scene.node.ISceneNode;
	import aerys.minko.scene.node.light.AmbientLight;
	import aerys.minko.scene.node.light.DirectionalLight;
	import aerys.minko.scene.node.light.PointLight;
	import aerys.minko.scene.node.light.SpotLight;
	import aerys.minko.type.loader.parser.ParserOptions;
	import aerys.minko.type.math.Vector4;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.helper.Color;
	import aerys.minko.type.parser.collada.resource.IResource;
	import aerys.minko.type.parser.collada.resource.light.Ambient;
	import aerys.minko.type.parser.collada.resource.light.Directional;
	import aerys.minko.type.parser.collada.resource.light.Light;
	import aerys.minko.type.parser.collada.resource.light.Point;
	import aerys.minko.type.parser.collada.resource.light.Spot;
	
	public final class InstanceLight implements IInstance
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");

		private var _document		: ColladaDocument;
		private var _sourceId		: String;
		private var _sid			: String;
		private var _name			: String;
		
		public function InstanceLight(document		: ColladaDocument,
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
			return _document.getLightbyId(_sourceId);
		}
		
		public function createSceneNode(options				: ParserOptions,
										sourceIdToSceneNode	: Object,
										scopedIdToSceneNode	: Object) : ISceneNode
		{
			var lightResource		: Light		= Light(resource);
			if (!lightResource)
				throw new Error();
			
			if (lightResource.ambient)
				return createAmbientLight(lightResource.ambient);
			if (lightResource.directional)
				return createDirectionalLight(lightResource.directional);
			if (lightResource.spot)
				return createSpotLight(lightResource.spot);
			if (lightResource.point)
				return createPointLight(lightResource.point);
			
			return null;
		}
		
		private function createPointLight(point : aerys.minko.type.parser.collada.resource.light.Point) : ISceneNode
		{
			var light	: PointLight	= new PointLight(Color.vectorToRGB(point.color));
			light.attenuationPolynomial	= new Vector4(
				point.constantAttenunation,
				point.linearAttenuation,
				point.quadraticAttenuation
			);

			return light;
		}
		
		private function createSpotLight(spot:Spot):ISceneNode
		{
			var spotLight	: SpotLight		= new SpotLight(Color.vectorToRGB(spot.color));
			spotLight.attenuationPolynomial = new Vector4(
				spot.constantAttenunation,
				spot.linearAttenuation,
				spot.quadraticAttenuation
			);
			spotLight.outerRadius = spot.falloffAngle;
			
			return spotLight;
		}
		
		private function createDirectionalLight(directional : Directional) : ISceneNode
		{
			var light	: DirectionalLight	= new DirectionalLight(
				Color.vectorToRGB(directional.color)
			);
			
			return light;
		}
		
		private function createAmbientLight(ambient : Ambient):ISceneNode
		{
			var light	: AmbientLight	= new AmbientLight(Color.vectorToRGB(ambient.color));
			
			return light;
		}
		
		public static function createFromXml(document : ColladaDocument, xml : XML) : InstanceLight
		{
			var sourceId	: String	= String(xml.@url).substr(1);
			var name		: String	= xml.@name;
			var sid			: String	= xml.@sid;
			
			return new InstanceLight(document, sourceId, name, sid);
		}
	}
}