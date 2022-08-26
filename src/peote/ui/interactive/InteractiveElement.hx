package peote.ui.interactive;

import peote.ui.interactive.Interactive;

import peote.ui.style.interfaces.Style;
import peote.ui.style.interfaces.StyleProgram;
import peote.ui.style.interfaces.StyleElement;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;

private typedef IAElementEventParams = InteractiveElement->PointerEvent->Void;
private typedef IAElementWheelEventParams = InteractiveElement->WheelEvent->Void;

@:allow(peote.ui)
@:access(peote.ui.style)
class InteractiveElement extends Interactive
{	
	public var style:Dynamic = null;

	public var styleProgram:StyleProgram = null;
	var styleElement:StyleElement;
	
	
	public function new(xPosition:Int=0, yPosition:Int=0, width:Int=100, height:Int=100, zIndex:Int=0, style:Style=null)
	{
		super(xPosition, yPosition, width, height, zIndex);		
		this.style = style;		
	}
	
	
	override inline function updateVisibleStyle():Void
	{
		if (style != null) styleProgram.updateElementStyle(uiDisplay, this);
	}
	
	override inline function updateVisibleLayout():Void
	{
		if (style != null) styleProgram.updateElementLayout(uiDisplay, this);
	}
	
	override inline function updateVisible():Void
	{
		if (style != null) styleProgram.updateElement(uiDisplay, this);
	}
	
	// -----------------
	override inline function onAddVisibleToDisplay()
	{
		if (style != null) styleProgram.addElement(uiDisplay, this);
	}
	
	override inline function onRemoveVisibleFromDisplay()
	{		
		if (style != null) styleProgram.removeElement(uiDisplay, this);
	}

	
	// ---------- Events --------------------
	
	public var onPointerOver(never, set):IAElementEventParams;
	inline function set_onPointerOver(f:IAElementEventParams):IAElementEventParams return setOnPointerOver(this, f);
	
	public var onPointerOut(never, set):IAElementEventParams;
	inline function set_onPointerOut(f:IAElementEventParams):IAElementEventParams return setOnPointerOut(this, f);
	
	public var onPointerMove(never, set):IAElementEventParams;
	inline function set_onPointerMove(f:IAElementEventParams):IAElementEventParams return setOnPointerMove(this, f);
	
	public var onPointerDown(never, set):IAElementEventParams;
	inline function set_onPointerDown(f:IAElementEventParams):IAElementEventParams return setOnPointerDown(this, f);
	
	public var onPointerUp(never, set):IAElementEventParams;
	inline function set_onPointerUp(f:IAElementEventParams):IAElementEventParams return setOnPointerUp(this, f);
	
	public var onPointerClick(never, set):IAElementEventParams;
	inline function set_onPointerClick(f:IAElementEventParams):IAElementEventParams return setOnPointerClick(this, f);
		
	public var onMouseWheel(default, set):IAElementWheelEventParams;
	inline function set_onMouseWheel(f:IAElementWheelEventParams):IAElementWheelEventParams  return setOnMouseWheel(this, f);
	
	
}