package peote.ui.interactive;

import peote.ui.interactive.Interactive;
import peote.ui.interactive.UIElement;
import peote.ui.style.interfaces.Style;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;

private typedef UIAreaEventParams = UIArea->PointerEvent->Void;
private typedef UIAreaWheelEventParams = UIArea->WheelEvent->Void;
private typedef UIAreaDragEventParams = UIArea->Float->Float->Void;
private typedef UIAreaFocusEventParams = UIArea->Void;

@:allow(peote.ui)
class UIArea extends Interactive
#if peote_layout
implements peote.layout.ILayoutElement
#end
{
	var uiElements = new Array<Interactive>();
	var last_x:Int;
	var last_y:Int;
	var last_xOffset:Int = 0;
	var last_yOffset:Int = 0;
	
	public var xOffset:Int = 0;
	public var yOffset:Int = 0;
	
	public var background:UIElement = null;
	
	public var backgroundStyle(get, set):Dynamic;
	inline function get_backgroundStyle():Dynamic return background.style;
	inline function set_backgroundStyle(style:Dynamic):Dynamic return background.style = style;
		
	public function new(xPosition:Int=0, yPosition:Int=0, width:Int=100, height:Int=100, zIndex:Int=0, backgroundStyle:Style=null) 
	{
		super(xPosition, yPosition, width, height, zIndex);
		
		if (backgroundStyle != null) background = new UIElement(xPosition, yPosition, width, height, zIndex, backgroundStyle);
		last_x = xPosition;
		last_y = yPosition;
	}
	
	public function add(uiElement:Interactive)
	{	
		// to bubble events down to the elements
		uiElement.overOutEventsBubbleTo = this;
		uiElement.upDownEventsBubbleTo = this;
		uiElement.wheelEventsBubbleTo = this;
		
		uiElement.x += x + xOffset;
		uiElement.y += y + yOffset;
		uiElement.z = z;
		// TODO: if mask-enabled
		
		uiElement.masked = true;
		uiElement.updateLayout();
		
		uiElements.push(uiElement);
		if (isVisible) uiDisplay.add(uiElement);
	}
	
	public function remove(uiElement:Interactive) 
	{
		if (isVisible) uiDisplay.remove(uiElement);
		uiElements.remove(uiElement);
	}
	
	
	
	// ---------------------------------------
	
		
	public inline function updateBackgroundStyle() if (background != null) background.updateVisibleStyle();
	
	override inline function updateVisibleStyle():Void
	{
		updateBackgroundStyle();
	}
	
	override inline function updateVisibleLayout():Void
	{
		if (background != null) {
			background.x = x; background.y = y;
			background.maskX = maskX; background.maskY = maskY; background.maskWidth = maskWidth; background.maskHeight = maskHeight;
			background.updateVisibleLayout();
		}
		
		var deltaX = x - last_x;
		var deltaY = y - last_y;
		var deltaXOffset = xOffset - last_xOffset;
		var deltaYOffset = yOffset - last_yOffset;
		
		last_x = x;
		last_y = y;
		last_xOffset = xOffset;
		last_yOffset = yOffset;
		
		for (uiElement in uiElements) {
			uiElement.x += deltaX; 
			uiElement.y += deltaY;
			uiElement.x += deltaXOffset; 
			uiElement.y += deltaYOffset;
			
			if (uiElement.masked) {
				uiElement.maskByElement(this);
			}
			
			uiElement.updateLayout();
		}
		

	}

	override inline function updateVisible():Void
	{
		if (background != null) background.updateVisible();
	}
	
	// -----------------
	
	override inline function onAddVisibleToDisplay()
	{
		if (background != null) uiDisplay.add(background);
		for (uiElement in uiElements) uiDisplay.add(uiElement);
	}
	
	override inline function onRemoveVisibleFromDisplay()
	{	
		if (background != null) uiDisplay.remove(background);
		for (uiElement in uiElements) uiDisplay.remove(uiElement);
	}


	// ---------------------------------------
	
/*	function maskElement(uiElement:Interactive, _x:Int, _right:Int, _y:Int, _bottom:Int) 
	{
		if (uiElement.x < _x) {
			if (uiElement.right < _x) uiElement.hide();
			else {
				uiElement.maskX = _x - uiElement.x;
				if (uiElement.right >= _right) uiElement.maskWidth = width;
				else uiElement.maskWidth = uiElement.width + uiElement.maskX;
				_maskElementY(uiElement, _y, _bottom);
			}
		} 
		else if (uiElement.right >= _right) {
			if (uiElement.x >= _right) uiElement.hide();
			else {
				uiElement.maskX = 0;
				uiElement.maskWidth = uiElement.width - (uiElement.right - _right);
				_maskElementY(uiElement, _y, _bottom);
			}
		}
		else {
			uiElement.maskX = 0;
			uiElement.maskWidth = uiElement.width;
			_maskElementY(uiElement, _y, _bottom);
		}
	}
	
	inline function _maskElementY(uiElement:Interactive, _y:Int, _bottom:Int) 
	{
		if (uiElement.y < _y) {
			if (uiElement.bottom < _y) uiElement.hide();
			else {
				uiElement.maskY = _y - uiElement.y;
				if (uiElement.bottom >= _bottom) uiElement.maskHeight = height;
				else uiElement.maskHeight = uiElement.height + uiElement.maskY;
				uiElement.show();
			}
		} 
		else if (uiElement.bottom >= _bottom) {
			if (uiElement.y >= _bottom) uiElement.hide();
			else {
				uiElement.maskY = 0;
				uiElement.maskHeight = uiElement.height - (uiElement.bottom - _bottom);
				uiElement.show();
			}
		}
		else {
			uiElement.maskY = 0;
			uiElement.maskHeight = uiElement.height;
			uiElement.show();
		}
	}*/
	
	
	// ------- UIArea Events ----------------
	
	
	// ---------- Events --------------------
	
	public var onPointerOver(never, set):UIAreaEventParams;
	inline function set_onPointerOver(f:UIAreaEventParams):UIAreaEventParams return setOnPointerOver(this, f);
	
	public var onPointerOut(never, set):UIAreaEventParams;
	inline function set_onPointerOut(f:UIAreaEventParams):UIAreaEventParams return setOnPointerOut(this, f);
	
	public var onPointerMove(never, set):UIAreaEventParams;
	inline function set_onPointerMove(f:UIAreaEventParams):UIAreaEventParams return setOnPointerMove(this, f);
	
	public var onPointerDown(never, set):UIAreaEventParams;
	inline function set_onPointerDown(f:UIAreaEventParams):UIAreaEventParams return setOnPointerDown(this, f);
	
	public var onPointerUp(never, set):UIAreaEventParams;
	inline function set_onPointerUp(f:UIAreaEventParams):UIAreaEventParams return setOnPointerUp(this, f);
	
	public var onPointerClick(never, set):UIAreaEventParams;
	inline function set_onPointerClick(f:UIAreaEventParams):UIAreaEventParams return setOnPointerClick(this, f);
	
	public var onMouseWheel(default, set):UIAreaWheelEventParams;
	inline function set_onMouseWheel(f:UIAreaWheelEventParams):UIAreaWheelEventParams  return setOnMouseWheel(this, f);
	
	public var onDrag(never, set):UIAreaDragEventParams;
	inline function set_onDrag(f:UIAreaDragEventParams):UIAreaDragEventParams return setOnDrag(this, f);
	
	public var onFocus(never, set):UIAreaFocusEventParams;
	inline function set_onFocus(f:UIAreaFocusEventParams):UIAreaFocusEventParams return setOnFocus(this, f);
	
}