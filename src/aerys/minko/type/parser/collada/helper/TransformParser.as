package aerys.minko.type.parser.collada.helper
{
	import aerys.minko.type.error.collada.ColladaError;
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.math.Vector4;

	public class TransformParser
	{
		private static const 	NS 				: Namespace 		= new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		private static var		MATRIX4X4_DATA	: Vector.<Number>	= new Vector.<Number>(16, true);
		
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
						transform = MatrixSanitizer.apply(transform);
						break;
					
					case 'matrix':
						// is this multiply or multiplyInverse?
						transform.prepend(NumberListParser.parseMatrix3D(child));	
						// handedness already changed (must not call MatrixSanitizer again)
						break;
					
					case 'rotate':
						var axis		: Vector4	= NumberListParser.parseVector4(child);
						var angle		: Number	= axis.w / 180 * Math.PI;
						axis.w = 0;
						transform.prependRotation(angle, axis);
						transform = MatrixSanitizer.apply(transform);
						break;
					
					case 'scale':
						var scale : Vector4 = NumberListParser.parseVector3(child);
						transform.prependScale(scale.x, scale.y, scale.z);
						transform = MatrixSanitizer.apply(transform);
						break;
					
					case 'skew':
						throw new ColladaError('Skewed transforms are not supported');
						break;
					
					case 'translate':
						var translation : Vector4 = NumberListParser.parseVector3(child);
						transform.prependTranslation(translation.x, translation.y, translation.z);
						transform = MatrixSanitizer.apply(transform);
						break;
				}
			}
						
			return transform;
		}
	}
}