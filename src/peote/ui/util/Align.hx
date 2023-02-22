package peote.ui.util;

abstract Align(Int) from Int to Int
{
	public static inline var TOP          = VAlign.TOP    | HAlign.CENTER;
	public static inline var TOP_LEFT     = VAlign.TOP    | HAlign.LEFT;
	public static inline var LEFT         = VAlign.CENTER | HAlign.LEFT;
	public static inline var BOTTOM_LEFT  = VAlign.BOTTOM | HAlign.LEFT;
	public static inline var BOTTOM       = VAlign.BOTTOM | HAlign.CENTER;
	public static inline var BOTTOM_RIGHT = VAlign.BOTTOM | HAlign.RIGHT;
	public static inline var RIGHT        = VAlign.CENTER | HAlign.RIGHT;
	public static inline var TOP_RIGHT    = VAlign.TOP    | HAlign.RIGHT;

	public static inline var CENTER  = VAlign.CENTER | HAlign.CENTER;
	

	public var horizontal(get, set):HAlign;
	inline function get_horizontal():HAlign return this & 3;
	inline function set_horizontal(h:HAlign):HAlign return this = (this & 12) | h;

	public var vertical(get, set):VAlign;
	inline function get_vertical():VAlign return this & 12;
	inline function set_vertical(v:VAlign):VAlign return this = (this & 3) | v;
}