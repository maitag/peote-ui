package peote.ui.util;

@:enum abstract UndoAction(Int) from Int to Int
{
	public static inline var INSERT = 0;
	public static inline var DELETE = 1;
}

