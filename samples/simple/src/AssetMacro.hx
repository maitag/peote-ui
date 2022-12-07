package;

#if macro
import haxe.macro.Expr;
import haxe.io.Path;
import sys.FileSystem;
import haxe.io.Path;
import sys.io.File;
#end

class AssetMacro {
	public static macro function wget(url:String, assetPath:String):ExprOf<String> {
		var path = Path.normalize("../" + assetPath);
		
		// create directory if it not exists
		if (!FileSystem.exists(Path.directory(path))) {
			try {
				FileSystem.createDirectory(Path.directory(path));
			} 
			catch (e) throw('can\'t create ${Path.directory(path)}' + e);			
		}
		
		if (!FileSystem.exists(path)) {
			var data:String;
			try {
				// hack around ssl-certification (https://github.com/HaxeFoundation/haxe/issues/9481#issuecomment-633579121)
				var req = new sys.Http(url);
				req.setHeader("Agent-Orange", ""); // or any user-agent ;)
				req.request(false);
				
				// loading data
				data = haxe.Http.requestUrl(url);
			} 
			catch (e) throw('\n\nCan\'t load testdata from $url \n(' + e + ')\nPlease load it manually and save into $assetPath!\n');
		}

		return macro $v{Path.normalize(assetPath)};
	}
}
