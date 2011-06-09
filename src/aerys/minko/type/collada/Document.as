package aerys.minko.type.collada
{
	import aerys.minko.ns.minko_collada;
	import aerys.minko.type.collada.intermediary.Source;
	import aerys.minko.type.collada.ressource.Controller;
	import aerys.minko.type.collada.ressource.Geometry;
	import aerys.minko.type.collada.ressource.Node;

	use namespace minko_collada;
	
	public class Document
	{
		public static const NS		: Namespace	= new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private var _controllers	: Vector.<Controller>;
		private var _geometries		: Vector.<Geometry>;
		private var _nodes			: Vector.<Node>;
		
		public function Document(xmlDocument : XML)
		{
			var xmlGeometries 	: XMLList	= xmlDocument..NS::library_geometries[0].NS::geometry;
			var xmlControllers	: XMLList	= xmlDocument..NS::library_controllers[0].NS::controller;
			var xmlNodes		: XMLList	= xmlDocument..NS::library_nodes[0].NS::node;
			
			for each (var xmlGeometry : XML in xmlGeometries)
				_geometries.push(new Geometry(xmlGeometry));
			
			for each (var xmlController : XML in xmlControllers)
				_controllers.push(new Controller(xmlController));
			
			for each (var xmlNode : XML in xmlNodes)
				_nodes.push(Node.createFromXML(xmlNode));
		}
	}
}