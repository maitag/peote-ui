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
	
	//var skins:Array<Skin>; // TODO: no references
	
	var draggingElements:Array<UIElement>;
	
	var maxTouchpoints:Int;

	public function new(x:Int, y:Int, width:Int, height:Int, color:Color=0x00000000, maxTouchpoints:Int = 3) 
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
		
		this.maxTouchpoints = maxTouchpoints;
		lastTouchOverIndex = new haxe.ds.Vector<Int>(maxTouchpoints);
		for (i in 0...lastTouchOverIndex.length) lastTouchOverIndex.set(i, -1);
		lastTouchDownIndex = new haxe.ds.Vector<Int>(maxTouchpoints);
		for (i in 0...lastTouchDownIndex.length) lastTouchDownIndex.set(i, -1);
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
	

	var lastTouchOverIndex:haxe.ds.Vector<Int>;
	var lastTouchDownIndex:haxe.ds.Vector<Int>;
	var lockTouchDown:Int = 0;
	
	// TODO: if backend allows multiple mice do same like with touch !
	var lastMouseOverIndex:Int = -1;
	var lastMouseDownIndex:Int = -1;
	var lockMouseDown = false;	

	
	
	public inline function onMouseMove (mouseX:Float, mouseY:Float):Void {
		if (mouseEnabled && peoteView != null)
		{
			var x = Std.int(mouseX);
			var y = Std.int(mouseY);
			var pickedIndex = peoteView.getElementAt(x, y, this, movePickProgram);
			
			// Over/Out
			if (pickedIndex != lastMouseOverIndex) {
				// TODO: bubbling only for container-elements
				// so no over and out to the parent-elements if bubbling is enabled into a child!
				if (lastMouseOverIndex >= 0) 
					movePickBuffer.getElement(lastMouseOverIndex).uiElement.pointerOut(x, y);
				if (pickedIndex >= 0) 
					movePickBuffer.getElement(pickedIndex).uiElement.pointerOver(x, y);
				lastMouseOverIndex = pickedIndex;
			}
			
			// Move
			if (pickedIndex >= 0) 
				movePickBuffer.getElement(pickedIndex).uiElement.pointerMove(x, y);
			
			// Dragging
			for (uiElement in draggingElements) {
				uiElement.dragTo(x, y);
				update(uiElement);
			}
		}
	}
	
	public inline function onTouchMove (touch:Touch):Void {
		if (touchEnabled && peoteView != null && touch.id < maxTouchpoints)
		{
			var x:Int = Math.round(touch.x * peoteView.width);
			var y:Int = Math.round(touch.y * peoteView.height);
			
			var pickedIndex = peoteView.getElementAt(x, y, this, movePickProgram);
			var lastOverIndex:Int = lastTouchOverIndex.get(touch.id);
			
			// Over/Out
			if (pickedIndex != lastOverIndex) {
				// TODO: bubbling only for container-elements
				// so no over and out to the parent-elements if bubbling is enabled into a child!
				if (lastOverIndex >= 0) 
					movePickBuffer.getElement(lastOverIndex).uiElement.pointerOut(x, y);
				if (pickedIndex >= 0) 
					movePickBuffer.getElement(pickedIndex).uiElement.pointerOver(x, y);
				lastTouchOverIndex.set(touch.id, pickedIndex);
			}
			
			// Move
			if (pickedIndex >= 0) 
				movePickBuffer.getElement(pickedIndex).uiElement.pointerMove(x, y);
			
			// Dragging
			for (uiElement in draggingElements) {
				uiElement.dragTo(x, y);
				update(uiElement);
			}
		}
	}
	
	public inline function onMouseDown (x:Float, y:Float, button:MouseButton):Void {
		if (mouseEnabled && !lockMouseDown && peoteView != null) 
		{
			lastMouseDownIndex = peoteView.getElementAt(x, y, this, clickPickProgram) ;
			if (lastMouseDownIndex >= 0) {
				clickPickBuffer.getElement(lastMouseDownIndex).uiElement.pointerDown(Std.int(x), Std.int(y));
				lockMouseDown = true;
			}
		}
		//var pickedElements = peoteView.getAllElementsAt(x, y, display, clickProgram);
		//trace(pickedElements);
	}
	
	public inline function onTouchStart (touch:Touch):Void {
		if (touchEnabled && (lockTouchDown & (1 << (touch.id+1))) == 0 && peoteView != null && touch.id < maxTouchpoints) 
		{
			var x:Int = Math.round(touch.x * peoteView.width);
			var y:Int = Math.round(touch.y * peoteView.height);
			
			// Over/Out
			var pickedIndex = peoteView.getElementAt(x, y, this, movePickProgram);

			if (pickedIndex >= 0) {
				movePickBuffer.getElement(pickedIndex).uiElement.pointerOver(x, y);
				lastTouchOverIndex.set(touch.id, pickedIndex);
			}
			var lastDownIndex = peoteView.getElementAt(x, y, this, clickPickProgram ) ;
			if (lastDownIndex >= 0) {
				clickPickBuffer.getElement(lastDownIndex).uiElement.pointerDown(x, y);
				lockTouchDown = lockTouchDown | (1 << (touch.id+1));
				lastTouchDownIndex.set(touch.id, lastDownIndex);
			}
		}
	}
	
	public inline function onMouseUp (x:Float, y:Float, button:MouseButton):Void {
		if (mouseEnabled && lastMouseDownIndex >= 0 && peoteView != null) {
			// Up
			var pickedIndex = peoteView.getElementAt(x, y, this, clickPickProgram);
			clickPickBuffer.getElement(lastMouseDownIndex).uiElement.pointerUp( Std.int(x), Std.int(y) );
			if (pickedIndex == lastMouseDownIndex) {
				clickPickBuffer.getElement(pickedIndex).uiElement.pointerClick( Std.int(x), Std.int(y) );
			}
			lastMouseDownIndex = -1;
			lockMouseDown = false;
		}			
		//var pickedElements = peoteView.getAllElementsAt(x, y, display, clickProgram);
		//trace(pickedElements);
	}
	
	public inline function onTouchEnd (touch:Touch):Void {
		if (touchEnabled && peoteView != null && touch.id < maxTouchpoints) {
			var x:Int = Math.round(touch.x * peoteView.width);
			var y:Int = Math.round(touch.y * peoteView.height);
			
			var pickedIndex:Int;
			var lastDownIndex = lastTouchDownIndex.get(touch.id);
			
			// Up
			if (lastDownIndex >= 0) {
				pickedIndex = peoteView.getElementAt(x, y, this, clickPickProgram);

				clickPickBuffer.getElement(lastDownIndex).uiElement.pointerUp(x, y);
				if (pickedIndex == lastDownIndex) {
					clickPickBuffer.getElement(pickedIndex).uiElement.pointerClick(x, y);
				}
				lastTouchDownIndex.set(touch.id, -1);
				lockTouchDown = lockTouchDown - (1 << (touch.id+1));
				
			}
			
			// Over/Out
			pickedIndex = peoteView.getElementAt(x, y, this, clickPickProgram);
			if (pickedIndex >=0 && pickedIndex == lastTouchOverIndex.get(touch.id)) {
				movePickBuffer.getElement(pickedIndex).uiElement.pointerOut(x, y);
				lastTouchOverIndex.set(touch.id, -1);
			}
			
			
		}			
	}

	public inline function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:MouseWheelMode):Void {
		if (mouseEnabled && lastMouseOverIndex >= 0 && peoteView != null) {
			movePickBuffer.getElement(lastMouseOverIndex).uiElement.mouseWheel( deltaX, deltaY, deltaMode );
		}
	}
	
	public inline function onTouchCancel(touch:Touch):Void {
		// TODO
		trace("onTouchCancel", touch.id, Math.round(touch.x * peoteView.width), Math.round(touch.y * peoteView.height) );
	}

	public inline function onWindowLeave ():Void {
		// mouse
		if (lastMouseOverIndex >= 0) {
			movePickBuffer.getElement(lastMouseOverIndex).uiElement.pointerOut( -1, -1) ;
			lastMouseOverIndex = -1;
		}
		if (lastMouseDownIndex >= 0) { 
			clickPickBuffer.getElement(lastMouseDownIndex).uiElement.pointerUp( -1, -1 );
			lastMouseDownIndex = -1;
			lockMouseDown = false;
		}
		// touch
		var lastIndex:Int;
		for (i in 0...lastTouchOverIndex.length) {
			lastIndex = lastTouchOverIndex.get(i) ;
			if (lastIndex >= 0) {
				movePickBuffer.getElement(lastIndex).uiElement.pointerOut( -1, -1) ;
				lastTouchOverIndex.set(i, -1);
			}
		}
		for (i in 0...lastTouchDownIndex.length) {
			lastIndex = lastTouchDownIndex.get(i);
			if (lastIndex >= 0) {
				clickPickBuffer.getElement(lastIndex).uiElement.pointerOut( -1, -1) ;
				lastTouchDownIndex.set(i, -1);
			}
		}
		lockTouchDown = 0;
	}
	
	public inline function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			//case KeyCode.NUMPAD_PLUS:
			default:
		}
	}
	
	public inline function onKeyUp (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			//case KeyCode.NUMPAD_PLUS:
			default:
		}
	}
	public inline function onTextInput (text:String):Void {
		
	}
	
}


