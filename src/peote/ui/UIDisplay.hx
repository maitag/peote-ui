package peote.ui;

import haxe.ds.Vector;

import lime.graphics.RenderContext;
import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.ui.MouseWheelMode;
import lime.ui.Touch;

import peote.ui.event.PointerEvent;
import peote.ui.event.PointerType;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;

import peote.view.utils.RenderListItem;

import peote.ui.interactive.Interactive;


@:access(peote.view)
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
	
	var uiElements:Array<Interactive>;
	
	var movePickBuffer:Buffer<Pickable>;
	var movePickProgram:Program;
	
	var clickPickBuffer:Buffer<Pickable>;
	var clickPickProgram:Program;
	
	var draggingMouseElements:Array<Interactive>;
	var draggingTouchElements:Vector<Array<Interactive>>;
	
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
	
		uiElements = new Array<Interactive>();
		//skins = new Array<Skin>();
		
		lastMouseDownIndex = new Vector<Int>(3);
		draggingMouseElements = new Array<Interactive>();
		for (i in 0...lastMouseDownIndex.length) {
			lastMouseDownIndex.set(i, -1);
		}

		this.maxTouchpoints = maxTouchpoints;
		lastTouchOverIndex = new Vector<Int>(maxTouchpoints);
		lastTouchDownIndex = new Vector<Int>(maxTouchpoints);
		draggingTouchElements = new Vector<Array<Interactive>>(maxTouchpoints);
		for (i in 0...maxTouchpoints) {
			lastTouchOverIndex.set(i, -1);
			lastTouchDownIndex.set(i, -1);
			draggingTouchElements.set(i, new Array<Interactive>());
		}
	}
	
	public function clear() {
		AVAILABLE_NUMBER &= ~(1 << number);
		// TODO: clear all programms and buffers
	}
	
	override public function addToPeoteView(peoteView:PeoteView, ?atDisplay:Display, addBefore:Bool=false)
	{
		super.addToPeoteView(peoteView, atDisplay, addBefore);
		movePickProgram.setNewGLContext(peoteView.gl);
		clickPickProgram.setNewGLContext(peoteView.gl);
		
		#if (peoteui_maxDisplays == "1")
		activeUIDisplay = uiDisplay;
		#else
		//TODO: check order for activeUIDisplay array
		if (atDisplay == null) {
			activeIndex = maxActiveIndex;
		}
		else {
			var displayListItem:RenderListItem<Display>;
			if (addBefore) displayListItem = peoteView.displayList.itemMap.get(atDisplay);
			else displayListItem = peoteView.displayList.itemMap.get(this).next;
			var firstFoundIndex = -1;
			while (displayListItem != null)
			{
				if ( Std.isOfType(displayListItem.value, UIDisplay) ) { //TODO: check for older haxe-version and Std.is() instead
					var d:UIDisplay = cast displayListItem.value;
					if (firstFoundIndex == -1) firstFoundIndex = d.activeIndex;
					d.activeIndex++;
					activeUIDisplay.set(d.activeIndex, d);
				}
				displayListItem = displayListItem.next;
			}
			
			if (firstFoundIndex == -1) activeIndex = maxActiveIndex;
			else activeIndex = firstFoundIndex;			
		}
		
		maxActiveIndex++;
		activeUIDisplay.set(activeIndex, this);
		trace(activeIndex,maxActiveIndex);
		#end
		
	}
	
	override public function removeFromPeoteView(peoteView:PeoteView)
	{
		super.removeFromPeoteView(peoteView);
		#if (peoteui_maxDisplays == "1")
			for (i in activeIndex + 1...maxActiveIndex) {
				activeUIDisplay.set(i-1, activeUIDisplay.get(i));
			}
			maxActiveIndex--;
		#else
		activeUIDisplay = null;
		#end
	}

	// optimized function to check if mouseposition inside UIDisplay
	@:access(peote.view.PeoteView)	
	inline function _isPointInside(px:Int, py:Int) {
		px = Std.int(px / peoteView.xz - peoteView.xOffset);
		py = Std.int(py / peoteView.yz - peoteView.yOffset);
		return (px >= x && px < x + width && py >= y && py < y + height);
	}

	// -------------------------------------------------------
	
	public function add(uiElement:Interactive):Void {
		//TODO
		if (uiElement.isVisible && uiElement.uiDisplay != null) {
			if (uiElement.uiDisplay == this) return; // is already added
			uiElement.uiDisplay.remove(uiElement); // remove from old one
		}

		uiElements.push(uiElement);
		uiElement.onAddToDisplay(this);
	}
	
	public function remove(uiElement:Interactive):Void {
		//TODO
		uiElements.remove(uiElement);
		uiElement.onRemoveFromDisplay(this);
	}
	
	public function removeAll():Void {
		for (uiElement in uiElements)
			remove(uiElement);
		//TODO
	}
	
	public function update(uiElement:Interactive):Void {
		uiElement.update();
		//TODO
	}
	
	public function updateAll():Void {
		for (uiElement in uiElements)
			uiElement.update();
		//TODO
	}
	
	// ----------------------------------------
	public function startDragging(uiElement:Interactive, e:PointerEvent):Void {
		if (! uiElement.isDragging) {
			uiElement.isDragging = true;
			switch (e.type) {
				case MOUSE: draggingMouseElements.push(uiElement);
				case TOUCH: draggingTouchElements.get(e.touch.id).push(uiElement);
				case PEN: // TODO!
			}
			
		} //TODO: #if peoteui_debug -> else WARNING: already in dragmode
	}

	public function stopDragging(uiElement:Interactive, e:PointerEvent):Void {
		if (uiElement.isDragging) {
			uiElement.isDragging = false;
			switch (e.type) {
				case MOUSE: {
					draggingMouseElements.remove(uiElement);
					if (draggingMouseElements.length == 0) mouseMove(e.x, e.y);
				}
				case TOUCH: {
					var draggingTouchElemArray = draggingTouchElements.get(e.touch.id);
					draggingTouchElemArray.remove(uiElement);
					if (draggingTouchElemArray.length == 0) touchMove(e.touch);
				}
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

	
	// ------------ PointerEvents ond the UIDisplay itselfs ----------
	
	public var onPointerOver:UIDisplay->PointerEvent->Void = null;
	public var onPointerOut:UIDisplay->PointerEvent->Void = null;
	public var onPointerDown:UIDisplay->PointerEvent->Void = null;
	public var onPointerUp:UIDisplay->PointerEvent->Void = null;
	public var onPointerClick:UIDisplay->PointerEvent->Void = null;
	
	
	
	public inline function mouseMove (mouseX:Float, mouseY:Float):Void {
		if (mouseEnabled && peoteView != null)
		{
			var x = Std.int(mouseX);
			var y = Std.int(mouseY);
			
			var pickedIndex = (_isPointInside(x, y)) ? peoteView.getElementAt(mouseX, mouseY, this, movePickProgram) : -1;
			
			if (draggingMouseElements.length == 0)	
			{	
				//var pickedIndex = (_isPointInside(x, y)) ? peoteView.getElementAt(mouseX, mouseY, this, movePickProgram) : -1;
				
				// Over/Out
				if (pickedIndex != lastMouseOverIndex) 
				{	
					if (lastMouseOverIndex >= 0) 
					{
						var lastElem = movePickBuffer.getElement(lastMouseOverIndex).uiElement;
						
						if (pickedIndex >= 0)
						{	
							var pickedElem = movePickBuffer.getElement(pickedIndex).uiElement;
							
							if (lastElem.intoOverOutEventBubbleOf(pickedElem))
							{
								//trace("AAAAAAAAAAAAAAAAAAAAAAA");
								while (pickedElem != null && pickedElem != lastElem) {
									pickedElem.pointerOver({x:x, y:y, type:PointerType.MOUSE});
									pickedElem = pickedElem.overOutEventsBubbleTo;
								}
							} 
							else
							{
								//trace("BBBBBBBBBBBBBBBBBBBBBBB");
								while (lastElem != null && lastElem != pickedElem) {
									lastElem.pointerOut({x:x, y:y, type:PointerType.MOUSE});
									lastElem = lastElem.overOutEventsBubbleTo;
								}
								if (lastElem == null)
									while (pickedElem != null) {
										pickedElem.pointerOver({x:x, y:y, type:PointerType.MOUSE});
										pickedElem = pickedElem.overOutEventsBubbleTo;
									}
							}							
						} 
						else
						{
							//trace("CCCCCCCCCCCCCCCCCCCCCCCCCC");
							while (lastElem != null) {
								lastElem.pointerOut({x:x, y:y, type:PointerType.MOUSE});
								lastElem = lastElem.overOutEventsBubbleTo;
							}
						}						
					}
					else
					{
						//trace("DDDDDDDDDDDDDDDDDDDDDDDDDD");
						if (pickedIndex >= 0) {
							var pickedElem = movePickBuffer.getElement(pickedIndex).uiElement;
							while (pickedElem != null) {
								pickedElem.pointerOver({x:x, y:y, type:PointerType.MOUSE});
								pickedElem = pickedElem.overOutEventsBubbleTo;
							}
						}
					}
					
					lastMouseOverIndex = pickedIndex;
				}
				
/*				// Move
				if (pickedIndex >= 0) {
					var pickedElem = movePickBuffer.getElement(pickedIndex).uiElement;
					while (pickedElem != null) {
						pickedElem.pointerMove({x:x, y:y, type:PointerType.MOUSE});
						pickedElem = pickedElem.moveEventsBubbleTo;
					}					
				}
*/			}
			else // Dragging
			{
				for (uiElement in draggingMouseElements) {
					uiElement.dragTo(x, y);
					update(uiElement);
				}
			}
			
			// Move
			if (pickedIndex >= 0) {
				var pickedElem = movePickBuffer.getElement(pickedIndex).uiElement;
				while (pickedElem != null) {
					pickedElem.pointerMove({x:x, y:y, type:PointerType.MOUSE});
					pickedElem = pickedElem.moveEventsBubbleTo;
				}					
			}
				
			
		}
	}
	
	public inline function touchMove (touch:Touch):Void {
		if (touchEnabled && peoteView != null && touch.id < maxTouchpoints)
		{
			var x:Int = Math.round(touch.x * peoteView.width);
			var y:Int = Math.round(touch.y * peoteView.height);
			
			var draggingTouchElemArray = draggingTouchElements.get(touch.id);
			
			var pickedIndex = (_isPointInside(x, y)) ? peoteView.getElementAt(x, y, this, movePickProgram) : -1;
			
			if (draggingTouchElemArray.length == 0)
			{	
				//var pickedIndex = (_isPointInside(x, y)) ? peoteView.getElementAt(x, y, this, movePickProgram) : -1;
				var lastOverIndex:Int = lastTouchOverIndex.get(touch.id);
				
				// touch Over/Out
				if (pickedIndex != lastOverIndex) 
				{					
					if (lastOverIndex >= 0) 
					{
						var lastElem = movePickBuffer.getElement(lastOverIndex).uiElement;
						
						if (pickedIndex >= 0)
						{
							var pickedElem = movePickBuffer.getElement(pickedIndex).uiElement;
							
							if (lastElem.intoOverOutEventBubbleOf(pickedElem))
							{
								//trace("A");
								while (pickedElem != null && pickedElem != lastElem) {
									pickedElem.pointerOver({x:x, y:y, type:PointerType.TOUCH, touch:touch});
									pickedElem = pickedElem.overOutEventsBubbleTo;
								}
							} 
							else
							{
								//trace("B");
								while (lastElem != null && lastElem != pickedElem) {
									lastElem.pointerOut({x:x, y:y, type:PointerType.TOUCH, touch:touch});
									lastElem = lastElem.overOutEventsBubbleTo;
								}
								if (lastElem == null)
									while (pickedElem != null) {
										pickedElem.pointerOver({x:x, y:y, type:PointerType.TOUCH, touch:touch});
										pickedElem = pickedElem.overOutEventsBubbleTo;
									}
							}							
						} 
						else
						{
							//trace("C");
							while (lastElem != null) {
								lastElem.pointerOut({x:x, y:y, type:PointerType.TOUCH, touch:touch});
								lastElem = lastElem.overOutEventsBubbleTo;
							}
						}						
					}
					else 
					{
						//trace("D");
						if (pickedIndex >= 0) {
							var pickedElem = movePickBuffer.getElement(pickedIndex).uiElement;
							while (pickedElem != null) {
								pickedElem.pointerOver({x:x, y:y, type:PointerType.TOUCH, touch:touch});
								pickedElem = pickedElem.overOutEventsBubbleTo;
							}
						}
					}
						
					lastTouchOverIndex.set(touch.id, pickedIndex);
				}
				
/*				// touch Move
				if (pickedIndex >= 0) {
					var pickedElem = movePickBuffer.getElement(pickedIndex).uiElement;
					while (pickedElem != null) {
						pickedElem.pointerMove({x:x, y:y, type:PointerType.TOUCH, touch:touch});
						pickedElem = pickedElem.moveEventsBubbleTo;
					}					
				}
*/			
			}
			else // touch Dragging
			{
				for (uiElement in draggingTouchElemArray) {
					uiElement.dragTo(x, y);
					update(uiElement);
				}
			}
			
			// touch Move
			if (pickedIndex >= 0) {
				var pickedElem = movePickBuffer.getElement(pickedIndex).uiElement;
				while (pickedElem != null) {
					pickedElem.pointerMove({x:x, y:y, type:PointerType.TOUCH, touch:touch});
					pickedElem = pickedElem.moveEventsBubbleTo;
				}					
			}
		}
	}
	
	public inline function mouseDown (mouseX:Float, mouseY:Float, button:MouseButton):Void {
		if (mouseEnabled && (lockMouseDown & (1 << (button+1))) == 0 && peoteView != null) 
		{
			var x = Std.int(mouseX);
			var y = Std.int(mouseY);
			
			if (_isPointInside(x, y))
			{
				var pickedIndex = peoteView.getElementAt(mouseX, mouseY, this, clickPickProgram) ;
				if (pickedIndex >= 0) {
					var pickedElem = clickPickBuffer.getElement(pickedIndex).uiElement;
					while (pickedElem != null) {
						pickedElem.pointerDown({x:x, y:y, type:PointerType.MOUSE, mouseButton:button});
						pickedElem = pickedElem.upDownEventsBubbleTo;
					}					

					lockMouseDown = lockMouseDown | (1 << (button+1));
					lastMouseDownIndex.set(button, pickedIndex);
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
			
			if (_isPointInside(x, y))
			{			
				// Over
				var pickedIndex = peoteView.getElementAt(x, y, this, movePickProgram);
				if (pickedIndex >= 0) {
					var pickedElem = movePickBuffer.getElement(pickedIndex).uiElement;
					while (pickedElem != null) {
						pickedElem.pointerOver({x:x, y:y, type:PointerType.TOUCH, touch:touch});
						pickedElem = pickedElem.overOutEventsBubbleTo;
					}					
					lastTouchOverIndex.set(touch.id, pickedIndex);
				}
				
				// Down
				var touchDownIndex = peoteView.getElementAt(x, y, this, clickPickProgram ) ;
				if (touchDownIndex >= 0) {
					var pickedElem = clickPickBuffer.getElement(touchDownIndex).uiElement;
					while (pickedElem != null) {
						pickedElem.pointerDown({x:x, y:y, type:PointerType.TOUCH, touch:touch});
						pickedElem = pickedElem.upDownEventsBubbleTo;
					}
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
			
			var _lastMouseDownIndex = lastMouseDownIndex.get(button);
			
			// Up
			if (_lastMouseDownIndex >= 0) {
				var lastMouseDownElem = clickPickBuffer.getElement(_lastMouseDownIndex).uiElement;
				var startClick = false;
				var pickedIndex = (_isPointInside(x, y)) ? peoteView.getElementAt(mouseX, mouseY, this, clickPickProgram) : -1;
				var pickedElem:Interactive = null;
				if (pickedIndex >= 0) {
					pickedElem = clickPickBuffer.getElement(pickedIndex).uiElement;
					if (lastMouseDownElem.intoUpDownEventBubbleOf(pickedElem)) startClick = true;
				}
				while (lastMouseDownElem != null) {
					lastMouseDownElem.pointerUp({x:x, y:y, type:PointerType.MOUSE, mouseButton:button});
					// Click
					if (!startClick && pickedElem == lastMouseDownElem) startClick = true;
					if (startClick) lastMouseDownElem.pointerClick({x:x, y:y, type:PointerType.MOUSE, mouseButton:button});					
					lastMouseDownElem = lastMouseDownElem.upDownEventsBubbleTo;
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
			var pickedElem:Interactive = null;
			var _lastTouchDownIndex = lastTouchDownIndex.get(touch.id);
			
			// Up
			if (_lastTouchDownIndex >= 0) {
				var lastTouchDownElem = clickPickBuffer.getElement(_lastTouchDownIndex).uiElement;
				var startClick = false;
				pickedIndex = (_isPointInside(x, y)) ? peoteView.getElementAt(x, y, this, clickPickProgram) : -1;
				if (pickedIndex >=0 ) {
					pickedElem = clickPickBuffer.getElement(pickedIndex).uiElement;
					if (lastTouchDownElem.intoUpDownEventBubbleOf(pickedElem)) startClick = true;
				}
				while (lastTouchDownElem != null) {
					lastTouchDownElem.pointerUp({x:x, y:y, type:PointerType.TOUCH, touch:touch});					
					// Click
					if (!startClick && pickedElem == lastTouchDownElem) startClick = true;
					if (startClick) lastTouchDownElem.pointerClick({x:x, y:y, type:PointerType.TOUCH, touch:touch});					
					lastTouchDownElem = lastTouchDownElem.upDownEventsBubbleTo;
				}				
				lastTouchDownIndex.set(touch.id, -1);
				lockTouchDown = lockTouchDown - (1 << (touch.id+1));				
			}
			
			// Out
			pickedIndex = (_isPointInside(x, y)) ? peoteView.getElementAt(x, y, this, movePickProgram) : -1;
			if (pickedIndex >=0 && pickedIndex == lastTouchOverIndex.get(touch.id)) {
				pickedElem = movePickBuffer.getElement(pickedIndex).uiElement;
				while (pickedElem != null) {
					pickedElem.pointerOut({x:x, y:y, type:PointerType.TOUCH, touch:touch});
					pickedElem = pickedElem.overOutEventsBubbleTo;
				}					
				lastTouchOverIndex.set(touch.id, -1);
			}
		}			
	}

	public inline function mouseWheel (deltaX:Float, deltaY:Float, deltaMode:MouseWheelMode):Void {
		if (mouseEnabled && lastMouseOverIndex >= 0 && peoteView != null) {
			var lastElem = movePickBuffer.getElement(lastMouseOverIndex).uiElement;
			while (lastElem != null) {
				lastElem.mouseWheel({deltaX:deltaX, deltaY:deltaY, deltaMode:deltaMode});
				lastElem = lastElem.wheelEventsBubbleTo;
			}			
		}
	}
	
	public inline function touchCancel(touch:Touch):Void {
		// TODO
		trace("onTouchCancel", touch.id, Math.round(touch.x * peoteView.width), Math.round(touch.y * peoteView.height));
	}

	public inline function windowLeave():Void {
		var lastElem:Interactive;
		// mouse
		if (lastMouseOverIndex >= 0) {
			lastElem = movePickBuffer.getElement(lastMouseOverIndex).uiElement;
			while (lastElem != null) {
				lastElem.pointerOut({x: -1, y: -1, type:PointerType.MOUSE});
				lastElem = lastElem.overOutEventsBubbleTo;
			}
			lastMouseOverIndex = -1;
		}
		var lastIndex:Int;
		for (i in 0...lastMouseDownIndex.length) {
			lastIndex = lastMouseDownIndex.get(i) ;
			if (lastIndex >= 0) {
				lastElem = clickPickBuffer.getElement(lastIndex).uiElement;
				while (lastElem != null) {
					lastElem.pointerUp({x:-1, y:-1, type:PointerType.MOUSE, mouseButton:i});
					lastElem = lastElem.upDownEventsBubbleTo;
				}
				lastMouseDownIndex.set(i, -1);
			}
		}
		lockMouseDown = 0;

		// touch
		for (i in 0...lastTouchOverIndex.length) {
			lastIndex = lastTouchOverIndex.get(i) ;
			if (lastIndex >= 0) {
				lastElem = movePickBuffer.getElement(lastIndex).uiElement;
				while (lastElem != null) {
					lastElem.pointerOut({x:-1, y:-1, type:PointerType.TOUCH, touch:new Touch(-1, -1, i, 0, 0, 0, 0)});
					lastElem = lastElem.overOutEventsBubbleTo;
				}
				lastTouchOverIndex.set(i, -1);
			}
		}
		for (i in 0...lastTouchDownIndex.length) {
			lastIndex = lastTouchDownIndex.get(i);
			if (lastIndex >= 0) {
				lastElem = clickPickBuffer.getElement(lastIndex).uiElement;
				while (lastElem != null) {
					lastElem.pointerUp({x:-1, y:-1, type:PointerType.TOUCH, touch:new Touch(-1, -1, i, 0, 0, 0, 0)});
					lastElem = lastElem.upDownEventsBubbleTo;
				}
				lastTouchDownIndex.set(i, -1);
			}
		}
		lockTouchDown = 0;
	}
	
	public inline function keyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			#if html5
			case KeyCode.TAB: untyped __js__('event.preventDefault();');
			#end
			//case KeyCode.F: window.fullscreen = !window.fullscreen;
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

	// override function onTextEdit(text:String, start:Int, length:Int) {}
	// override function onTextInput (text:String)	{}
	
	
	
	
	
	// -------- register Events from Lime Application ----------
	
/*	public var pointerEnabled(get, set):Bool;
	public inline function set_pointerEnabled(b:Bool):Bool {
		if (b) activate(this) else deactivate(this);
		return b;
	}
*/
	public var bubbleMouseDown:Bool = false;

	#if (peoteui_maxDisplays == "1")
		//public inline function get_pointerEnabled():Bool return (activeUIDisplay == this);
		
		static var activeUIDisplay:UIDisplay;

		static public inline function mouseMoveActive(mouseX:Float, mouseY:Float) if (activeUIDisplay!=null) activeUIDisplay.mouseMove(mouseX, mouseY);	
		static public inline function mouseDownActive(mouseX:Float, mouseY:Float, button:MouseButton) if (activeUIDisplay!=null) activeUIDisplay.mouseDown(mouseX, mouseY, button);
		static public inline function mouseUpActive(mouseX:Float, mouseY:Float, button:MouseButton) if (activeUIDisplay!=null) activeUIDisplay.mouseUp(mouseX, mouseY, button);
		static public inline function mouseWheelActive(dx:Float, dy:Float, mode:MouseWheelMode) if (activeUIDisplay!=null) activeUIDisplay.mouseWheel(dx, dy, mode);
		
		static public inline function touchStartActive(touch:Touch) if (activeUIDisplay!=null) activeUIDisplay.touchStart(touch);
		static public inline function touchMoveActive(touch:Touch) if (activeUIDisplay!=null) activeUIDisplay.touchMove(touch);
		static public inline function touchEndActive(touch:Touch) if (activeUIDisplay!=null) activeUIDisplay.touchEnd(touch);
		static public inline function touchCancelActive(touch:Touch) if (activeUIDisplay!=null) activeUIDisplay.touchCancel(touch);

		static public inline function windowLeaveActive() if (activeUIDisplay!=null) activeUIDisplay.windowLeave();

	#else
		//public inline function get_pointerEnabled():Bool return (activeUIDisplay.indexOf(this) >= 0);

		var activeIndex:Int = 0;
		static var maxActiveIndex:Int = 0;
		static var activeUIDisplay = new Vector<UIDisplay>(MAX_DISPLAYS);
		
		static public inline function mouseMoveActive(mouseX:Float, mouseY:Float) for (i in 0...maxActiveIndex) activeUIDisplay.get(i).mouseMove(mouseX, mouseY);	
		static public inline function mouseUpActive(mouseX:Float, mouseY:Float, button:MouseButton) for (i in 0...maxActiveIndex) activeUIDisplay.get(i).mouseUp(mouseX, mouseY, button);
		static public inline function mouseDownActive(mouseX:Float, mouseY:Float, button:MouseButton) {
			for (i in 0...maxActiveIndex) {
				var ui:UIDisplay = activeUIDisplay.get(maxActiveIndex-i-1);
				// TODO : in den handlern (peoteView != null) durch isVisible ersetzen und zurückgeben wenn innerhalb des Displays
				if (ui.isVisible) {
					// TODO: depth-sorted iteration and STOP THE LOOP if triggered (so no bubbling between the UIDisplays)
					//if (ui.mouseDown(mouseX, mouseY, button) && ui.onPointerDown != null) {
						//ui.onPointerDown(ui, {x:Std.int(mouseX), y:Std.int(mouseY), type:PointerType.MOUSE, mouseButton:button});
						//break;
					//}
					ui.mouseDown(mouseX, mouseY, button);
					if (ui._isPointInside(Std.int(mouseX), Std.int(mouseY)) && ui.onPointerDown != null) {
						ui.onPointerDown(ui, {x:Std.int(mouseX), y:Std.int(mouseY), type:PointerType.MOUSE, mouseButton:button});
						if (!ui.bubbleMouseDown) break;
						//while (ui != null) {
							//ui.mouseDown(mouseX, mouseY, button);
							//if (ui._isPointInside(Std.int(mouseX), Std.int(mouseY)) && ui.onPointerDown != null) {
								//ui.onPointerDown(ui, {x:Std.int(mouseX), y:Std.int(mouseY), type:PointerType.MOUSE, mouseButton:button});
							//}
							//ui = ui.upDownEventsBubbleTo;
						//}					
						
					}
				}
			}
		}
		static public inline function mouseWheelActive(dx:Float, dy:Float, mode:MouseWheelMode) for (i in 0...maxActiveIndex) activeUIDisplay.get(i).mouseWheel(dx, dy, mode);
		
		static public inline function touchStartActive(touch:Touch) for (i in 0...maxActiveIndex) activeUIDisplay.get(i).touchStart(touch);
		static public inline function touchMoveActive(touch:Touch) for (i in 0...maxActiveIndex) activeUIDisplay.get(i).touchMove(touch);
		static public inline function touchEndActive(touch:Touch) for (i in 0...maxActiveIndex) activeUIDisplay.get(i).touchEnd(touch);
		static public inline function touchCancelActive(touch:Touch) for (i in 0...maxActiveIndex) activeUIDisplay.get(i).touchCancel(touch);

		static public inline function windowLeaveActive() for (i in 0...maxActiveIndex) activeUIDisplay.get(i).windowLeave();
	#end

	// -------- register Events from Lime Application ----------
	
	public static function registerEvents(window:Window) {
		
		window.onMouseUp.add(mouseUpActive);
		window.onMouseDown.add(mouseDownActive);
		window.onMouseWheel.add(mouseWheelActive);
		
		// TODO: keyboard & text
		
		Touch.onStart.add(touchStartActive);
		Touch.onMove.add(touchMoveActive);
		Touch.onEnd.add(touchEndActive);
		Touch.onCancel.add(touchCancelActive);

		#if (! html5)
		window.onRender.add(_mouseMoveFrameSynced);
		window.onMouseMove.add(_mouseMove);
		window.onLeave.add(_windowLeave);
		#else
		window.onMouseMove.add(mouseMoveActive);
		window.onLeave.add(windowLeaveActive);
		#end
	}
	
	#if (! html5)
		static var isMouseMove = false;
		static var lastMouseMoveX:Float = 0.0;
		static var lastMouseMoveY:Float = 0.0;
		
		static inline function _mouseMove (x:Float, y:Float) {
			lastMouseMoveX = x;
			lastMouseMoveY = y;
			isMouseMove = true;
		}
		
		static inline function _mouseMoveFrameSynced(context:RenderContext):Void {
			if (isMouseMove) {
				isMouseMove = false;
				mouseMoveActive(lastMouseMoveX, lastMouseMoveY);
			}
		}
		
		static inline function _windowLeave() {
			lastMouseMoveX = lastMouseMoveY = -1; // fix for another onMouseMoveFrameSynced() by render-loop
			windowLeaveActive();
		}
	#end

	// TODO:
	public static function unRegisterEvents(window:Window) {
		
		window.onMouseUp.remove(mouseUpActive);
		window.onMouseDown.remove(mouseDownActive);
		window.onMouseWheel.remove(mouseWheelActive);
		
		// TODO: keyboard & text
		
		Touch.onStart.remove(touchStartActive);
		Touch.onMove.remove(touchMoveActive);
		Touch.onEnd.remove(touchEndActive);
		Touch.onCancel.remove(touchCancelActive);

		#if (! html5)
		window.onRender.remove(_mouseMoveFrameSynced);
		window.onMouseMove.remove(_mouseMove);
		window.onLeave.remove(_windowLeave);
		#else
		window.onMouseMove.remove(mouseMoveActive);
		window.onLeave.remove(windowLeaveActive);
		#end
		
	}
			
}


