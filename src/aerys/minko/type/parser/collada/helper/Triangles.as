package aerys.minko.type.parser.collada.helper
{
	import aerys.minko.ns.minko_collada;
	import aerys.minko.type.error.collada.ColladaError;
	import aerys.minko.type.parser.collada.enum.InputType;
	import aerys.minko.type.stream.IndexStream;
	import aerys.minko.type.stream.StreamUsage;
	import aerys.minko.type.stream.VertexStream;
	import aerys.minko.type.stream.VertexStreamList;
	import aerys.minko.type.stream.format.VertexComponent;
	import aerys.minko.type.stream.format.VertexFormat;

	public class Triangles
	{
		private static const NS : Namespace = new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private const NOT_YET_IMPLEMENTED_FAIL : Function = function(xmlPrimitive : XML) : void { 
			throw new ColladaError(xmlPrimitive.localName() + ' primitives are not supported yet'); 
		};
		
		private const NAME_TO_PARSER : Object = {
			'lines'			: NOT_YET_IMPLEMENTED_FAIL,
			'linestrips'	: NOT_YET_IMPLEMENTED_FAIL,
			'polygons'		: fillVerticesFromPolygons,
			'polylist'		: fillVerticesFromPolylist,
			'triangles'		: fillVerticesFromTriangles,
			'trifans'		: NOT_YET_IMPLEMENTED_FAIL,
			'tristrips'		: NOT_YET_IMPLEMENTED_FAIL
		};
		
		private var _material			: String;
		
		/**
		 * Contains a list of all semantics here 
		 */		
		private var _semantics			: Vector.<String>;
		
		/**
		 * We have to store this because there are two kinds of &lt;input&gt; nodes (shared and unshared) 
		 * 
		 * _offsets[semantic] = uint 
		 */
		private var _offsets			: Object;
		
		/**
		 * _sources[semantic] = Source 
		 */		
		private var _sources			: Object;
		
		/**
		 * as ids can be shared, this tells really how many ids are they
		 * per vertex.
		 */		
		private var _indicesPerVertex	: uint;
		
		/**
		 * Contains all ids (triangulated).
		 */		
		private var _triangleVertices	: Vector.<uint>;
		
		public function get material()			: String			{ return _material; }
		public function get semantics()			: Vector.<String>	{ return _semantics; }
		public function get indicesPerVertex()	: uint				{ return _indicesPerVertex; }
		public function get vertexCount()		: uint				{ return _triangleVertices.length / _indicesPerVertex; }
		public function get triangleCount()		: uint				{ return vertexCount / 3; }
		
		public function Triangles(xmlPrimitive	: XML = null, 
								  xmlMesh		: XML = null)
		{
			if (xmlPrimitive && xmlMesh)
				initializeFromXML(xmlPrimitive, xmlMesh);
		}
		
		/*
		* Fixme
		* There is maybe a misunderstanding reading the collada specifications, and it seams illogical
		* droping this data for the vertex component.
		* 
		* Nevertheless, we already know everything about the vertices.
		* According to the collada 1.5 specs, there is always and only 1 vertices nodes per mesh.
		* cf : Collada, Specification – Core Elements Reference 5-89, so why do we need references to it?
		*/
		private function initializeFromXML(xmlPrimitive	: XML, 
										   xmlMesh		: XML) : void
		{
			_semantics			= new Vector.<String>();
			_material			= xmlPrimitive.@material;
			_offsets			= new Object();
			_sources			= new Object();	
			
			_indicesPerVertex	= 0;
			
			var sources		: XMLList	= xmlMesh..NS::source;
			for each (var input : XML in xmlPrimitive.NS::input)
			{
				var semantic 	: String	= String(input.@semantic);
				var offset		: uint		= parseInt(String(input.@offset));
				var sourceId	: String	= String(input.@source).substr(1);
				
				if (offset + 1 > _indicesPerVertex)
					_indicesPerVertex = offset + 1;
				
				// fixme dirty patch to drop duplicate semantics.
				var isInside : Boolean = false;
				for each (var element : String in _semantics)
					if (element == semantic)
					{
						isInside = true;
						break;
					}
				if (!isInside)
					_semantics.push(semantic);
				_offsets[semantic] = offset;
				
				if (semantic != 'VERTEX')
					_sources[semantic] = Source.createFromXML(sources.(@id == sourceId)[0]);
			}
			
			// will triangulate the data in here and push ids to _triangleVertices
			NAME_TO_PARSER[xmlPrimitive.localName()](xmlPrimitive);
			
//			 cf comentary upside.
//			if (_offsets['VERTEX'] == undefined)
//				throw new Error(
//					'Invalid collada file. An input of VERTEX semantic is ' +
//					'mandatory in ' + xmlPrimitive.localName() + ' nodes');
		}
		
		/**
		 * No need for triangulation: just copies data from the p xml node to 
		 * our triangle vector. 
		 */		
		private function fillVerticesFromTriangles(xmlPrimitive : XML) : void
		{
			_triangleVertices = NumberListParser.parseUintList(xmlPrimitive.NS::p[0]);
		}
		
		/**
		 * Triangulate using p and vcount and push data to the triangle vector.
		 */		
		private function fillVerticesFromPolylist(xmlPrimitive : XML) : void
		{
			_triangleVertices	= new Vector.<uint>();
			
			var indexList 			: Vector.<uint> = NumberListParser.parseUintList(xmlPrimitive.NS::p[0]);
			var polyCountList		: Vector.<uint> = NumberListParser.parseUintList(xmlPrimitive.NS::vcount[0]);
			var polyCountListLength	: uint			= polyCountList.length;
			var currentIndex		: uint			= 0;
			
			for (var polygonId : uint = 0; polygonId < polyCountListLength; ++polygonId)
			{
				var numVertices : uint = polyCountList[polygonId];
				
				for (var j : uint = 1; j < numVertices - 1; ++j)
				{
					var k : uint;
					// triangle 0
					for (k = 0; k < _indicesPerVertex; ++k)
						_triangleVertices.push(indexList[currentIndex * _indicesPerVertex + k]);
					
					// triangle j 
					for (k = 0; k < _indicesPerVertex; ++k)
						_triangleVertices.push(indexList[(currentIndex + j) * _indicesPerVertex + k]);
					
					// triangle j + 1
					for (k = 0; k < _indicesPerVertex; ++k)
						_triangleVertices.push(indexList[(currentIndex + j + 1) * _indicesPerVertex + k]);
				}
				
				currentIndex += numVertices;
			}
		}
		
		private function fillVerticesFromPolygons(xmlPrimitive : XML) : void
		{
			_triangleVertices	= new Vector.<uint>();
			
			for each (var xmlP : XML in xmlPrimitive.NS::p)
			{
				var indexList		: Vector.<uint> = NumberListParser.parseUintList(xmlP);
				var numVertices 	: uint			= indexList.length / _indicesPerVertex;
				
				for (var j : uint = 1; j < numVertices - 1; ++j)
				{
					var k : uint;
					
					// triangle 0
					for (k = 0; k < _indicesPerVertex; ++k)
						_triangleVertices.push(indexList[k]);
					
					// triangle j 
					for (k = 0; k < _indicesPerVertex; ++k)
						_triangleVertices.push(indexList[j * _indicesPerVertex + k]);
					
					// triangle j + 1
					for (k = 0; k < _indicesPerVertex; ++k)
						_triangleVertices.push(indexList[(j + 1) * _indicesPerVertex + k]);
				}
			}
		}
		
		public function computeIndexStream() : IndexStream
		{
			var numVertices	: uint			= _triangleVertices.length / _indicesPerVertex;
			var indexBuffer : Vector.<uint> = new Vector.<uint>(numVertices, true);
			
			for (var i : uint = 0; i < numVertices; ++i)
				indexBuffer[i] = i;
			
			return new IndexStream(StreamUsage.DYNAMIC, indexBuffer);
		}
		
		public function computeVertexStream(verticesSemantics	: Vector.<String>,
											verticesDataSources	: Object) : VertexStream
		{
			var streamList : VertexStreamList = computeVertexStreamList(verticesSemantics, verticesDataSources);
			return VertexStream.extractSubStream(streamList, StreamUsage.DYNAMIC);
		}
		
		private function computeVertexStreamList(verticesSemantics		: Vector.<String>,
									   			 verticesDataSources	: Object) : VertexStreamList
		{
			var numSemantics		: uint;
			var semantic			: String;
			var componentId			: uint;
			var vertexStreamList	: VertexStreamList = new VertexStreamList();
			
			// handle vertexId (to be able to resplit buffers later, and load skins,
			// PC2 files or anything that need to change the vertices).
			vertexStreamList.pushVertexStream(computeIdVertexStream());
			
			// handle vertex semantics (usually, only position, sometimes with UV)
			numSemantics = verticesSemantics.length;
			
			for (componentId = 0; componentId < numSemantics; ++componentId)
			{
				semantic = verticesSemantics[componentId];
				vertexStreamList.pushVertexStream(
					computeVertexStreamFromSource(semantic, verticesDataSources[semantic], true)
				);
			}
			
			// handle triangle semantics (usually normals, uvs, colors...)
			numSemantics = _semantics.length;
			for (componentId = 0; componentId < numSemantics; ++componentId)
			{
				semantic = _semantics[componentId];
				if (semantic == 'VERTEX')
					continue;
				
				vertexStreamList.pushVertexStream(
					computeVertexStreamFromSource(semantic, _sources[semantic], false)
				);
			}
			
			return vertexStreamList;
		}
		
		private function computeVertexStreamFromSource(semantic			: String,
													   source			: Source, 
													   isVertexSource	: Boolean) : VertexStream
		{
			var buffer : Vector.<Number>;
			
			buffer = createVertexBuffer(semantic, source, isVertexSource);
			return createVertexStream(semantic, buffer);
		}
		
		private function createVertexBuffer(semantic		: String,
											source			: Source,
											isVertexSource	: Boolean) : Vector.<Number>
		{
			var numTriangleVertices	: uint				= _triangleVertices.length;
			var numVertices			: uint				= numTriangleVertices / _indicesPerVertex;
			var sourceData			: Array				= source.data;
			var sourceStride		: uint				= source.stride
			
			var vertexBuffer		: Vector.<Number>	= new Vector.<Number>(numVertices * sourceStride);
			var vertexBufferPos 	: uint				= 0;
			
			for (var indexOffset : uint = _offsets[isVertexSource ? 'VERTEX' : semantic]; 
				indexOffset < numTriangleVertices; 
				indexOffset += _indicesPerVertex)
			{
				var sourceIndex			: uint = _triangleVertices[indexOffset] * sourceStride;
				var sourceIndexLimit	: uint = sourceIndex + sourceStride;
				
				for (; sourceIndex < sourceIndexLimit; ++sourceIndex)
					vertexBuffer[vertexBufferPos++] = sourceData[sourceIndex]; 
			}
			
			return vertexBuffer;
		}
		
		/**
		 * This method is mainly here to manage collada's texture coords: invert the v coordinate, and
		 * if uvw was present in the feed, strip the w component.
		 */		
		private function createVertexStream(semantic	: String,
											buffer		: Vector.<Number>) : VertexStream
		{
			var component	: VertexComponent	= InputType.minko_collada::TO_COMPONENT[semantic];
			var format		: VertexFormat		= new VertexFormat(component);
			
			if (semantic == InputType.TEXCOORD)
			{
				var bufferLength	: uint = buffer.length;
				var numVertices		: uint = _triangleVertices.length / _indicesPerVertex;
				
				// sometimes, collada feed 3 numbers for texcoords (event for 2 dimensional images).
				if (bufferLength == 3 * numVertices)
				{
					for (var vertexId : uint = 0; vertexId < numVertices; ++vertexId)
					{
						buffer[2 * vertexId] = buffer[3 * vertexId];
						buffer[2 * vertexId + 1] = buffer[3 * vertexId + 1];
					}
					
					buffer			= buffer;
					bufferLength	= buffer.length	= 2 * numVertices;
				}
				
				if (bufferLength != 2 * numVertices)
					throw new Error("Failed importing UV stream.");
				
				// collada invert the v coordinate.
				for (var i : uint = 1; i < bufferLength; i += 2)
					buffer[i] = 1 - buffer[i];
			}
			
			return new VertexStream(StreamUsage.DYNAMIC, format, buffer);
		}
		
		public function computeIdVertexStream() : VertexStream
		{
			var numTriangleVertices	: uint				= _triangleVertices.length;
			var numVertices			: uint				= numTriangleVertices / _indicesPerVertex;
			
			var vertexBuffer		: Vector.<Number>	= new Vector.<Number>(numVertices);
			var vertexBufferPos 	: uint				= 0;
			
			for (var indexOffset : uint = _offsets['VERTEX']; 
				indexOffset < numTriangleVertices; 
				indexOffset += _indicesPerVertex)
			{
				vertexBuffer[vertexBufferPos++] = _triangleVertices[indexOffset];
			}
			
			return new VertexStream(StreamUsage.DYNAMIC, new VertexFormat(VertexComponent.ID), vertexBuffer);
		}
	}
}