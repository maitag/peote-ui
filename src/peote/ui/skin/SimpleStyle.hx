package peote.ui.skin;

import peote.view.Color;

@:structInit 
class SimpleStyle 
{
	public static inline var DEFAULT_color:Color = Color.GREY2;

	public var color:Null<Color> = DEFAULT_color;
	
	public function new(?color:Color) 
	{
		this.color = color;
	}
	
}
