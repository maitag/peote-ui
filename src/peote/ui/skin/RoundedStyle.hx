package peote.ui.skin;

import peote.view.Color;

@:structInit
class RoundedStyle //extends SimpleStyle
{	
	public static inline var DEFAULT_color      :Color = Color.GREY2;
	public static inline var DEFAULT_borderColor:Color = Color.GREY6;
	public static inline var DEFAULT_borderSize  :Float = 4.0;
	public static inline var DEFAULT_borderRadius:Float = 20.0;
	
	public var color      :Null<Color> = DEFAULT_color;
	public var borderColor:Null<Color> = DEFAULT_borderColor;

	public var borderSize:Null<Float>   = DEFAULT_borderSize;
	public var borderRadius:Null<Float> = DEFAULT_borderRadius;
	
	public function new(
		?color:Null<Color>,
		?borderColor:Null<Color>,
		?borderSize:Null<Float>,
		?borderRadius:Null<Float> 
	) {
		//super(color);
		this.color = color;
		
		this.borderColor = borderColor;
		this.borderSize = borderSize;
		this.borderRadius = borderRadius;
	}
	
}
