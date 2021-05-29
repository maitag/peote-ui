package peote.ui.interactive;

import peote.ui.skin.interfaces.Skin;
import peote.ui.skin.SimpleStyle;
import peote.ui.interactive.UIElement;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;


private typedef ButtonEventParams = Button->PointerEvent->Void;

class Button extends UIElement
{
	public var onPointerOver(default, set):ButtonEventParams;
	inline function set_onPointerOver(f:ButtonEventParams):ButtonEventParams {
		rebindPointerOver( f.bind(this), f == null);
		return onPointerOver = f;
	}
	
	public var onPointerOut(default, set):ButtonEventParams;
	inline function set_onPointerOut(f:ButtonEventParams):ButtonEventParams {
		rebindPointerOut( f.bind(this), f == null);
		return onPointerOut = f;
	}
	
	public var onPointerMove(default, set):ButtonEventParams;
	inline function set_onPointerMove(f:ButtonEventParams):ButtonEventParams {
		rebindPointerMove( f.bind(this), f == null);
		return onPointerMove = f;
	}
	
	public var onPointerDown(default, set):ButtonEventParams;
	inline function set_onPointerDown(f:ButtonEventParams):ButtonEventParams {
		rebindPointerDown( f.bind(this), f == null);
		return onPointerDown = f;
	}
	
	public var onPointerUp(default, set):ButtonEventParams;
	inline function set_onPointerUp(f:ButtonEventParams):ButtonEventParams {
		rebindPointerUp( f.bind(this), f == null);
		return onPointerUp = f;
	}
	
	public var onPointerClick(default, set):ButtonEventParams;
	inline function set_onPointerClick(f:ButtonEventParams):ButtonEventParams {
		rebindPointerClick( f.bind(this), f == null);
		return onPointerClick = f;
	}

	
	
	public var onMouseWheel(default, set):Button->WheelEvent->Void;
	inline function set_onMouseWheel(f:Button->WheelEvent->Void):Button->WheelEvent->Void {
		rebindMouseWheel( f.bind(this), f == null);
		return onMouseWheel = f;
	}
	
	
	
	public function new(xPosition:Int=0, yPosition:Int=0, width:Int=100, height:Int=100, zIndex:Int=0, skin:Skin = null, style:SimpleStyle = null) 
	{
		super(xPosition, yPosition, width, height, zIndex, skin, style);
		
		// here defining for what events a Button needs over/click pickables
		
		// what graphics (skin) a Button needs is defined here
		
	}
	
	
}