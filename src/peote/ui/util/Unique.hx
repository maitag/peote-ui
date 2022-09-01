package peote.ui.util;

class Unique {
	public static var styleID(get, null):Int = 0;
	static function get_styleID():Int return styleID++;
	
	public static var fontStyleID(get, null):Int = 256;
	static function get_fontStyleID():Int return fontStyleID++;
}