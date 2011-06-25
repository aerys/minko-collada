package aerys.minko.type.collada.helper
{
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.math.Transform3D;
	import aerys.minko.type.math.Vector4;

	public class TransformParser
	{
		private static const NS : Namespace = 
			new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		public static function parseTransform(node : XML) : Matrix4x4
		{
			var numChildren	: Number		= node.length();
			var children	: XMLList		= node.children();
			var transform	: Transform3D	= new Transform3D();
			
			for (var i : int = 0; i < numChildren; ++i)
			{
				var child	: XML		= children[i];
				var name	: String	= child.name();
				
				if (name == NS.uri + '::lookat')
				{
					var lookAt : Vector.<Vector4> = NumberListParser.parseVector3List(child);
					transform.pointAt(lookAt[0], lookAt[1], lookAt[2]);
				}
				else if (name == NS.uri + '::matrix')
				{
					transform.multiply(NumberListParser.parseMatrix4x4(child));
				}
				else if (name == NS.uri + '::rotate')
				{
					var rotation : Vector4 = NumberListParser.parseVector4(child);
					transform.appendRotation(rotation.w / 180 * Math.PI, rotation);
				}
				else if (name == NS.uri + '::scale')
				{
					var scale : Vector4 = NumberListParser.parseVector3(child);
					transform.appendScale(scale.x, scale.y, scale.z);
				}
				else if (name == NS.uri + '::skew')
				{
					throw new Error('Skewed transforms are not supported');
				}
				else if (name == NS.uri + '::translate')
				{
					var translation : Vector4 = NumberListParser.parseVector3(child);
					transform.appendTranslation(translation.x, translation.y, translation.z);
				}
			}
			
			return transform;
		}
		
	}
}