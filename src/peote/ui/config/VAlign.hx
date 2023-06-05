package peote.ui.config;

#if (haxe_ver >= 4.0) enum #else @:enum#end
abstract VAlign(Int) from Int to Int 
{
	public static inline var TOP   :Int = 0 << 2;
	public static inline var CENTER:Int = 1 << 2;
	public static inline var BOTTOM:Int = 2 << 2;
}