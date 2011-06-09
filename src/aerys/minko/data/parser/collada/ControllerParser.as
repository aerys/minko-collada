package aerys.minko.data.parser.collada
{
	import aerys.minko.type.collada.ressource.Controller;
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.stream.VertexStream;
	import aerys.minko.type.vertex.format.VertexComponent;
	import aerys.minko.type.vertex.format.VertexFormat;
	import aerys.minko.type.collada.intermediary.Source;

	internal class ControllerParser
	{
//		private static const NS					: Namespace		= ColladaParser.NS;
//		
//		private static const JOINT				: String		= "JOINT";
//		private static const WEIGHT				: String		= "WEIGHT";
//		private static const TRANSFORM			: String		= "TRANSFORM";
//		private static const INV_BIND_MATRIX	: String		= "INV_BIND_MATRIX";
//		
//		private static const BONE_COMPONENTS	: Vector.<VertexComponent> = 
//			Vector.<VertexComponent>([
//				VertexComponent.BONE0, VertexComponent.BONE1, 
//				VertexComponent.BONE2, VertexComponent.BONE3, 
//				VertexComponent.BONE4, VertexComponent.BONE5, 
//				VertexComponent.BONE6, VertexComponent.BONE7
//			]);
//		
//		public static function parseControllers(dae 	: XML,
//												meshes	: Object) : Boolean
//		{
//			var controllerNodes : XMLList	= dae..NS::library_controllers
//											 	 .NS::controller;
//			
//			for each (var controllerNode : XML in controllerNodes)
//			{
//				parseController(dae, controllerNode, meshes);
//			}
//			
//			return true;
//		}
//		
//		private static function parseController(dae 		: XML,
//												controller 	: XML,
//												meshes		: Object) : Boolean
//		{
//			var skin 			: XML 					= controller.NS::skin[0];
//			
//			var jointsNames 	: Vector.<String> 		= parseJoints(controller);
//			var invBindMatrices : Vector.<Matrix4x4> 	= parseInvBindMatrix(controller);
//			var weights			: Vector.<Number> 		= parseWeights(controller);
//			
//			var vcount 			: Vector.<int> 			= parseIntVector(skin.NS::vertex_weights
//																		     .NS::vcount[0]);
//			var v 				: Vector.<int> 			= parseIntVector(skin.NS::vertex_weights
//													  						 .NS::v[0]);
//			
//			var offsetJoint		: int 					= skin.NS::vertex_weights
//															  .NS::input
//															  .(@semantic == JOINT)
//															  .@offset;
//			var offsetWeight 	: int 					= skin.NS::vertex_weights
//										 					  .NS::input
//										 					  .(@semantic == WEIGHT)
//										 					  .@offset;
//			
//			var numInputs 		: int 					= controller..NS::vertex_weights
//											  						.NS::input
//											  						.length();
//			
//			var k 				: int 					= 0;
//			
//			var bonesData		: Vector.<Number>		= new Vector.<Number>();
//			
//			var maxVcount : uint = 0
//			for (var i : int = 0; i < vcount.length; i++)
//			{
//				var vc : int = vcount[i];
//				
//				if (maxVcount < vc)
//					maxVcount = vc;
//			}
//			
//			for (i = 0; i < vcount.length; i++)
//			{
//				vc = vcount[i];
//				
//				for (var j : int = 0; j < vc; j++)
//				{
//					bonesData.push(v[int(k + offsetJoint)],				// bone id
//								   weights[v[int(k + offsetWeight)]]);	// weight
//					
//					k += numInputs;
//				}
//				
//				for (; j < maxVcount; j++)
//				{
//					bonesData.push(0,	// bone id
//								   0);	// weight
//				}
//			}
//			
//			var vertexFormat	: VertexFormat	= new VertexFormat();
//			var skinSource 		: String	 	= skin.@source.substring(1);
//			
//			for (k = 0; k < maxVcount; ++k)
//				vertexFormat.addComponent(BONE_COMPONENTS[k]);
//			
//			meshes[skinSource] = new Controller(
//				controller.@id, meshes[skinSource], 
//				new VertexStream(bonesData, vertexFormat), 
//				jointsNames, invBindMatrices
//			);;
//			
//			return true;
//		}
//		
//		private static function parseInvBindMatrix(controller : XML) : Vector.<Matrix4x4>
//		{
//			var sourceId : String = controller..NS::joints
//											  .NS::input
//											  .(@semantic == INV_BIND_MATRIX)
//											  .@source
//											  .substring(1);
//			var xmlSource : XML = controller..NS::source
//										 .(@id == sourceId)[0];
//			
//			var source : Source = Source.createFromXML(xmlSource);
//			return Vector.<Matrix4x4>(source.data);
//		}
//		
//		private static function parseJoints(controller : XML) : Vector.<String>
//		{
//			var sourceId : String = controller..NS::joints
//											  .NS::input
//											  .(@semantic == JOINT)
//											  .@source
//											  .substring(1);
//			var xmlSource : XML = controller..NS::source
//										 .(@id == sourceId)[0];
//			
//			var source : Source = Source.createFromXML(xmlSource);
//			
//			return Vector.<String>(source.data);
//		}
//		
//		private static function parseWeights(controller : XML) : Vector.<Number>
//		{
//			var sourceId : String = controller..NS::vertex_weights
//												.NS::input
//												.(@semantic == WEIGHT)
//												.@source
//												.substring(1);
//			var xmlSource : XML = controller..NS::source
//										   .(@id == sourceId)[0];
//			
//			var source : Source = Source.createFromXML(xmlSource);
//			
//			return Vector.<Number>(source.data);
//		}
//		
//		private static function parseIntVector(node : XML) : Vector.<int>
//		{
//			var data : Array = String(node).split(" ");
//			var length : int = data.length;
//			var out : Vector.<int> = new Vector.<int>(length, true);
//			
//			for (var i : int = 0; i < length; ++i)
//				out[i] = parseInt(data[i]);
//			
//			return out;
//		}
	}
}