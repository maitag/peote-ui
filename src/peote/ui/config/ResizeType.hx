package peote.ui.config;

@:enum abstract ResizeType(Int) from Int to Int 
{
	public static inline var TOP          = 1;
	public static inline var LEFT         = 2;
	public static inline var BOTTOM       = 4;
	public static inline var RIGHT        = 8;
	public static inline var TOP_LEFT     = 16;
	public static inline var TOP_RIGHT    = 32;
	public static inline var BOTTOM_LEFT  = 64;
	public static inline var BOTTOM_RIGHT = 128;
	
	public static inline var NONE         = 0;
	public static inline var ALL          = 255;
	public static inline var SIDE         = 15;
	
	
	public var hasEdge(get, never):Bool;
	inline function get_hasEdge():Bool return this > 15;
	
	public var hasSide(get, never):Bool;
	inline function get_hasSide():Bool return 0 < this & 15;
	
	
	public var hasTop(get, never):Bool;
	inline function get_hasTop():Bool return 0 < this & TOP;
	
	public var hasLeft(get, never):Bool;
	inline function get_hasLeft():Bool return 0 < this & LEFT;
	
	public var hasBottom(get, never):Bool;
	inline function get_hasBottom():Bool return 0 < this & BOTTOM;
	
	public var hasRight(get, never):Bool;
	inline function get_hasRight():Bool return 0 < this & RIGHT;
	
	public var hasTopLeft(get, never):Bool;
	inline function get_hasTopLeft():Bool return 0 < this & TOP_LEFT;
	
	public var hasTopRight(get, never):Bool;
	inline function get_hasTopRight():Bool return 0 < this & TOP_RIGHT;

	public var hasBottomLeft(get, never):Bool;
	inline function get_hasBottomLeft():Bool return 0 < this & BOTTOM_LEFT;
	
	public var hasBottomRight(get, never):Bool;
	inline function get_hasBottomRight():Bool return 0 < this & BOTTOM_RIGHT;

/*	
	public var atLeft(get, never):Bool;
	inline function get_atLeft():Bool return 0 < this & (TOP_LEFT + LEFT + BOTTOM_LEFT);

	public var atRight(get, never):Bool;
	inline function get_atRight():Bool return 0 < this & (TOP_RIGHT + RIGHT + BOTTOM_RIGHT);

	public var atTop(get, never):Bool;
	inline function get_atTop():Bool return 0 < this & (TOP_LEFT + TOP + TOP_RIGHT);

	public var atBottom(get, never):Bool;
	inline function get_atBottom():Bool return 0 < this & (BOTTOM_LEFT + BOTTOM + BOTTOM_RIGHT);
*/
	

}