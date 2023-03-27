package peote.ui.style;

import peote.ui.style.interfaces.Style;
import peote.ui.util.Space;

@:structInit
class SliderStyleImpl
{
	public var backgroundStyle:Style = null;	
	public var draggerStyle:Style = null;
	
	// force a vertical or horizontal slider,
	// by default it's set automatically (by aspect ratio of slidersize)
	public var vertical:Null<Bool> = null;    		
	
	// to en/disable dragging at start
	// TODO: public var draggable:Bool = true;

	// default slider behavior is:
	// 0.0 < -- > 1.0
	//  ^
	//  |
	//  v
	// 1.0	
	// to change this -> feel free to reverse
	public var reverse:Bool = false;
   
	public var draggerSpace:Space = null;
	public var backgroundSpace:Space = null;
	
	// ------------- into slider waist sizing -----------------
	
	// dragger pixel-size, is automatic set to slider size by default
	public var draggerSize:Null<Int> = null;
	public var draggerSizePercent:Null<Float> = null;
    
	// dragger pixel-offset
	public var draggerOffset:Null<Int> = null; // pixel offset
	public var draggerOffsetPercent:Null<Float> = null;  // 0.5 is for center
	
	// background pixel-size, is automatic set to slider size by default
	public var backgroundSize:Null<Int> = null;
	public var backgroundSizePercent:Null<Float> = null;
	
	// background pixel-offset
	public var backgroundOffset:Null<Int> = null; // pixel offset
	public var backgroundOffsetPercent:Null<Float> = null;  // 0.5 is for center
	
	// ------- into slider length and dragg direction ---------
	
	// pixel-size for the draggersize into dragg-direction, 
	// also to clamp values of slider.setDraggerSize(0.2)
	// at default it is same as draggerSize
	public var draggerLength:Null<Int> = null;
	public var draggerLengthPercent:Null<Float> = null;
	
	public var backgroundLength:Null<Int> = null;
	public var backgroundLengthPercent:Null<Float> = null;
	
	
	// extra spaces for dragarea start/end
	public var draggSpace:Null<Int> = null;
	public var draggSpaceStart:Null<Int> = null;
	public var draggSpaceEnd:Null<Int> = null;
}

@:structInit
@:forward
abstract SliderStyle(SliderStyleImpl) from SliderStyleImpl to SliderStyleImpl
{
	@:from
	static public inline function fromStyle(s:Style):SliderStyle {
		return {backgroundStyle:s, draggerStyle:s};
		// TODO: gemeinsames interface (ohne alle speziellen argumente!) was den style kopiert
		//return {backgroundStyle:s.copyAll(), draggerStyle:s.copyAll()};
	}

	//@:to
	//public inline function toStyle():Style {
		//return this.backgroundStyle;
	//}
}