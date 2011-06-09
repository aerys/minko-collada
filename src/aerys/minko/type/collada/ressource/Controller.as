package aerys.minko.type.collada.ressource
{
	import aerys.minko.scene.node.skeleton.Joint;
	import aerys.minko.type.collada.Document;
	import aerys.minko.type.collada.intermediary.Source;
	import aerys.minko.type.math.Matrix4x4;

	public class Controller implements IRessource
	{
		// morph related data
		/* not yet implemented */
		
		// skin related data
		private var _id					: String;
		private var _bindShapeMatrix	: Matrix4x4; // defaults to identity
		
		private var _geometryId			: String;
		
		/**
		 * Contains the strings ids of the bones used in the two following vectors
		 */
		private var _jointIds 			: Vector.<String>;
		private var _jointIdToIndex		: Object;
		
		/**
		 * Contains  the inverse bind matrix of each joint 
		 * in the skeleton (wtf is it?)
		 * 
		 * Use it this way:
		 * 		_invBindMatrices[_jointIdToIndex[jointId]]
		 */
		private var _invBindMatrices : Vector.<Matrix4x4>
		
		/**
		 * Contains weights for each bone and vertex
		 * Use it this way:
		 * 		_weights[vertexId][_jointIdToIndex[jointId]]
		 */
		private var _weights : Vector.<Vector.<Number>>;
		
		
		public function Controller(xmlController : XML)
		{
			throw new Error('Implement me');
		}
		
		
	}
}