package peote.ui;

import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.ui.MouseWheelMode;
import lime.ui.Touch;

import peote.view.PeoteGL;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;

import peote.ui.widgets.UIElement;
import peote.ui.widgets.UIElement.Pickable;


@:allow(peote.ui.widgets.UIElement)
class UIDisplay extends Display 
{
	var uiElements:Array<UIElement>;
	
	var movePickBuffer:Buffer<Pickable>;
	var movePickProgram:Program;
	
	var clickPickBuffer:Buffer<Pickable>;
	var clickPickProgram:Program;
	
	var lastOverIndex:Int = -1;
	var lastDownIndex:Int = -1;
	
	//var skins:Array<Skin>; // TODO: no references
	
	var draggingElements:Array<UIElement>;

	public function new(x:Int, y:Int, width:Int, height:Int, color:Color=0x00000000) 
	{
		super(x, y, width, height, color);
		
		// elements for mouseOver/Out ----------------------
		movePickBuffer = new Buffer<Pickable>(16, 8); // TODO: fill with constants
		movePickProgram = new Program(movePickBuffer);
				
		// elements for mouseDown/Up ----------------------
		clickPickBuffer = new Buffer<Pickable>(16,8); // TODO: fill with constants
		clickPickProgram = new Program(clickPickBuffer);
	
		uiElements = new Array<UIElement>();
		draggingElements = new Array<UIElement>();
		//skins = new Array<Skin>();
	}
	
	override private function setNewGLContext(newGl:PeoteGL)
	{
		super.setNewGLContext(newGl);
		movePickProgram.setNewGLContext(newGl);
		clickPickProgram.setNewGLContext(newGl);
	}
	
	public function add(uiElement:UIElement):Void {
		//TODO
		uiElements.push(uiElement);
		uiElement.onAddToDisplay(this);
	}
	
	public function remove(uiElement:UIElement):Void {
		//TODO
		uiElements.remove(uiElement);
		uiElement.onRemoveFromDisplay(this);
	}
	
	public function removeAll():Void {
		for (uiElement in uiElements)
			remove(uiElement);
		//TODO
	}
	
	public function update(uiElement:UIElement):Void {
		uiElement.update();
		//TODO
	}
	
	public function updateAll():Void {
		for (uiElement in uiElements)
			uiElement.update();
		//TODO
	}
	
	// ----------------------------------------
	public function startDragging(uiElement:UIElement):Void {
		if (! uiElement.isDragging) {
			uiElement.isDragging = true;
			draggingElements.push(uiElement);
		} //TODO: #if peoteui_debug -> else WARNING: already in dragmode
	}

	public function stopDragging(uiElement:UIElement):Void {
		if (uiElement.isDragging) {
			uiElement.isDragging = false;
			draggingElements.remove(uiElement);
		} //TODO: #if peoteui_debug -> else WARNING: is not into dragmode
	}

	
	
	// ----------------------------------------
	public function onMouseMove (x:Float, y:Float):Void
	{
		if (peoteView != null)
		try {
			var pickedIndex = peoteView.getElementAt(x, y, this, movePickProgram);
			
			// onMouseOver/onMouseOut
			if (pickedIndex != lastOverIndex) {
				// TODO: bubbling only for container-elements
				// so no over and out to the parent-elements if bubbling is enabled into a child!
				if (lastOverIndex >= 0) 
					movePickBuffer.getElement(lastOverIndex).uiElement.mouseOut( Std.int(x), Std.int(y) );
				if (pickedIndex >= 0) 
					movePickBuffer.getElement(pickedIndex).uiElement.mouseOver(  Std.int(x), Std.int(y) );
				lastOverIndex = pickedIndex;
			}
			
			// onMouseMove
			if (pickedIndex >= 0) 
				movePickBuffer.getElement(pickedIndex).uiElement.mouseMove( Std.int(x), Std.int(y) );
			
			// Dragging
			for (uiElement in draggingElements) {
				uiElement.dragTo(Std.int(x), Std.int(y));
				update(uiElement);
			}
		}
		catch (e:Dynamic) trace("ERROR:", e);
		
	}

	var lockMouseDown = false;
	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		try {
			if (!lockMouseDown && peoteView != null) 
			{
				lastDownIndex = peoteView.getElementAt( x, y, this, clickPickProgram ) ;
				if (lastDownIndex >= 0) {
					clickPickBuffer.getElement(lastDownIndex).uiElement.mouseDown( Std.int(x), Std.int(y) );
					lockMouseDown = true;
				}
			}
			//var pickedElements = peoteView.getAllElementsAt(x, y, display, clickProgram);
			//trace(pickedElements);
			
		}
		catch (e:Dynamic) trace("ERROR:", e);
		
	}
	
	public function onMouseUp (x:Float, y:Float, button:MouseButton):Void
	{
		try {
			if (lastDownIndex >= 0 && peoteView != null) {
				var pickedIndex = peoteView.getElementAt(x, y, this, clickPickProgram);
				clickPickBuffer.getElement(lastDownIndex).uiElement.mouseUp( Std.int(x), Std.int(y) );
				if (pickedIndex == lastDownIndex) {
					clickPickBuffer.getElement(pickedIndex).uiElement.mouseClick( Std.int(x), Std.int(y) );
				}
				lastDownIndex = -1;
				lockMouseDown = false;
			}			
			//var pickedElements = peoteView.getAllElementsAt(x, y, display, clickProgram);
			//trace(pickedElements);
			
		}
		catch (e:Dynamic) trace("ERROR:", e);
		
	}

	// TODO ------------
	public function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:MouseWheelMode):Void {
		if (lastOverIndex >= 0) {
			movePickBuffer.getElement(lastOverIndex).uiElement.mouseWheel( deltaX, deltaY, deltaMode );
		}
	}
	
	public function onTouchStart (touch:Touch):Void {
		trace("onTouchStart", touch.id, Math.round(touch.x * peoteView.width), Math.round(touch.y * peoteView.height) );
	}
	public function onTouchMove (touch:Touch):Void {
		trace("onTouchMove", touch.id, Math.round(touch.x * peoteView.width), Math.round(touch.y * peoteView.height) );
	}
	public function onTouchEnd (touch:Touch):Void {
		trace("onTouchEnd", touch.id, Math.round(touch.x * peoteView.width), Math.round(touch.y * peoteView.height) );
	}
	public function onTouchCancel(touch:Touch):Void {
		trace("onTouchCancel", touch.id, Math.round(touch.x * peoteView.width), Math.round(touch.y * peoteView.height) );
	}

	public function onWindowLeave ():Void {
		//trace("onWindowLeave");
		if (lastOverIndex >= 0) {
			movePickBuffer.getElement(lastOverIndex).uiElement.mouseOut( -1, -1) ;
			lastOverIndex = -1;
		}
		if (lastDownIndex >= 0) { 
			clickPickBuffer.getElement(lastDownIndex).uiElement.mouseUp( -1, -1 );
			lastDownIndex = -1;
			lockMouseDown = false;
		}
	}
	
	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			//case KeyCode.NUMPAD_PLUS:
			default:
		}
	}
	
	public function onKeyUp (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			//case KeyCode.NUMPAD_PLUS:
			default:
		}
	}
	public function onTextInput (text:String):Void {
		
	}
	
}


