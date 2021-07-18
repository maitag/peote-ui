package peote.ui.interactive;

import peote.ui.skin.interfaces.Skin;
import peote.ui.interactive.UIElement;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;


private typedef ButtonEventParams = Button->PointerEvent->Void;
private typedef ButtonWheelEventParams = Button->WheelEvent->Void;

class Button extends UIElement
{
	public var onPointerOver(never, set):ButtonEventParams;
	inline function set_onPointerOver(f:ButtonEventParams):ButtonEventParams return setOnPointerOver(this, f);
	
	public var onPointerOut(never, set):ButtonEventParams;
	inline function set_onPointerOut(f:ButtonEventParams):ButtonEventParams return setOnPointerOut(this, f);
	
	public var onPointerMove(never, set):ButtonEventParams;
	inline function set_onPointerMove(f:ButtonEventParams):ButtonEventParams return setOnPointerMove(this, f);
	
	public var onPointerDown(never, set):ButtonEventParams;
	inline function set_onPointerDown(f:ButtonEventParams):ButtonEventParams return setOnPointerDown(this, f);
	
	public var onPointerUp(never, set):ButtonEventParams;
	inline function set_onPointerUp(f:ButtonEventParams):ButtonEventParams return setOnPointerUp(this, f);
	
	public var onPointerClick(never, set):ButtonEventParams;
	inline function set_onPointerClick(f:ButtonEventParams):ButtonEventParams return setOnPointerClick(this, f);
		
	public var onMouseWheel(default, set):ButtonWheelEventParams;
	inline function set_onMouseWheel(f:ButtonWheelEventParams):ButtonWheelEventParams  return setOnMouseWheel(this, f);
	
	
	public static inline function noOperation(b:Button, e:PointerEvent):Void {}
	public static inline function noWheelOperation(b:Button, e:WheelEvent):Void {}
	
	public function new(xPosition:Int=0, yPosition:Int=0, width:Int=100, height:Int=100, zIndex:Int=0, skin:Skin = null, style:Dynamic = null) 
	{
		super(xPosition, yPosition, width, height, zIndex, skin, style);		
	}	
	
}