package peote.ui.interactive;

import peote.ui.interactive.Interactive;
import peote.view.Display;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;

private typedef IADisplayEventParams = InteractiveDisplay->PointerEvent->Void;
private typedef IADisplayWheelEventParams = InteractiveDisplay->WheelEvent->Void;

@:allow(peote.ui)
class InteractiveDisplay extends Interactive
{	
	public var display:Display = null; // TODO: use a setter to change the display at runtime
	
	public function new(xPosition:Int=0, yPosition:Int=0, width:Int=100, height:Int=100, zIndex:Int=0, color = 0x00000000) 
	{
		super(xPosition, yPosition, width, height, zIndex);
		
		display = new Display(xPosition, yPosition, width, height, color);
	}
	
	
	override inline function updateVisible():Void
	{
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
	
	public var onPointerOver(never, set):IADisplayEventParams;
	inline function set_onPointerOver(f:IADisplayEventParams):IADisplayEventParams return setOnPointerOver(this, f);
	
	public var onPointerOut(never, set):IADisplayEventParams;
	inline function set_onPointerOut(f:IADisplayEventParams):IADisplayEventParams return setOnPointerOut(this, f);
	
	public var onPointerMove(never, set):IADisplayEventParams;
	inline function set_onPointerMove(f:IADisplayEventParams):IADisplayEventParams return setOnPointerMove(this, f);
	
	public var onPointerDown(never, set):IADisplayEventParams;
	inline function set_onPointerDown(f:IADisplayEventParams):IADisplayEventParams return setOnPointerDown(this, f);
	
	public var onPointerUp(never, set):IADisplayEventParams;
	inline function set_onPointerUp(f:IADisplayEventParams):IADisplayEventParams return setOnPointerUp(this, f);
	
	public var onPointerClick(never, set):IADisplayEventParams;
	inline function set_onPointerClick(f:IADisplayEventParams):IADisplayEventParams return setOnPointerClick(this, f);
		
	public var onMouseWheel(default, set):IADisplayWheelEventParams;
	inline function set_onMouseWheel(f:IADisplayWheelEventParams):IADisplayWheelEventParams  return setOnMouseWheel(this, f);
	
	
}