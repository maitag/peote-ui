package peote.ui.interactive;

import peote.ui.interactive.Interactive;
import peote.view.Display;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;

private typedef UIDisplayEventParams = UIDisplay->PointerEvent->Void;
private typedef UIDisplayWheelEventParams = UIDisplay->WheelEvent->Void;
private typedef UIDisplayDragEventParams = UIDisplay->Float->Float->Void;
private typedef UIDisplayFocusEventParams = UIDisplay->Void;

@:allow(peote.ui)
class UIDisplay extends Interactive
{	
	public var display:Display = null; // TODO: use a setter to change the display at runtime
	
	public function new(xPosition:Int=0, yPosition:Int=0, width:Int=100, height:Int=100, zIndex:Int=0, color = 0x00000000) 
	{
		super(xPosition, yPosition, width, height, zIndex);
		
		display = new Display(xPosition, yPosition, width, height, color);
	}
	
	
	override inline function updateVisible():Void
	{
		// TODO: masking
		display.x = x;
		display.y = y;
		display.width = width;
		display.height = height;
	}
	
	// -----------------
	
	override inline function onAddVisibleToDisplay()
	{
		uiDisplay._peoteView.addDisplay(display, uiDisplay);
	}
	
	override inline function onRemoveVisibleFromDisplay()
	{		
		uiDisplay._peoteView.removeDisplay(display);
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
	
	public var onDrag(never, set):UIElementDragEventParams;
	inline function set_onDrag(f:UIElementDragEventParams):UIElementDragEventParams return setOnDrag(this, f);
	
	public var onFocus(never, set):UIElementFocusEventParams;
	inline function set_onFocus(f:UIElementFocusEventParams):UIElementFocusEventParams return setOnFocus(this, f);
	
}