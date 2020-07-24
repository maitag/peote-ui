package peote.ui.widgets;

import peote.ui.skin.Skin;
import peote.ui.skin.Style;
import peote.ui.widgets.UIElement;

class DraggButton extends UIElement
{
	public var onMouseOver(default, set):DraggButton->Int->Int->Void;
	inline function set_onMouseOver(f:DraggButton->Int->Int->Void):DraggButton->Int->Int->Void {
		rebindMouseOver( f.bind(this), f == null);
		return onMouseOver = f;
	}
	
	public var onMouseOut(default, set):DraggButton->Int->Int->Void;
	inline function set_onMouseOut(f:DraggButton->Int->Int->Void):DraggButton->Int->Int->Void {
		rebindMouseOut( f.bind(this), f == null);
		return onMouseOut = f;
	}
	
	public var onMouseClick(default, set):DraggButton->Int->Int->Void;
	inline function set_onMouseClick(f:DraggButton->Int->Int->Void):DraggButton->Int->Int->Void {
		rebindMouseClick( f.bind(this), f == null);
		return onMouseClick = f;
	}

	
	// dragging
	public var onMouseDown:DraggButton->Int->Int->Void;
	function _onMouseDown(x:Int, y:Int) {
		uiDisplay.startDragging(this);
		if (onMouseDown != null) onMouseDown(this, x, y);
	}
	
	public var onMouseUp:DraggButton->Int->Int->Void;
	function _onMouseUp(x:Int, y:Int) {
		uiDisplay.stopDragging(this);
		if (onMouseUp != null) onMouseUp(this, x, y);
	}
	
	
	
	
	public function new(dragAreaX:Int=0, dragAreaY:Int=0, dragAreaWidth:Int=100, dragAreaHeight:Int=100,  minWidth:Int=10, minHeight:Int=10, zIndex:Int=0, skin:Skin = null, style:Style = null) 
	{
		super(dragAreaX, dragAreaY, minWidth, minHeight, zIndex, skin, style);
		
		rebindMouseUp  ( _onMouseUp, false);
		rebindMouseDown( _onMouseDown, false);
		
		// here defining for what events a Draggable needs over/click pickables
		
		// what graphics (skin) a Draggable needs is defined here
		
	}
	
	
	
}