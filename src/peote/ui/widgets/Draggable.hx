package peote.ui.widgets;

import peote.ui.skin.Skin;
import peote.ui.skin.Style;
import peote.ui.widgets.UIElement;

class Draggable extends UIElement
{
	public var onMouseOver(default, set):UIDisplay->Draggable->Int->Int->Void;
	inline function set_onMouseOver(f:UIDisplay->Draggable->Int->Int->Void):UIDisplay->Draggable->Int->Int->Void {
		rebindMouseOver( f.bind(uiDisplay, this), f == null);
		return onMouseOver = f;
	}
	
	public var onMouseOut(default, set):UIDisplay->Draggable->Int->Int->Void;
	inline function set_onMouseOut(f:UIDisplay->Draggable->Int->Int->Void):UIDisplay->Draggable->Int->Int->Void {
		rebindMouseOut( f.bind(uiDisplay, this), f == null);
		return onMouseOut = f;
	}
	
	public var onMouseUp(default, set):UIDisplay->Draggable->Int->Int->Void;
	inline function set_onMouseUp(f:UIDisplay->Draggable->Int->Int->Void):UIDisplay->Draggable->Int->Int->Void {
		rebindMouseUp( f.bind(uiDisplay, this), f == null);
		return onMouseUp = f;
	}
	
	public var onMouseDown(default, set):UIDisplay->Draggable->Int->Int->Void;
	inline function set_onMouseDown(f:UIDisplay->Draggable->Int->Int->Void):UIDisplay->Draggable->Int->Int->Void {
		rebindMouseDown( f.bind(uiDisplay, this), f == null);
		return onMouseDown = f;
	}
	
	public var onMouseClick(default, set):UIDisplay->Draggable->Int->Int->Void;
	inline function set_onMouseClick(f:UIDisplay->Draggable->Int->Int->Void):UIDisplay->Draggable->Int->Int->Void {
		rebindMouseClick( f.bind(uiDisplay, this), f == null);
		return onMouseClick = f;
	}
	
	
	
	public function new(dragAreaX:Int=0, dragAreaY:Int=0, dragAreaWidth:Int=100, dragAreaHeight:Int=100,  minWidth:Int=10, minHeight:Int=10, zIndex:Int=0, skin:Skin = null, style:Style = null) 
	{
		super(dragAreaX, dragAreaY, minWidth, minHeight, zIndex, skin, style);
		
		// here defining for what events a Draggable needs over/click pickables
		
		// what graphics (skin) a Draggable needs is defined here
		
	}
	
	
	public function test() {
		mouseClick(10, 20);
	}
	
}