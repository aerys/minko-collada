package aerys.minko.data.parser.collada
{
	import aerys.minko.scene.node.IScene;
	import aerys.minko.scene.node.group.TransformGroup;
	import aerys.minko.scene.node.mesh.IMesh;
//	import aerys.minko.type.collada.Joint;
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.math.Transform3D;
	import aerys.minko.type.math.Vector4;
	import aerys.minko.type.parser.IParser3D;
	
	import flash.utils.ByteArray;
	
	/**
	 * @author Jean-Marc Le Roux
	 */
	public class ColladaParser implements IParser3D
	{
//		public static const NS				: Namespace	= new Namespace("http://www.collada.org/2005/11/COLLADASchema");
//		
//		private static const TYPE_NODE		: String	= "NODE";
//		private static const TYPE_JOINT		: String	= "JOINT";
//		
//		private static const PARAM_ANGLE	: String	= "ANGLE";
//		
//		private static const NAME_ROTATE	: String	= "rotate";
//		private static const NAME_TRANSLATE	: String	= "translate";
//		private static const NAME_NODE		: String	= "node";
//		
//		private var _skeletons	: Object			= new Object();
//		
		private var _data 		: Vector.<IScene>	= new Vector.<IScene>();
		
		public function get data() : Vector.<IScene>
		{
			return _data;
		}
		
		public final function parse(data : ByteArray) : Boolean
		{
//			//try
//			{
//				var dae			: XML		= new XML(data.toString());
//				
//				
//				var meshes		: Object	= GeometryParser.parse(dae);
//				ControllerParser.parseControllers(dae, meshes);
//				for each (var mesh : IMesh in meshes)
//					_data.push(mesh);
//				
//				
//				var scenes 		: XMLList 	= dae.NS::library_visual_scenes
//										   		 .NS::visual_scene;
//				
//				var numScenes 	: int 		= scenes.length();
//				
////				for (var j : int = 0; j < numScenes; ++j)
////				{
////					var sceneNode	: XML		= scenes[j];
////					var nodes 		: XMLList 	= sceneNode.NS::node.(@type == TYPE_NODE);
////					var numNodes 	: int 		= nodes.length();
////					
////					trace("scene", sceneNode.@name);
////					
////					for (var i : int = 0; i < numNodes; ++i)
////						_data.push(parseNode(dae, nodes[i]));
////				}
//			}
//			
//			
//			/*catch (e : Error)
//			{
//				return false;
//			}*/
//		
			return true;
		}
////		
////		private function parseNode(dae 	: XML,
////								   node : XML) : IScene
////		{
////			var scene				: TransformGroup	= new TransformGroup();
////			var children 			: XMLList 			= node.children();
////			var numChildren		 	: int 				= children.length();
////			var matrix 				: Transform3D 		= new Transform3D();
////			var instanceController 	: XML 				= node.NS::instance_controller[0];
////			var skeleton 			: XMLList			= instanceController.NS::skeleton;
////			var i 					: int 				= 0;
////			var controllerId 		: String 			= instanceController.@url.substring(1);
////			
////			scene.name = node.@name;
////			trace("node", scene.name);
////			
////			// read skeleton
////			if (skeleton.length())
////			{
////				var bones : Array = skeleton.toString().split(" ");
////				
////				for each (var boneId : String in bones)
////				{
////					var jointNode : XML = node.parent()
////											  .NS::node
////											  .(@name == boneId.substring(1))[0];
////					
////					scene.addChild(parseJoint(jointNode));
////				}
////			}
////			
////			// read transformation
////			Matrix4x4.copy(parseTransformation(node), scene.transform);
////			
////			return scene;
////		}
////		
////		
////		private function parseJoint(jointNode : XML) : Joint
////		{
////			var joint 		: Joint 		= new Joint(jointNode.@name);
////			var sid 		: String	 	= jointNode.@sid;
////			var matrix 		: Transform3D	= new Transform3D();
////			var children 	: XMLList	 	= jointNode.children();
////			var numChildren : int 			= children.length();
////			var isBone 		: Boolean 		= _skeletons[jointNode.@id];
////			
////			trace("=======", isBone ? "bone" : "joint", ":", joint.name);
////			// TODO: get the bone data
////			
////			// parse children nodes
////			for (var i : int = 0; i < numChildren; ++i)
////			{
////				var child 		: XML 		= children[i];
////				var name 		: String 	= child.localName();
////				var childSid 	: String 	= child.@sid;
////				var data		: Array		= null;
////				
////				if (name == NAME_NODE && child.@type == TYPE_JOINT)
////				{
////					joint.addChild(parseJoint(child));
////				}
////				else
////				{
////					// parse transformations and push them
////					if (name == NAME_TRANSLATE)
////					{
////						var translate : Vector4 = parseRotate(child);
////						
////						matrix.appendTranslation(translate.x,
////							translate.y,
////							translate.z);
////					}
////					else if (name == NAME_ROTATE)
////					{
////						var rotation : Vector4 = parseRotate(child);
////						
////						matrix.appendRotation(rotation.w, rotation);
////					}
////					
////					/*if (isBone)
////					{
////						var target : String = jointNode.@id + "/" + childSid + ".";
////						
////						// Todo: handle translation
////						target += PARAM_ANGLE;
////						
////						var animationNode : XML = _animations.(NS::channel.@target == target)[0];
////						
////						if (animationNode != null)
////						{
////							var animation : ColladaAnimation = new ColladaAnimation();
////							
////							animation.parse(animationNode);
////						}
////					}*/
////				}
////			}
////			
////			return joint;
////		}
//		
//		private function parseTransformation(node : XML) : Transform3D
//		{
//			var numChildren	: Number		= node.length();
//			var children	: XMLList		= node.children();
//			var transform	: Transform3D	= new Transform3D();
//			
//			for (var i : int = 0; i < numChildren; ++i)
//			{
//				var child : XML = children[i];
//				var name : String = child.name();
//				
//				if (name == NAME_ROTATE)
//				{
//					var rotation : Vector4 = parseRotate(child);
//					
//					transform.appendRotation(rotation.w, rotation);
//				}
//				else if (name == NAME_TRANSLATE)
//				{
//					var translation : Vector4 = parseTranslate(child);
//					
//					transform.appendTranslation(translation.x, translation.y, translation.z);
//				}
//			}
//			
//			return transform;
//		}
//		
//		private function parseRotate(rotate : XML ) : Vector4
//		{
//			var data : Array = String(rotate).split(" ");
//			
//			return new Vector4(parseFloat(data[0]),
//				parseFloat(data[1]),
//				parseFloat(data[2]),
//				parseFloat(data[3]));
//		}
//		
//		private function parseTranslate(translate : XML ) : Vector4
//		{
//			var data : Array = String(translate).split(" ");
//			
//			return new Vector4(parseFloat(data[0]),
//				parseFloat(data[1]),
//				parseFloat(data[2]));
//		}
	}
}