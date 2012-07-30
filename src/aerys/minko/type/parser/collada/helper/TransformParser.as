package aerys.minko.type.parser.collada.helper
{
	import aerys.minko.type.error.collada.ColladaError;
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.math.Vector4;

	public class TransformParser
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		public static function parseTransform(node : XML) : Matrix4x4
		{
			var children	: XMLList	= node.children();
			var numChildren	: Number	= children.length();
			var transform	: Matrix4x4	= new Matrix4x4();
			
			for (var i : int = 0; i < numChildren; ++i)
			{
				var child	: XML		= children[i];
				var name	: String	= child.localName();
				
				switch (name)
				{
					case 'lookat':
						var lookAt : Vector.<Vector4> = NumberListParser.parseVector3List(child);
						transform.lookAt(lookAt[0], lookAt[1], lookAt[2]);
						break;
					
					case 'matrix':
						// is this multiply or multiplyInverse?
						transform.prepend(NumberListParser.parseMatrix3D(child));
						break;
					
					case 'rotate':
						var axis		: Vector4	= NumberListParser.parseVector4(child);
						var angle		: Number	= axis.w / 180 * Math.PI;
						axis.w = 0;
						transform.prependRotation(angle, axis);
						break;
					
					case 'scale':
						var scale : Vector4 = NumberListParser.parseVector3(child);
						transform.prependScale(scale.x, scale.y, scale.z);
						break;
					
					case 'skew':
						throw new ColladaError('Skewed transforms are not supported');
						break;
					
					case 'translate':
						var translation : Vector4 = NumberListParser.parseVector3(child);
						transform.prependTranslation(translation.x, translation.y, translation.z);
						break;
				}
			}
			
			return transform;
		}
		
	}
}