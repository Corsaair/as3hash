
package corsaair.tool.hash
{
    import C.stdlib.*;
    
    import cli.args.*;
    
    import encoding.ansi.AnsiString;
    
    import flash.utils.ByteArray;
    
    import hash.ap;
    import hash.bkdr;
    import hash.brp;
    import hash.dek;
    import hash.djb;
    import hash.elf;
    import hash.fnv;
    import hash.js;
    import hash.pjw;
    import hash.rs;
    import hash.sdbm;
    
    import shell.FileSystem;

	public class App
	{
        
        private var _parser:ArgParser;
        private var _results:ArgResults;
        
        public var executableName:String;
        public var description:String;
        
		public function App()
		{
			super();
            _ctor();
		}
        
        private function _ctor():void
        {
            _parser  = new ArgParser();
            _parser.addFlag( "DEBUG", "D", "Debugging", false, false, null, true );
            _parser.addFlag( "help", "h", "Print this usage information.", false, false );
            _parser.addFlag( "verbose", "v", "Show additional diagnostic informations.", false, false );
            _parser.addOption( "hash", "a", "Hashing function used",
                               "",
                               [ "ap", "bkdr", "brp", "dek", "djb", "elf", "fnv", "js", "pjw", "rs", "sdbm" ],
                               { ap:   "Arash Partow hash function",
                                 bkdr: "Brian Kernighan and Dennis Ritchie hash function",
                                 brp:  "Bruno R. Preiss hash function",
                                 dek:  "Donald E. Knuth hash function",
                                 djb:  "Professor Daniel J. Bernstein hash function",
                                 elf:  "ELF hash function",
                                 fnv:  "Fowler–Noll–Vo hash function",
                                 js:   "Justin Sobel hash function",
                                 pjw:  "Peter J. Weinberger hash function",
                                 rs:   "Robert Sedgwicks hash function",
                                 sdbm: "open source SDBM project hash function"
                               },
                               "ap" );
            _parser.addOption( "format", "f", "Output format used",
                               "",
                               [ "hex", "num" ],
                               { hex: "hexadecimal",
                                 num: "numeric"
                               },
                               "hex" );
            _parser.addOption( "color", "c", "Output color",
                               "",
                               [ "none", "red", "green", "blue" ],
                               { none:  "no color",
                                 red:   "red color",
                                 green: "green color",
                                 blue:  "blue color"
                               },
                               "none" );
            
            executableName = "as3hash";
            description    = "Multiple hashing functions.";
        }
        
        private function _uintToHex( n:uint ):String
        {
            var hex:String = n.toString( 16 );
            if( hex.length%2 != 0 ) { hex = "0" + hex; }
            return hex;
        }
        
        public function showUsage( message:String = "" ):void
        {
            trace( executableName + " - " + description + "\n" );
            if( message != "" )
            {
                trace( message );
            }
            trace( "Usage: "  );
            trace( _parser.usage );
        }
        
        public function main( argv:Array = null ):void
        {
            if( (argv == null) || (argv && argv.length == 0) )
            {
                showUsage();
                exit( EXIT_FAILURE );
            }
        
            try
            {
                _results = _parser.parse( argv );
            }
            catch( e:SyntaxError )
            {
                showUsage( e.message );
                exit( EXIT_FAILURE );
            }
            
            if( _results[ "DEBUG" ] )
            {
                trace( "" );
                trace( JSON.stringify( _results, null, "  " ) );
                trace( "" );
                trace( "   help = " + _results[ "help" ] );
                trace( "verbose = " + _results[ "verbose" ] );
                trace( "   hash = " + _results[ "hash" ] );
                trace( " format = " + _results[ "format" ] );
                trace( "  color = " + _results[ "color" ] );
                trace( " string = " + _results.rest[0] );
            }
            
            if( _results.options[ "help" ] == true )
            {
                showUsage();
            }
            else
            {
                var str:String = "";
                var type:String;
                
                var tmp:String = _results.rest.join( " " );
                if( tmp )
                {
                    str = tmp;
                }
                
                if( _results[ "DEBUG" ] )
                {
                    trace( " str = " + str );
                }
                
                
                var bytes:ByteArray = new ByteArray();
                
                if( (str != "") && FileSystem.exists( str ) )
                {
                    bytes = FileSystem.readByteArray( str );
                    type = "file";
                }
                else
                {
                    bytes.writeUTFBytes( str );
                    type = "string";
                }
                bytes.position = 0;
                
                var hash:uint = 0;
                
                switch( _results[ "hash" ] )
                {
                    case "ap":
                    hash = ap( bytes );
                    break;
                    
                    case "bkdr":
                    hash = bkdr( bytes );
                    break;
                    
                    case "brp":
                    hash = brp( bytes );
                    break;
                    
                    case "dek":
                    hash = dek( bytes );
                    break;
                    
                    case "djb":
                    hash = djb( bytes );
                    break;
                    
                    case "elf":
                    hash = elf( bytes );
                    break;
                    
                    case "fnv":
                    hash = fnv( bytes );
                    break;
                    
                    case "js":
                    hash = js( bytes );
                    break;
                    
                    case "pjw":
                    hash = pjw( bytes );
                    break;
                    
                    case "rs":
                    hash = rs( bytes );
                    break;
                    
                    case "sdbm":
                    hash = sdbm( bytes );
                    break;
                }
                
                if( _results[ "DEBUG" ] )
                {
                    trace( " hash = " + hash );
                }
                
                
                var result:String = "";
                switch( _results[ "format" ] )
                {
                    case "num":
                    result = String( hash );
                    break;
                    
                    case "hex":
                    result = _uintToHex( hash );
                    break;
                }
                
                switch( _results[ "color" ] )
                {
                    case "red":
                    result += "「R! 」";
                    break;
                    
                    case "green":
                    result += "「G! 」";
                    break;
                    
                    case "blue":
                    result += "「B! 」";
                    break;
                    
                    case "none":
                    default:
                    // nothing
                }
                
                if( _results[ "color" ] != "none" )
                {
                    var ansi:AnsiString = new AnsiString( result );
                    result = ansi.toString();
                }
                
                if( _results[ "verbose" ] )
                {
                    var pre:String = _results[ "hash" ];
                    var sep:String = ":";
                    var post:String = type;
                    
                    if( _results[ "color" ] != "none" )
                    {
                        var tmp1:AnsiString = new AnsiString( pre + "「W! 」" );
                        pre = tmp1.toString();
                        
                        var tmp2:AnsiString = new AnsiString( sep + "「K! 」" );
                        sep = tmp2.toString();
                        
                        var tmp3:AnsiString = new AnsiString( post + "「Y! 」" );
                        post = tmp3.toString();
                    }
                    
                    trace( pre + sep + result + sep + post );
                }
                else
                {
                    trace( result );
                }
            }
            
            exit( EXIT_SUCCESS );
        }
        
	}

}
