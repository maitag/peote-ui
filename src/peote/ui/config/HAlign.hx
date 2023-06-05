package peote.ui.config;

#if (haxe_ver >= 4.0) enum #else @:enum#end
abstract HAlign(Int) from Int to Int 
{
	public static inline var LEFT  :Int = 0;
	public static inline var CENTER:Int = 1;
	public static inline var RIGHT :Int = 2;
}