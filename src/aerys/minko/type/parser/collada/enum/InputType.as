package aerys.minko.type.parser.collada.enum
{
	import aerys.minko.ns.minko_collada;
	import aerys.minko.render.geometry.stream.format.VertexComponent;
	

	/**
	 * All types of input nodes.
	 * 
	 * @author Romain Gilliotte
	 * @see Collada 1.5 specs, page 5-48
	 */	
	public class InputType
	{
		use namespace minko_collada;
		
		public static const BINORMAL		: String = 'BINORMAL';
		public static const COLOR			: String = 'COLOR';
		public static const CONTINUITY		: String = 'CONTINUITY';
		public static const IMAGE			: String = 'IMAGE';
		public static const INPUT			: String = 'INPUT';
		public static const IN_TANGENT		: String = 'IN_TANGENT';
		public static const INTERPOLATION	: String = 'INTERPOLATION';
		public static const INV_BIND_MATRIX	: String = 'INV_BIND_MATRIX';
		public static const JOINT			: String = 'JOINT';
		public static const LINEAR_STEPS	: String = 'LINEAR_STEPS';
		public static const MORPH_TARGET	: String = 'MORPH_TARGET';
		public static const MORPH_WEIGHT	: String = 'MORPH_WEIGHT';
		public static const NORMAL			: String = 'NORMAL';
		public static const OUTPUT			: String = 'OUTPUT';
		public static const OUT_TANGENT		: String = 'OUT_TANGENT';
		public static const POSITION		: String = 'POSITION';
		public static const TANGENT			: String = 'TANGENT';
		public static const TEXBINORMAL		: String = 'TEXBINORMAL';
		public static const TEXCOORD		: String = 'TEXCOORD';
		public static const TEXTANGENT		: String = 'TEXTANGENT';
		public static const UV				: String = 'UV';
		public static const VERTEX			: String = 'VERTEX';
		public static const WEIGHT			: String = 'WEIGHT';
		
		minko_collada static const TO_COMPONENT : Object = new Object();
		{
			TO_COMPONENT[POSITION] = VertexComponent.XYZ;
			TO_COMPONENT[COLOR] = VertexComponent.RGBA;
			TO_COMPONENT[TEXCOORD] = VertexComponent.UV;
			TO_COMPONENT[NORMAL] = VertexComponent.NORMAL;
			TO_COMPONENT[TANGENT] = VertexComponent.TANGENT;
		};
	}
}
