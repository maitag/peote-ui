package peote.ui.interactive;

import haxe.ds.Vector;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.ui.MouseWheelMode;
import lime.ui.Touch;

import peote.ui.event.PointerEvent;
import peote.ui.event.PointerType;
import peote.view.PeoteView;

import peote.view.PeoteGL;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;

import peote.ui.interactive.InteractiveElement;


@:allow(peote.ui.interactive)
class UIDisplay extends Display
{
	#if peoteui_maxDisplays
		static public var MAX_DISPLAYS:Int = Std.parseInt(haxe.macro.Compiler.getDefine("peoteui_maxDisplays"));
	#else
		static public inline var MAX_DISPLAYS:Int = 16;
	#end
	
	static var AVAILABLE_NUMBER = 0;
	static function getFreeNumber():Int {
		var bit = 1;
		for (i in 0...MAX_DISPLAYS) {
			if (AVAILABLE_NUMBER & bit == 0) {
				AVAILABLE_NUMBER |= bit;
				return i;
			}
			bit = bit << 1;
		}
		throw('Error, reach maximum of $MAX_DISPLAYS UIDisplays');
	}
	public var number(default, null):Int;
	
	var uiElements:Array<InteractiveElement>;
	
	var movePickBuffer:Buffer<Pickable>;
	var movePickProgram:Program;
	
	var clickPickBuffer:Buffer<Pickable>;
	var clickPickProgram:Program;
	
	var draggingMouseElements:Array<InteractiveElement>;
	var draggingTouchElements:Vector<Array<InteractiveElement>>;
	
	var maxTouchpoints:Int;

	public function new(x:Int, y:Int, width:Int, height:Int, color:Color=0x00000000, maxTouchpoints:Int = 3) 
	{
		number = getFreeNumber();  trace('MAX_DISPLAYs: $MAX_DISPLAYS', 'UIDisplay NUMBER is $number');
		
		super(x, y, width, height, color);
		
		// elements for mouseOver/Out ----------------------
		movePickBuffer = new Buffer<Pickable>(16, 8); // TODO: fill with constants
		movePickProgram = new Program(movePickBuffer);
				
		// elements for mouseDown/Up ----------------------
		clickPickBuffer = new Buffer<Pickable>(16,8); // TODO: fill with constants
		clickPickProgram = new Program(clickPickBuffer);
	
		uiElements = new Array<InteractiveElement>();
		//skins = new Array<Skin>();
		
		lastMouseDownIndex = new Vector<Int>(3);
		draggingMouseElements = new Array<InteractiveElement>();
		for (i in 0...lastMouseDownIndex.length) {
			lastMouseDownIndex.set(i, -1);
		}

		this.maxTouchpoints = maxTouchpoints;
		lastTouchOverIndex = new Vector<Int>(maxTouchpoints);
		lastTouchDownIndex = new Vector<Int>(maxTouchpoints);
		draggingTouchElements = new Vector<Array<InteractiveElement>>(maxTouchpoints);
		for (i in 0...maxTouchpoints) {
			lastTouchOverIndex.set(i, -1);
			lastTouchDownIndex.set(i, -1);
			draggingTouchElements.set(i, new Array<InteractiveElement>());
		}
	}
	
	public function clear() {
		AVAILABLE_NUMBER &= ~(1 << number);
		// TODO: clear all programms and buffers
	}
	
	override private function setNewGLContext(newGl:PeoteGL)
	{
		super.setNewGLContext(newGl);
		movePickProgram.setNewGLContext(newGl);
		clickPickProgram.setNewGLContext(newGl);
	}
	
	public function add(uiElement:InteractiveElement):Void {
		//TODO
		uiElements.push(uiElement);
		uiElement.onAddToDisplay(this);
	}
	
	public function remove(uiElement:InteractiveElement):Void {
		//TODO
		uiElements.remove(uiElement);
		uiElement.onRemoveFromDisplay(this);
	}
	
	public function removeAll():Void {
		for (uiElement in uiElements)
			remove(uiElement);
		//TODO
	}
	
	public function update(uiElement:InteractiveElement):Void {
		uiElement.update();
		//TODO
	}
	
	public function updateAll():Void {
		for (uiElement in uiElements)
			uiElement.update();
		//TODO
	}
	
	// ----------------------------------------
	public function startDragging(uiElement:InteractiveElement, e:PointerEvent):Void {
		if (! uiElement.isDragging) {
			uiElement.isDragging = true;
			switch (e.type) {
				case MOUSE: draggingMouseElements.push(uiElement);
				case TOUCH: draggingTouchElements.get(e.touch.id).push(uiElement);
				case PEN: // TODO!
			}
			
		} //TODO: #if peoteui_debug -> else WARNING: already in dragmode
	}

	public function stopDragging(uiElement:InteractiveElement, e:PointerEvent):Void {
		if (uiElement.isDragging) {
			uiElement.isDragging = false;
			switch (e.type) {
				case MOUSE: draggingMouseElements.remove(uiElement);
				case TOUCH: draggingTouchElements.get(e.touch.id).remove(uiElement);
				case PEN: // TODO!
			}
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
	var lastMouseDownIndex:haxe.ds.Vector<Int>;
	var lockMouseDown:Int = 0;	

	
	
	public inline function mouseMove (mouseX:Float, mouseY:Float):Void {
		if (mouseEnabled && peoteView != null)
		{
			var x = Std.int(mouseX);
			var y = Std.int(mouseY);
			
			var pickedIndex = (isPointInside(x, y)) ? peoteView.getElementAt(mouseX, mouseY, this, movePickProgram) : -1;
			
			// Over/Out
			if (pickedIndex != lastMouseOverIndex) {
				// TODO: bubbling only for container-elements
				// so no over and out to the parent-elements if bubbling is enabled into a child!
				if (lastMouseOverIndex >= 0) 
					movePickBuffer.getElement(lastMouseOverIndex).uiElement.pointerOut({x:x, y:y, type:PointerType.MOUSE});
				if (pickedIndex >= 0) 
					movePickBuffer.getElement(pickedIndex).uiElement.pointerOver({x:x, y:y, type:PointerType.MOUSE});
				lastMouseOverIndex = pickedIndex;
			}
			
			// Move
			if (pickedIndex >= 0) 
				movePickBuffer.getElement(pickedIndex).uiElement.pointerMove({x:x, y:y, type:PointerType.MOUSE});
			
			// Dragging
			for (uiElement in draggingMouseElements) {
				uiElement.dragTo(x, y);
				update(uiElement);
			}
		}
	}
	
	public inline function touchMove (touch:Touch):Void {
		if (touchEnabled && peoteView != null && touch.id < maxTouchpoints)
		{
			var x:Int = Math.round(touch.x * peoteView.width);
			var y:Int = Math.round(touch.y * peoteView.height);
			
			var pickedIndex = (isPointInside(x, y)) ? peoteView.getElementAt(x, y, this, movePickProgram) : -1;
			var lastOverIndex:Int = lastTouchOverIndex.get(touch.id);
			
			// Over/Out
			if (pickedIndex != lastOverIndex) {
				// TODO: bubbling only for container-elements
				// so no over and out to the parent-elements if bubbling is enabled into a child!
				if (lastOverIndex >= 0) 
					movePickBuffer.getElement(lastOverIndex).uiElement.pointerOut({x:x, y:y, type:PointerType.TOUCH, touch:touch});
				if (pickedIndex >= 0) 
					movePickBuffer.getElement(pickedIndex).uiElement.pointerOver({x:x, y:y, type:PointerType.TOUCH, touch:touch});
				lastTouchOverIndex.set(touch.id, pickedIndex);
			}
			
			// Move
			if (pickedIndex >= 0) 
				movePickBuffer.getElement(pickedIndex).uiElement.pointerMove({x:x, y:y, type:PointerType.TOUCH, touch:touch});
			
			// Dragging
			for (uiElement in draggingTouchElements.get(touch.id)) {
				uiElement.dragTo(x, y);
				update(uiElement);
			}
		}
	}
	
	public inline function mouseDown (mouseX:Float, mouseY:Float, button:MouseButton):Void {
		if (mouseEnabled && (lockMouseDown & (1 << (button+1))) == 0 && peoteView != null) 
		{
			var x = Std.int(mouseX);
			var y = Std.int(mouseY);
			
			if (isPointInside(x, y))
			{			
				var mouseDownIndex = peoteView.getElementAt(mouseX, mouseY, this, clickPickProgram) ;
				if (mouseDownIndex >= 0) {
					clickPickBuffer.getElement(mouseDownIndex).uiElement.pointerDown({x:x, y:y, type:PointerType.MOUSE, mouseButton:button});
					lockMouseDown = lockMouseDown | (1 << (button+1));
					lastMouseDownIndex.set(button, mouseDownIndex);
				}
			}
		}
		//var pickedElements = peoteView.getAllElementsAt(x, y, display, clickProgram);
		//trace(pickedElements);
	}
	
	public inline function touchStart (touch:Touch):Void {
		if (touchEnabled && (lockTouchDown & (1 << (touch.id+1))) == 0 && peoteView != null && touch.id < maxTouchpoints) 
		{
			var x:Int = Math.round(touch.x * peoteView.width);
			var y:Int = Math.round(touch.y * peoteView.height);
			
			if (isPointInside(x, y))
			{			
				// Out
				var pickedIndex = peoteView.getElementAt(x, y, this, movePickProgram);
				if (pickedIndex >= 0) {
					movePickBuffer.getElement(pickedIndex).uiElement.pointerOver({x:x, y:y, type:PointerType.TOUCH, touch:touch});
					lastTouchOverIndex.set(touch.id, pickedIndex);
				}
				// Down
				var touchDownIndex = peoteView.getElementAt(x, y, this, clickPickProgram ) ;
				if (touchDownIndex >= 0) {
					clickPickBuffer.getElement(touchDownIndex).uiElement.pointerDown({x:x, y:y, type:PointerType.TOUCH, touch:touch});
					lockTouchDown = lockTouchDown | (1 << (touch.id+1));
					lastTouchDownIndex.set(touch.id, touchDownIndex);
				}
			}
		}
	}
	
	public inline function mouseUp (mouseX:Float, mouseY:Float, button:MouseButton):Void {
		if (mouseEnabled && peoteView != null) {
			
			var x = Std.int(mouseX);
			var y = Std.int(mouseY);
			
			var mouseDownIndex = lastMouseDownIndex.get(button);
			
			if (mouseDownIndex >= 0) {
				// Up
				var pickedIndex = (isPointInside(x, y)) ? peoteView.getElementAt(mouseX, mouseY, this, clickPickProgram) : -1;
				clickPickBuffer.getElement(mouseDownIndex).uiElement.pointerUp({x:x, y:y, type:PointerType.MOUSE, mouseButton:button});
				
				// Click
				if (pickedIndex == mouseDownIndex) {
					clickPickBuffer.getElement(pickedIndex).uiElement.pointerClick({x:x, y:y, type:PointerType.MOUSE, mouseButton:button});
				}
				lastMouseDownIndex.set(button, -1);
				lockMouseDown = lockMouseDown - (1 << (button+1));
			}
		}			
		//var pickedElements = peoteView.getAllElementsAt(x, y, display, clickProgram);
		//trace(pickedElements);
	}
	
	public inline function touchEnd (touch:Touch):Void {
		if (touchEnabled && peoteView != null && touch.id < maxTouchpoints) {
			
			var x:Int = Math.round(touch.x * peoteView.width);
			var y:Int = Math.round(touch.y * peoteView.height);
			
			var pickedIndex:Int;
			var touchDownIndex = lastTouchDownIndex.get(touch.id);
			
			// Up
			if (touchDownIndex >= 0) {
				pickedIndex = (isPointInside(x, y)) ? peoteView.getElementAt(x, y, this, clickPickProgram) : -1;

				clickPickBuffer.getElement(touchDownIndex).uiElement.pointerUp({x:x, y:y, type:PointerType.TOUCH, touch:touch});
				if (pickedIndex == touchDownIndex) {
					clickPickBuffer.getElement(pickedIndex).uiElement.pointerClick({x:x, y:y, type:PointerType.TOUCH, touch:touch});
				}
				lastTouchDownIndex.set(touch.id, -1);
				lockTouchDown = lockTouchDown - (1 << (touch.id+1));
				
			}
			
			// Out
			pickedIndex = (isPointInside(x, y)) ? peoteView.getElementAt(x, y, this, clickPickProgram) : -1;
			if (pickedIndex >=0 && pickedIndex == lastTouchOverIndex.get(touch.id)) {
				movePickBuffer.getElement(pickedIndex).uiElement.pointerOut({x:x, y:y, type:PointerType.TOUCH, touch:touch});
				lastTouchOverIndex.set(touch.id, -1);
			}
		}			
	}

	public inline function mouseWheel (deltaX:Float, deltaY:Float, deltaMode:MouseWheelMode):Void {
		if (mouseEnabled && lastMouseOverIndex >= 0 && peoteView != null) {
			movePickBuffer.getElement(lastMouseOverIndex).uiElement.mouseWheel({deltaX:deltaX, deltaY:deltaY, deltaMode:deltaMode});
		}
	}
	
	public inline function touchCancel(touch:Touch):Void {
		// TODO
		trace("onTouchCancel", touch.id, Math.round(touch.x * peoteView.width), Math.round(touch.y * peoteView.height));
	}

	public inline function windowLeave():Void {
		// mouse
		if (lastMouseOverIndex >= 0) {
			movePickBuffer.getElement(lastMouseOverIndex).uiElement.pointerOut({x:-1, y:-1, type:PointerType.MOUSE});
			lastMouseOverIndex = -1;
		}
		var lastIndex:Int;
		for (i in 0...lastMouseDownIndex.length) {
			lastIndex = lastMouseDownIndex.get(i) ;
			if (lastIndex >= 0) {
				clickPickBuffer.getElement(lastIndex).uiElement.pointerUp({x:-1, y:-1, type:PointerType.MOUSE, mouseButton:i});
				lastMouseDownIndex.set(i, -1);
			}
		}
		lockMouseDown = 0;

		// touch
		for (i in 0...lastTouchOverIndex.length) {
			lastIndex = lastTouchOverIndex.get(i) ;
			if (lastIndex >= 0) {
				movePickBuffer.getElement(lastIndex).uiElement.pointerOut({x:-1, y:-1, type:PointerType.TOUCH, touch:new Touch(-1, -1, i, 0, 0, 0, 0)});
				lastTouchOverIndex.set(i, -1);
			}
		}
		for (i in 0...lastTouchDownIndex.length) {
			lastIndex = lastTouchDownIndex.get(i);
			if (lastIndex >= 0) {
				clickPickBuffer.getElement(lastIndex).uiElement.pointerUp({x:-1, y:-1, type:PointerType.TOUCH, touch:new Touch(-1, -1, i, 0, 0, 0, 0)});
				lastTouchDownIndex.set(i, -1);
			}
		}
		lockTouchDown = 0;
	}
	
	public inline function keyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			//case KeyCode.NUMPAD_PLUS:
			default:
		}
	}
	
	public inline function keyUp (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			//case KeyCode.NUMPAD_PLUS:
			default:
		}
	}
	public inline function textInput (text:String):Void {
		
	}

	
	// ---------------------------------------- show, hide and interface to peote-layout
	var lastPeoteView:PeoteView = null;
	
	public function show():Void {
		if (peoteView == null && lastPeoteView != null) {
			lastPeoteView.addDisplay(this);
		} 
	}
	
	public function hide():Void{
		if (peoteView != null) {
			lastPeoteView = peoteView;
			peoteView.removeDisplay(this);
		}		
	}
		
}


