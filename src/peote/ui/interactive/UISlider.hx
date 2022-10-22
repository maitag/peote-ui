package peote.ui.interactive;

import peote.ui.interactive.Interactive;
import peote.ui.interactive.UIElement;
import peote.ui.style.SliderStyle;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;

private typedef UISliderEventParams = UISlider->PointerEvent->Void;
private typedef UISliderWheelEventParams = UISlider->WheelEvent->Void;
private typedef UISliderDragEventParams = UISlider->Float->Float->Void;
private typedef UISliderFocusEventParams = UISlider->Void;

@:allow(peote.ui)
class UISlider extends Interactive
#if peote_layout
implements peote.layout.ILayoutElement
#end
{	
	public var dragger:UIElement = null;
	
	public function new(xPosition:Int=0, yPosition:Int=0, width:Int=100, height:Int=100, zIndex:Int=0, sliderStyle:SliderStyle=null) 
	{
		super(xPosition, yPosition, width, height, zIndex);
		
		// ...
	}
		
	override function updateVisible():Void
	{
		
	}
	
	// -----------------
	
	override inline function onAddVisibleToDisplay()
	{
		
	}
	
	override inline function onRemoveVisibleFromDisplay()
	{		
		
	}

	// ---------- Events --------------------
	
	public var onPointerOver(never, set):UISliderEventParams;
	inline function set_onPointerOver(f:UISliderEventParams):UISliderEventParams return setOnPointerOver(this, f);
	
	public var onPointerOut(never, set):UISliderEventParams;
	inline function set_onPointerOut(f:UISliderEventParams):UISliderEventParams return setOnPointerOut(this, f);
	
	public var onPointerMove(never, set):UISliderEventParams;
	inline function set_onPointerMove(f:UISliderEventParams):UISliderEventParams return setOnPointerMove(this, f);
	
	public var onPointerDown(never, set):UISliderEventParams;
	inline function set_onPointerDown(f:UISliderEventParams):UISliderEventParams return setOnPointerDown(this, f);
	
	public var onPointerUp(never, set):UISliderEventParams;
	inline function set_onPointerUp(f:UISliderEventParams):UISliderEventParams return setOnPointerUp(this, f);
	
	public var onPointerClick(never, set):UISliderEventParams;
	inline function set_onPointerClick(f:UISliderEventParams):UISliderEventParams return setOnPointerClick(this, f);
		
	public var onMouseWheel(default, set):UISliderWheelEventParams;
	inline function set_onMouseWheel(f:UISliderWheelEventParams):UISliderWheelEventParams  return setOnMouseWheel(this, f);
	
	public var onDrag(never, set):UISliderDragEventParams;
	inline function set_onDrag(f:UISliderDragEventParams):UISliderDragEventParams return setOnDrag(this, f);
	
	public var onFocus(never, set):UISliderFocusEventParams;
	inline function set_onFocus(f:UISliderFocusEventParams):UISliderFocusEventParams return setOnFocus(this, f);
	
}