package peote.ui.style;

import peote.view.Color;
import peote.ui.skin.SkinType;

@:structInit
class RoundedStyle //extends SimpleStyle
{	
	public var compatibleSkins(default, null):SkinType = SkinType.Simple | SkinType.Rounded;

	public var color      :Null<Color> = Color.GREY2;
	public var borderColor:Null<Color> = Color.GREY6;
	public var borderSize:Null<Float>   =  4.0;
	public var borderRadius:Null<Float> = 20.0;
	
	public function new(
		?color:Null<Color>,
		?borderColor:Null<Color>,
		?borderSize:Null<Float>,
		?borderRadius:Null<Float> 
	) {
		compatibleSkins = SkinType.Simple | SkinType.Rounded;
		//super(color);
		if (color != null) this.color = color;
		
		if (borderColor != null) this.borderColor = borderColor;
		if (borderSize != null) this.borderSize = borderSize;
		if (borderRadius != null) this.borderRadius = borderRadius;
	}
	
}
