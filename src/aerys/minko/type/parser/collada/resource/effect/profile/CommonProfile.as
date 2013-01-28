package aerys.minko.type.parser.collada.resource.effect.profile
{
	import aerys.minko.Minko;
	import aerys.minko.render.material.Material;
	import aerys.minko.render.material.basic.BasicMaterial;
	import aerys.minko.type.error.collada.ColladaError;
	import aerys.minko.type.loader.parser.ParserOptions;
	import aerys.minko.type.log.DebugLevel;
	import aerys.minko.type.parser.collada.ColladaDocument;
	import aerys.minko.type.parser.collada.resource.effect.NewParam;
	import aerys.minko.type.parser.collada.resource.effect.technique.ConstantTechnique;
	import aerys.minko.type.parser.collada.resource.effect.technique.IExtraTechnique;
	import aerys.minko.type.parser.collada.resource.effect.technique.ITechnique;
	import aerys.minko.type.parser.collada.resource.effect.technique.OpenCollada3DSMaxExtraTechnique;
	import aerys.minko.type.parser.collada.resource.effect.technique.PhongTechnique;

	public class CommonProfile implements IProfile
	{
		public static const NS					: Namespace		= new Namespace(
            'http://www.collada.org/2005/11/COLLADASchema'
        );
		public static const DEFAULT_MATERIAL	: Material		= new BasicMaterial({
            diffuseColor: 0x00ff00ff
        });
		
		private var _id			: String;
		private var _params		: Object;
		private var _technique	: ITechnique;
        private var _extras     : Vector.<IExtraTechnique>;
		private var _document	: ColladaDocument;
		
		public function get id() : String
        {
            return _id;
        }
        
		public function get params() : Object
        {
            return _params;
        }
        
		public function get technique()	: ITechnique
        {
            return _technique;
        }
		
		public static function createFromXML(xml : XML, document : ColladaDocument) : CommonProfile
		{
			var id	        : String                    = xml.@id;
            var technique	: ITechnique	            = null;
            var extras      : Vector.<IExtraTechnique>  = new <IExtraTechnique>[];
			
			// parse technique.
            for each (var xmlTechnique : XML in xml.NS::technique[0].children())
            {
                var techniqueName : String = xmlTechnique.localName();
                
    			switch (techniqueName)
    			{
    				case 'constant':	
    					technique = ConstantTechnique.createFromXML(xmlTechnique, document);  
    					break;
                    case 'lambert':
                    case 'blinn':
                        Minko.log(
                            DebugLevel.PLUGIN_WARNING,
                            'Unkown technique \'' + techniqueName + '\', using Phong as a fallback.'
                        );
    				case 'phong':
    					technique = PhongTechnique.createFromXML(xmlTechnique, document);  
    					break;
                    case 'extra':
                        for each (xmlTechnique in xmlTechnique.NS::technique)
                            pushExtraTechnique(extras, xmlTechnique, document);
                        break;
    			}
            }
			
			// parse parameters.
			var params : Object = {};
			for each (var xmlNewParam : XML in xml.NS::newparam)
				params[xmlNewParam.@sid] = NewParam.createFromXML(xmlNewParam, document);
			
			return new CommonProfile(id, params, technique, extras, document);
		}
        
        private static function pushExtraTechnique(extras       : Vector.<IExtraTechnique>,
                                                   xmlTechnique : XML,
                                                   document     : ColladaDocument) : void
        {
            var profileName : String = xmlTechnique.@profile;
            
            switch (profileName)
            {
                case 'OpenCOLLADA3dsMax':
                    extras.push(OpenCollada3DSMaxExtraTechnique.fromXML(xmlTechnique, document));
                    break;
                default:
                    Minko.log(
                        DebugLevel.PLUGIN_WARNING,
                        'Unkown extra technique \'' + profileName + '\''
                    );
            }
        }
		
		public function CommonProfile(id		: String,
									  params	: Object,
									  technique	: ITechnique,
                                      extras    : Vector.<IExtraTechnique>,
									  document	: ColladaDocument)
		{
			_id			= id;
			_params		= params;
			_technique	= technique;
            _extras     = extras;
			_document	= document;
		}
		
		public function createMaterial(parserOptions 	: ParserOptions,
									   params 			: Object,
									   setParams 		: Object) : Material
		{
			var key			: String;
			var localParams : Object = new Object();
			
			for (key in params)
				localParams[key] = params[key];
			for (key in _params)
				localParams[key] = _params[key];
			
            var material : Material = _technique.createMaterial(
				parserOptions, localParams, setParams
			);
            
            for each (var extraTechnique : IExtraTechnique in _extras)
                extraTechnique.applyToMaterial(material, localParams, setParams);
            
			return material;
		}
	}
}
