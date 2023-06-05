package peote.ui.util;

#if (haxe_ver >= 4.0) enum #else @:enum#end
abstract UndoAction(Int) from Int to Int
{
	public static inline var INSERT = 0;
	public static inline var DELETE = 1;
}

