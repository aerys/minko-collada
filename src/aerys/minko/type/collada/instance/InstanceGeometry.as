package aerys.minko.type.collada.instance
{
	import aerys.minko.scene.node.Model;
	import aerys.minko.type.collada.Document;
	import aerys.minko.type.collada.ressource.Geometry;
	import aerys.minko.type.collada.ressource.IRessource;
	
	public class InstanceGeometry implements IInstance
	{
		private var _document			: Document;
		
		private var _sourceId			: String;
		private var _bindedMaterialId	: String;
		
		public function InstanceGeometry(document			: Document,
										 sourceId			: String = null,
										 bindedMaterialId	: String = null)
		{
			_document			= document;
			_sourceId			= sourceId;
			_bindedMaterialId	= bindedMaterialId;
		}
		
		public static function createFromXML(xml		: XML, 
											 document	: Document) : InstanceGeometry
		{
			throw new Error('implement me');
		}
		
		public static function createFromSourceId(document : Document,
												  sourceId : String) : InstanceGeometry
		{
			return new InstanceGeometry(document, sourceId);
		}
		
		public function toModel() : Model
		{
			var geometryRessource : Geometry = ressource as Geometry;
			
			var model : Model	= new Model();
			model.mesh			= geometryRessource.toMesh();
			
			if (_bindedMaterialId)
				throw new Error('implement me!');
			
			return model
		}
		
		public function get ressource() : IRessource
		{
			return _document.getGeometryById(_sourceId);
		}
	}
}