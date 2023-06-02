package peote.ui.interactive;

import peote.ui.interactive.Interactive;
import peote.ui.interactive.UIElement;
import peote.ui.config.ElementConfig;
import peote.ui.config.SliderConfig;
import peote.ui.config.Space;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;

private typedef UISliderEventParams = UISlider->PointerEvent->Void;
private typedef UISliderWheelEventParams = UISlider->WheelEvent->Void;
private typedef UISliderDragEventParams = UISlider->Float->Float->Void;
private typedef UISliderFocusEventParams = UISlider->Void;
private typedef UISliderResizeEventParams = UISlider->Int->Int->Void;

@:allow(peote.ui)
class UISlider extends Interactive
#if peote_layout
implements peote.layout.ILayoutElement
#end
{
	var _percent:Float = 0.0; // allways from 0.0 to 1.0
	
	public var percent(get, set):Float;
	inline function get_percent():Float return (reverse) ? 1.0 - _percent : _percent;
	inline function set_percent(v:Float):Float {
		setPercent(v, false, false);
		return v;
	}
	
	public var valueStart:Float = 0.0;
	public var valueEnd:Float = 1.0;
	
	public var value(get, set):Float;
	inline function get_value():Float return valueStart + percent * (valueEnd - valueStart);
	inline function set_value(v:Float):Float {
		setValue(v, false, false);
		return v;
	}
	
	inline function normalizeValue(v:Float):Float {
		if (valueStart != valueEnd) return (v - valueStart) / (valueEnd - valueStart)
		else return 0.0;
	}
	
	public inline function setPercent(percent:Float, triggerOnChange:Bool = true, triggerMouseMove:Bool = true) 
	{
		if (percent < 0.0) percent = 0.0 else if (percent > 1.0) percent = 1.0;
		_percent = (reverse) ? 1.0 - percent : percent;
		updateDragger(triggerOnChange, triggerMouseMove);
	}
	
	public inline function setValue(value:Float, triggerOnChange:Bool = true, triggerMouseMove:Bool = true) 
	{
		setPercent(normalizeValue(value), triggerOnChange, triggerMouseMove);
	}
		
	public inline function setRange(start:Float, end:Float, ?draggerLengthPercent:Null<Float>, triggerOnChange:Bool = true, triggerMouseMove:Bool = true) 
	{
		var newValue:Float = valueStart;
		if (valueStart != valueEnd) newValue = start + (value - valueStart) * (end - start) / (valueEnd - valueStart);
		
		valueStart = start;
		valueEnd = end;
		
		if (draggerLengthPercent != null) this.draggerLengthPercent = draggerLengthPercent;		
		// TODO disable dragging: if (valueStart == valueEnd)
		
		setValue(newValue, triggerOnChange, triggerMouseMove);
	}
	
	public inline function setDraggerLength(sizePercent:Null<Float>, triggerMouseMove:Bool = true) 
	{
		// TODO
		draggerLengthPercent = sizePercent;
		updateDragger(false, triggerMouseMove);
	}
		
 	public inline function updateDragger(triggerOnChange:Bool = true, triggerMouseMove:Bool = true) 
	{
		if (dragger.isDragging) return;
		
		if (isVertical) {
			dragger.height = draggerHeight;
			dragger.y = getDraggerPos(!isVertical, y, height, dragger.height);
		}
		else {
			dragger.width = draggerWidth;
			dragger.x = getDraggerPos(isVertical, x, width, dragger.width);
		}
		
		dragger.maskByElement(this);
		dragger.updateLayout();
		
		if (isVisible && triggerMouseMove) uiDisplay.triggerMouse(this);
		if (triggerOnChange) {
			if (_onChange != null) _onChange(this, value, percent);
			if (onChange != null) onChange(this, value, percent);
		}
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
	
	public var isVertical(default, null):Bool = false;	
	public var reverse:Bool = false;
	
	public var draggerLength:Null<Int> = null;
	var _sizePercent:Null<Float> = null;
	public var draggerLengthPercent(default, set):Null<Float> = null;
	inline function set_draggerLengthPercent(p:Null<Float>):Null<Float> return draggerLengthPercent = (p != null && p > 1.0) ? 1.0 : p;
	
	var draggerWidth(get, never):Int;
	var draggerHeight(get, never):Int;
	inline function get_draggerWidth():Int return get_draggerWidthHeight(isVertical, width, height);
	inline function get_draggerHeight():Int return get_draggerWidthHeight(!isVertical, height, width);	
	inline function get_draggerWidthHeight(_isVertical:Bool, w:Int, h:Int):Int {
		if (_isVertical) return w;
		else {
			if (draggerLengthPercent == null) return (draggerLength != null) ? draggerLength : h;
			else return Std.int( (draggerLength == null) ? (w- draggSpaceStart - draggSpaceEnd) * draggerLengthPercent : Math.max(draggerLength, (w- draggSpaceStart - draggSpaceEnd) * draggerLengthPercent) );
		}
	}
	
	inline function getDraggerPos(_isVertical:Bool, pos:Int, size:Int, draggerSize:Int):Int {
		if (_isVertical) return pos;
		else return pos + draggSpaceStart + Std.int( (size - draggerSize - draggSpaceStart - draggSpaceEnd) * _percent );
	}
	
	public var draggSpaceStart:Int = 0;
	public var draggSpaceEnd:Int = 0;

	public function new(xPosition:Int, yPosition:Int, width:Int, height:Int, zIndex:Int=0, ?config:SliderConfig) 
	{
		super(xPosition, yPosition, width, height, zIndex);
		
		if (config != null) 
		{			
			isVertical = (config.vertical == null) ? (width < height) : config.vertical;
			reverse = config.reverse;
			
			if (config.backgroundStyle != null) {
				var backgroundSpace:Space = (config.backgroundSpace != null) ? config.backgroundSpace.copy() : new Space();
				backgroundSpace.setRelativeWidthOrHeight(isVertical, width, height, config.backgroundSize, config.backgroundSizePercent, config.backgroundOffset, config.backgroundOffsetPercent);
				backgroundSpace.setRelativeWidthOrHeight(!isVertical, width, height, config.backgroundLength, config.backgroundLengthPercent, null, null);
				//background = new UIElement(x, y, width, height, zIndex + 1, { backgroundStyle:config.backgroundStyle, space:backgroundSpace });				
				background = new UIElement(x, y, width, height, zIndex + 1, new ElementConfig(config.backgroundStyle, backgroundSpace));				
			}
			
			if (config.draggSpace != null) draggSpaceStart = draggSpaceEnd = config.draggSpace;
			if (config.draggSpaceStart != null) draggSpaceStart = config.draggSpaceStart;
			if (config.draggSpaceEnd != null) draggSpaceEnd = config.draggSpaceEnd;
			
			draggerLength = config.draggerLength;
			draggerLengthPercent = config.draggerLengthPercent;
						
			if (config.draggerStyle != null) {
				var draggerSpace:Space = (config.draggerSpace != null) ? config.draggerSpace.copy() : new Space();
				draggerSpace.setRelativeWidthOrHeight(isVertical, width, height, config.draggerSize, config.draggerSizePercent, config.draggerOffset, config.draggerOffsetPercent);
				//dragger = new UIElement(getDraggerPos(isVertical, x, width, draggerWidth), getDraggerPos(!isVertical, y, height, draggerHeight), draggerWidth, draggerHeight, zIndex + 2, { backgroundStyle:config.draggerStyle, space:draggerSpace });
				dragger = new UIElement(getDraggerPos(isVertical, x, width, draggerWidth), getDraggerPos(!isVertical, y, height, draggerHeight), draggerWidth, draggerHeight, zIndex + 2, new ElementConfig(config.draggerStyle, draggerSpace) );
			}
			else dragger = new UIElement(getDraggerPos(isVertical, x, width, draggerWidth), getDraggerPos(!isVertical, y, height, draggerHeight), draggerWidth, draggerHeight, zIndex + 2);
			
			if (config.valueStart != 0.0 || config.valueEnd != 1.0) setRange(config.valueStart, config.valueEnd, false, false);
			if (config.value != 0.0) value = config.value;
			//updateDragger(false, false);
		}
		
		// set dragger events
		dragger.onPointerOver = function(uiElement:UIElement, e:PointerEvent) if (onDraggerPointerOver != null) onDraggerPointerOver(this, e);
		dragger.onPointerOut = function(uiElement:UIElement, e:PointerEvent) if (onDraggerPointerOut != null) onDraggerPointerOut(this, e);

		// start/stop dragging
		dragger.onPointerDown = function(uiElement:UIElement, e:PointerEvent) {
			if (onDraggerPointerDown != null) onDraggerPointerDown(this, e);
			#if (!peoteui_no_masking)
			dragger.masked = false; // <-- dragg allways the fully dragger (unmask it before)
			#end
			// TODO: better let disable dragging
			if (valueStart != valueEnd) dragger.startDragging(e); // <----- start dragging
		}
		
		dragger.onPointerUp = function(uiElement:UIElement, e:PointerEvent) {
			dragger.stopDragging(e);  // <----- stop dragging
			updateLayout();
			if (onDraggerPointerUp != null) onDraggerPointerUp(this, e);
		}
		
		// onDrag event
		dragger.onDrag = function(uiElement:UIElement, percentX:Float, percentY:Float) {
			_percent = (isVertical) ? percentY : percentX;
			if (_onChange != null) _onChange(this, value, percent);
			if (onChange != null) onChange(this, value, percent);
		}
		
		// to bubble events down to the dragger
		dragger.overOutEventsBubbleTo = this;
		dragger.upDownEventsBubbleTo = this;
		dragger.wheelEventsBubbleTo = this;
		
		if (background != null || dragger != null) changeZIndex = onChangeZIndex;
	}
	
	inline function updateDragArea() {
		if (isVertical) dragger.setDragArea(dragger.x, y + draggSpaceStart, dragger.width, height - draggSpaceStart - draggSpaceEnd);
		else dragger.setDragArea(x + draggSpaceStart, dragger.y, width - draggSpaceStart - draggSpaceEnd, dragger.height);
	}
	
	public inline function updateBackgroundStyle() if (background != null) background.updateVisibleStyle();
	public inline function updateDraggerStyle() if (dragger != null) dragger.updateVisibleStyle();
	
	inline function onChangeZIndex(z:Int, deltaZ:Int):Void
	{
		if (background != null) background.z += deltaZ;
		if (dragger != null) dragger.z += deltaZ;
	}
	
	override inline function updateVisibleStyle():Void
	{
		updateBackgroundStyle();
		updateDraggerStyle();
	}
	
	override inline function updateVisibleLayout():Void
	{
		if (!isVisible) return;
		
		if (background != null) {
			background.x = x;
			background.y = y;
			background.width = width;
			background.height = height;
			background.maskByElement(this);
			background.updateLayout();
		}
		if (dragger != null) {
			dragger.width = draggerWidth;
			dragger.height = draggerHeight;			
			dragger.x = getDraggerPos(isVertical, x, width, dragger.width);
			dragger.y = getDraggerPos(!isVertical, y, height, dragger.height);
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
	
	override inline function onAddVisibleToDisplay()
	{
		if (background != null) uiDisplay.add(background);
		if (dragger != null) {
			uiDisplay.add(dragger);			
			updateDragArea(); // set the drag-area to same size as the slider
		}
	}
	
	override inline function onRemoveVisibleFromDisplay()
	{
		if (background != null) uiDisplay.remove(background);
		if (dragger != null && dragger.isVisible) uiDisplay.remove(dragger);
	}
	
	// ------ internal Events ---------------
	var _onChange(null, default):UISlider->Float->Float->Void = null;

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
	
	public var onMouseWheel(never, set):UISliderWheelEventParams;
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