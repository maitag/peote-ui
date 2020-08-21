package peote.ui.widgets;

import lime.ui.MouseWheelMode;

import peote.ui.skin.Skin;
import peote.ui.skin.Style;
import peote.ui.widgets.UIElement;

class Button extends UIElement
{
	public var onPointerOver(default, set):Button->Int->Int->Void;
	inline function set_onPointerOver(f:Button->Int->Int->Void):Button->Int->Int->Void {
		rebindPointerOver( f.bind(this), f == null);
		return onPointerOver = f;
	}
	
	public var onPointerOut(default, set):Button->Int->Int->Void;
	inline function set_onPointerOut(f:Button->Int->Int->Void):Button->Int->Int->Void {
		rebindPointerOut( f.bind(this), f == null);
		return onPointerOut = f;
	}
	
	public var onPointerMove(default, set):Button->Int->Int->Void;
	inline function set_onPointerMove(f:Button->Int->Int->Void):Button->Int->Int->Void {
		rebindPointerMove( f.bind(this), f == null);
		return onPointerMove = f;
	}
	
	public var onPointerDown(default, set):Button->Int->Int->Void;
	inline function set_onPointerDown(f:Button->Int->Int->Void):Button->Int->Int->Void {
		rebindPointerDown( f.bind(this), f == null);
		return onPointerDown = f;
	}
	
	public var onPointerUp(default, set):Button->Int->Int->Void;
	inline function set_onPointerUp(f:Button->Int->Int->Void):Button->Int->Int->Void {
		rebindPointerUp( f.bind(this), f == null);
		return onPointerUp = f;
	}
	
	public var onPointerClick(default, set):Button->Int->Int->Void;
	inline function set_onPointerClick(f:Button->Int->Int->Void):Button->Int->Int->Void {
		rebindPointerClick( f.bind(this), f == null);
		return onPointerClick = f;
	}
	
	public var onMouseWheel(default, set):Button->Float->Float->MouseWheelMode->Void;
	inline function set_onMouseWheel(f:Button->Float->Float->MouseWheelMode->Void):Button->Float->Float->MouseWheelMode->Void {
		rebindMouseWheel( f.bind(this), f == null);
		return onMouseWheel = f;
	}
	
	
	
	public function new(xPosition:Int=0, yPosition:Int=0, width:Int=100, height:Int=100, zIndex:Int=0, skin:Skin = null, style:Style = null) 
	{
		super(xPosition, yPosition, width, height, zIndex, skin, style);
		
		// here defining for what events a Button needs over/click pickables
		
		// what graphics (skin) a Button needs is defined here
		
	}
	
	
}