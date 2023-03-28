package peote.ui.interactive;

import peote.ui.interactive.Interactive;
import peote.ui.interactive.UIElement;
import peote.ui.interactive.interfaces.ParentElement;
import peote.ui.style.interfaces.Style;

//import peote.ui.event.PointerEvent;
//import peote.ui.event.WheelEvent;

@:allow(peote.ui)
class UIArea extends UIElement implements ParentElement
#if peote_layout
implements peote.layout.ILayoutElement
#end
{
	var childs = new Array<Interactive>();

	var last_x:Int;
	var last_y:Int;
	
	public var xOffset:Int = 0;
	public var yOffset:Int = 0;
	
	public var xOffsetStart(get, never):Int;
	inline function get_xOffsetStart():Int return -innerLeft;
	public var xOffsetEnd(get, never):Int;
	inline function get_xOffsetEnd():Int {
		return (innerRight - width < innerLeft) ? -innerLeft : width - innerRight;
	}

	public var yOffsetStart(get, never):Int;
	inline function get_yOffsetStart():Int return -innerTop;
	public var yOffsetEnd(get, never):Int;
	inline function get_yOffsetEnd():Int {
		return (innerBottom - height < innerTop) ? -innerTop : height - innerBottom;
	}
	
	public var innerLeft(default, null):Int = 0;
	public var innerRight(default, null):Int = 0;
	public var innerWidth(get, never):Int;
	inline function get_innerWidth():Int return innerRight - innerLeft;
			
	public var innerTop(default, null):Int = 0;
	public var innerBottom(default, null):Int = 0;
	public var innerHeight(get, never):Int;
	inline function get_innerHeight():Int return innerBottom - innerTop;
			
	public function new(xPosition:Int=0, yPosition:Int=0, width:Int=100, height:Int=100, zIndex:Int=0, backgroundStyle:Style=null) 
	{
		super(xPosition, yPosition, width, height, zIndex, backgroundStyle);
		
		last_x = xPosition;
		last_y = yPosition;
	}
	
	public function add(child:Interactive)
	{
		var resizeWidth = false;
		var resizeHeight = false;
		var old_innerWidth = innerWidth;
		var old_innerHeight = innerHeight;
		
		if (childs.length == 0) {
			if (innerLeft   != child.left  ) { innerLeft   = child.left;   resizeWidth  = true; }
			if (innerRight  != child.right ) { innerRight  = child.right;  resizeWidth  = true; }
			if (innerTop    != child.top   ) { innerTop    = child.top;    resizeHeight = true; }
			if (innerBottom != child.bottom) { innerBottom = child.bottom; resizeHeight = true; }
		} else {
			if (child.left   < innerLeft  )  { innerLeft   = child.left;   resizeWidth  = true; }
			if (child.right  > innerRight )  { innerRight  = child.right;  resizeWidth  = true; }
			if (child.top    < innerTop   )  { innerTop    = child.top;    resizeHeight = true; }
			if (child.bottom > innerBottom)  { innerBottom = child.bottom; resizeHeight = true; }
		}
		
			if (resizeWidth && _onResizeInnerWidth != null) _onResizeInnerWidth (this, innerWidth, innerWidth - old_innerWidth);
			if (resizeHeight && _onResizeInnerHeight != null) _onResizeInnerHeight(this, innerHeight, innerHeight - old_innerHeight);
			if (resizeWidth && onResizeInnerWidth != null) onResizeInnerWidth (this, innerWidth, innerWidth - old_innerWidth);
			if (resizeHeight && onResizeInnerHeight != null) onResizeInnerHeight(this, innerHeight, innerHeight - old_innerHeight);
		
		childs.push(child);
		
		// to bubble events down to the elements
		child.overOutEventsBubbleTo = this;
		child.upDownEventsBubbleTo = this;
		child.wheelEventsBubbleTo = this;
		
		child.setParentPosOffset(this);
		
		if (isVisible) {
			uiDisplay.add(child);
			child.maskByElement(this);
			child.updateLayout(); // need if the child is a parent itself
		}
		
	}
	
	public function remove(child:Interactive) 
	{
		if (isVisible) uiDisplay.remove(child);
		childs.remove(child);
		
		if (child.left - x - xOffset >= innerLeft || child.right - x - xOffset >= innerRight || 
			child.top - y - yOffset >= innerTop || child.bottom - y - yOffset >= innerBottom) updateInnerSize();
		
		child.removeParentPosOffset(this);
	}
	
	// ---------------------------------------
	public function updateInnerSize() 
	{
		var old_innerLeft = innerLeft;
		var old_innerRight = innerRight;
		var old_innerTop = innerTop;
		var old_innerBottom = innerBottom;
		if (childs.length == 0) {
			innerLeft = 0;
			innerRight = 0;
			innerTop = 0;
			innerBottom = 0;
		}
		else {
			innerLeft = childs[0].left - x - xOffset;
			innerRight = childs[0].right - x - xOffset;
			innerTop = childs[0].top - y - yOffset;
			innerBottom = childs[0].bottom - y - yOffset;
			var child:Interactive;
			for (i in 1...childs.length) {
				child = childs[i];
				if (child.left   - x - xOffset < innerLeft  ) innerLeft   = child.left   - x - xOffset;
				if (child.right  - x - xOffset > innerRight ) innerRight  = child.right  - x - xOffset;
				if (child.top    - y - yOffset < innerTop   ) innerTop    = child.top    - y - yOffset;
				if (child.bottom - y - yOffset > innerBottom) innerBottom = child.bottom - y - yOffset;
			}
		}

		if (_onResizeInnerWidth  != null && (old_innerLeft != innerLeft || old_innerRight  != innerRight )) _onResizeInnerWidth (this, innerWidth,  innerWidth  - old_innerRight  + old_innerLeft);
		if (_onResizeInnerHeight != null && (old_innerTop  != innerTop  || old_innerBottom != innerBottom)) _onResizeInnerHeight(this, innerHeight, innerHeight - old_innerBottom + old_innerTop);
		if (onResizeInnerWidth  != null && (old_innerLeft != innerLeft || old_innerRight  != innerRight )) onResizeInnerWidth (this, innerWidth,  innerWidth  - old_innerRight  + old_innerLeft);
		if (onResizeInnerHeight != null && (old_innerTop  != innerTop  || old_innerBottom != innerBottom)) onResizeInnerHeight(this, innerHeight, innerHeight - old_innerBottom + old_innerTop);
	}
	
	// ---------------------------------------
	
	override inline function updateUIElementLayout():Void
	{
		if (!isVisible) return;

		var deltaX = x + xOffset - last_x;
		var deltaY = y + yOffset - last_y;
		last_x = x + xOffset;
		last_y = y + yOffset;
		
		for (child in childs) {
			child.x += deltaX;
			child.y += deltaY;
			child.maskByElement(this);
			child.updateLayout();
		}
	}

	override inline function updateUIElement():Void
	{
		updateUIElementLayout();
	}
	
	// -----------------
	
	override inline function onAddUIElementToDisplay()
	{
		for (child in childs) {
			uiDisplay.add(child);
			//child.updateLayout(); // need if the child is a parent itself
		}
	}
	
	override inline function onRemoveUIElementFromDisplay()
	{	
		for (child in childs) 
			if (child.isVisible) uiDisplay.remove(child);
	}	
	
	// --------------------
	public inline function setOffset(xOffset:Int, yOffset:Int, update:Bool = true, triggerEvent:Bool = false) {
		if (triggerEvent) {
			if (_onChangeXOffset != null) _onChangeXOffset(this, xOffset , xOffset-this.xOffset);
			if (_onChangeYOffset != null) _onChangeYOffset(this, yOffset , yOffset-this.yOffset);
			if (onChangeXOffset != null) onChangeXOffset(this, xOffset , xOffset-this.xOffset);
			if (onChangeYOffset != null) onChangeYOffset(this, yOffset , yOffset-this.yOffset);
		}
		this.xOffset = xOffset;
		this.yOffset = yOffset;
		if (update) updateLayout();
	}
	public inline function setXOffset(xOffset:Int, update:Bool = true, triggerEvent:Bool = false) _setXOffset(xOffset, update, triggerEvent, triggerEvent);
	inline function _setXOffset(xOffset:Int, update:Bool, triggerInternalEvent:Bool, triggerEvent:Bool) {
		if (triggerInternalEvent && _onChangeXOffset != null) _onChangeXOffset(this, xOffset , xOffset-this.xOffset);
		if (triggerEvent && onChangeXOffset != null) onChangeXOffset(this, xOffset , xOffset-this.xOffset);
		this.xOffset = xOffset;
		if (update) updateLayout();
	}
	public inline function setYOffset(yOffset:Int, update:Bool = true, triggerEvent:Bool = false) _setYOffset(yOffset, update, triggerEvent, triggerEvent);
	inline function _setYOffset(yOffset:Int, update:Bool, triggerInternalEvent:Bool, triggerEvent:Bool) {
		if (triggerInternalEvent && _onChangeYOffset != null) _onChangeYOffset(this, yOffset , yOffset-this.yOffset);
		if (triggerEvent && onChangeYOffset != null) onChangeYOffset(this, yOffset , yOffset-this.yOffset);
		this.yOffset = yOffset;
		if (update) updateLayout();
	}

	// ------- bind automatic to UISliders ------
	// TODO: check that the internal events not already used, 
	// more parameters: offsetBySlider, sliderByOffset, sliderByResize, sliderByTextResize
	
	public function bindHSlider(slider:peote.ui.interactive.UISlider) {
		slider.setRange(0, Math.min(0, width - innerRight), width / innerRight, false, false );		
		slider._onChange = function(_, value:Float, _) _setXOffset(Std.int(value), true, false, true); // don't trigger internal _onChangeXOffset again!
		_onChangeXOffset = function (_,xOffset:Float,_) slider.setValue(xOffset, true, false); // trigger sliders _onChange and onChange						
		_onResizeWidth = function(_,_,_) slider.setRange(0, Math.min(0, width - innerRight), width / innerRight, true, false );
		_onResizeInnerWidth = function(_,_,_) slider.setRange(0, Math.min(0, width - innerRight), width / innerRight, true, false );
	}
	
	public function bindVSlider(slider:peote.ui.interactive.UISlider) {
		slider.setRange(0, Math.min(0, height - innerBottom), height / innerBottom , false, false);				
		slider._onChange = function(_, value:Float, _) _setYOffset(Std.int(value), true, false, true); // don't trigger internal _onChangeYOffset again!
		_onChangeYOffset = function (_,yOffset:Float,_) slider.setValue(yOffset, true, false); // trigger sliders _onChange and onChange						
		_onResizeHeight = function(_,_,_) slider.setRange(0, Math.min(0, height - innerBottom), height / innerBottom , true, false);
		_onResizeInnerHeight = function(_,_,_) slider.setRange(0, Math.min(0, height - innerBottom), height / innerBottom , true, false);
	}
	
	public function unbindHSlider(slider:peote.ui.interactive.UISlider) {
		slider._onChange = null; _onChangeXOffset = null; _onResizeWidth = null; _onResizeInnerWidth = null;
	}
	
	public function unbindVSlider(slider:peote.ui.interactive.UISlider) {
		slider._onChange = null; _onChangeYOffset = null; _onResizeHeight = null; _onResizeInnerHeight = null;
	}
	
	
	// ------ internal Events ---------------

	var _onChangeXOffset:UIArea->Int->Int->Void = null;
	var _onChangeYOffset:UIArea->Int->Int->Void = null;
	var _onResizeInnerWidth:UIArea->Int->Int->Void = null;
	var _onResizeInnerHeight:UIArea->Int->Int->Void = null;
	
	// ------- UIArea Events ----------------
	public var onChangeXOffset:UIArea->Int->Int->Void = null;
	public var onChangeYOffset:UIArea->Int->Int->Void = null;
	public var onResizeInnerWidth:UIArea->Int->Int->Void = null;
	public var onResizeInnerHeight:UIArea->Int->Int->Void = null;
	


}