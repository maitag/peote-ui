package peote.ui.interactive;

import peote.ui.interactive.Interactive;
import peote.ui.interactive.UIElement;
import peote.ui.interactive.interfaces.ParentElement;
import peote.ui.style.SliderStyle;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;

private typedef UISliderEventParams = UISlider->PointerEvent->Void;
private typedef UISliderWheelEventParams = UISlider->WheelEvent->Void;
private typedef UISliderDragEventParams = UISlider->Float->Float->Void;
private typedef UISliderFocusEventParams = UISlider->Void;
private typedef UISliderResizeEventParams = UISlider->Int->Int->Void;

@:allow(peote.ui)
class UISlider extends Interactive implements ParentElement
#if peote_layout
implements peote.layout.ILayoutElement
#end
{
	public var xOffset:Int = 0;
	public var yOffset:Int = 0;
	
	var last_x:Int;
	var last_y:Int;
			

	public var isVertical(default, null):Bool = false;
	
	public var valueStart:Float = 0.0;
	public var valueEnd:Float = 1.0;
	
	var _percent:Float = 0.0; // allways from 0.0 to 1.0
	
	public var percent(get, set):Float;
	inline function get_percent():Float return _percent;
	inline function set_percent(v:Float):Float {
		setPercent(v, false, false);
		return v;
	}
	
	public var value(get, set):Float;
	inline function get_value():Float return valueStart + _percent * (valueEnd - valueStart);
	inline function set_value(v:Float):Float {
		setValue(v, false, false);
		return v;
	}
	
	inline function normalizeValue(v:Float):Float {
		return v / (valueEnd - valueStart);
	}
	
	public inline function setPercent(percent:Float, triggerOnChange:Bool = true, triggerMouseMove:Bool = true) 
	{
		if (percent < 0.0) percent = 0.0 else if (percent > 1.0) percent = 1.0;
		_percent = percent;		
		updateDragger(triggerOnChange, triggerMouseMove);
	}
	
	public inline function setValue(value:Float, triggerOnChange:Bool = true, triggerMouseMove:Bool = true) 
	{
		setPercent(normalizeValue(value), triggerOnChange, triggerMouseMove);
	}
		
 	public inline function updateDragger(triggerOnChange:Bool = true, triggerMouseMove:Bool = true) 
	{
		if (dragger.isDragging) return;
		
		if (isVertical) dragger.y = y + Std.int( (height - dragger.height) * _percent );
		else dragger.x = x + Std.int( (width - dragger.width) * _percent );
 		if (isVertical) dragger.y = y + Std.int( (height - dragger.height) * _percent );
		else dragger.x = x + Std.int( (width - dragger.width) * _percent );
				
		dragger.maskByElement(this);
		dragger.updateLayout();
		
		if (isVisible && triggerMouseMove) uiDisplay.triggerMouse(this);
		if (triggerOnChange && onChange != null) onChange(this, value, percent);
	}
	
	public inline function setDelta(delta:Float, triggerOnChange:Bool = true, triggerMouseMove:Bool = true) 
	{
		// TODO: value/percent
		setValue(value + delta, triggerOnChange, triggerMouseMove);
	}

	public inline function setWheelDelta(delta:Float, triggerOnChange:Bool = true, triggerMouseMove:Bool = true) 
	{
		// TODO: make 0.05 here customizable (e.g. pixels per wheelclick)
		setPercent(percent - ((delta > 0) ? 1 : -1 ) * 0.05, triggerOnChange, triggerMouseMove);
	}

	var dragger:UIElement = null;
	var background:UIElement = null;
	
	public var backgroundStyle(get, set):Dynamic;
	inline function get_backgroundStyle():Dynamic return background.style;
	inline function set_backgroundStyle(style:Dynamic):Dynamic return background.style = style;
	
	public var draggerStyle(get, set):Dynamic;
	inline function get_draggerStyle():Dynamic return dragger.style;
	inline function set_draggerStyle(style:Dynamic):Dynamic return dragger.style = style;
	
	var sliderStyle:SliderStyle;
	
	public function new(xPosition:Int, yPosition:Int, width:Int, height:Int, zIndex:Int=0, sliderStyle:SliderStyle=null) 
	{
		super(xPosition, yPosition, width, height, zIndex);

		last_x = xPosition;
		last_y = yPosition;
		
		if (width < height) isVertical = true;
		
		this.sliderStyle = sliderStyle;
		
		if (sliderStyle.backgroundStyle != null) {
			background = new UIElement(xPosition, yPosition, width, height, zIndex+1, sliderStyle.backgroundStyle);
		}
		
		var draggerWidth:Int; 
		var draggerHeight:Int;
		
		if (isVertical) {
			if (sliderStyle.draggerSize != null) draggerWidth = sliderStyle.draggerSize else draggerWidth = width;
			if (sliderStyle.draggerLength != null) draggerHeight = sliderStyle.draggerLength else draggerHeight = width;
			if (sliderStyle.draggerStyle != null) {
				dragger = new UIElement(xPosition+Std.int((width - draggerWidth)/2), yPosition, draggerWidth, draggerHeight, zIndex+2, sliderStyle.draggerStyle);
			}
		}
		else {
			if (sliderStyle.draggerSize != null) draggerHeight = sliderStyle.draggerSize else draggerHeight = height;
			if (sliderStyle.draggerLength != null) draggerWidth = sliderStyle.draggerLength else draggerWidth = height;
			if (sliderStyle.draggerStyle != null) {
				dragger = new UIElement(xPosition, yPosition+Std.int((height - draggerHeight)/2), draggerWidth, draggerHeight, zIndex+2, sliderStyle.draggerStyle);
			}
		}
		
		
		// set the drag-area to same size as the slider
		//setDragArea();

		dragger.onPointerOver = function(uiElement:UIElement, e:PointerEvent) if (onDraggerPointerOver != null) onDraggerPointerOver(this, e);
		dragger.onPointerOut = function(uiElement:UIElement, e:PointerEvent) if (onDraggerPointerOut != null) onDraggerPointerOut(this, e);

		// start/stop dragging
		dragger.onPointerDown = function(uiElement:UIElement, e:PointerEvent) {
			if (onDraggerPointerDown != null) onDraggerPointerDown(this, e);
			#if (!peoteui_no_masking)
			dragger.masked = false; // <-- dragg allways the fully dragger (unmask it before)
			#end
			dragger.startDragging(e); // <----- start dragging
		}
		
		dragger.onPointerUp = function(uiElement:UIElement, e:PointerEvent) {
			dragger.stopDragging(e);  // <----- stop dragging
			updateLayout();
			if (onDraggerPointerUp != null) onDraggerPointerUp(this, e);
		}
		
		// onDrag event
		dragger.onDrag = function(uiElement:UIElement, percentX:Float, percentY:Float) {
			_percent = (isVertical) ? percentY : percentX;
			if (onChange != null) onChange(this, value, (isVertical) ? percentY : percentX);
		}
		
		// to bubble events down to the dragger
		dragger.overOutEventsBubbleTo = this;
		dragger.upDownEventsBubbleTo = this;
		dragger.wheelEventsBubbleTo = this;
	}
	
	inline function updateDragArea() {
		if (isVertical) dragger.setDragArea(x+Std.int((width - dragger.width)/2), y, dragger.width, height);
		else dragger.setDragArea(x, y+Std.int((height - dragger.height)/2), width, dragger.height);
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
		if (!isVisible) return;
		
		var deltaX = x - last_x;
		var deltaY = y - last_y;
		last_x = x;
		last_y = y;
		
		if (background != null) {
			background.x += deltaX;
			background.y += deltaY;
			background.width = width;
			background.height = height;
			background.maskByElement(this);
			background.updateLayout();
		}
		if (dragger != null) {
			dragger.x += deltaX;
			dragger.y += deltaY;
			if (isVertical) {
				if (sliderStyle.draggerSize == null) dragger.width = width;
				if (sliderStyle.draggerLength == null) dragger.height = width;
			}
			else {
				if (sliderStyle.draggerSize == null) dragger.height = height;
				if (sliderStyle.draggerLength == null) dragger.width = height;
			}
			updateDragArea();
			dragger.maskByElement(this);
			dragger.updateLayout();
		}
	}	
	
	override inline function updateVisible():Void
	{
		updateVisibleStyle();
		updateVisibleLayout();
	}
	
	// -----------------
	
	override inline function onAddVisibleToDisplay()
	{
		if (background != null) uiDisplay.add(background);
		if (dragger != null) {
			uiDisplay.add(dragger);
			// set the drag-area to same size as the slider
			updateDragArea();
		}
	}
	
	override inline function onRemoveVisibleFromDisplay()
	{
		if (background != null) {
			uiDisplay.remove(background);
		}
		if (dragger != null && dragger.isVisible) {
			uiDisplay.remove(dragger);
		}
		
	}

	// ------- DraggerEvents ----------------
	public var onDraggerPointerOver(null, default):UISliderEventParams = null;
	public var onDraggerPointerOut(null, default):UISliderEventParams = null;
	public var onDraggerPointerDown(null, default):UISliderEventParams = null;
	public var onDraggerPointerUp(null, default):UISliderEventParams = null;
	
	public var onChange(null, default):UISlider->Float->Float->Void = null;
	
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
	
	public var onResizeWidth(never, set):UISliderResizeEventParams;
	inline function set_onResizeWidth(f:UISliderResizeEventParams):UISliderResizeEventParams return setOnResizeWidth(this, f);
	
	public var onResizeHeight(never, set):UISliderResizeEventParams;
	inline function set_onResizeHeight(f:UISliderResizeEventParams):UISliderResizeEventParams return setOnResizeHeight(this, f);
}