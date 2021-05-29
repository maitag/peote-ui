package peote.ui.skin;

import peote.view.Color;


@:structInit 
class SimpleStyle 
{

	public var color:Color = Color.GREY2;
	
	//public var borderColor:Color = Color.GREY6;
	//public var borderSize:Float = 4.0;
	//public var borderRadius:Float = 20.0;
	
	public function new(color:Color = null) 
	{
		if (color != null) this.color = color;
	}
	
}
