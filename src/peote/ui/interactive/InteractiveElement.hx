package peote.ui.interactive;

import peote.ui.interactive.Interactive;

import peote.ui.skin.interfaces.Skin;
import peote.ui.skin.interfaces.SkinElement;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;

private typedef IAElementEventParams = InteractiveElement->PointerEvent->Void;
private typedef IAElementWheelEventParams = InteractiveElement->WheelEvent->Void;

@:allow(peote.ui)
class InteractiveElement extends Interactive
{	
	public var skin:Skin = null; // TODO: use a setter to change the skin at runtime
		
	public var style(default, set):Dynamic = null;
	inline function set_style(s:Dynamic):Dynamic 
	{
		//trace("set style");
		if (skin == null) {
			if (s != null) throw ("Error, for styling the widget needs a skin");
			style = s;
		} 
		else style = skin.setCompatibleStyle(s); // TODO: in debug mode trace a warning here if a compatible skin is recreated!
		
		return style;
	}		
	
	var skinElement:SkinElement;
	
	public function new(xPosition:Int=0, yPosition:Int=0, width:Int=100, height:Int=100, zIndex:Int=0, skin:Skin=null, style:Dynamic=null)
	{
		super(xPosition, yPosition, width, height, zIndex);
		
		this.skin = skin;
		set_style(style);
	}
	
	
	override inline function updateVisibleStyle():Void
	{
		if (skin != null) skin.updateElementStyle(uiDisplay, this);
	}
	
	override inline function updateVisibleLayout():Void
	{
		if (skin != null) skin.updateElementLayout(uiDisplay, this);
	}
	
	override inline function updateVisible():Void
	{
		if (skin != null) skin.updateElement(uiDisplay, this);
	}
	
	// -----------------
	
	override inline function onAddVisibleToDisplay()
	{
		if (skin != null) skin.addElement(uiDisplay, this);
	}
	
	override inline function onRemoveVisibleFromDisplay()
	{		
		if (skin != null) skin.removeElement(uiDisplay, this);
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