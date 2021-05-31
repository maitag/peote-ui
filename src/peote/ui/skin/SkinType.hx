package peote.ui.skin;

@:enum abstract SkinType(Int) from Int to Int 
{
	public static inline var Simple  :Int = 1;
	public static inline var Rounded :Int = 2;
	public static inline var Textured:Int = 4;
	public static inline var Sliced  :Int = 8;
}
