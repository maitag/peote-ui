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
	public var mouseEnabled = true;
	public var touchEnabled = true;
	
	public function onMouseMove (x:Float, y:Float):Void {
		if (mouseEnabled) onPointerMove(Std.int(x), Std.int(y));
	}
	
	public function onTouchMove (touch:Touch):Void {
		if (touchEnabled) onPointerMove(Math.round(touch.x * peoteView.width), Math.round(touch.y * peoteView.height));
	}

	public inline function onPointerMove (x:Int, y:Int):Void
	{
		if (peoteView != null)
		{
			var pickedIndex = peoteView.getElementAt(x, y, this, movePickProgram);
			
			// Over/Out
			if (pickedIndex != lastOverIndex) {
				// TODO: bubbling only for container-elements
				// so no over and out to the parent-elements if bubbling is enabled into a child!
				if (lastOverIndex >= 0) 
					movePickBuffer.getElement(lastOverIndex).uiElement.mouseOut(x, y);
				if (pickedIndex >= 0) 
					movePickBuffer.getElement(pickedIndex).uiElement.mouseOver(x, y);
				lastOverIndex = pickedIndex;
			}
			
			// Move
			if (pickedIndex >= 0) 
				movePickBuffer.getElement(pickedIndex).uiElement.mouseMove(x, y);
			
			// Dragging
			for (uiElement in draggingElements) {
				uiElement.dragTo(Std.int(x), Std.int(y));
				update(uiElement);
			}
		}
	}
	
	var lockDown = false;
	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		if (mouseEnabled && !lockDown && peoteView != null) 
		{
			lastDownIndex = peoteView.getElementAt( x, y, this, clickPickProgram ) ;
			if (lastDownIndex >= 0) {
				clickPickBuffer.getElement(lastDownIndex).uiElement.mouseDown( Std.int(x), Std.int(y) );
				lockDown = true;
			}
		}
		//var pickedElements = peoteView.getAllElementsAt(x, y, display, clickProgram);
		//trace(pickedElements);
	}
	
	public function onTouchStart (touch:Touch):Void {
		if (touchEnabled && !lockDown && peoteView != null) 
		{
			var x:Int = (Math.round(touch.x * peoteView.width));
			var y:Int = Std.int(Math.round(touch.y * peoteView.height));
			//trace("onTouchStart", touch.id, x, y);
			
			// Over/Out
			var pickedIndex = peoteView.getElementAt(x, y, this, movePickProgram);
			if (pickedIndex >= 0) {
				movePickBuffer.getElement(pickedIndex).uiElement.mouseOver(x, y);
				lastOverIndex = pickedIndex;
			}
			lastDownIndex = peoteView.getElementAt( x, y, this, clickPickProgram ) ;
			if (lastDownIndex >= 0) {
				clickPickBuffer.getElement(lastDownIndex).uiElement.mouseDown( x, y);
				lockDown = true;
			}
		}
	}
	
	public function onMouseUp (x:Float, y:Float, button:MouseButton):Void
	{
		if (mouseEnabled && lastDownIndex >= 0 && peoteView != null) {
			// Up
			var pickedIndex = peoteView.getElementAt(x, y, this, clickPickProgram);
			clickPickBuffer.getElement(lastDownIndex).uiElement.mouseUp( Std.int(x), Std.int(y) );
			if (pickedIndex == lastDownIndex) {
				clickPickBuffer.getElement(pickedIndex).uiElement.mouseClick( Std.int(x), Std.int(y) );
			}
			lastDownIndex = -1;
			lockDown = false;
		}			
		//var pickedElements = peoteView.getAllElementsAt(x, y, display, clickProgram);
		//trace(pickedElements);
	}
	
	public function onTouchEnd (touch:Touch):Void {
		if (touchEnabled && peoteView != null) {
			var x:Int = (Math.round(touch.x * peoteView.width));
			var y:Int = Std.int(Math.round(touch.y * peoteView.height));
			
			var pickedIndex:Int;
			// Up
			if (lastDownIndex >= 0) {
				pickedIndex = peoteView.getElementAt(touch.x * peoteView.width, touch.y * peoteView.height, this, clickPickProgram);
				clickPickBuffer.getElement(lastDownIndex).uiElement.mouseUp(x, y);
				if (pickedIndex == lastDownIndex) {
					clickPickBuffer.getElement(pickedIndex).uiElement.mouseClick(x, y);
				}
				lastDownIndex = -1;
				lockDown = false;
			}
			
			// Over/Out
			pickedIndex = peoteView.getElementAt(x, y, this, movePickProgram);
			if (lastOverIndex >= 0 && pickedIndex == lastOverIndex) {
				movePickBuffer.getElement(pickedIndex).uiElement.mouseOut(x, y);
				lastOverIndex = 0;
			}
			
		}			
	}

	public function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:MouseWheelMode):Void {
		if (mouseEnabled && lastOverIndex >= 0 && peoteView != null) {
			movePickBuffer.getElement(lastOverIndex).uiElement.mouseWheel( deltaX, deltaY, deltaMode );
		}
	}
	
	public function onTouchCancel(touch:Touch):Void {
		// TODO
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
			lockDown = false;
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


