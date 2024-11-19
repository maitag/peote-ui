package peote.ui.interactive;

import peote.view.Element;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;
import peote.ui.PeoteUIDisplay;
import peote.ui.interactive.interfaces.ParentElement;
import peote.ui.config.Space;

class Pickable implements Element
{
	public var uiElement:Interactive;
	
	@posX public var x:Int=0;
	@posY public var y:Int=0;	
	@sizeX public var w:Int=100;
	@sizeY public var h:Int=100;
	@zIndex public var z:Int = 0;
	
	var OPTIONS = { picking: true };
	
	public function new( uiElement:Interactive )
	{
		this.uiElement = uiElement;
		update(uiElement);
	}

	public inline function update( uiElement:Interactive ):Void
	{
		this.uiElement = uiElement;
		z = uiElement.z;

		#if (peoteui_no_masking)
		x = uiElement.x;
		y = uiElement.y;
		w = uiElement.width;
		h = uiElement.height;
		#else
		if (uiElement.masked) { // if some of the edges is cut by mask for scroll-area
			x = uiElement.x + uiElement.maskX;
			y = uiElement.y + uiElement.maskY;
			w = uiElement.maskWidth;
			h = uiElement.maskHeight;
		} else {
			x = uiElement.x;
			y = uiElement.y;
			w = uiElement.width;
			h = uiElement.height;
		}
		#end
		
	}
}

// ---------------------------------------------------------------
private
#if (haxe_ver >= 4.0) enum #else @:enum#end
abstract UIEventMove(Int) from Int to Int {

	public static inline var over :Int = 1;
	public static inline var out  :Int = 2;
	public static inline var move :Int = 4;
	public static inline var wheel:Int = 8;
}

private 
#if (haxe_ver >= 4.0) enum #else @:enum#end
abstract UIEventClick(Int) from Int to Int {

	public static inline var down :Int = 1;
	public static inline var up   :Int = 2;
	public static inline var click:Int = 4;
}

// ---------------------------------------------------------------
// ---------------------------------------------------------------
// ---------------------------------------------------------------

@:allow(peote.ui)
class Interactive
#if peote-layout
implements peote.layout.ILayoutElement
#end
{
	// ---------------------------------------------------------	
	public var uiDisplay(default, null):PeoteUIDisplay = null;
	public var isVisible(default, null):Bool = false;

	var pickableMove:Pickable = null;
	var pickableClick:Pickable = null;
	
	public var overOutEventsBubbleToDisplay:Bool = true;
	public var overOutEventsBubbleTo:Interactive = null;
	public function intoOverOutEventBubbleOf(e:Interactive):Bool {
		while (e.overOutEventsBubbleTo != null) {
			if (e.overOutEventsBubbleTo == this) return true;
			e = e.overOutEventsBubbleTo;
		}
		return false;
	}
	
	public var moveEventsBubbleToDisplay:Bool = false;
	public var moveEventsBubbleTo:Interactive = null;
/*	public function intoMoveEventBubbleOf(e:InteractiveElement):Bool {
		while (e.moveEventsBubbleTo != null) {
			if (e.moveEventsBubbleTo == this) return true;
			e = e.moveEventsBubbleTo;
		}
		return false;
	}
*/	
	public var upDownEventsBubbleToDisplay:Bool = false;
	public var upDownEventsBubbleTo:Interactive = null;
	public function intoUpDownEventBubbleOf(e:Interactive):Bool {
		while (e.upDownEventsBubbleTo != null) {
			if (e.upDownEventsBubbleTo == this) return true;
			e = e.upDownEventsBubbleTo;
		}
		return false;
	}
	
	public var wheelEventsBubbleToDisplay:Bool = false;
	public var wheelEventsBubbleTo:Interactive = null;
/*	public function intoWheelEventBubbleOf(e:InteractiveElement):Bool {
		while (e.wheelEventsBubbleTo != null) {
			if (e.wheelEventsBubbleTo == this) return true;
			e = e.wheelEventsBubbleTo;
		}
		return false;
	}
*/	
	
	public inline function setParentPosOffset(p:ParentElement) {
		x += p.x + p.xOffset;
		y += p.y + p.yOffset;
		z += p.z + 1;
	}
	
	public inline function removeParentPosOffset(p:ParentElement) {
		x -= p.x + p.xOffset;
		y -= p.y + p.yOffset;
		z -= p.z + 1;
	}
	
	public inline function setParentPos(p:ParentElement) {
		x += p.x;
		y += p.y;
		z += p.z + 1;
	}
	
	public inline function removeParentPos(p:ParentElement) {
		x -= p.x ;
		y -= p.y;
		z -= p.z + 1;
	}
	
	
	public var x:Int;
	public var y:Int;
	
	public var z(default, set):Int;
	inline function set_z(v:Int):Int {
		if (v != z) {
			if (changeZIndex != null) {
				var oldZ = z;
				changeZIndex(z = v, v - oldZ);
			} else z = v;
		}
		return v;
	}
	var changeZIndex:Int->Int->Void = null;

/*	
	public var width(default, set):Int;
	inline function set_width(w:Int):Int {
		if (w != width) {
			if (resizeWidth != null) {
				var oldWidth = width;
				resizeWidth(width = w, w - oldWidth);
			} else width = w;
		}
		return w;
	}

	public var height(default, set):Int;
	inline function set_height(h:Int):Int {
		if (h != height) {
			if (resizeHeight != null) {
				var oldHeight = height;
				resizeHeight(height = h, h - oldHeight);
			} else height = h;
		}
		return h;
	}
*/	
	public var width(default, set):Int;
	inline function set_width(w:Int):Int {
		if (w != width) {
			var delta = w - width;
			width = w;
			resizeWidth(delta);
		}
		return w;
	}

	public var height(default, set):Int;
	inline function set_height(h:Int):Int {
		if (h != height) {
			var delta = h - height;
			height = h; 
			resizeHeight(delta);
		}
		return h;
	}
	
	// get position by side
	public var left(get, set):Int;
	inline function get_left():Int return x;
	inline function set_left(v:Int):Int return x = v;
	
	public var top(get, set):Int;
	inline function get_top():Int return y;
	inline function set_top(v:Int):Int return y = v;
		
	public var right(get, set):Int;
	inline function get_right():Int return x + width;
	inline function set_right(v:Int):Int { x = v - width; return v; }
	
	public var bottom(get, set):Int;
	inline function get_bottom():Int return y + height;
	inline function set_bottom(v:Int):Int { y = v - height; return v; }
	
	// all setters here will also changing the size to keep the opposite sideposition
	public var leftSize(never, set):Int;
	inline function set_leftSize(v:Int):Int { width = right - v; return x = v; }
	
	public var topSize(never, set):Int;
	inline function set_topSize(v:Int):Int { height = bottom - v; return y = v; }
		
	public var rightSize(never, set):Int;
	inline function set_rightSize(v:Int):Int { width = v - x; return v; }
	
	public var bottomSize(never, set):Int;
	inline function set_bottomSize(v:Int):Int { height = v - y; return v; }
	
	
	
	#if (!peoteui_no_masking)
	public var masked:Bool = false;
	public var maskX:Int = 0;
	public var maskY:Int = 0;
	public var maskWidth:Int;
	public var maskHeight:Int;
	#end
	
	
	// Pointer and MouseWheel events
	public var pointerOver :PointerEvent->Void;
	var pointerOut  :PointerEvent->Void;
	var pointerMove :PointerEvent->Void;
	var mouseWheel  :WheelEvent->Void;
	
	var hasMoveEvent:Int = 0;

	public var hasPointerOver(get, never):Bool;
	public var hasPointerOut (get, never):Bool;
	public var hasPointerMove(get, never):Bool;
	public var hasMouseWheel (get, never):Bool;
	inline function get_hasPointerOver():Bool return (hasMoveEvent & UIEventMove.over > 0);
	inline function get_hasPointerOut ():Bool return (hasMoveEvent & UIEventMove.out  > 0);
	inline function get_hasPointerMove():Bool return (hasMoveEvent & UIEventMove.move > 0);
	inline function get_hasMouseWheel ():Bool return (hasMoveEvent & UIEventMove.wheel > 0);
	
	public var hasOverOutMoveWheel (get, never):Bool;
	inline function get_hasOverOutMoveWheel():Bool return (hasMoveEvent > 0);
	
	var pointerUp   :PointerEvent->Void;
	var pointerDown :PointerEvent->Void;
	var pointerClick:PointerEvent->Void;
	var hasClickEvent:Int = 0;
	
	static inline function noOperation(e:PointerEvent):Void {}
	static inline function noWheelOperation(e:WheelEvent):Void {}
	
	// drag and focus events
	var drag:Float->Float->Void = null;
	var focus:Void->Void = null;

	public function new(xPosition:Int, yPosition:Int, width:Int, height:Int, zIndex:Int)
	{
		x = xPosition;
		y = yPosition;
		
		this.width  = width;
		this.height = height;
		
		#if (!peoteui_no_masking)
		maskWidth  = width;
		maskHeight = height;
		#end
		z = zIndex;
				
		pointerOver  = noOperation;
		pointerOut   = noOperation;
		pointerMove  = noOperation;
		mouseWheel = noWheelOperation;
		
		pointerDown  = noOperation;
		pointerUp    = noOperation;
		pointerClick = noOperation;
	}
	
	
	public function updateStyle():Void
	{
		updateVisibleStyle(); // hook to childclass
	}
	
	public function updateLayout():Void
	{
		updateVisibleLayout(); // hook to childclass
		updatePickable();
	}
	
	public function update():Void
	{
		updateVisible(); // hook to childclass
		updatePickable();
	}
	
	// TODO: rename all hooks into: updateInteractive... 
	function updateVisibleStyle():Void {} // to override by childclasses
	function updateVisibleLayout():Void {} // to override by childclasses
	function updateVisible():Void {} // to override by childclasses	
	
	inline function updatePickable():Void
	{
		if ( hasMoveEvent != 0 ) {
			pickableMove.update(this);
			if (isVisible) uiDisplay.movePickBuffer.updateElement( pickableMove );
		}
		if ( hasClickEvent != 0 ) {
			pickableClick.update(this);
			if (isVisible) uiDisplay.clickPickBuffer.updateElement( pickableClick );
		}
	}
	
	// -----------------
	
	inline function onAddToDisplay(uiDisplay:PeoteUIDisplay)
	{
		this.uiDisplay = uiDisplay;
		isVisible = true;
		onAddVisibleToDisplay(); // hook to childclass
		if ( hasMoveEvent  != 0 ) addPickableMove();	
		if ( hasClickEvent != 0 ) addPickableClick();
	}
	
	function onAddVisibleToDisplay():Void {} // to override by childclasses
	
	// -----------------
	
	inline function onRemoveFromDisplay(uiDisplay:PeoteUIDisplay)
	{		
		if (uiDisplay != this.uiDisplay) throw('Error, $this is not inside uiDisplay: $uiDisplay');
		onRemoveVisibleFromDisplay(); // hook to childclass
		if ( hasMoveEvent  != 0 ) removePickableMove();
		if ( hasClickEvent != 0 ) removePickableClick();		
		isVisible = false;
	}
	
	function onRemoveVisibleFromDisplay():Void {} // to override by childclasses
	
	// -----------------

	public function show():Void {
		if (!isVisible && uiDisplay != null) {
			uiDisplay.add(this);
			isVisible = true; // TODO: is this need here?
		} 
	}
	
	public function hide():Void {
		if (isVisible) {
			uiDisplay.remove(this);
			isVisible = false; // TODO: is this need here?
		}		
	}
	
	
	// ----------------- Dragging ----------------------------
	
	var dragMinX:Int = -0x7fff;
	var dragMinY:Int = -0x7fff;
	var dragMaxX:Int = 0x7fff;
	var dragMaxY:Int = 0x7fff;
	
	public var isDragging(default, null):Bool = false;
	
	var dragOriginX:Int = 0;
	var dragOriginY:Int = 0;
	
	public inline function setDragArea(dragAreaX:Int, dragAreaY:Int, dragAreaWidth:Int, dragAreaHeight:Int) 
	{
		dragMinX = dragAreaX;
		dragMinY = dragAreaY;
		dragMaxX = dragAreaX + dragAreaWidth;
		dragMaxY = dragAreaY + dragAreaHeight;
	}
	
	inline function dragTo(dragToX:Int, dragToY:Int):Void
	{
		dragToX = Std.int(dragToX / uiDisplay.peoteView.xz / uiDisplay.xz);
		dragToY = Std.int(dragToY / uiDisplay.peoteView.yz / uiDisplay.yz);
		
		if (dragToX >= (dragMinX + dragOriginX)) {
			if (dragToX < (dragMaxX - width + dragOriginX)) x = dragToX - dragOriginX;
			else x = dragMaxX - width;
		} else x = dragMinX;
		
		if (dragToY >= dragMinY + dragOriginY) {
			if (dragToY < dragMaxY - height + dragOriginY) y = dragToY - dragOriginY;
			else y = dragMaxY - height;
		} else y = dragMinY;
		
		// call the drag-event
		if (drag != null) {
			//drag((x - dragMinX) / (dragMaxX - dragMinX - width), (y - dragMinY) / (dragMaxY - dragMinY - height));
			var _dx = (dragMaxX - dragMinX - width);
			var _dy = (dragMaxY - dragMinY - height);
			drag( ( _dx != 0) ? (x - dragMinX) / _dx : 0.0,  ( _dy != 0) ? (y - dragMinY) / _dy : 0.0);
		}
	}

	public function startDragging(e:PointerEvent)
	{
		if (isVisible) {
			dragOriginX = Std.int(e.x / uiDisplay.peoteView.xz / uiDisplay.xz) - x;
			dragOriginY = Std.int(e.y / uiDisplay.peoteView.yz / uiDisplay.yz) - y;
			uiDisplay.startDraggingElement(this, e);
		}
	}
	
	public function stopDragging(e:PointerEvent)
	{
		if (isVisible) uiDisplay.stopDraggingElement(this, e);
	}
	
	// ----------------- Helpers -----------------------------
	public inline function localX(globalX:Float):Float {
		if (uiDisplay == null) throw("Error, ui-element has to add to an UIDisplay instance first");
		return uiDisplay.localX(globalX) - x;
	}
	
	public inline function localY(globalY:Float):Float {
		if (uiDisplay == null) throw("Error, ui-element has to add to an UIDisplay instance first");
		return uiDisplay.localY(globalY) - y;
	}
	
	public inline function pointIsInside(x:Float, y:Float):Bool {
		return (this.x <= x && x < this.x + width) && (this.y <= y && y < this.y + height);
	}
	
	// ----------------- Event-Bindings ----------------------

	private inline function setOnPointerOver<T>(object:T, f:T->PointerEvent->Void):T->PointerEvent->Void {
		rebindPointerOver(f.bind(object), f == null);
		return f;
	}
		
	private inline function rebindPointerOver(newBinding:PointerEvent->Void, isNull:Bool):Void {
		if ( !isNull ) {
			pointerOver = newBinding;
			if ( hasMoveEvent == 0 ) addPickableMove();
			hasMoveEvent |= UIEventMove.over;
		}
		else if (hasMoveEvent & UIEventMove.over > 0) {
			hasMoveEvent &= ~UIEventMove.over;
			if ( hasMoveEvent == 0 ) removePickableMove();
			pointerOver = noOperation;
		}
	}

	private inline function setOnPointerOut<T>(object:T, f:T->PointerEvent->Void):T->PointerEvent->Void {
		rebindPointerOut(f.bind(object), f == null);
		return f;
	}
		
	private inline function rebindPointerOut(newBinding:PointerEvent->Void, isNull:Bool):Void {
		if ( !isNull ) {
			pointerOut = newBinding;
			if ( hasMoveEvent == 0 ) addPickableMove();
			hasMoveEvent |= UIEventMove.out;
		}
		else if (hasMoveEvent & UIEventMove.out > 0) {
			hasMoveEvent &= ~UIEventMove.out;
			if ( hasMoveEvent == 0 ) removePickableMove();
			pointerOut = noOperation;
		}
	}

	private inline function setOnPointerMove<T>(object:T, f:T->PointerEvent->Void):T->PointerEvent->Void {
		rebindPointerMove(f.bind(object), f == null);
		return f;
	}
		
	private inline function rebindPointerMove(newBinding:PointerEvent->Void, isNull:Bool):Void {
		if ( !isNull ) {
			pointerMove = newBinding;
			if ( hasMoveEvent == 0 ) addPickableMove();
			hasMoveEvent |= UIEventMove.move;
		}
		else if (hasMoveEvent & UIEventMove.move > 0) {
			hasMoveEvent &= ~UIEventMove.move;
			if ( hasMoveEvent == 0 ) removePickableMove();
			pointerMove = noOperation;
		}
	}

	private inline function setOnMouseWheel<T>(object:T, f:T->WheelEvent->Void):T->WheelEvent->Void {
		rebindMouseWheel(f.bind(object), f == null);
		return f;
	}
	
	private inline function rebindMouseWheel(newBinding:WheelEvent->Void, isNull:Bool):Void {
		if ( !isNull ) {
			mouseWheel = newBinding;
			if ( hasMoveEvent == 0 ) addPickableMove();
			hasMoveEvent |= UIEventMove.wheel;
		}
		else if (hasMoveEvent & UIEventMove.wheel > 0) {
			hasMoveEvent &= ~UIEventMove.wheel;
			if ( hasMoveEvent == 0 ) removePickableMove();
			mouseWheel = noWheelOperation;
		}
	}

	// -----------------

	private inline function setOnPointerUp<T>(object:T, f:T->PointerEvent->Void):T->PointerEvent->Void {
		rebindPointerUp(f.bind(object), f == null);
		return f;
	}
		
	private inline function rebindPointerUp(newBinding:PointerEvent->Void, isNull:Bool):Void {
		if ( !isNull ) {
			pointerUp = newBinding;
			if ( hasClickEvent == 0 ) addPickableClick();
			hasClickEvent |= UIEventClick.up;
		}
		else if (hasMoveEvent & UIEventClick.up > 0) {
			hasClickEvent &= ~UIEventClick.up;
			if ( hasClickEvent == 0 ) removePickableClick();
			pointerUp = noOperation;
		}
	}
	
	private inline function setOnPointerDown<T>(object:T, f:T->PointerEvent->Void):T->PointerEvent->Void {
		rebindPointerDown(f.bind(object), f == null);
		return f;
	}
		
	private inline function rebindPointerDown(newBinding:PointerEvent->Void, isNull:Bool):Void {
		if ( !isNull ) {
			pointerDown = newBinding;
			if ( hasClickEvent == 0 ) addPickableClick();
			hasClickEvent |= UIEventClick.down;
		}
		else if (hasMoveEvent & UIEventClick.down > 0) {
			hasClickEvent &= ~UIEventClick.down;
			if ( hasClickEvent == 0 ) removePickableClick();
			pointerDown = noOperation;
		}
	}
	
	private inline function setOnPointerClick<T>(object:T, f:T->PointerEvent->Void):T->PointerEvent->Void {
		rebindPointerClick(f.bind(object), f == null);
		return f;
	}
		
	private inline function rebindPointerClick(newBinding:PointerEvent->Void, isNull:Bool):Void {
		if ( !isNull ) {
			pointerClick = newBinding;
			if ( hasClickEvent == 0 ) addPickableClick();
			hasClickEvent |= UIEventClick.click;
		}
		else if (hasMoveEvent & UIEventClick.click > 0) {
			hasClickEvent &= ~UIEventClick.click;
			if ( hasClickEvent == 0 ) removePickableClick();
			pointerClick = noOperation;
		}
	}
	
	// -----------------
	
	private inline function setOnDrag<T>(object:T, f:T->Float->Float->Void):T->Float->Float->Void {
		if (f == null) drag = null else drag = f.bind(object);
		return f;
	}
	
	private inline function setOnFocus<T>(object:T, f:T->Void):T->Void {
		if (f == null) focus = null else focus = f.bind(object);
		return f;
	}
	/*
	// resize events
	var resizeWidth:Int->Int->Void = null;
	var resizeHeight:Int->Int->Void = null;

	private inline function setOnResizeWidth<T>(object:T, f:T->Int->Int->Void):T->Int->Int->Void {
		if (f == null) resizeWidth = null else resizeWidth = f.bind(object);
		return f;
	}
	
	private inline function setOnResizeHeight<T>(object:T, f:T->Int->Int->Void):T->Int->Int->Void {
		if (f == null) resizeHeight = null else resizeHeight = f.bind(object);
		return f;
	}
	*/
	// ------ custom and internal resize Events ---------------
	var _resizeWidthIntern:Int->Int->Void = null;
	var _resizeWidthSlider:Int->Int->Void = null;
	var _resizeWidth:Int->Int->Void = null;
	inline function resizeWidth(delta:Int):Void {
		if (_resizeWidthIntern != null) _resizeWidthIntern(width, delta);
		if (_resizeWidthSlider != null) _resizeWidthSlider(width, delta);
		if (_resizeWidth != null) _resizeWidth(width, delta);
	}

	private inline function setOnResizeWidthIntern<T>(object:T, f:T->Int->Int->Void):T->Int->Int->Void {
		if (f == null) _resizeWidthIntern = null else _resizeWidthIntern = f.bind(object);
		return f;
	}

	private inline function setOnResizeWidthSlider<T>(object:T, f:T->Int->Int->Void):T->Int->Int->Void {
		if (f == null) _resizeWidthSlider = null else _resizeWidthSlider = f.bind(object);
		return f;
	}

	private inline function setOnResizeWidth<T>(object:T, f:T->Int->Int->Void):T->Int->Int->Void {
		if (f == null) _resizeWidth = null else _resizeWidth = f.bind(object);
		return f;
	}
	
	var _resizeHeightIntern:Int->Int->Void = null;
	var _resizeHeightSlider:Int->Int->Void = null;
	var _resizeHeight:Int->Int->Void = null;
	inline function resizeHeight(delta:Int):Void {
		if (_resizeHeightIntern != null) _resizeHeightIntern(height, delta);
		if (_resizeHeightSlider != null) _resizeHeightSlider(height, delta);
		if (_resizeHeight != null) _resizeHeight(height, delta);
	}

	private inline function setOnResizeHeightIntern<T>(object:T, f:T->Int->Int->Void):T->Int->Int->Void {
		if (f == null) _resizeHeightIntern = null else _resizeHeightIntern = f.bind(object);
		return f;
	}

	private inline function setOnResizeHeightSlider<T>(object:T, f:T->Int->Int->Void):T->Int->Int->Void {
		if (f == null) _resizeHeightSlider = null else _resizeHeightSlider = f.bind(object);
		return f;
	}

	private inline function setOnResizeHeight<T>(object:T, f:T->Int->Int->Void):T->Int->Int->Void {
		if (f == null) _resizeHeight = null else _resizeHeight = f.bind(object);
		return f;
	}
	
	
	// -----------------
		
	private function addPickableMove()
	{
		//trace("addPickableMove");
		if (pickableMove==null) pickableMove = new Pickable(this);
		if (isVisible) uiDisplay.movePickBuffer.addElement( pickableMove );
	}
	
	private function removePickableMove()
	{
		//trace("removePickableMove");
		if (isVisible) {
			var index = uiDisplay.movePickBuffer.getElementIndex(pickableMove);
			// if not the last one into buffer
			if (index < uiDisplay.movePickBuffer.length - 1) {
				if ( uiDisplay.mouseEnabled && uiDisplay.lastMouseOverIndex == uiDisplay.movePickBuffer.length - 1)
						uiDisplay.lastMouseOverIndex = index;
				if (uiDisplay.touchEnabled) {
					for (i in 0...uiDisplay.lastTouchOverIndex.length) {
						if ( uiDisplay.lastTouchOverIndex.get(i) == uiDisplay.movePickBuffer.length - 1)
							uiDisplay.lastTouchOverIndex.set(i, index);
					}
				}
			}
			uiDisplay.movePickBuffer.removeElement( pickableMove );  //pickableOver=null
		}
	}
	
	private function addPickableClick()
	{
		//trace("addPickableClick");
		if (pickableClick == null) pickableClick = new Pickable(this);		
		if (isVisible) uiDisplay.clickPickBuffer.addElement( pickableClick );
	}
	
	private function removePickableClick()
	{
		//trace("removePickableClick");
		if (isVisible) {
			var index = uiDisplay.clickPickBuffer.getElementIndex(pickableClick);
			// if not the last one into buffer
			if (index < uiDisplay.clickPickBuffer.length - 1) {
				if (uiDisplay.mouseEnabled) {
					for (i in 0...uiDisplay.lastMouseDownIndex.length) {
						if ( uiDisplay.lastMouseDownIndex.get(i) == uiDisplay.clickPickBuffer.length - 1)
							uiDisplay.lastMouseDownIndex.set(i, index);
					}
				}
				if (uiDisplay.touchEnabled) {
					for (i in 0...uiDisplay.lastTouchDownIndex.length) {
						if ( uiDisplay.lastTouchDownIndex.get(i) == uiDisplay.clickPickBuffer.length - 1)
							uiDisplay.lastTouchDownIndex.set(i, index);
					}
				}
			}
			uiDisplay.clickPickBuffer.removeElement( pickableClick ); //pickableClick=null
		}
	}
	
	// -----------------------------------------------------------------
	
	public inline function maskByElement(uiElement:Interactive, maskOnDrag:Bool = false, maskSpace:Space = null)
	{
		#if (!peoteui_no_parentmasking)
		if (maskOnDrag || !isDragging) {
			if (maskSpace != null) _maskByElement(uiElement, maskSpace.left, maskSpace.right, maskSpace.top, maskSpace.bottom);
			else _maskByElement(uiElement, 0, 0, 0, 0);
		}
		#end
	}
	
	inline function _maskByElement(uiElement:Interactive, leftOffset:Int, rightOffset:Int, topOffset:Int, bottomOffset:Int)
	{
		#if (!peoteui_no_masking)
		masked = if (uiElement.masked) 
			mask(uiElement.x + uiElement.maskX + leftOffset, uiElement.y + uiElement.maskY + topOffset, uiElement.maskWidth - leftOffset - rightOffset, uiElement.maskHeight - topOffset - bottomOffset, uiElement.isVisible);
		else mask(uiElement.x + leftOffset, uiElement.y + topOffset, uiElement.width - leftOffset - rightOffset, uiElement.height - topOffset - bottomOffset, uiElement.isVisible);
		#else
		if (uiElement.isVisible && isOutsideOf(uiElement.x + leftOffset, uiElement.y + topOffset, uiElement.width - leftOffset - rightOffset, uiElement.height - topOffset - bottomOffset)) 
			hide();
		else if (uiElement.isVisible) show();
		#end
	}
	
	inline function isOutsideOf(_x:Int, _y:Int, _width:Int, _height:Int) {
		return (right <= _x || x >= _x + _width || bottom <= _y || y >= _y + _height);
	}
	
	#if (!peoteui_no_masking)
	inline function mask(_x:Int, _y:Int, _width:Int, _height:Int, _isVisible:Bool):Bool
	{
		if (x < _x) {
			if (right <= _x) { maskWidth = 0; if (_isVisible && isVisible) uiDisplay.remove(this); return false;}
			else {
				maskX = _x - x;
				if (right >= _x + _width) maskWidth = _width;
				else maskWidth = width - maskX;
				return _maskElementY(_y, _height, true, _isVisible);
			}
		} 
		else if (right > _x + _width) {
			if (x >= _x + _width) { maskWidth = 0; if (_isVisible && isVisible) uiDisplay.remove(this); return false;}
			else {
				maskX = 0;
				maskWidth = width - (right - (_x + _width));
				return _maskElementY(_y, _height, true, _isVisible);
			}
		}
		else {
			maskX = 0;
			maskWidth = width;
			return _maskElementY(_y, _height, false, _isVisible);
		}
	}
	
	inline function _maskElementY(_y:Int, _height:Int, xMasked, _isVisible:Bool):Bool
	{
		if (y < _y) {
			if (bottom <= _y) { maskHeight = 0; if (_isVisible && isVisible) uiDisplay.remove(this); return false; }
			else {
				maskY = _y - y;
				if (bottom >= _y + _height) maskHeight = _height;
				else maskHeight = height - maskY;
				if (_isVisible && !isVisible) uiDisplay.add(this);
				return true;
			}
		} 
		else if (bottom > _y + _height) {
			if (y >= _y + _height)  { maskHeight = 0; if (_isVisible && isVisible) uiDisplay.remove(this); return false; }
			else {
				maskY = 0;
				maskHeight = height - (bottom - (_y + _height));
				if (_isVisible && !isVisible) uiDisplay.add(this);
				return true;
			}
		}
		else {
			maskY = 0;
			maskHeight = height;
			if (_isVisible && !isVisible) uiDisplay.add(this);
			return xMasked;
		}
	}
	#end
		
	
	#if peote_layout
	// ----------- Interface for peote-layout --------------------

	public inline function showByLayout():Void show();
	public inline function hideByLayout():Void hide();

	public inline function updateByLayout(layoutContainer:peote.layout.LayoutContainer) {
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
			else {
				_updateByLayout(layoutContainer);
			}
		}
		else if (!layoutContainer.isHidden) // not full outside of the Mask anymore
		{
			#if peotelayout_debug
			//trace("showed", layoutContainer.layout.name);
			#end
			_updateByLayout(layoutContainer);
			show();
		}		
	}
	
	public inline function _updateByLayout(layoutContainer:peote.layout.LayoutContainer) {
		x = Math.round(layoutContainer.x);
		y = Math.round(layoutContainer.y);
		z = Math.round(layoutContainer.depth);
		width = Math.round(layoutContainer.width);
		height = Math.round(layoutContainer.height);
		
		#if (!peoteui_no_textmasking && !peoteui_no_masking)
		if (layoutContainer.isMasked) { // if some of the edges is cut by mask for scroll-area
			maskX = Math.round(layoutContainer.maskX);
			maskY = Math.round(layoutContainer.maskY);
			maskWidth  = Math.round(layoutContainer.maskWidth);
			maskHeight = Math.round(layoutContainer.maskHeight);
		}
		masked = layoutContainer.isMasked;
		#end
		
		updateLayout();
	}
	
	#end			
}