package peote.ui.util;

class Unique {
	public static var id(get, null):Int = 0;
	static function get_id():Int return id++;
}