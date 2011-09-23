package aerys.minko.type.parser.collada.resource
{
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.instance.IInstance;
	import aerys.minko.type.parser.collada.instance.InstanceEffect;
	
	public class Material implements IResource
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _document		: ColladaDocument;
		private var _id				: String;
		private var _name			: String;
		private var _instanceEffect : InstanceEffect;
		
		public function get id()				: String			{ return _id;				}
		public function get name()				: String			{ return _name;				}
		public function get instanceEffect()	: InstanceEffect	{ return _instanceEffect;	}
		
		public static function fillStoreFromXML(xmlDocument	: XML,
												document	: ColladaDocument, 
												store		: Object) : void
		{
			var xmlMaterialLibrary	: XML		= xmlDocument..NS::library_materials[0];
			if (!xmlMaterialLibrary)
				return;
			
			var xmlMaterials 			: XMLList	= xmlMaterialLibrary.NS::material;
			
			for each (var xmlMaterial : XML in xmlMaterials)
			{
				var material : Material = createFromXML(xmlMaterial, document);
				store[material.id] = material;
			}
		}
		
		public static function createFromXML(xmlMaterial : XML, document : ColladaDocument) : Material
		{
			var xmlInstanceEffect	: XML		= xmlMaterial.NS::instance_effect[0]
			var material			: Material	= new Material();
			
			material._id				= xmlMaterial.@id;
			material._name				= xmlMaterial.@name;
			material._instanceEffect	= InstanceEffect.createFromXML(xmlInstanceEffect, document);
			
			return material;
		}
		
		public function createInstance():IInstance
		{
			return InstanceEffect.createFromSourceId(_id, _document);
		}
	}
}