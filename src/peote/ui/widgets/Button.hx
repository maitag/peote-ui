package peote.ui.widgets;

import peote.ui.skin.Skin;
import peote.ui.skin.Style;
import peote.ui.widgets.UIElement;

class Button extends UIElement
{
	public var onMouseOver(default, set):Button->Int->Int->Void;
	inline function set_onMouseOver(f:Button->Int->Int->Void):Button->Int->Int->Void {
		rebindMouseOver( f.bind(this), f == null);
		return onMouseOver = f;
	}
	
	public var onMouseOut(default, set):Button->Int->Int->Void;
	inline function set_onMouseOut(f:Button->Int->Int->Void):Button->Int->Int->Void {
		rebindMouseOut( f.bind(this), f == null);
		return onMouseOut = f;
	}
	
	public var onMouseDown(default, set):Button->Int->Int->Void;
	inline function set_onMouseDown(f:Button->Int->Int->Void):Button->Int->Int->Void {
		rebindMouseDown( f.bind(this), f == null);
		return onMouseDown = f;
	}
	
	public var onMouseUp(default, set):Button->Int->Int->Void;
	inline function set_onMouseUp(f:Button->Int->Int->Void):Button->Int->Int->Void {
		rebindMouseUp( f.bind(this), f == null);
		return onMouseUp = f;
	}
	
	public var onMouseClick(default, set):Button->Int->Int->Void;
	inline function set_onMouseClick(f:Button->Int->Int->Void):Button->Int->Int->Void {
		rebindMouseClick( f.bind(this), f == null);
		return onMouseClick = f;
	}
	
	
	
	public function new(xPosition:Int=0, yPosition:Int=0, width:Int=100, height:Int=100, zIndex:Int=0, skin:Skin = null, style:Style = null) 
	{
		super(xPosition, yPosition, width, height, zIndex, skin, style);
		
		// here defining for what events a Button needs over/click pickables
		
		// what graphics (skin) a Button needs is defined here
		
	}
	
	
	public function test() {
		mouseClick(10, 20);
	}
	
}