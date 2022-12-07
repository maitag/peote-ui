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
				data = haxe.Http.requestUrl(url);
				File.saveContent(path, data);
			} 
			catch (e) throw('can\'t load data from $url' + e);			
		}
		
		return macro $v{Path.normalize(assetPath)};
	}
}
