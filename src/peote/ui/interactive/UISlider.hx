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
	public var isVertical(default, null):Bool = false;
	
	public var _value:Float = 0.0;
	
	public var value(get, set):Float;
	inline function get_value():Float return _value;
	inline function set_value(v:Float):Float {
		setValue(v, false, false);
		return v;
	}
	
	public inline function setValue(value:Float, triggerOnChange:Bool = true, triggerMouseMove:Bool = true) 
	{
		if (dragger.isDragging) return;
		
		if (value < 0.0) value = 0.0 else if (value > 1.0) value = 1.0;
 		if (isVertical) dragger.y = Std.int( y + (height - dragger.height) * value );
		else dragger.x = Std.int( x + (width - dragger.width) * value );
		//dragger.updateLayout();
		_updateDraggerMask();
		if (isVisible && triggerMouseMove) uiDisplay.triggerMouse(this);
		if (triggerOnChange && onChange != null) onChange(this, value);
		_value = value;
	}
	
	public inline function setDelta(delta:Float, triggerOnChange:Bool = true, triggerMouseMove:Bool = true) 
	{
		setValue(value + delta, triggerOnChange, triggerMouseMove);
	}

	var dragger:UIElement = null;
	var background:UIElement = null;
	
	public var backgroundStyle(get, set):Dynamic;
	inline function get_backgroundStyle():Dynamic return background.style;
	inline function set_backgroundStyle(style:Dynamic):Dynamic return background.style = style;
	
	public var draggerStyle(get, set):Dynamic;
	inline function get_draggerStyle():Dynamic return dragger.style;
	inline function set_draggerStyle(style:Dynamic):Dynamic return dragger.style = style;
	
	public function new(xPosition:Int=0, yPosition:Int=0, width:Int=100, height:Int=100, zIndex:Int=0, sliderStyle:SliderStyle=null) 
	{
		super(xPosition, yPosition, width, height, zIndex);

		if (width < height) isVertical = true;
		
		if (sliderStyle.backgroundStyle != null) background = new UIElement(xPosition, yPosition, width, height, zIndex, sliderStyle.backgroundStyle);
		
		var draggerWidth:Int; 
		var draggerHeight:Int;
		if (isVertical) {
			if (sliderStyle.draggerSize != null) draggerWidth = sliderStyle.draggerSize else draggerWidth = width;
			if (sliderStyle.draggerLength != null) draggerHeight = sliderStyle.draggerLength else draggerHeight = width;
		}
		else {
			if (sliderStyle.draggerSize != null) draggerHeight = sliderStyle.draggerSize else draggerHeight = height;
			if (sliderStyle.draggerLength != null) draggerWidth = sliderStyle.draggerLength else draggerWidth = height;
		}
		
		if (sliderStyle.draggerStyle != null) dragger = new UIElement(xPosition, yPosition, draggerWidth, draggerHeight, zIndex+1, sliderStyle.draggerStyle);
		
		// set the drag-area to same size as the slider
		dragger.setDragArea(xPosition, yPosition, width, height);

		dragger.onPointerOver = function(uiElement:UIElement, e:PointerEvent) if (onDraggerPointerOver != null) onDraggerPointerOver(this, e);
		dragger.onPointerOut = function(uiElement:UIElement, e:PointerEvent) if (onDraggerPointerOut != null) onDraggerPointerOut(this, e);

		// start/stop dragging
		dragger.onPointerDown = function(uiElement:UIElement, e:PointerEvent) {
			if (onDraggerPointerDown != null) onDraggerPointerDown(this, e);
			dragger.masked = false;
			dragger.startDragging(e); // <----- start dragging
			//trace("Dragger: DOWN", dragger.isDragging);
		}
		
		dragger.onPointerUp = function(uiElement:UIElement, e:PointerEvent) {
			//trace("Dragger: UP ", dragger.isDragging, uiDisplay.draggingMouseElements.length);
			
			// PROBLEM: SUPER-Glitch here if buffer-index is changed so not same as pickable anymore or something
			// how could it not be the same "dragger"-instance here anymore =?= 
			
			dragger.stopDragging(e);  // <----- stop dragging
			_updateDraggerMask();
			if (onDraggerPointerUp != null) onDraggerPointerUp(this, e);
		}
		
		// onDrag event
		dragger.onDrag = function(uiElement:UIElement, percentX:Float, percentY:Float) {
			_value = (isVertical) ? percentY : percentX;
			if (onChange != null) onChange(this, (isVertical) ? percentY : percentX);
		}
		
		// to bubble events down to the dragger
		dragger.overOutEventsBubbleTo = this;
		dragger.upDownEventsBubbleTo = this;
		dragger.wheelEventsBubbleTo = this;


	}
		
	public inline function updateBackgroundStyle() if (background != null) background.updateVisibleStyle();
	public inline function updateDraggerStyle() if (dragger != null) dragger.updateVisibleStyle();
	
	override inline function updateVisibleStyle():Void
	{
		updateBackgroundStyle();
		updateDraggerStyle();
	}
	
	override inline function updateVisibleLayout():Void
	{
		if (background != null) {
			background.x = x; background.y = y;
			if (masked) {
				background.maskX = maskX; background.maskY = maskY; background.maskWidth = maskWidth; background.maskHeight = maskHeight;
				background.masked = true;
			}
			background.updateVisibleLayout();
		}
		if (dragger != null) {
			//dragger.x = x; dragger.y = y;
			
			if (isVertical) {
				dragger.x = x;
				dragger.y = Std.int( y + (height - dragger.height) * value );
			}
			else {
				dragger.y = y;
				dragger.x = Std.int( x + (width - dragger.width) * value );
			}
			
			dragger.setDragArea(x, y, width, height);
			_updateDraggerMask();
		}
	}

	function _updateDraggerMask()
	{				
		if (masked) 
		{
			dragger.maskByElement(this);			
			dragger.masked = true;
		}
		
		//dragger.update();
		dragger.updateLayout();
	}
	
	
	override inline function updateVisible():Void
	{
		updateVisibleStyle();
		updateVisibleLayout();
	}
	
	// -----------------
	
	override inline function onAddVisibleToDisplay()
	{ 	//trace("SliderShows");
		if (background != null) uiDisplay.add(background);
		if (dragger != null && !dragger.isVisible) uiDisplay.add(dragger);
	}
	
	override inline function onRemoveVisibleFromDisplay()
	{	//trace("SliderHides", dragger.isVisible);
		if (background != null) uiDisplay.remove(background);
		if (dragger != null && dragger.isVisible) uiDisplay.remove(dragger);
		
	}

	// ------- DraggerEvents ----------------
	public var onDraggerPointerOver(null, default):UISliderEventParams = null;
	public var onDraggerPointerOut(null, default):UISliderEventParams = null;
	public var onDraggerPointerDown(null, default):UISliderEventParams = null;
	public var onDraggerPointerUp(null, default):UISliderEventParams = null;
	
	public var onChange(null, default):UISlider->Float->Void = null;
	
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