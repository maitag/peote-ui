package peote.ui.style;

import peote.ui.style.interfaces.Style;

@:structInit
class SliderStyleImpl
{
	public var backgroundStyle:Style = null;	
	public var draggerStyle:Style = null;
	
	// force a vertical or horizontal slider,
	// by default it's set automatically (by aspect ratio of slidersize)
	public var vertical:Null<Bool> = null;    		
	
	// to en/disable dragging at start
	public var draggable:Bool = true;

	// default slider behavior is:
    // 0.0 < -- > 1.0
    //  ^
    //  |
    //  v
    // 1.0	
	// to change this -> feel free to reverse
	public var reverse:Bool = false;
   
	
	// ------------- into slider waist sizing -----------------
	
	// dragger pixel-size, is automatic set to slider size by default
	public var draggerSize:Null<Int> = null;
	public var draggerSizePercent:Null<Float> = null;
    
	// dragger pixel-offset, is centered by default
	public var draggerOffset:Int = 0;
	
	
	// ------- into slider length and dragg direction ---------
	
	// pixel-size for the draggersize into dragg-direction, 
	// also to clamp values of slider.setDraggerSize(0.2)
	// at default it is same as draggerSize
	public var draggerLength:Null<Int> = null;
	public var draggerLengthPercent:Null<Float> = null;
}

@:structInit
@:forward
abstract SliderStyle(SliderStyleImpl) from SliderStyleImpl to SliderStyleImpl
{
	@:from
	static public inline function fromStyle(s:Style):SliderStyle {
		return {backgroundStyle:s};
	}

	@:to
	public inline function toStyle():Style {
		return this.backgroundStyle;
	}	
}