package aerys.minko.data.parser.collada 
{
	import aerys.minko.scene.node.mesh.Mesh;
	import aerys.minko.type.stream.IndexStream;
	import aerys.minko.type.stream.VertexStream;
	import aerys.minko.type.stream.VertexStreamList;
	import aerys.minko.type.collada.intermediary.Source;
	

	/**
	 * @author Jean-Marc Le Roux
	 */
	internal final class GeometryParser
	{
		private static const NS			: Namespace	= null//ColladaParser.NS;
		
		private static const POSITION	: String	= "POSITION";
		private static const VERTEX		: String	= "VERTEX";
		private static const TEXCOORD	: String	= "TEXCOORD";
		
		private static const X			: String	= "X";
		private static const Y			: String	= "Y";
		private static const Z			: String	= "Z";
		
		private static const S			: String	= "S";
		private static const T			: String	= "T";
		
		public static function parse(dae : XML) : Object
		{
			var meshes		: Object	= new Object();
			var geometries 	: XMLList 	= dae..NS::library_geometries[0]
											 .NS::geometry;
			var numNodes 	: int 		= geometries.length();
			
			for (var i : int = 0; i < numNodes; ++i)
			{
				var geometry 	: XML 		= geometries[i];
				var mesh 		: Mesh	 	= parseMesh(geometry.NS::mesh[0]);
	
				mesh.name = geometry.@name;
				meshes[mesh.name] = mesh;
			}
			
			return meshes;
		}
		
		private static function parseMesh(meshNode : XML) : Mesh
		{
			var triangles 			: Boolean 			= meshNode.NS::triangles.length();
			var node 				: XML 				= triangles ? meshNode.NS::triangles[0]
																	: meshNode.NS::polylist[0];
			var inputs				: XMLList		 	= node.NS::input;
			var numInputs 			: int 				= inputs.length();
			var offsetVertices 		: int 				= inputs.(@semantic == VERTEX).@offset;
			var offsetUV 			: int 				= inputs.(@semantic == TEXCOORD).@offset;
			var vertexCount 		: Vector.<uint> 	= triangles ? null : parseVertexCount(node);
			var polygons 			: Vector.<uint> 	= parsePolygons(node.NS::p[0]);
			var numPolygons 		: int 				= polygons.length;
			var vertexData 			: Vector.<Number> 	= parseVertices(meshNode);
			var stData 				: Vector.<Number> 	= parseST(meshNode);
			var polygonIndex 		: int 				= 0;
			var vertexCountIndex 	: int 				= 0;
			var indiceToVertex 		: Array 			= new Array();
			var vertexToUv 			: Array 			= new Array();
			var newIndice 			: int 				= 0;
			var vertices 			: Vector.<Number> 	= new Vector.<Number>();
			var uvs 				: Vector.<Number> 	= new Vector.<Number>();
			var indices 			: Vector.<uint> 	= new Vector.<uint>();
			
			// for each polygon
			while (polygonIndex < numPolygons)
			{
				var numVertices 	: int 			= triangles
													  ? 3
													  : vertexCount[int(vertexCountIndex++)];
				var polygonIndices 	: Vector.<uint> = numVertices == 3
													  ? indices
													  : new Vector.<uint>();
				
				// read one polygon
				for (var j : int = 0; j < numVertices; ++j)
				{
					var vertexIndice 	: int	= polygons[int(polygonIndex + offsetVertices)];
					var uvIndice 		: int 	= polygons[int(polygonIndex + offsetUV)];
					
					// if the same (vertex, uv) pair exists
					if (indiceToVertex[vertexIndice] && vertexToUv[vertexIndice] == uvIndice)
					{
						// use the "old" index
						polygonIndices.push(indiceToVertex[vertexIndice]);
					}
					else
					{
						// register the new index
						indiceToVertex[vertexIndice] = newIndice;
						vertexToUv[vertexIndice] = uvIndice;
						
						// write vertex/uv
						vertices.push(vertexData[int(vertexIndice * 3)],
									  vertexData[int(vertexIndice * 3 + 1)],
									  vertexData[int(vertexIndice * 3 + 2)]);
						
						uvs.push(stData[int(uvIndice * 2)],
								 1. - stData[int(uvIndice * 2 + 1)]);
						
						polygonIndices.push(newIndice++);
					}
					
					polygonIndex += numInputs;
				}
				
				// triangulate if necessary
				if (numVertices != 3)
				{
					for (j = 1; j < numVertices - 1; ++j)
					{
						indices.push(polygonIndices[0],
									 polygonIndices[j],
									 polygonIndices[int((j + 1) % numVertices)]);
					}
				}
			}
			
			indices = indices.reverse();
			
			var vstream : VertexStream = VertexStream.fromPositionsAndUVs(vertices, uvs);
			
			return new Mesh(new VertexStreamList(vstream),
							new IndexStream(indices));
		}
		
		private static function parsePolygons(polygons : XML) : Vector.<uint>
		{
			var data 	: Array 		= String(polygons).split(" ");
			var length 	: int 			= data.length;
			var p 		: Vector.<uint> = new Vector.<uint>(length, true);
			
			for (var i : int = 0; i < length; ++i)
				p[i] = parseInt(data[i]);
			
			return p;
		}
		
		private static function parseVertexCount(polylist : XML) : Vector.<uint>
		{
			var data 	: Array 		= String(polylist.NS::vcount[0]).split(" ");
			var length 	: int 			= data.length;
			var out 	: Vector.<uint> = new Vector.<uint>(length, true);
			
			for (var i : int = 0; i < length; ++i)
				out[i] = parseInt(data[i]);
			
			return out;
		}
		
		private static function parseVertices(mesh : XML) : Vector.<Number>
		{
			var node : XML = mesh.NS::polylist.length() ? mesh.NS::polylist[0]
														  : mesh.NS::triangles[0];
			var sourceId : String = node.NS::input
									  	.(@semantic == VERTEX)[0]
									  	.@source
									  	.substring(1);
			var sources : XMLList = mesh.NS::vertices
										.(@id == sourceId)
										.NS::input
										.(@semantic == POSITION)
										.@source;
			
			var vertices : Array = new Array();
			
			for each (sourceId in sources)
			{
				var source : XML = mesh.NS::source
										 .(@id == sourceId.substring(1))[0];
				
				Source.createFromXML(source);
			}
			
			return Vector.<Number>(vertices);
		}
		
		private static function parseST(mesh : XML) : Vector.<Number>
		{
			var node : XML = mesh.NS::polylist.length() ? mesh.NS::polylist[0]
														: mesh.NS::triangles[0];
			var sourceId : String = node.NS::input
									    .(@semantic == TEXCOORD)
									    .@source
									    .substring(1);
			var xmlSource : XML = mesh.NS::source
									 .(@id == sourceId)[0];
			
			var source : Source = Source.createFromXML(xmlSource);
			
			return Vector.<Number>(source.data);
		}
			
	}

}