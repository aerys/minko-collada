package aerys.minko.type.collada.store
{
	import aerys.minko.type.math.Matrix4x4;

	/**
	 * This represent a <source> node in a collada document, and provides
	 * methods to easily access the contained data.
	 * 
	 * @author Romain Gilliotte <romain.gilliotte@aerys.in>
	 * 
	 */	
	public final class Source
	{
		private static const NS	: Namespace	= new Namespace("http://www.collada.org/2005/11/COLLADASchema");
		
		private static const TYPES	: Object	= {
			"float"		: Number,
			"Name"		: String,
			"float4x4"	: Matrix4x4
		};
		
		protected var _id			: String;
		protected var _stride		: uint;
		protected var _count		: uint;
		protected var _paramNames	: Vector.<String>;
		protected var _paramTypes	: Vector.<Class>;
		protected var _data			: Array;
		
		public function get id()			: String			{ return _id; }
		public function get stride()		: uint				{ return _stride; }
		public function get count()			: uint				{ return _count; }
		public function get paramNames()	: Vector.<String>	{ return _paramNames; }
		public function get paramTypes()	: Vector.<Class>	{ return _paramTypes; }
		public function get data()			: Array				{ return _data; }
		
		/*
		 * For an obscure reason, there is no way to get the raw data using the
		 * .(@attrName == value) syntax, so we loop over all children to find the node we are
		 * searching for.
		 * 
		 * This should be the following.
		 * 		var xmlRawData			: XML		= xmlSource.(@id == sourceId)[0];
		 *
		 * If someone do understand what is wrong here, please fix it.
		 */
		public static function createFromXML(xmlSource : XML) : Source
		{
			// fill the source object.
			var source : Source		= new Source();
			source._id				= String(xmlSource.@id);
			
			var xmlAccessor : XML	= xmlSource..NS::accessor[0];
			source._stride			= parseInt(String(xmlAccessor.@stride));
			source._count			= parseInt(String(xmlAccessor.@count));
			
			source._paramNames	= new Vector.<String>();
			source._paramTypes	= new Vector.<Class>();
			for each (var xmlParam : XML in xmlAccessor.NS::param)
			{
				source._paramNames.push(String(xmlParam.@name));
				source._paramTypes.push(TYPES[String(xmlParam.@type)]);
			}
			
			// read data
			var sourceId			: String	= String(xmlAccessor.@source).substr(1);
			
			/*
			 * Kludge here.
			 */
			var xmlRawData			: XML		= null;
			for each (var node : XML in xmlSource.children())
				if (sourceId == node.attribute('id'))
					xmlRawData = node;
			
			if (xmlRawData == null)
				throw new Error('Source data could not be found');
			
			/*
			 * End of kludge.
			 */
			
			var rawData 			: Array		= String(xmlRawData).split(" ");
			
			var currentOffset		: uint		= 0;
			var currentDatum		: *;
			
			source._data = new Array();
			for (var index : uint = 0; index < source._count; ++index)
				for each (var paramType : Class in source._paramTypes)
			{
				if (paramType == String)
					currentDatum = rawData[currentOffset++];
				else if (paramType == Number)
					currentDatum = parseFloat(rawData[int(currentOffset++)]);
				else if (paramType == Matrix4x4)
					currentDatum = new Matrix4x4(
						parseFloat(rawData[int(currentOffset++)]), parseFloat(rawData[int(currentOffset++)]),
						parseFloat(rawData[int(currentOffset++)]), parseFloat(rawData[int(currentOffset++)]),
						parseFloat(rawData[int(currentOffset++)]), parseFloat(rawData[int(currentOffset++)]),
						parseFloat(rawData[int(currentOffset++)]), parseFloat(rawData[int(currentOffset++)]),
						parseFloat(rawData[int(currentOffset++)]), parseFloat(rawData[int(currentOffset++)]),
						parseFloat(rawData[int(currentOffset++)]), parseFloat(rawData[int(currentOffset++)]),
						parseFloat(rawData[int(currentOffset++)]), parseFloat(rawData[int(currentOffset++)]),
						parseFloat(rawData[int(currentOffset++)]), parseFloat(rawData[int(currentOffset++)])
					);
				else
					throw new Error('Unknown type found');
				
				source._data.push(currentDatum);
			}
			
			return source;
		}
		
		public function getItem(index : uint) : Object
		{
			var out : Object = new Object();
			
			for each (var paramName : String in _paramNames)
			out[paramName] = getComponentByParamName(index, paramName);
			
			return out;
		}
		
		public function getComponentByParamIndex(index		: uint, 
												 paramIndex	: uint) : Object
		{
			return _data[index * _paramNames.length + paramIndex];
		}
		
		public function getComponentByParamName(index		: uint, 
												paramName	: String) : Object
		{
			return _data[index * _paramNames.length + _paramNames.indexOf(paramName)];
		}
		
		public function pushVertexComponent(vertexId	: uint, 
											out			: Vector.<Number>) : void
		{
			var start	: uint = vertexId * _stride;
			var end		: uint = start + _stride;
			
			for (var i : uint = start; i < end; ++i)
			{
				// if data[i] is not a float, an exception will be raised.
				out.push(_data[i]);
			}
		}
	}
}