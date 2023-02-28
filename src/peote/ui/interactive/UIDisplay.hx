package peote.ui.interactive;

import peote.ui.interactive.Interactive;
import peote.view.Color;
import peote.view.Display;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;

private typedef UIDisplayEventParams = UIDisplay->PointerEvent->Void;
private typedef UIDisplayWheelEventParams = UIDisplay->WheelEvent->Void;
private typedef UIDisplayDragEventParams = UIDisplay->Float->Float->Void;
private typedef UIDisplayFocusEventParams = UIDisplay->Void;
private typedef UIDisplayResizeEventParams = UIDisplay->Int->Int->Void;

@:allow(peote.ui)
class UIDisplay extends Interactive
#if peote_layout
implements peote.layout.ILayoutElement
#end
{	
	public var display:Display = null; // TODO: use a setter to change the display at runtime
	
	var addAtDisplay:Display;
	var addBefore:Bool;
	
	public var xOffset(default, set):Float = 0.0;
	public inline function set_xOffset(offset:Float):Float {
		#if (peoteui_no_masking)
		display.xOffset = offset;
		#else
		display.xOffset = offset - maskX;
		#end
		return xOffset = offset;
	}

	public var yOffset(default, set):Float = 0.0;
	public inline function set_yOffset(offset:Float):Float {
		#if (peoteui_no_masking)
		display.yOffset = offset;
		#else
		display.yOffset = offset - maskY;
		#end
		return yOffset = offset;
	}

	// TODO: zoom, xZoom and yZoom should delegate do .display!
	
	public function new(xPosition:Int = 0, yPosition:Int = 0, width:Int = 100, height:Int = 100, zIndex:Int = 0, color:Color = 0, addAtDisplay:Display = null, addBefore:Bool = false) 
	{
		super(xPosition, yPosition, width, height, zIndex);

		this.addAtDisplay = addAtDisplay;
		this.addBefore = addBefore;
		
		// TODO: also let hook custom Displays and not allways creating a new one here!
		display = new Display(xPosition, yPosition, width, height, color);
	}
	
	override inline function updateVisibleLayout():Void
	{
		#if (peoteui_no_masking)
			display.x = Std.int(x * uiDisplay.xz + uiDisplay.xOffset + uiDisplay.x);
			display.y = Std.int(y * uiDisplay.yz + uiDisplay.yOffset + uiDisplay.y);
			display.width  = Std.int(width  * uiDisplay.xz);
			display.height = Std.int(height * uiDisplay.yz);
		#else
		if (masked) { // if some of the edges is cut by mask for scroll-area
			display.x = Std.int((x + maskX) * uiDisplay.xz + uiDisplay.xOffset + uiDisplay.x);
			display.y = Std.int((y + maskY) * uiDisplay.yz + uiDisplay.yOffset + uiDisplay.y);
			display.width  = Std.int(maskWidth  * uiDisplay.xz);
			display.height = Std.int(maskHeight * uiDisplay.yz);
			display.xOffset = Std.int(xOffset - maskX * uiDisplay.xz);
			display.yOffset = Std.int(yOffset - maskY * uiDisplay.yz);
		} else {
			display.x = Std.int(x * uiDisplay.xz + uiDisplay.xOffset + uiDisplay.x);
			display.y = Std.int(y * uiDisplay.yz + uiDisplay.yOffset + uiDisplay.y);
			display.width  = Std.int(width  * uiDisplay.xz);
			display.height = Std.int(height * uiDisplay.yz);
			display.xOffset = 0;
			display.yOffset = 0;
		}
		#end
		// TODO: only inside updateStyle and also a boolean to en/disable zoomToPeoteUIDisplay!
		display.zoom  = uiDisplay.zoom;
		display.xZoom = uiDisplay.xZoom;
		display.yZoom = uiDisplay.yZoom;
	}

	override inline function updateVisible():Void
	{
		updateVisibleLayout();
	}
	
	// -----------------
	override inline function onAddVisibleToDisplay()
	{
		trace("UIDisplay onAddVisibleToDisplay", uiDisplay.xz);
		if (uiDisplay.peoteView != null) {
			// TODO: updating zoom at the first time ?
			uiDisplay.peoteView.addDisplay(display, addAtDisplay, addBefore);
		}
	}
	
	@:access(peote.view.Display)
	override inline function onRemoveVisibleFromDisplay()
	{
		trace("UIDisplay onRemoveVisibleFromDisplay");
		if (uiDisplay.peoteView != null) uiDisplay.peoteView.removeDisplay(display);
	}

	
	
	
	// ---------- Events --------------------
	
	public var onPointerOver(never, set):UIDisplayEventParams;
	inline function set_onPointerOver(f:UIDisplayEventParams):UIDisplayEventParams return setOnPointerOver(this, f);
	
	public var onPointerOut(never, set):UIDisplayEventParams;
	inline function set_onPointerOut(f:UIDisplayEventParams):UIDisplayEventParams return setOnPointerOut(this, f);
	
	public var onPointerMove(never, set):UIDisplayEventParams;
	inline function set_onPointerMove(f:UIDisplayEventParams):UIDisplayEventParams return setOnPointerMove(this, f);
	
	public var onPointerDown(never, set):UIDisplayEventParams;
	inline function set_onPointerDown(f:UIDisplayEventParams):UIDisplayEventParams return setOnPointerDown(this, f);
	
	public var onPointerUp(never, set):UIDisplayEventParams;
	inline function set_onPointerUp(f:UIDisplayEventParams):UIDisplayEventParams return setOnPointerUp(this, f);
	
	public var onPointerClick(never, set):UIDisplayEventParams;
	inline function set_onPointerClick(f:UIDisplayEventParams):UIDisplayEventParams return setOnPointerClick(this, f);
		
	public var onMouseWheel(default, set):UIDisplayWheelEventParams;
	inline function set_onMouseWheel(f:UIDisplayWheelEventParams):UIDisplayWheelEventParams  return setOnMouseWheel(this, f);
	
	public var onDrag(never, set):UIDisplayDragEventParams;
	inline function set_onDrag(f:UIDisplayDragEventParams):UIDisplayDragEventParams return setOnDrag(this, f);
	
	public var onFocus(never, set):UIDisplayFocusEventParams;
	inline function set_onFocus(f:UIDisplayFocusEventParams):UIDisplayFocusEventParams return setOnFocus(this, f);
	
	public var onResizeWidth(never, set):UIDisplayResizeEventParams;
	inline function set_onResizeWidth(f:UIDisplayResizeEventParams):UIDisplayResizeEventParams return setOnResizeWidth(this, f);
	
	public var onResizeHeight(never, set):UIDisplayResizeEventParams;
	inline function set_onResizeHeight(f:UIDisplayResizeEventParams):UIDisplayResizeEventParams return setOnResizeHeight(this, f);
}