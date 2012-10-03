package aerys.minko.type.parser.collada.helper
{
	import aerys.minko.Minko;
	import aerys.minko.ns.minko_collada;
	import aerys.minko.render.geometry.stream.IndexStream;
	import aerys.minko.render.geometry.stream.StreamUsage;
	import aerys.minko.render.geometry.stream.VertexStream;
	import aerys.minko.render.geometry.stream.VertexStreamList;
	import aerys.minko.render.geometry.stream.format.VertexComponent;
	import aerys.minko.render.geometry.stream.format.VertexFormat;
	import aerys.minko.render.geometry.stream.iterator.VertexIterator;
	import aerys.minko.render.geometry.stream.iterator.VertexReference;
	import aerys.minko.type.error.collada.ColladaError;
	import aerys.minko.type.log.DebugLevel;
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.parser.collada.enum.InputType;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public final class Triangles
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
		private var _indicesPerVertex	: int;
		
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
			_semantics			= new <String>[];
			_material			= xmlPrimitive.@material;
			_offsets			= {};
			_sources			= {};	
			
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
				{
					var source : XML = sources.(@id == sourceId)[0];
					
					if (source != null)
						_sources[semantic] = Source.createFromXML(source);
					else
						Minko.log(
							DebugLevel.PLUGIN_ERROR,
							'ColladaPlugin: Broken reference to source with id \''
							+ sourceId + '\'.'
						);
				}
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
			_triangleVertices = new <uint>[];
			NumberListParser.parseUintList(xmlPrimitive.NS::p[0], _triangleVertices);
		}
		
		/**
		 * Triangulate using p and vcount and push data to the triangle vector.
		 */		
		private function fillVerticesFromPolylist(xmlPrimitive : XML) : void
		{
			_triangleVertices	= new <uint>[];
			
			var writeIndex : int = 0;
			
			var xmlP : XML = xmlPrimitive.NS::p[0];
			var xmlVCount : XML = xmlPrimitive.NS::vcount[0];
			
			var indexList 			: Vector.<uint> = new Vector.<uint>();
			var polyCountList		: Vector.<uint> = new Vector.<uint>();
			
			NumberListParser.parseUintList(xmlP, indexList);
			
			var polyCountListLength	: uint = NumberListParser.parseUintList(xmlVCount, polyCountList);
			var currentIndex		: uint = 0;
			var length		: uint			= 0;
			
			for (var polygonId : uint = 0; polygonId < polyCountListLength; ++polygonId)
			{
				var numVertices : uint = polyCountList[polygonId];
				
				if (length < writeIndex)
					_triangleVertices.length = length = 2 * writeIndex;
				
				for (var j : uint = 1; j < numVertices - 1; ++j)
				{
					var k : uint;
					// triangle 0
					for (k = 0; k < _indicesPerVertex; ++k)
						_triangleVertices[writeIndex++] = indexList[int(int(currentIndex * _indicesPerVertex) + k)];
					
					// triangle j 
					for (k = 0; k < _indicesPerVertex; ++k)
						_triangleVertices[writeIndex++] = indexList[(currentIndex + j) * _indicesPerVertex + k];
					
					// triangle j + 1
					for (k = 0; k < _indicesPerVertex; ++k)
						_triangleVertices[writeIndex++] = indexList[(currentIndex + j + 1) * _indicesPerVertex + k];
				}
				
				currentIndex += numVertices;
			}
			
			_triangleVertices.length = writeIndex;
		}
		
		private function fillVerticesFromPolygons(xmlPrimitive : XML) : void
		{
			_triangleVertices	= new Vector.<uint>();
			var writeIndex : int = 0;
			
			var indexList	: Vector.<uint> = new Vector.<uint>();
			var length		: uint			= 0;
			
			for each (var xmlP : XML in xmlPrimitive.NS::p)
			{
				var indexListLength	: uint = NumberListParser.parseUintList(xmlP, indexList);
				var numVerticesM1	: uint = indexListLength / _indicesPerVertex - 1;
				
				if (length < writeIndex)
					_triangleVertices.length = length = 2 * writeIndex;
				
				for (var j : uint = 1; j < numVerticesM1; ++j)
				{
					var k : int;
					
					// triangle 0
					for (k = 0; k < _indicesPerVertex; ++k)
						_triangleVertices[writeIndex++] = indexList[k];
					
					// triangle j 
					for (k = 0; k < _indicesPerVertex; ++k)
						_triangleVertices[writeIndex++] = indexList[int(int(j * _indicesPerVertex) + k)];
					
					// triangle j + 1
					for (k = 0; k < _indicesPerVertex; ++k)
						_triangleVertices[writeIndex++] = indexList[int(int(int(j + 1) * _indicesPerVertex) + k)];
				}
			}
			
			_triangleVertices.length = writeIndex;
		}
		
		public function fastComputeIndexStream(verticesSemantics	: Vector.<String>,
											   verticesDataSources	: Object) : Vector.<uint>
		{
			var numTriangleVertices	: uint			= _triangleVertices.length;
			var numVertices			: uint			= numTriangleVertices / _indicesPerVertex;
			
			var indexBuffer			: Vector.<uint>	= new <uint>[];
			var vertexBufferPos 	: uint			= 0;
			
			for (var indexOffset : uint = _offsets['VERTEX']; 
				 indexOffset < numTriangleVertices; 
				 indexOffset += _indicesPerVertex)
			{
				indexBuffer.push(_triangleVertices[indexOffset]);
			}
			
			return indexBuffer;
		}
		
		public function fastComputeVertexStream(verticesSemantics	: Vector.<String>,
												verticesDataSources	: Object) : VertexStream
		{
			var numSemantics		: uint;
			var semantic			: String;
			var componentId			: uint;
			var vertexStreamList	: VertexStreamList = new VertexStreamList();
			
			var numVertices			: uint = Source(verticesDataSources['POSITION']).data.length / 3;
			
			var format				: VertexFormat = new VertexFormat(VertexComponent.ID);
			
			numSemantics = verticesSemantics.length;
			for (componentId = 0; componentId < numSemantics; ++componentId)
				if (InputType.minko_collada::TO_COMPONENT[verticesSemantics[componentId]])
					format.addComponent(InputType.minko_collada::TO_COMPONENT[verticesSemantics[componentId]]);
			
			numSemantics = _semantics.length;
			for (componentId = 0; componentId < numSemantics; ++componentId)
				if (InputType.minko_collada::TO_COMPONENT[_semantics[componentId]])
					format.addComponent(InputType.minko_collada::TO_COMPONENT[_semantics[componentId]]);
			
			
			var dwordsPerVertex		: uint				= format.numBytesPerVertex;
			var bufferSize			: uint 				= numVertices * dwordsPerVertex;
			var vertexBuffer		: Vector.<Number>	= new Vector.<Number>(bufferSize, true);
			var numTriangleVertices	: uint				= _triangleVertices.length;
			var component			: VertexComponent
			
			numSemantics = verticesSemantics.length;
			for (componentId = 0; componentId < numSemantics; ++componentId)
			{
				semantic = verticesSemantics[componentId];
				component = InputType.minko_collada::TO_COMPONENT[semantic];
				if (!component)
					continue;
				
				var source			: Source	= verticesDataSources[semantic];
				var sourceData		: Array		= source.data;
				var componentDwords	: uint		= component.numProperties;
				var sourceStride	: uint		= source.stride;
				
				var innerOffset		: uint		= format.getBytesOffsetForComponent(component);
				
				for (var indexOffset : uint = _offsets['VERTEX']; 
					 indexOffset < numTriangleVertices; 
					 indexOffset += _indicesPerVertex)
				{
					var vertexId			: uint = _triangleVertices[indexOffset];
					var sourceIndex			: uint = vertexId * sourceStride;
					var sourceIndexLimit	: uint = sourceIndex + componentDwords;
					
					var destIndex			: uint = vertexId * dwordsPerVertex + innerOffset;
					
					for (; sourceIndex < sourceIndexLimit; ++sourceIndex)
						vertexBuffer[destIndex++] = sourceData[sourceIndex];
				}
			}
			
			var index2Offset : uint;
			numSemantics = _semantics.length;
			for (componentId = 0; componentId < numSemantics; ++componentId)
			{
				semantic = _semantics[componentId];
				component = InputType.minko_collada::TO_COMPONENT[semantic];
				if (!component)
					continue;
				
				source			= _sources[_semantics[componentId]];
				sourceData		= source.data;
				componentDwords	= component.numProperties;
				sourceStride	= source.stride;
				innerOffset		= format.getBytesOffsetForComponent(component);
					
				for (indexOffset = _offsets['VERTEX'], index2Offset = _offsets[semantic]; 
					 indexOffset < numTriangleVertices; 
					 indexOffset += _indicesPerVertex,
					 index2Offset += _indicesPerVertex)
				{
					var dataId	: uint = _triangleVertices[index2Offset];
					
					vertexId			= _triangleVertices[indexOffset];
					sourceIndex			= dataId * sourceStride;
					sourceIndexLimit	= sourceIndex + componentDwords;
					
					destIndex			= vertexId * dwordsPerVertex + innerOffset;
					
					for (; sourceIndex < sourceIndexLimit; ++sourceIndex)
						vertexBuffer[destIndex++] = sourceData[sourceIndex];
				}
			}
			
			var j : Number = 0;
			for (var i : uint = format.getBytesOffsetForComponent(VertexComponent.ID);
				i < bufferSize;
				i += dwordsPerVertex)
			{
				vertexBuffer[i] = j++;
			}
			
			// invert z to handle right to left handed coordinates
			for (i = 0; i < bufferSize; i+= dwordsPerVertex)
			{
				if (format.hasComponent(VertexComponent.XYZ))
					vertexBuffer[format.getOffsetForProperty('x')] *= -1.0;
				if (format.hasComponent(VertexComponent.NORMAL))
					vertexBuffer[format.getOffsetForProperty('nx')] *= -1.0;
				if (format.hasComponent(VertexComponent.TANGENT))
					vertexBuffer[format.getOffsetForProperty('tx')] *= -1.0;
				
				if (format.hasComponent(VertexComponent.UV))
				{
					var vOffset : uint = format.getOffsetForProperty('v');
					
					vertexBuffer[vOffset] = 1. - vertexBuffer[vOffset];
				}
			}
			
			return VertexStream.fromVector(StreamUsage.DYNAMIC, format, vertexBuffer);
		}
		
		public function computeIndexStream() : Vector.<uint>
		{
			var numIndices	: uint			= _triangleVertices.length / _indicesPerVertex;
			var data		: Vector.<uint>	= new <uint>[];
			
			for (var i : uint = 0; i < numIndices; ++i)
				data[i] = numIndices - i - 1;
			
			return data;
		}
		
		public function computeVertexStream(verticesSemantics	: Vector.<String>,
											verticesDataSources	: Object) : VertexStream
		{
			var streamList 	: VertexStreamList 	= computeVertexStreamList(verticesSemantics, verticesDataSources);
			var stream		: VertexStream		= VertexStream.extractSubStream(streamList, StreamUsage.DYNAMIC);
//			var format		: VertexFormat		= stream.format;
//			var numVertices	: uint				= stream.numVertices;
//			var scale		: Matrix4x4			= new Matrix4x4().appendScale(1, 1, -1);
//			
//			if (format.hasComponent(VertexComponent.XYZ))
//				stream.applyTransform(VertexComponent.XYZ, scale);
//			if (format.hasComponent(VertexComponent.NORMAL))
//				stream.applyTransform(VertexComponent.NORMAL, scale);
//			if (format.hasComponent(VertexComponent.TANGENT))
//				stream.applyTransform(VertexComponent.TANGENT, scale);
			
			return stream;
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
				if (InputType.minko_collada::TO_COMPONENT[semantic] == undefined)
					continue;
				
				if (_sources[semantic])
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
			return createVertexStream(semantic, createVertexBuffer(semantic, source, isVertexSource));
		}
		
		private function createVertexBuffer(semantic		: String,
											source			: Source,
											isVertexSource	: Boolean) : ByteArray
		{
			var numTriangleVertices	: uint		= _triangleVertices.length;
			var numVertices			: uint		= numTriangleVertices / _indicesPerVertex;
			var sourceData			: Array		= source.data;
			var sourceStride		: uint		= source.stride
			var vertexBuffer		: ByteArray	= new ByteArray();
			
			vertexBuffer.endian = Endian.LITTLE_ENDIAN;
			for (var indexOffset : uint = _offsets[isVertexSource ? 'VERTEX' : semantic]; 
			 	 indexOffset < numTriangleVertices; 
				 indexOffset += _indicesPerVertex)
			{
				var sourceIndex			: uint = _triangleVertices[indexOffset] * sourceStride;
				var sourceIndexLimit	: uint = sourceIndex + sourceStride;
				
				for (; sourceIndex < sourceIndexLimit; ++sourceIndex)
					vertexBuffer.writeFloat(sourceData[sourceIndex]);
			}
			
			vertexBuffer.position = 0;
						
			return vertexBuffer;
		}
		
		/**
		 * This method is mainly here to manage collada's texture coords: invert the v coordinate, and
		 * if uvw was present in the feed, strip the w component.
		 */		
		private function createVertexStream(semantic	: String,
											buffer		: ByteArray) : VertexStream
		{
			var component	: VertexComponent	= InputType.minko_collada::TO_COMPONENT[semantic];
			var format		: VertexFormat		= new VertexFormat(component);
			
			if (semantic == InputType.TEXCOORD)
			{
				var numDwords	: uint = buffer.bytesAvailable >>> 2;
				var numVertices	: uint = _triangleVertices.length / _indicesPerVertex;

				// sometimes, collada feed 3 numbers for texcoords (even for 2 dimensional images).
				if (numDwords == 3 * numVertices)
				{
					buffer.position = 0;
					for (var vertexId : uint = 0; vertexId < numVertices; ++vertexId)
						buffer.writeBytes(buffer, vertexId * 12, 8);
					
					numDwords = 2 * numVertices;
					buffer.length = numVertices << 3;
				}
				
				if (numDwords != 2 * numVertices)
					throw new Error('Failed importing UV stream.');
				
				buffer.position = 0;
				// collada invert the v coordinate.
				for (var i : uint = 1; i < numDwords; i += 2)
				{
					var u : Number = buffer.readFloat();
					var v : Number = buffer.readFloat();
					
					buffer.position -= 4;
					buffer.writeFloat(1. - v);
				}
				
				buffer.position = 0;
			}
			
			return new VertexStream(StreamUsage.DYNAMIC, format, buffer);
		}
		
		public function computeIdVertexStream() : VertexStream
		{
			var numTriangleVertices	: uint		= _triangleVertices.length;
			var numVertices			: uint		= numTriangleVertices / _indicesPerVertex;
			
			var vertexBuffer		: ByteArray	= new ByteArray();
			
			vertexBuffer.endian = Endian.LITTLE_ENDIAN;
			for (var indexOffset : uint = _offsets['VERTEX'];
				 indexOffset < numTriangleVertices; 
				 indexOffset += _indicesPerVertex)
			{
				vertexBuffer.writeFloat(_triangleVertices[indexOffset]);
			}
			
			vertexBuffer.position = 0;
			
			return new VertexStream(StreamUsage.DYNAMIC, new VertexFormat(VertexComponent.ID), vertexBuffer);
		}
	}
}