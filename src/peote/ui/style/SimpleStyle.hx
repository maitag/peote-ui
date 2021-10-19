package peote.ui.style;

import peote.view.Color;
import peote.ui.skin.SkinType;

@:structInit 
class SimpleStyle 
{
	public var compatibleSkins(default, null):SkinType = SkinType.Simple;
	
	public var color:Null<Color> = Color.GREY2;
	
	public function new(?color:Color) 
	{
		compatibleSkins = SkinType.Simple;
		if (color != null) this.color = color;
	}
	
	public inline function copy():RoundedStyle
	{
		return new RoundedStyle(color);
	}
	
}
