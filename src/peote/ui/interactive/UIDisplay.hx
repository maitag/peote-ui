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

	public function new(xPosition:Int = 0, yPosition:Int = 0, width:Int = 100, height:Int = 100, color:Color = 0, addAtDisplay:Display = null, addBefore:Bool = false) 
	{
		super(xPosition, yPosition, width, height, 0);

		this.addAtDisplay = addAtDisplay;
		this.addBefore = addBefore;
		display = new Display(xPosition, yPosition, width, height, color);
	}
	
	
	override inline function updateVisibleLayout():Void
	{
		// TODO: masking
		#if (peoteui_no_masking)
		display.x = Std.int(uiDisplay.globalX(x));
		display.y = Std.int(uiDisplay.globalY(y));
		display.width = width;
		display.height = height;
		#else
		if (masked) { // if some of the edges is cut by mask for scroll-area
			display.x = Std.int(uiDisplay.globalX(x)) + maskX;
			display.y = Std.int(uiDisplay.globalY(y)) + maskY;
			display.width = maskWidth;
			display.height = maskHeight;
			display.xOffset = xOffset - maskX;
			display.yOffset = yOffset - maskY;
		} else {
			display.x = Std.int(uiDisplay.globalX(x));
			display.y = Std.int(uiDisplay.globalY(y));
			display.width = width;
			display.height = height;
		}
		#end
		
		display.xZoom = uiDisplay.xZoom;
		display.yZoom = uiDisplay.yZoom;
	}

	override inline function updateVisible():Void
	{
		updateVisibleLayout();
	}
	
	// -----------------
	@:access(peote.view.Display)
	override inline function onAddVisibleToDisplay()
	{
		trace("UIDisplay onAddVisibleToDisplay");
		if (uiDisplay.peoteView != null) uiDisplay.peoteView.addDisplay(display, addAtDisplay, addBefore);
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
	
}