package peote.ui;

import haxe.ds.Vector;
import peote.ui.interactive.input2action.InputTextLine;
import peote.ui.interactive.input2action.InputTextPage;
import peote.ui.interactive.interfaces.InputFocus;

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
import peote.ui.interactive.interfaces.InputText;

import peote.ui.style.interfaces.Style;
import peote.ui.style.interfaces.FontStyle;
import peote.ui.style.interfaces.StyleID;


@:access(peote.view)
@:allow(peote.ui.interactive)
class PeoteUIDisplay extends Display
#if peote_layout
implements peote.layout.ILayoutElement
#end
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
	
	public var overOutEventsBubble:Bool = false;
	public var moveEventsBubble:Bool = false;
	public var upDownEventsBubble:Bool = false;
	public var wheelEventsBubble:Bool = false;

	var uiElements:Array<Interactive>;
	
	var movePickBuffer:Buffer<Pickable>;
	var movePickProgram:Program;
	
	var clickPickBuffer:Buffer<Pickable>;
	var clickPickProgram:Program;
	
	var draggingMouseElements:Array<Interactive>;
	var draggingTouchElements:Vector<Array<Interactive>>;
	
	var maxTouchpoints:Int;
	
	var usedStyleProgram = new Array<Program>();
	var usedStyleID = new Array<Int>();
	var stylePosBeforeFont:Int = 0;
	var autoAddStyles = true;
		
	public function new(x:Int, y:Int, width:Int, height:Int, color:Color=0x00000000, maxTouchpoints:Int = 3, availableStyles:Array<StyleID> = null, autoAddStyles:Null<Bool> = null)
	{
		number = getFreeNumber(); // trace('MAX_DISPLAYs: $MAX_DISPLAYS', 'UIDisplay NUMBER is $number');
		
		super(x, y, width, height, color);
		
		addAvailableStyles(availableStyles, autoAddStyles);
		
		// elements for mouseOver/Out ----------------------
		movePickBuffer = new Buffer<Pickable>(1024, 1024); // TODO: fill with constants
		movePickProgram = new Program(movePickBuffer);
				
		// elements for mouseDown/Up ----------------------
		clickPickBuffer = new Buffer<Pickable>(1024, 1024); // TODO: fill with constants
		clickPickProgram = new Program(clickPickBuffer);
	
		uiElements = new Array<Interactive>();
		//skins = new Array<Skin>();
		
		lastMouseDownIndex = new Vector<Int>(3);
		for (i in 0...lastMouseDownIndex.length) {
			lastMouseDownIndex.set(i, -1);
		}
		
		draggingMouseElements = new Array<Interactive>();

		this.maxTouchpoints = maxTouchpoints;
		lastTouchOverIndex = new Vector<Int>(maxTouchpoints);
		lastTouchDownIndex = new Vector<Int>(maxTouchpoints);
		
		draggingTouchElements = new Vector<Array<Interactive>>(maxTouchpoints);
				
		for (i in 0...maxTouchpoints) {
			lastTouchOverIndex.set(i, -1);
			lastTouchDownIndex.set(i, -1);
			draggingTouchElements.set(i, new Array<Interactive>());
		}
		
		InputTextLine.init();
		InputTextPage.init();
	}
	
	public function clear() {
		AVAILABLE_NUMBER &= ~(1 << number);
		// TODO: clear all programms and buffers
	}
	
	override public function addToPeoteView(peoteView:PeoteView, ?atDisplay:Display, addBefore:Bool=false)
	{
		if ( isIn(peoteView) ) removeFromActiveUIDisplay();
		super.addToPeoteView(peoteView, atDisplay, addBefore);
		movePickProgram.setNewGLContext(peoteView.gl);
		clickPickProgram.setNewGLContext(peoteView.gl);
		addToActiveUIDisplay(atDisplay, addBefore);
	}	
		
	override public function removeFromPeoteView(peoteView:PeoteView)
	{
		removeFromActiveUIDisplay();
		super.removeFromPeoteView(peoteView);
	}
	
	override public function show() {
		super.show();
		addToActiveUIDisplay(this);
	}
	
	override public function hide() {
		super.hide();
		removeFromActiveUIDisplay();
	}
		
	#if (peoteui_maxDisplays != "1")
	override public function swapDisplay(display:Display):Void
	{
		swapActiveUIDisplays(display); 
		super.swapDisplay(display);
	}
	#end

	// optimized function to check if mouseposition inside UIDisplay
	//@:access(peote.view.PeoteView)	
	inline function _isPointInside(px:Int, py:Int) {
		px = Std.int(px / peoteView.xz - peoteView.xOffset);
		py = Std.int(py / peoteView.yz - peoteView.yOffset);
		return (px >= x && px < x + width && py >= y && py < y + height);
	}

	// -------------------------------------------------------
	inline function addAvailableStyles(availableStyles:Array<StyleID>, autoAddStyles:Null<Bool>) {
		// --------------------------------
		if (availableStyles == null) {
			this.autoAddStyles = (autoAddStyles == null) ? true : autoAddStyles;
			usedStyleProgram = new Array<Program>();
		}
		else {
			this.autoAddStyles = (autoAddStyles == null) ? false : autoAddStyles;
			var noFontYet = true;
			for (style in availableStyles) {
				var id = style.getUUID();
				if (usedStyleID.contains(id)) throw('Error by creating new UIDisplay. Give each of the styles "${Type.getClassName(Type.getClass(style))}" an unique ID to have multiple of them into the availableStyles list!');
				usedStyleID.push(id);
				if ( style.isFontStyle() ) {
					usedStyleProgram.push(null); // <- will be created by first UITextLine
					noFontYet = false;
				} 
				else {
					var program:Program = (style:Dynamic).createStyleProgram();
					usedStyleProgram.push(program);
					this.addProgram(program);
					if (noFontYet) stylePosBeforeFont++;
				}
			}
		}
	}
	
	inline function autoAddStyleProgram(program:Program, styleId:Int, addOnTop:Bool = false) { //trace("autoadd", styleId, addOnTop);
		if (addOnTop) {
			usedStyleID.push(styleId);
			usedStyleProgram.push(program);
			this.addProgram(program);
		} else {
			usedStyleID.insert(stylePosBeforeFont, styleId);
			if (stylePosBeforeFont == 0) this.addProgram(program, true);
			else this.addProgram(program, usedStyleProgram[stylePosBeforeFont-1]);
			usedStyleProgram.insert(stylePosBeforeFont, program);
			stylePosBeforeFont++;
		}
	}
	
	inline function addProgramAtStylePos(program:Program, stylePos:Int) { //trace("Add StyleProgram at",stylePos);
		usedStyleProgram[stylePos] = program;
		var afterProgram:Program = null;
		while (stylePos-- > 0) {
			afterProgram = usedStyleProgram[stylePos];
			if (afterProgram != null) break;		
		}
		this.addProgram(program, afterProgram, (afterProgram==null) ? true : false);
	}
	
	// -------------------------------
	
	inline public function addStyleProgram(style:Style, addOnTop:Bool = false):Program {
		var program:Program;
		var stylePos = usedStyleID.indexOf( style.getUUID() );
		if (stylePos < 0) {
			program = (style:Dynamic).createStyleProgram();
			autoAddStyleProgram(cast program, style.getUUID(), addOnTop);
		}
		else {
			program = cast usedStyleProgram[stylePos];
			if (program == null) {
				program = (style:Dynamic).createStyleProgram();
				addProgramAtStylePos(program, stylePos);
			}
		}
		//trace("usedStyleID:",usedStyleID);
		return program;
	}
		
	 public function addFontStyleProgram(style:FontStyle, font:Dynamic, addOnTop:Bool = true):Program {
		// TODO: check font type
		var program:Program;
		var stylePos = usedStyleID.indexOf( style.getUUID() );
		if (stylePos < 0) {
			if (font == null) throw('Error by addFontStyleProgram(). The style "${Type.getClassName(Type.getClass(style))}(${style.id})" needs a corresponding font parameter.');
			program = font.createFontProgram(style, #if (peoteui_no_textmasking || peoteui_no_masking) false #else true #end, 4*1024, 4*1024, true);
			autoAddStyleProgram(cast program, style.getUUID(), addOnTop);
		}
		else {
			program = cast usedStyleProgram[stylePos];
			if (program == null) {
				if (font == null) throw('Error by getProgram(). The style "${Type.getClassName(Type.getClass(style))}(${style.id})" is a FontStyle so it needs a corresponding font parameter.');
				program = font.createFontProgram(style, #if (peoteui_no_textmasking || peoteui_no_masking) false #else true #end, 4*1024, 4*1024, true);				
				addProgramAtStylePos(program, stylePos);
			}
		}
		return program;
	}
		
	inline public function getStyleProgram(style:Style):Program {
		var stylePos = usedStyleID.indexOf( style.getUUID() );
		if (stylePos < 0) throw('Error by getProgram(). The style "${Type.getClassName(Type.getClass(style))}" id=${style.id} is not inside the availableStyles of UIDisplay.');
		var program:Program = cast usedStyleProgram[stylePos];
		if (program == null) {
			program = (style:Dynamic).createStyleProgram();
			addProgramAtStylePos(program, stylePos);
		} 
		return program;
	}
	
	inline public function getFontStyleProgram(style:FontStyle, font:Dynamic):Program {
		// TODO: check font type
		var stylePos = usedStyleID.indexOf( style.getUUID() );
		if (stylePos < 0) throw('Error by getProgram(). The style "${Type.getClassName(Type.getClass(style))}" id=${style.id} is not inside the availableStyles of UIDisplay.');
		var program:Program = cast usedStyleProgram[stylePos];
		if (program == null) {
			if (font == null) throw('Error by getProgram(). The style "${Type.getClassName(Type.getClass(style))}(${style.id})" is a FontStyle so it needs a corresponding font parameter.');
			program = font.createFontProgram(style, #if (peoteui_no_textmasking || peoteui_no_masking) false #else true #end, 4*1024, 4*1024, true);
			addProgramAtStylePos(program, stylePos);
		} 
		return program;
	}
	
	
	// TODO: to clean up all programs
	//inline function removeStyleProgram(program:Program, stylePos:Int) {
		//trace('REMOVE STYLEPROGRAM $stylePos');
		//usedStyleProgram.set(stylePos, null);
		//this.removeProgram(program);
	//}
		
	
	// -------------------------------------------------------	
	public function add(uiElement:Interactive):Void {
		//TODO
		if (uiElement.isVisible && uiElement.uiDisplay != null) {
			//if (uiElement.uiDisplay == this) return; // is already added
			//else 
			throw('Error, uiElement is already added to UIDisplay ${uiElement.uiDisplay.number}');
		}
		uiElements.push(uiElement);		
		uiElement.onAddToDisplay(this);
	}
	
	public function remove(uiElement:Interactive):Void {
		
		// TODO: check for GLITCH here!
		// send pointerout if was over while deleting
		if (lastMouseOverIndex >= 0) {
			var lastElem = movePickBuffer.getElement(lastMouseOverIndex).uiElement;
			if (lastElem == uiElement) {
				while (lastElem != null) {
					lastElem.pointerOut({x: -1, y: -1, type:PointerType.MOUSE});
					lastElem = lastElem.overOutEventsBubbleTo;
				}
				lastMouseOverIndex = -1;
			}
		}
		
		uiElements.remove(uiElement);
		uiElement.onRemoveFromDisplay(this);
		
	}
	
	public function removeAll():Void {
		for (uiElement in uiElements)
			remove(uiElement);
		//TODO
	}
	
	public function swap(uiElement1:Interactive, uiElement2:Interactive):Void {
		//TODO: if same z-index -> swap the elements and pickables inside buffer,
		//      else -> swap only z-index
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
	public function startDraggingElement(uiElement:Interactive, e:PointerEvent):Void {
		//trace("start dragging element", uiElement.isDragging);
		if (! uiElement.isDragging) {
			uiElement.isDragging = true;
			switch (e.type) {
				case MOUSE: draggingMouseElements.push(uiElement);
				case TOUCH: draggingTouchElements.get(e.touch.id).push(uiElement);
				case PEN: // TODO!
			}
			
		} //TODO: #if peoteui_debug -> else WARNING: already in dragmode
	}

	public function stopDraggingElement(uiElement:Interactive, e:PointerEvent):Void {
		//trace("stop dragging element", uiElement.isDragging, draggingMouseElements.length);
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
	
	var lastMouseOverIndex:Int = -1;
	var lastMouseDownIndex:haxe.ds.Vector<Int>;
	var lockMouseDown:Int = 0;	

	
	// ------------ PointerEvents ond the UIDisplay itselfs ----------
	
	public var onPointerOver:PeoteUIDisplay->PointerEvent->Void = null;
	public var onPointerOut:PeoteUIDisplay->PointerEvent->Void = null;
	public var onPointerDown:PeoteUIDisplay->PointerEvent->Void = null;
	public var onPointerUp:PeoteUIDisplay->PointerEvent->Void = null;
	public var onPointerClick:PeoteUIDisplay->PointerEvent->Void = null;
	public var onPointerMove:PeoteUIDisplay->PointerEvent->Void = null;
	
	
	static inline var HAS_OVEROUT:Int = 1;
	static inline var HAS_MOVE:Int = 2;
	static inline var HAS_OVEROUT_MOVE:Int = 3;

	var isMouseInside:Bool = false;
	var isMouseOver:Bool = false;
	
	var lastMouseX:Float = 0.0;
	var lastMouseY:Float = 0.0;
	
	var isTriggerMouse = false; // to keep sure its not called recursively
	public inline function triggerMouse(uiElement:Interactive) {
		if (!isTriggerMouse && uiElement.hasMoveEvent != 0 && uiElement.pointIsInside(localX(lastMouseX), localY(lastMouseY)) ) {
			isTriggerMouse = true;
			mouseMove(lastMouseX, lastMouseY);
			isTriggerMouse = false;
		}
	}
	
	public inline function mouseMove (mouseX:Float, mouseY:Float, checkForEvent:Int = HAS_OVEROUT_MOVE):Int
	{
		if (mouseEnabled && peoteView != null)
		{
			var x = Std.int(lastMouseX = mouseX);
			var y = Std.int(lastMouseY = mouseY);
			
			var isInside:Bool = false;
			var pickedIndex = -1;
			
			if (checkForEvent>0 && _isPointInside(x, y) )
			{
				isInside = true;
				pickedIndex = peoteView.getElementAt(mouseX, mouseY, this, movePickProgram);					
			}
			
			if (intoSelectionTextLine != null) // text selection
			{
				intoSelectionTextLine.onSelect({x:Std.int(localX(x)), y:Std.int(localX(y)), type:PointerType.MOUSE});
			}
			else if (draggingMouseElements.length > 0) // Dragging
			{
				for (uiElement in draggingMouseElements) {
					uiElement.dragTo(x, y);
					//update(uiElement);
					uiElement.updateLayout();
				}
			}
			else
			{
				var hasEventOver = false;
				var hasEventOut = false;
				
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
									if (pickedElem.overOutEventsBubbleTo==null && !pickedElem.overOutEventsBubbleToDisplay) hasEventOut = true; // UIDisplay event
									pickedElem = pickedElem.overOutEventsBubbleTo;
								}
							} 
							else
							{
								//trace("BBBBBBBBBBBBBBBBBBBBBBB");
								while (lastElem != null && lastElem != pickedElem) {
									lastElem.pointerOut({x:x, y:y, type:PointerType.MOUSE});
									if (lastElem.overOutEventsBubbleTo==null && !lastElem.overOutEventsBubbleToDisplay) hasEventOver = true; // UIDisplay event
									lastElem = lastElem.overOutEventsBubbleTo;
								}
								if (lastElem == null) {
									while (pickedElem != null) {
										pickedElem.pointerOver({x:x, y:y, type:PointerType.MOUSE});
										if (pickedElem.overOutEventsBubbleTo==null && !pickedElem.overOutEventsBubbleToDisplay) hasEventOut = true; // UIDisplay event
										pickedElem = pickedElem.overOutEventsBubbleTo;
									}
								}
							}							
						} 
						else
						{
							//trace("CCCCCCCCCCCCCCCCCCCCCCCCCC");
							while (lastElem != null) {
								lastElem.pointerOut({x:x, y:y, type:PointerType.MOUSE});
								if (lastElem.overOutEventsBubbleTo==null && !lastElem.overOutEventsBubbleToDisplay) hasEventOver = true; // UIDisplay event
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
								if (pickedElem.overOutEventsBubbleTo==null && !pickedElem.overOutEventsBubbleToDisplay) hasEventOut = true; // UIDisplay event 
								pickedElem = pickedElem.overOutEventsBubbleTo;
							}
						}
					}
					
					lastMouseOverIndex = pickedIndex;					
				}
				
				// -------- on MOVE DISPLAY --------				
				if ( checkForEvent & HAS_MOVE != 0)  // was bubbled throught multiple displays
				{
					// Move
					var hasEventMove = false;
					if (pickedIndex >= 0) {
						var pickedElem = movePickBuffer.getElement(pickedIndex).uiElement;
						while (pickedElem != null) {
							pickedElem.pointerMove({x:x, y:y, type:PointerType.MOUSE});
							if (pickedElem.moveEventsBubbleTo==null && pickedElem.moveEventsBubbleToDisplay) hasEventMove = true; // UIDisplay event 
							pickedElem = pickedElem.moveEventsBubbleTo;
						}					
					} else hasEventMove = true; // UIDisplay event 
				
					//  UIDisplay Move
					if (hasEventMove) {
						if (onPointerMove != null) onPointerMove(this, {x:x, y:y, type:PointerType.MOUSE});
						// not bubbleMove to next displays
						if (!moveEventsBubble) checkForEvent -= HAS_MOVE;
					}
					else checkForEvent -= HAS_MOVE;					
				}
				
				// -------- on Over/OUT DISPLAY --------				
				if ( checkForEvent & HAS_OVEROUT != 0) // was bubbled throught multiple displays
				{
					if (isInside) {
						if (!isMouseInside) {
							isMouseInside = true;
							hasEventOver = true;
						}
					} 
					else if (isMouseInside) {
						isMouseInside = false;
						hasEventOut = true;
					}

					if (hasEventOver && !hasEventOut) {
						if (onPointerOver != null) onPointerOver(this, {x:x, y:y, type:PointerType.MOUSE});
						isMouseOver = true;
					}
					else if (hasEventOut && !hasEventOver) {
						if (onPointerOut != null) onPointerOut(this, {x:x, y:y, type:PointerType.MOUSE});					
						isMouseOver = false;
					}
					
					if (isMouseInside) {
						if (!isMouseOver || !overOutEventsBubble) checkForEvent -= HAS_OVEROUT; // no more bubbling to lower displays
					}
					
				}
				else { // remove the old over if no bubbling					
					if (isMouseInside) {
						if (onPointerOut != null) onPointerOut(this, {x:x, y:y, type:PointerType.MOUSE});					
						isMouseInside = isMouseOver = false;
					}
				}
				// ------------------------------
				
			}
			
		}		
		return checkForEvent;
	}
	
	var isTouchInside:Bool = false;
	var isTouchOver:Bool = false;
	
	public inline function touchMove (touch:Touch, checkForEvent:Int = HAS_OVEROUT_MOVE):Int
	{
		if (touchEnabled && peoteView != null && touch.id < maxTouchpoints)
		{
			var x:Int = Math.round(touch.x * peoteView.width);
			var y:Int = Math.round(touch.y * peoteView.height);
			
			var isInside:Bool = false;
			var pickedIndex = -1;
			
			if (checkForEvent>0 && _isPointInside(x, y) )
			{
				isInside = true;
				pickedIndex = peoteView.getElementAt(x, y, this, movePickProgram);					
			}
			
			var draggingTouchElemArray = draggingTouchElements.get(touch.id);						
			if (draggingTouchElemArray.length > 0) // touch Dragging
			{
				for (uiElement in draggingTouchElemArray) {
					uiElement.dragTo(x, y);
					update(uiElement);
				}
			}	
			else
			{
				var hasEventOver = false;
				var hasEventOut = false;
				
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
									if (pickedElem.overOutEventsBubbleTo==null && !pickedElem.overOutEventsBubbleToDisplay) hasEventOut = true; // UIDisplay event
									pickedElem = pickedElem.overOutEventsBubbleTo;
								}
							} 
							else
							{
								//trace("B");
								while (lastElem != null && lastElem != pickedElem) {
									lastElem.pointerOut({x:x, y:y, type:PointerType.TOUCH, touch:touch});
									if (lastElem.overOutEventsBubbleTo==null && !lastElem.overOutEventsBubbleToDisplay) hasEventOver = true; // UIDisplay event
									lastElem = lastElem.overOutEventsBubbleTo;
								}
								if (lastElem == null)
									while (pickedElem != null) {
										pickedElem.pointerOver({x:x, y:y, type:PointerType.TOUCH, touch:touch});
										if (pickedElem.overOutEventsBubbleTo==null && !pickedElem.overOutEventsBubbleToDisplay) hasEventOut = true; // UIDisplay event
										pickedElem = pickedElem.overOutEventsBubbleTo;
									}
							}							
						} 
						else
						{
							//trace("C");
							while (lastElem != null) {
								lastElem.pointerOut({x:x, y:y, type:PointerType.TOUCH, touch:touch});
								if (lastElem.overOutEventsBubbleTo==null && !lastElem.overOutEventsBubbleToDisplay) hasEventOver = true; // UIDisplay event
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
								if (pickedElem.overOutEventsBubbleTo==null && !pickedElem.overOutEventsBubbleToDisplay) hasEventOut = true; // UIDisplay event 
								pickedElem = pickedElem.overOutEventsBubbleTo;
							}
						}
					}
						
					lastTouchOverIndex.set(touch.id, pickedIndex);
				}
				
				// -------- on touch MOVE DISPLAY --------				
				if ( checkForEvent & HAS_MOVE != 0)  // was bubbled throught multiple displays
				{
					// Move
					var hasEventMove = false;
					if (pickedIndex >= 0) {
						var pickedElem = movePickBuffer.getElement(pickedIndex).uiElement;
						while (pickedElem != null) {
							pickedElem.pointerMove({x:x, y:y, type:PointerType.TOUCH, touch:touch});
							if (pickedElem.moveEventsBubbleTo==null && pickedElem.moveEventsBubbleToDisplay) hasEventMove = true; // UIDisplay event 
							pickedElem = pickedElem.moveEventsBubbleTo;
						}					
					} else hasEventMove = true; // UIDisplay event 
				
					//  UIDisplay Move
					if (hasEventMove && (isTouchDown & (1 << touch.id)) > 0) {
						if (onPointerMove != null) onPointerMove(this, {x:x, y:y, type:PointerType.TOUCH, touch:touch});
						// not bubbleMove to next displays
						if (!moveEventsBubble) checkForEvent -= HAS_MOVE;
					}
					else checkForEvent -= HAS_MOVE;					
				}
				
				// -------- on touch Over/OUT DISPLAY --------				
				if ( checkForEvent & HAS_OVEROUT != 0 && (isTouchDown & (1 << touch.id)) > 0) // was bubbled throught multiple displays
				{
					if (isInside) {
						if (!isTouchInside) {
							isTouchInside = true;
							hasEventOver = true;
						}
					} 
					else if (isTouchInside) {
						isTouchInside = false;
						hasEventOut = true;
					}

					if (hasEventOver && !hasEventOut && !isTouchOver) { trace("KK");
						if (onPointerOver != null) onPointerOver(this, {x:x, y:y, type:PointerType.TOUCH, touch:touch});
						isTouchOver = true;
					}
					else if (hasEventOut && !hasEventOver && isTouchOver) {
						if (onPointerOut != null) onPointerOut(this, {x:x, y:y, type:PointerType.TOUCH, touch:touch});					
						isTouchOver = false;
					}
					
					if (isTouchInside) {
						if (!isTouchOver || !overOutEventsBubble) checkForEvent -= HAS_OVEROUT; // no more bubbling to lower displays
					}
					
				}
				else { // remove the old over if no bubbling					
					if (isTouchInside) {
						if (onPointerOut != null) onPointerOut(this, {x:x, y:y, type:PointerType.MOUSE});					
						isTouchInside = isTouchOver = false;
					}
				}
				// ------------------------------
				
			}
			
		}
		return checkForEvent;
	}
	
	var isMouseDown:Int = 0;
	
	public inline function mouseDown (mouseX:Float, mouseY:Float, button:MouseButton):Bool
	{
		var hasEventDown = false;
		if (mouseEnabled && (lockMouseDown & (1 << button)) == 0 && peoteView != null) 
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
						if (pickedElem.upDownEventsBubbleTo==null && pickedElem.upDownEventsBubbleToDisplay) hasEventDown = true; // UIDisplay event
						pickedElem = pickedElem.upDownEventsBubbleTo;
					}					

					lockMouseDown = lockMouseDown | (1 << button);
					lastMouseDownIndex.set(button, pickedIndex);
					
					if (hasEventDown) { // UIDisplay event
						if (onPointerDown != null) onPointerDown(this, {x:x, y:y, type:PointerType.MOUSE, mouseButton:button});
						isMouseDown = isMouseDown | (1 << button);
						hasEventDown = !upDownEventsBubble;
					} 
					else hasEventDown=true; // UIDisplay event

				}
				else { // UIDisplay event
					if (onPointerDown != null) onPointerDown(this, {x:x, y:y, type:PointerType.MOUSE, mouseButton:button});
					isMouseDown = isMouseDown | (1 << button);
					hasEventDown = !upDownEventsBubble;
				}

			}
		}
				
		//var pickedElements = peoteView.getAllElementsAt(x, y, display, clickProgram);//trace(pickedElements);
		return hasEventDown;
	}
	
	var isTouchDown:Int = 0;
	
	public inline function touchStart (touch:Touch):Bool {
		var hasEventDown = false;
		var hasEventOver = false;
		if (touchEnabled && (lockTouchDown & (1 << touch.id)) == 0 && peoteView != null && touch.id < maxTouchpoints)
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
						if (pickedElem.overOutEventsBubbleTo==null && pickedElem.overOutEventsBubbleToDisplay) hasEventOver = true; // UIDisplay event
						pickedElem = pickedElem.overOutEventsBubbleTo;
					}					
					lastTouchOverIndex.set(touch.id, pickedIndex);
				}
				else hasEventOver = true;
				
				// Down
				var touchDownIndex = peoteView.getElementAt(x, y, this, clickPickProgram ) ;
				if (touchDownIndex >= 0) {
					var pickedElem = clickPickBuffer.getElement(touchDownIndex).uiElement;
					while (pickedElem != null) {
						pickedElem.pointerDown({x:x, y:y, type:PointerType.TOUCH, touch:touch});
						if (pickedElem.upDownEventsBubbleTo==null && pickedElem.upDownEventsBubbleToDisplay) hasEventDown = true; // UIDisplay event
						pickedElem = pickedElem.upDownEventsBubbleTo;
					}
					lockTouchDown = lockTouchDown | (1 << touch.id);
					lastTouchDownIndex.set(touch.id, touchDownIndex);
				}
				else hasEventDown = true; // UIDisplay event
				
				
				// UIDisplay event
				trace("hasEventOver", hasEventOver, "isTouchOver", isTouchOver);
				if (hasEventOver && !isTouchOver) {
					if (onPointerOver != null) onPointerOver(this, {x:x, y:y, type:PointerType.TOUCH, touch:touch});
					isTouchOver = true;
					hasEventOver = !overOutEventsBubble;
				}
				else hasEventOver = true; // TODO: same as for touchmove and via checkForEvent
				
				trace("hasEventDown", hasEventDown);
				if (hasEventDown) {
					if (onPointerDown != null) onPointerDown(this, {x:x, y:y, type:PointerType.TOUCH, touch:touch});
					isTouchDown = isTouchDown | (1 << touch.id);
					hasEventDown = !upDownEventsBubble;
				}
				else hasEventDown=true; // TODO: same as for touchmove and via checkForEvent
			}
			
		}
		
		return (hasEventOver || hasEventDown);
	}
	
	public inline function mouseUp (mouseX:Float, mouseY:Float, button:MouseButton)
	{		
		if (mouseEnabled && peoteView != null)
		{
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
				lockMouseDown = lockMouseDown - (1 << button);
			} 
			
			// UIDisplay event
			if (isMouseDown & (1 << button) != 0) {
				if (onPointerUp != null) onPointerUp(this, {x:x, y:y, type:PointerType.MOUSE, mouseButton:button});
				
				//if (onPointerClick != null && _isPointInside(x, y)) {
				if (onPointerClick != null && isMouseOver) {
					onPointerClick(this, {x:x, y:y, type:PointerType.MOUSE, mouseButton:button});
				}
				isMouseDown = isMouseDown - (1 << button);
			}
			
		}			
		
	}
	
	public inline function touchEnd (touch:Touch) {
		//var hasEventUp = false;
		//var hasEventOut = false;
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
				
				//if (lastTouchDownElem == null) hasEventUp = true;
				
				while (lastTouchDownElem != null) {
					lastTouchDownElem.pointerUp({x:x, y:y, type:PointerType.TOUCH, touch:touch});
					//if (!hasEventUp && lastTouchDownElem.upDownEventsBubbleToDisplay) hasEventUp = true;
					
					// Click
					if (!startClick && pickedElem == lastTouchDownElem) startClick = true;
					if (startClick) lastTouchDownElem.pointerClick({x:x, y:y, type:PointerType.TOUCH, touch:touch});					
					lastTouchDownElem = lastTouchDownElem.upDownEventsBubbleTo;
				}				
				lastTouchDownIndex.set(touch.id, -1);
				lockTouchDown = lockTouchDown - (1 << touch.id);				
			}
			//else hasEventUp = (_isPointInside(x, y));
			
			// Out
			pickedIndex = (_isPointInside(x, y)) ? peoteView.getElementAt(x, y, this, movePickProgram) : -1;
			if (pickedIndex >=0 && pickedIndex == lastTouchOverIndex.get(touch.id)) {
				pickedElem = movePickBuffer.getElement(pickedIndex).uiElement;
				while (pickedElem != null) {
					pickedElem.pointerOut({x:x, y:y, type:PointerType.TOUCH, touch:touch});
					//if (!hasEventOut && pickedElem.upDownEventsBubbleToDisplay) hasEventOut = true; // UIDisplay event
					pickedElem = pickedElem.overOutEventsBubbleTo;
				}					
				lastTouchOverIndex.set(touch.id, -1);
			}
			//else hasEventOut = true;
			
			// UIDisplay event
			if ((isTouchDown & (1 << touch.id)) > 0) {
				
				isTouchDown = isTouchDown - (1 << touch.id);
				if (isTouchOver) {
					if (onPointerOut != null) onPointerOut(this, {x:x, y:y, type:PointerType.TOUCH, touch:touch});
					isTouchOver = false;
				}
				
				if (onPointerUp != null) onPointerUp(this, {x:x, y:y, type:PointerType.TOUCH, touch:touch});
				
				if (onPointerClick != null && _isPointInside(x, y)) {
					onPointerClick(this, {x:x, y:y, type:PointerType.TOUCH, touch:touch});
				}
			}
		}	
		
		//return (hasEventUp || hasEventOut);
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
		//trace("----------windowLeave-----------");
		
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
				
		// UIDisplay event
		if (isMouseOver) {
			if (onPointerOut != null) onPointerOut(this, {x:-1, y:-1, type:PointerType.MOUSE});					
			isMouseInside = false;
			isMouseOver = false;
		}
		
		var button = 0;
		while (isMouseDown > 0) {			
			if (isMouseDown & (1 << button) > 0) {
				if (onPointerUp != null) onPointerUp(this, {x:-1, y:-1, type:PointerType.MOUSE, mouseButton:button});
				isMouseDown -= (1 << button);
			}
			button++;
		}

		
		// -----------------touch ----------------
		
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
		
		// UIDisplay event
		// TODO: for all touch-ids ?
		if (isTouchOver) {
			if (onPointerOut != null) onPointerOut(this, {x:-1, y:-1, type:PointerType.TOUCH, touch:new Touch(-1, -1, 0, 0, 0, 0, 0)});					
			isTouchInside = false;
			isTouchOver = false;
		}
		
		var touchID = 0;
		while (isTouchDown > 0) {
			if (isTouchDown & (1 << touchID) > 0) {
				if (onPointerUp != null) onPointerUp(this, {x:-1, y:-1, type:PointerType.TOUCH, touch:new Touch(-1, -1, touchID, 0, 0, 0, 0)});
				isTouchDown -= (1 << touchID);
			}
			touchID++;
		}
		
	}
	
	// ----------------- KEYBOARD - EVENTS ----------------------------
		
	
	//public var onKeyDown:UIDisplay->InputEvent->Void = null;

	@:access(input2action.Input2Action)
	inline function keyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		#if html5
		if (modifier.altKey && modifier.ctrlKey) js.Syntax.code('event.preventDefault();');
		#end
		//trace("key DOWN");
		if (inputFocusElement != null) {
			switch (keyCode) {
				#if html5
				case KeyCode.TAB: js.Syntax.code('event.preventDefault();');
				#end
				default:
			}
		
			inputFocusElement.keyDown(keyCode, modifier);
		}
	}
	
	@:access(input2action.Input2Action)
	inline function keyUp (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		if (inputFocusElement != null) inputFocusElement.keyUp(keyCode, modifier);
	}
	
	inline function textInput (chars:String):Void {
		//trace("textInput:", chars.length);
		if (inputFocusElement != null) inputFocusElement.textInput(chars);
	}
	
	// -------------------------- text inputfocus  --------------------------
	
	static var inputFocusUIDisplay:PeoteUIDisplay = null;
	var inputFocusElement:InputFocus = null;
	
	inline function setInputFocus(t:InputFocus, e:PointerEvent=null) {
		if (inputFocusElement != t) {

			inputFocusUIDisplay = this;
			
			if (inputFocusElement != null) inputFocusElement.removeInputFocus();
			
			//trace("setInputFocus");
			inputFocusElement = t;
		}
	}
	
	inline function removeInputFocus(t:InputFocus) {
		//trace("removeInputFocus");
		inputFocusElement = null;
	}
	
	// -------------------------- text selection  --------------------------
	public inline function localPointerEvent(e:PointerEvent):PointerEvent 
		return {x:Std.int(localX(e.x)), y:Std.int(localY(e.y)), type:e.type, touch:e.touch, mouseButton:e.mouseButton};
	
	static var intoSelectionTextLine:InputText = null;

	public function startSelection(t:InputText, e:PointerEvent) {
		if (intoSelectionTextLine != null) intoSelectionTextLine.onSelectStop(localPointerEvent(e)); // if there is another into selectionMode
		intoSelectionTextLine = t;
		t.onSelectStart(localPointerEvent(e));
	}
	
	public function stopSelection(t:InputText, e:PointerEvent) {
		intoSelectionTextLine = null;
		t.onSelectStop(localPointerEvent(e));
	}
		
	
	
	// ----------------- Dragging ----------------------------
	
	var dragMinX:Int = -0x7fff;
	var dragMinY:Int = -0x7fff;
	var dragMaxX:Int = 0x7fff;
	var dragMaxY:Int = 0x7fff;
	
	var draggingMouseButton:Int = 0;
	var draggingTouchID:Int = 0;
	
	public var isDragging(get, never):Bool;
	inline function get_isDragging():Bool {
		return (draggingMouseButton != 0 || draggingTouchID != 0);
	}
	
	var dragOriginX:Int = 0;
	var dragOriginY:Int = 0;
	
	public inline function setDragArea(dragAreaX:Int, dragAreaY:Int, dragAreaWidth:Int, dragAreaHeight:Int) 
	{
		dragMinX = dragAreaX;
		dragMinY = dragAreaY;
		dragMaxX = dragAreaX + dragAreaWidth;
		dragMaxY = dragAreaY + dragAreaHeight;
	}
	
	inline function dragTo(dragToX:Float, dragToY:Float):Void
	{
		if (peoteView != null) _dragTo(dragToX, dragToY);
	}
	
	inline function dragToTouch(touch:Touch):Void
	{
		if (peoteView != null) _dragTo(Math.round(touch.x * peoteView.width), Math.round(touch.y * peoteView.height));
	}
	
	inline function _dragTo(dragToX:Float, dragToY:Float):Void
	{
		var toX:Int = Std.int(dragToX / peoteView.xz / xz);
		var toY:Int = Std.int(dragToY / peoteView.yz / yz);
		
		if (toX >= (dragMinX + dragOriginX)) {
			if (toX < (dragMaxX - width + dragOriginX)) x = toX - dragOriginX;
			else x = dragMaxX - width;
		} else x = dragMinX;
		
		if (toY >= dragMinY + dragOriginY) {
			if (toY < dragMaxY - height + dragOriginY) y = toY - dragOriginY;
			else y = dragMaxY - height;
		} else y = dragMinY;
	}
	
	
	// -------- register Events from Lime Application ----------
	
/*	public var pointerEnabled(get, set):Bool;
	public inline function set_pointerEnabled(b:Bool):Bool {
		if (b) activate(this) else deactivate(this);
		return b;
	}
*/
	
	#if (peoteui_maxDisplays == "1")
		//public inline function get_pointerEnabled():Bool return (activeUIDisplay == this);
		
		static var activeUIDisplay:PeoteUIDisplay;
		inline function addToActiveUIDisplay(?atDisplay:Display, addBefore:Bool = false) activeUIDisplay = this;
		inline function removeFromActiveUIDisplay() activeUIDisplay = null;

		public function startDragging(e:PointerEvent) {
			dragOriginX = Std.int(e.x / peoteView.xz / xz) - x;
			dragOriginY = Std.int(e.y / peoteView.yz / yz) - y;
			switch (e.type) {
				case MOUSE: draggingMouseButton = draggingMouseButton | (1 << e.mouseButton);
				case TOUCH: draggingTouchID = draggingTouchID | (1 << e.touch.id);
				case PEN: // TODO!
			}				
		}
		
		public function stopDragging(e:PointerEvent) {
			if (isDragging) {
				switch (e.type) {
					case MOUSE:
						if (draggingMouseButton & (1 << e.mouseButton) > 0) draggingMouseButton -= (1 << e.mouseButton);
						if (draggingMouseButton == 0) mouseMove(e.x, e.y);
					case TOUCH:
						if (draggingTouchID & (1 << e.touch.id) > 0) draggingTouchID -= (1 << e.touch.id);
						if (draggingTouchID == 0) touchMove(e.touch);
					case PEN: // TODO!
				}
			}
		}
		
		static public inline function mouseMoveActive(mouseX:Float, mouseY:Float) {
			if (activeUIDisplay != null) {
				if (activeUIDisplay.mouseEnabled && activeUIDisplay.draggingMouseButton > 0) activeUIDisplay.dragTo(mouseX, mouseY);
				else activeUIDisplay.mouseMove(mouseX, mouseY);
			}
		}
		static public inline function mouseDownActive(mouseX:Float, mouseY:Float, button:MouseButton) if (activeUIDisplay!=null) activeUIDisplay.mouseDown(mouseX, mouseY, button);
		static public inline function mouseUpActive(mouseX:Float, mouseY:Float, button:MouseButton) if (activeUIDisplay!=null) activeUIDisplay.mouseUp(mouseX, mouseY, button);
		static public inline function mouseWheelActive(dx:Float, dy:Float, mode:MouseWheelMode) if (activeUIDisplay!=null) activeUIDisplay.mouseWheel(dx, dy, mode);
		
		static public inline function touchMoveActive(touch:Touch) {
			if (activeUIDisplay != null) {
				if (activeUIDisplay.touchEnabled && activeUIDisplay.draggingTouchID > 0) activeUIDisplay.dragToTouch(touch);
				else activeUIDisplay.touchMove(touch);
			}
		}
		static public inline function touchStartActive(touch:Touch) if (activeUIDisplay!=null) activeUIDisplay.touchStart(touch);
		static public inline function touchEndActive(touch:Touch) if (activeUIDisplay!=null) activeUIDisplay.touchEnd(touch);
		static public inline function touchCancelActive(touch:Touch) if (activeUIDisplay!=null) activeUIDisplay.touchCancel(touch);

		static public inline function keyDownActive(keyCode:KeyCode, modifier:KeyModifier) if (activeUIDisplay!=null) activeUIDisplay.keyDown(keyCode, modifier);
		static public inline function keyUpActive(keyCode:KeyCode, modifier:KeyModifier) if (activeUIDisplay!=null) activeUIDisplay.keyUp(keyCode, modifier);
		static public inline function textInputActive(text:String) if (activeUIDisplay!=null) activeUIDisplay.textInput(text);

		static public inline function windowLeaveActive() if (activeUIDisplay!=null) activeUIDisplay.windowLeave();

	#else
		//public inline function get_pointerEnabled():Bool return (activeUIDisplay.indexOf(this) >= 0);

		var activeIndex:Int = 0;
		static var maxActiveIndex:Int = 0;
		static var activeUIDisplay = new Vector<PeoteUIDisplay>(MAX_DISPLAYS);
		
		inline function swapActiveUIDisplays(display:Display) 
		{
			if ( Std.isOfType(display, PeoteUIDisplay) ) {
				_swapActiveUIDisplays(cast display);
			}
			else {
				var displayListItem:RenderListItem<Display> = peoteView.displayList.itemMap.get(display);
				while (displayListItem.value != null && !Std.isOfType(displayListItem.value, PeoteUIDisplay)) {
					displayListItem = displayListItem.next;
				}
				if (displayListItem.value == null ) {
					if ( activeIndex != 0) _swapActiveUIDisplays(activeUIDisplay.get(0)); // swap with the first
				}
				else {
					var d:PeoteUIDisplay = cast displayListItem.value;
					if ( activeIndex > d.activeIndex+1) _swapActiveUIDisplays(activeUIDisplay.get(d.activeIndex+1)); // swap to right
					if ( activeIndex < d.activeIndex) _swapActiveUIDisplays(d); // swap to left
				}
			}
		}
		
		inline function _swapActiveUIDisplays(display:PeoteUIDisplay) 
		{
			activeUIDisplay.set(activeIndex, display);
			activeUIDisplay.set(display.activeIndex, this);				
			var tmp = activeIndex;
			activeIndex = display.activeIndex;
			display.activeIndex = tmp;
		}
		
		inline function addToActiveUIDisplay(?atDisplay:Display, addBefore:Bool=false)
		{
			if (addBefore && (atDisplay == null || atDisplay == peoteView.displayList.first.value)) {
				activeIndex = maxActiveIndex;
			}
			else {
				var displayListItem:RenderListItem<Display> = peoteView.displayList.first;
				var toItem:RenderListItem<Display> = peoteView.displayList.itemMap.get(this);
				var i = maxActiveIndex;
				while (displayListItem != toItem)
				{
					if ( Std.isOfType(displayListItem.value, PeoteUIDisplay) ) { //TODO: check for older haxe-version and Std.is() instead
						var d:PeoteUIDisplay = cast displayListItem.value;
						i = d.activeIndex; 
						d.activeIndex = d.activeIndex+1;
						activeUIDisplay.set(d.activeIndex, d);
					}
					displayListItem = displayListItem.next;
				}
				activeIndex = i;
			}		
			maxActiveIndex++;
			activeUIDisplay.set(activeIndex, this);
		}
		
		inline function removeFromActiveUIDisplay()
		{
			for (i in activeIndex + 1...maxActiveIndex) {
				var d:PeoteUIDisplay = activeUIDisplay.get(i);
				d.activeIndex = i - 1;
				activeUIDisplay.set(d.activeIndex, d);
			}
			maxActiveIndex--;
		}
		
		static var draggingMouseDisplays:Array<PeoteUIDisplay> = new Array<PeoteUIDisplay>();
		static var draggingTouchDisplays:Array<PeoteUIDisplay> = new Array<PeoteUIDisplay>();
		
		public function startDragging(e:PointerEvent) {
			dragOriginX = Std.int(e.x / peoteView.xz / xz) - x;
			dragOriginY = Std.int(e.y / peoteView.yz / yz) - y;
			
			switch (e.type) {
				case MOUSE: 
					if (draggingMouseButton == 0) draggingMouseDisplays.push(this);
					draggingMouseButton = draggingMouseButton | (1 << e.mouseButton);
				case TOUCH: 
					if (draggingTouchID == 0)  draggingTouchDisplays.push(this);
					draggingTouchID = draggingTouchID | (1 << e.touch.id);
				case PEN: // TODO!
			}
		}
		
		public function stopDragging(e:PointerEvent) {
			if (isDragging) {
				switch (e.type) {
					case MOUSE:
						if (draggingMouseButton & (1 << e.mouseButton) > 0) draggingMouseButton -= (1 << e.mouseButton);
						if (draggingMouseButton == 0) {
							draggingMouseDisplays.remove(this);
							mouseMoveActive(e.x, e.y);
						}
					
					case TOUCH:
						if (draggingTouchID & (1 << e.touch.id) > 0) draggingTouchID -= (1 << e.touch.id);
						if (draggingTouchID == 0) {
							draggingTouchDisplays.remove(this);
							touchMoveActive(e.touch);
						}
					
					case PEN: // TODO!
				}
			}
		}
		
		static public inline function mouseMoveActive(mouseX:Float, mouseY:Float)
		{
			var checkForEvent:Int = HAS_OVEROUT_MOVE;
			if (draggingMouseDisplays.length > 0) { // Dragging
				for (d in draggingMouseDisplays) if (d.mouseEnabled) d.dragTo(mouseX, mouseY);
			}
			else for (i in 0...maxActiveIndex) {
				checkForEvent = activeUIDisplay.get(i).mouseMove(mouseX, mouseY, checkForEvent);
				//if (i==0 && ( (checkForEvent & HAS_OVEROUT) >0)) trace("bubble OVER OUT");
				//if (i==0 && ( (checkForEvent & HAS_MOVE) >0)) trace("bubble MOVE");
			}
		}
		static public inline function mouseDownActive(mouseX:Float, mouseY:Float, button:MouseButton) for (i in 0...maxActiveIndex) if (activeUIDisplay.get(i).mouseDown(mouseX, mouseY, button)) break;
		static public inline function mouseUpActive(mouseX:Float, mouseY:Float, button:MouseButton) for (i in 0...maxActiveIndex) activeUIDisplay.get(i).mouseUp(mouseX, mouseY, button);
		static public inline function mouseWheelActive(dx:Float, dy:Float, mode:MouseWheelMode) for (i in 0...maxActiveIndex) activeUIDisplay.get(i).mouseWheel(dx, dy, mode);
		
		static public inline function touchMoveActive(touch:Touch) {
			var checkForEvent:Int = HAS_OVEROUT_MOVE;
			if (draggingTouchDisplays.length > 0) { // touch Dragging			
				for (d in draggingTouchDisplays) if (d.touchEnabled && (d.isTouchDown & (1 << touch.id)) > 0) d.dragToTouch(touch); // TODO: store touch-point inside Display
			}	
			else for (i in 0...maxActiveIndex) checkForEvent = activeUIDisplay.get(i).touchMove(touch, checkForEvent);
		}
		static public inline function touchStartActive(touch:Touch) for (i in 0...maxActiveIndex) if (activeUIDisplay.get(i).touchStart(touch)) break;
		static public inline function touchEndActive(touch:Touch) for (i in 0...maxActiveIndex) activeUIDisplay.get(i).touchEnd(touch);
		static public inline function touchCancelActive(touch:Touch) for (i in 0...maxActiveIndex) activeUIDisplay.get(i).touchCancel(touch);
		
		static public inline function keyDownActive(keyCode:KeyCode, modifier:KeyModifier) for (i in 0...maxActiveIndex) activeUIDisplay.get(i).keyDown(keyCode, modifier);
		static public inline function keyUpActive(keyCode:KeyCode, modifier:KeyModifier) for (i in 0...maxActiveIndex) activeUIDisplay.get(i).keyUp(keyCode, modifier);
		static public inline function textInputActive(text:String) if (inputFocusUIDisplay != null) inputFocusUIDisplay.textInput(text);

		static public inline function windowLeaveActive() for (i in 0...maxActiveIndex) activeUIDisplay.get(i).windowLeave();
	#end

	// -------- register Events from Lime Application ----------
	
	public static function registerEvents(window:Window) {
		
		window.textInputEnabled = true; // this is disabled on default for html5

		
		window.onMouseUp.add(mouseUpActive);
		window.onMouseDown.add(mouseDownActive);
		window.onMouseWheel.add(mouseWheelActive);
		
		Touch.onStart.add(touchStartActive);
		Touch.onMove.add(touchMoveActive);
		Touch.onEnd.add(touchEndActive);
		Touch.onCancel.add(touchCancelActive);

		#if html5
		window.onMouseMove.add(mouseMoveActive);
		window.onLeave.add(windowLeaveActive);
		window.onActivate.add(_windowActivateHackFocus);
		#else
		window.onRender.add(_mouseMoveFrameSynced);
		window.onMouseMove.add(_mouseMove);
		window.onLeave.add(_windowLeave);
		#end
		
		// keyboard & text
		window.onKeyDown.add(keyDownActive);
		window.onKeyUp.add(keyUpActive);
		window.onTextInput.add(textInputActive);
		
	}
	
	#if html5
		@:access(lime._internal.backend.html5.HTML5Window)
		static inline function _windowActivateHackFocus() {
		//Timer.delay(function() {
			lime._internal.backend.html5.HTML5Window.textInput.focus();
		//}, 200);
		}
	#else
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

	public static function unRegisterEvents(window:Window) {
		
		window.onMouseUp.remove(mouseUpActive);
		window.onMouseDown.remove(mouseDownActive);
		window.onMouseWheel.remove(mouseWheelActive);
		
		Touch.onStart.remove(touchStartActive);
		Touch.onMove.remove(touchMoveActive);
		Touch.onEnd.remove(touchEndActive);
		Touch.onCancel.remove(touchCancelActive);

		#if html5
		window.onMouseMove.remove(mouseMoveActive);
		window.onLeave.remove(windowLeaveActive);
		#else
		window.onRender.remove(_mouseMoveFrameSynced);
		window.onMouseMove.remove(_mouseMove);
		window.onLeave.remove(_windowLeave);
		#end
		
		// keyboard & text
		window.onKeyDown.remove(keyDownActive);
		window.onKeyUp.remove(keyUpActive);
		window.onTextInput.remove(textInputActive);		
	}
	
	// ----------------------------------------------------------------------------
	
	#if peote_layout // ----------- Interface for peote-layout --------------------

	public inline function showByLayout() show();
	public inline function hideByLayout() hide();
	
	public function updateByLayout(layoutContainer:peote.layout.LayoutContainer) {
		// TODO: layoutContainer.updateMask() from here to make it only on-need
		
		if (isVisible)
		{
			if (layoutContainer.isHidden) // if it is full outside of the Mask (so invisible)
			{
				#if peotelayout_debug
				//trace("removed", layoutContainer.layout.name);
				#end
				hide();
			}
			else _update(layoutContainer);
		}
		else if (!layoutContainer.isHidden) // not full outside of the Mask anymore
		{
			#if peotelayout_debug
			//trace("showed", layoutContainer.layout.name);
			#end
			_update(layoutContainer);
			show();
		}		
	}	

	inline function _update(layoutContainer:peote.layout.LayoutContainer) {
		x = Math.round(layoutContainer.x);
		y = Math.round(layoutContainer.y);
		
		if (layoutContainer.isMasked) { // if some of the edges is cut by mask for scroll-area
			x += Math.round(layoutContainer.maskX);
			y += Math.round(layoutContainer.maskY);
			width = Math.round(layoutContainer.maskWidth);
			height = Math.round(layoutContainer.maskHeight);
		}
		else {
			width = Math.round(layoutContainer.width);
			height = Math.round(layoutContainer.height);
		}
	}
	#end			

}


