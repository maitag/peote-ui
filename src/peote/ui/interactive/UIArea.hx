package peote.ui.interactive;

import lime.ui.MouseCursor;
import peote.ui.event.PointerEvent;
import peote.ui.interactive.Interactive;
import peote.ui.interactive.UIElement;
import peote.ui.interactive.interfaces.ParentElement;
import peote.ui.config.AreaConfig;
import peote.ui.config.ResizeType;
import peote.ui.config.Space;
import peote.ui.interactive.UIElement;

@:allow(peote.ui)
class UIArea extends UIElement implements ParentElement
#if peote_layout
implements peote.layout.ILayoutElement
#end
{
	var childs = new Array<Interactive>();
	var childsFixed = new Array<Interactive>();
	
	var last_x:Int;
	var last_y:Int;
	var last_xOffset:Int;
	var last_yOffset:Int;
	
	public var xOffset:Int = 0;
	public var yOffset:Int = 0;
	
	public var maskSpace:Space = null;

	public var xOffsetStart(get, never):Int;
	// inline function get_xOffsetStart():Int return ((maskSpace != null) ? maskSpace.left : 0) - innerLeft;
	inline function get_xOffsetStart():Int return -innerLeft;
	public var xOffsetEnd(get, never):Int;
	// inline function get_xOffsetEnd():Int return (innerRight - width - ((maskSpace != null) ? maskSpace.right : 0) < innerLeft) ? xOffsetStart : width - ((maskSpace != null) ? maskSpace.right : 0) - innerRight;
	// inline function get_xOffsetEnd():Int return width - ((maskSpace != null) ? maskSpace.left + maskSpace.right : 0) - innerWidth;
	inline function get_xOffsetEnd():Int return width - ((maskSpace != null) ? maskSpace.left + maskSpace.right : 0) - innerRight;

	public var yOffsetStart(get, never):Int;
	// inline function get_yOffsetStart():Int return ((maskSpace != null) ? maskSpace.top : 0) - innerTop;
	inline function get_yOffsetStart():Int return -innerTop;
	public var yOffsetEnd(get, never):Int;
	// inline function get_yOffsetEnd():Int return (innerBottom - height - ((maskSpace != null) ? maskSpace.top+maskSpace.bottom : 0) < innerTop) ? yOffsetStart : height - ((maskSpace != null) ?  maskSpace.top+maskSpace.bottom : 0) - innerBottom;
	// inline function get_yOffsetEnd():Int return height - ((maskSpace != null) ?  maskSpace.top + maskSpace.bottom : 0) - innerHeight;
	inline function get_yOffsetEnd():Int return height - ((maskSpace != null) ?  maskSpace.top + maskSpace.bottom : 0) - innerBottom;
	
	public var innerLeft(default, null):Int = 0;
	public var innerRight(default, null):Int = 0;
	public var innerWidth(get, never):Int;
	inline function get_innerWidth():Int return innerRight - innerLeft;
			
	public var innerTop(default, null):Int = 0;
	public var innerBottom(default, null):Int = 0;
	public var innerHeight(get, never):Int;
	inline function get_innerHeight():Int return innerBottom - innerTop;
			
	public function new(xPosition:Int, yPosition:Int, width:Int, height:Int, zIndex:Int = 0, ?config:AreaConfig) 
	{
		super(xPosition, yPosition, width, height, zIndex, config);
		
		if (config != null) {
			maskSpace = config.maskSpace;
			resizerSize = config.resizerSize;
			resizerEdgeSize = config.resizerEdgeSize;
			minWidth  = config.minWidth;
			maxWidth  = config.maxWidth;
			minHeight = config.minHeight;
			maxHeight = config.maxHeight;
			createAllResizer(config.resizeType);
		}
		
		last_x = xPosition;
		last_y = yPosition;
		last_xOffset = xOffset + xPosition;
		last_yOffset = yOffset + yPosition;
		
		changeZIndex = onChangeZIndex;		
	}
	
	inline function onChangeZIndex(z:Int, deltaZ:Int):Void
	{
		for (child in childs) child.z += deltaZ;
		for (child in childsFixed) child.z += deltaZ;
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
		child.moveEventsBubbleTo = this;
		
		child.setParentPosOffset(this);  // TODO:overriding z setter into interactive  to also update z of all childs!
		if (maskSpace != null) {
			child.x += maskSpace.left;
			child.y += maskSpace.top;
		}

		// TODO
		if (isVisible) {
			uiDisplay.add(child); // <-- glitch: if child is a autosized-text-element it gets its size at the First time here!
			//child.maskByElement(this, maskSpace);
			//child.updateLayout(); // need if the child is a parent itself
		}
		// here to update pickable also if area not added
		child.maskByElement(this, maskSpace);
		child.updateLayout(); // need if the child is a parent itself
	}
	
	public function addFixed(child:Interactive)
	{
		childsFixed.push(child);
		
		// to bubble events down to the elements
		child.overOutEventsBubbleTo = this;
		child.upDownEventsBubbleTo = this;
		child.wheelEventsBubbleTo = this;
		child.moveEventsBubbleTo = this;

		child.setParentPos(this);
		if (isVisible) uiDisplay.add(child);
		child.updateLayout(); // need if the child is a parent itself
	}

	public function remove(child:Interactive) 
	{
		if (isVisible && child.isVisible) uiDisplay.remove(child);
		childs.remove(child);
		
		if (maskSpace != null) {
			child.x -= maskSpace.left;
			child.y -= maskSpace.top;
		}
		// if (child.left - x - xOffset >= innerLeft || child.right - x - xOffset >= innerRight || 
			// child.top - y - yOffset >= innerTop || child.bottom - y - yOffset >= innerBottom) updateInnerSize();
		if (child.left - x - xOffset <= innerLeft || child.right - x - xOffset >= innerRight || 
			child.top - y - yOffset <= innerTop || child.bottom - y - yOffset >= innerBottom) updateInnerSize();
		
		child.removeParentPosOffset(this);
	}

	public function removeFixed(child:Interactive) 
	{
		if (isVisible && child.isVisible) uiDisplay.remove(child);
		childsFixed.remove(child);
		child.removeParentPos(this);
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
			var xOff:Int = x + xOffset;
			var yOff:Int = y + yOffset;
			if (maskSpace != null) {
				xOff += maskSpace.left;
				yOff += maskSpace.top;
			}
			innerLeft = childs[0].left - xOff;
			innerRight = childs[0].right - xOff;
			innerTop = childs[0].top - yOff;
			innerBottom = childs[0].bottom - yOff;
			var child:Interactive;
			for (i in 1...childs.length) {
				child = childs[i];
				if (child.left   - xOff < innerLeft  ) innerLeft   = child.left   - xOff;
				if (child.right  - xOff > innerRight ) innerRight  = child.right  - xOff;
				if (child.top    - yOff < innerTop   ) innerTop    = child.top    - yOff;
				if (child.bottom - yOff > innerBottom) innerBottom = child.bottom - yOff;
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

		var deltaX = x + xOffset - last_xOffset;
		var deltaY = y + yOffset - last_yOffset;
		last_xOffset = x + xOffset;
		last_yOffset = y + yOffset;
		
		for (child in childs) {
			child.x += deltaX;
			child.y += deltaY;
			child.maskByElement(this, maskSpace);
			child.updateLayout();
		}

		deltaX = x - last_x;
		deltaY = y - last_y;
		last_x = x;
		last_y = y;

		for (child in childsFixed) {
			child.x += deltaX;
			child.y += deltaY;
			child.maskByElement(this); // TODO: only if child have that option
			child.updateLayout();
		}		
		updateResizer(resizerAvail);
	}

	override inline function updateUIElement():Void
	{
		updateUIElementLayout();
	}
	
	// -----------------
	
	override function onAddUIElementToDisplay()
	{
		for (child in childs) {
			uiDisplay.add(child);
			// TODO: this is need if add the area to display after adding childs
			child.maskByElement(this, maskSpace);
			child.updateLayout(); // need if the child is a parent itself?
		}

		for (child in childsFixed) {
			uiDisplay.add(child);
			// TODO: this is need if add the area to display after adding childs
			// child.maskByElement(this, maskSpace);
			child.updateLayout(); // need if the child is a parent itself?
		}
		addResizer(resizerAvail);
	}
	
	override function onRemoveUIElementFromDisplay()
	{	
		for (child in childs) if (child.isVisible) uiDisplay.remove(child);
		for (child in childsFixed) if (child.isVisible) uiDisplay.remove(child);
		removeResizer(resizerAvail);
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
		if (update) updateUIElementLayout();
	}
	public inline function setXOffset(xOffset:Int, update:Bool = true, triggerEvent:Bool = false) _setXOffset(xOffset, update, triggerEvent, triggerEvent);
	inline function _setXOffset(xOffset:Int, update:Bool, triggerInternalEvent:Bool, triggerEvent:Bool) {
		if (triggerInternalEvent && _onChangeXOffset != null) _onChangeXOffset(this, xOffset , xOffset-this.xOffset);
		if (triggerEvent && onChangeXOffset != null) onChangeXOffset(this, xOffset , xOffset-this.xOffset);
		this.xOffset = xOffset;
		if (update) updateUIElementLayout();
	}
	public inline function setYOffset(yOffset:Int, update:Bool = true, triggerEvent:Bool = false) _setYOffset(yOffset, update, triggerEvent, triggerEvent);
	inline function _setYOffset(yOffset:Int, update:Bool, triggerInternalEvent:Bool, triggerEvent:Bool) {
		if (triggerInternalEvent && _onChangeYOffset != null) _onChangeYOffset(this, yOffset , yOffset-this.yOffset);
		if (triggerEvent && onChangeYOffset != null) onChangeYOffset(this, yOffset , yOffset-this.yOffset);
		this.yOffset = yOffset;
		if (update) updateUIElementLayout();
	}

	// ----------- Resizer buttons ---------------
	
	var resizerAvail:ResizeType = ResizeType.NONE;
	
	var resizerSize:Int = 5;
	var resizerEdgeSize:Int = 7;
	var minWidth:Int  = 10;
	var maxWidth:Int  = 2000;
	var minHeight:Int = 10;
	var maxHeight:Int = 2000;
	
	var resizerTop:UIElement = null;
	var resizerLeft:UIElement = null;
	var resizerBottom:UIElement = null;
	var resizerRight:UIElement = null;
	var resizerTopLeft:UIElement = null;
	var resizerTopRight:UIElement = null;
	var resizerBottomLeft:UIElement = null;
	var resizerBottomRight:UIElement = null;
	
	public function createAllResizer(t:ResizeType)
	{
		resizerAvail = t;
		if ( t.hasTop ) { resizerTop = createResizer( ResizeType.TOP,
			function(r, e) { r.setDragArea(x, max(0, bottom - maxHeight), r.width, min(bottom,  maxHeight) - minHeight ); r.startDragging(e); },
			function (r, _, _) { topSize = r.y; updateLayout(); } );
		}
		if ( t.hasLeft ) { resizerLeft = createResizer( ResizeType.LEFT,
			function(r, e) { r.setDragArea(max(0, right - maxWidth), y , min(right,  maxWidth) - minWidth, r.height ); r.startDragging(e); },
			function (r, _, _) { leftSize = r.x; updateLayout(); } );
		}
		if ( t.hasBottom ) { resizerBottom = createResizer( ResizeType.BOTTOM,
			function(r, e) { r.setDragArea(x, y + minHeight , r.width, min(maxHeight, uiDisplay.height- y) - minHeight ); r.startDragging(e); },
			function (r, _, _) { bottomSize = r.bottom; updateLayout(); } );
		}
		if ( t.hasRight ) { resizerRight = createResizer( ResizeType.RIGHT,
			function(r, e) { r.setDragArea(x + minWidth, y , min(maxWidth , uiDisplay.width - x) - minWidth, r.height ); r.startDragging(e); },
			function (r, _, _) { rightSize = r.right; updateLayout(); } );
		}
		
		if ( t.hasTopLeft ) { resizerTopLeft = createResizer( ResizeType.TOP_LEFT,
			function(r, e) { r.setDragArea(max(0, right - maxWidth), max(0, bottom - maxHeight) ,min(right,  maxWidth) - minWidth, min(bottom,  maxHeight) - minHeight ); r.startDragging(e); },
			function (r, _, _) { topSize = r.y; leftSize = r.x; updateLayout(); } );
		}
		if ( t.hasTopRight ) { resizerTopRight = createResizer( ResizeType.TOP_RIGHT,
			function(r, e) { r.setDragArea(x + minWidth, max(0, bottom - maxHeight), min(maxWidth, uiDisplay.width - x) - minWidth, min(bottom,  maxHeight) - minHeight ); r.startDragging(e); },
			function (r, _, _) { topSize = r.y; rightSize = r.right; updateLayout(); } );
		}
		if ( t.hasBottomLeft) { resizerBottomLeft = createResizer( ResizeType.BOTTOM_LEFT,
			function(r, e) { r.setDragArea(max(0, right - maxWidth), y + minHeight, min(right,  maxWidth) - minWidth, min(maxHeight, uiDisplay.height- y) - minHeight); r.startDragging(e); },
			function (r, _, _) { leftSize = r.x; bottomSize = r.bottom; updateLayout(); } );
		}
		if ( t.hasBottomRight ) { resizerBottomRight = createResizer( ResizeType.BOTTOM_RIGHT,
			function(r, e) { r.setDragArea(x + minWidth, y + minHeight, min(maxWidth, uiDisplay.width - x) - minWidth, min(maxHeight, uiDisplay.height- y) - minHeight); r.startDragging(e); },
			function (r, _, _) { rightSize = r.right; bottomSize = r.bottom; updateLayout(); } );
		}
		updateResizer(resizerAvail);
	}	
	inline function min(a:Int, b:Int):Int return (a < b) ? a : b;
	inline function max(a:Int, b:Int):Int return (a > b) ? a : b;
	
	inline function createResizer(t:ResizeType, onPointerDown:UIElement->PointerEvent->Void, onDrag:UIElement->Float->Float->Void):UIElement {
		var r:UIElement;
		if (t.hasEdge) {
			r = new UIElement(0, 0, resizerEdgeSize, resizerEdgeSize, 3);
			if (t.hasBottomRight || t.hasTopLeft) r.onPointerOver  = function(_, _) uiDisplay.peoteView.window.cursor = MouseCursor.RESIZE_NWSE;
			else r.onPointerOver  = function(_, _) uiDisplay.peoteView.window.cursor = MouseCursor.RESIZE_NESW;
		} else {
			r = new UIElement(0, 0, resizerSize, resizerSize, 3);
			if (t.hasLeft || t.hasRight) r.onPointerOver  = function(_, _) uiDisplay.peoteView.window.cursor = MouseCursor.RESIZE_WE;
			else r.onPointerOver = function(_, _) uiDisplay.peoteView.window.cursor = MouseCursor.RESIZE_NS;
		}
		r.onPointerOut = function(_, _) uiDisplay.peoteView.window.cursor = MouseCursor.DEFAULT;
		r.onPointerDown = onPointerDown; r.onDrag = onDrag;		
		r.onPointerUp = function(r, e) r.stopDragging(e);
		return r;
	}
		
	inline function updateResizer(r:ResizeType) {
		if (r == 0) return;
		if (r.hasSide) {
			if (r.hasTop) { resizerTop.y = y; resizerTop.x = x + ((r.hasTopLeft) ? resizerTopLeft.width : (r.hasLeft) ? resizerLeft.width : 0); resizerTop.rightSize = right - ((r.hasTopRight) ? resizerTopRight.width : (r.hasRight) ? resizerRight.width : 0); resizerTop.updateLayout(); }
			if (r.hasLeft) { resizerLeft.x = x; resizerLeft.y = y + ((r.hasTopLeft) ? resizerTopLeft.height : (r.hasTop) ? resizerTop.height : 0); resizerLeft.bottomSize = bottom - ((r.hasBottomLeft) ? resizerBottomLeft.height : (r.hasBottom) ? resizerBottom.height : 0); resizerLeft.updateLayout(); }
			if (r.hasBottom) { resizerBottom.bottom = bottom; resizerBottom.x = x + ((r.hasBottomLeft) ? resizerBottomLeft.width : (r.hasLeft) ? resizerLeft.width : 0); resizerBottom.rightSize = right - ((r.hasBottomRight) ? resizerBottomRight.width : (r.hasRight) ? resizerRight.width : 0); resizerBottom.updateLayout(); }
			if (r.hasRight) { resizerRight.right = right; resizerRight.y = y + ((r.hasTopRight) ? resizerTopRight.height : (r.hasTop) ? resizerTop.height : 0); resizerRight.bottomSize = bottom - ((r.hasBottomRight) ? resizerBottomRight.height : (r.hasBottom) ? resizerBottom.height : 0); resizerRight.updateLayout(); }
		}
		if (r.hasEdge) {
			if (r.hasTopLeft) { resizerTopLeft.x = x; resizerTopLeft.y = y; resizerTopLeft.updateLayout(); }
			if (r.hasTopRight) {resizerTopRight.right = right; resizerTopRight.y = y; resizerTopRight.updateLayout(); }
			if (r.hasBottomLeft) { resizerBottomLeft.x = x; resizerBottomLeft.bottom = bottom; resizerBottomLeft.updateLayout(); }
			if (r.hasBottomRight) { resizerBottomRight.right = right; resizerBottomRight.bottom = bottom; resizerBottomRight.updateLayout(); }
		}
	}
	
	inline function addResizer(r:ResizeType) {
		if (r == 0) return;
		if (r.hasSide) {
			if (r.hasTop) uiDisplay.add(resizerTop);
			if (r.hasLeft) uiDisplay.add(resizerLeft);
			if (r.hasBottom) uiDisplay.add(resizerBottom);
			if (r.hasRight) uiDisplay.add(resizerRight);
		}
		if (r.hasEdge) {
			if (r.hasTopLeft) uiDisplay.add(resizerTopLeft);
			if (r.hasTopRight) uiDisplay.add(resizerTopRight);
			if (r.hasBottomLeft) uiDisplay.add(resizerBottomLeft);
			if (r.hasBottomRight) uiDisplay.add(resizerBottomRight);
		}
	}
	
	inline function removeResizer(r:ResizeType) {
		if (r == 0) return;
		if (r.hasSide) {
			if (r.hasTop) uiDisplay.remove(resizerTop);
			if (r.hasLeft) uiDisplay.remove(resizerLeft);
			if (r.hasBottom) uiDisplay.remove(resizerBottom);
			if (r.hasRight) uiDisplay.remove(resizerRight);
		}
		if (r.hasEdge) {
			if (r.hasTopLeft) uiDisplay.remove(resizerTopLeft);
			if (r.hasTopRight) uiDisplay.remove(resizerTopRight);
			if (r.hasBottomLeft) uiDisplay.remove(resizerBottomLeft);
			if (r.hasBottomRight) uiDisplay.remove(resizerBottomRight);
		}
	}
	
	// ------- bind to UISliders ---------------
	
	// TODO: check that the internal events not already used, 
	// more parameters: offsetBySlider, sliderByOffset, sliderByResize, sliderByTextResize
	
	public function bindHSlider(slider:peote.ui.interactive.UISlider, triggerOnInnerResize = true, triggerOnResize = true) {
		slider.setRange(xOffsetStart, xOffsetEnd, (width - ((maskSpace != null) ? maskSpace.left + maskSpace.right : 0)) / innerWidth, false, false);
		// slider.setValue(xOffset, false, false);

		slider._onChange = function(_,value:Float,_) _setXOffset(Math.round(value), true, false, true); // don't trigger internal _onChangeXOffset again!
		_onChangeXOffset = function (_,xOffset:Float,_) slider.setValue(xOffset, true, false); // trigger sliders _onChange and onChange

		_onResizeInnerWidth = function(_,_,_) {
			slider.setRange(xOffsetStart, xOffsetEnd, (width - ((maskSpace != null) ? maskSpace.left + maskSpace.right : 0)) / innerWidth, triggerOnInnerResize, false);
			if (!triggerOnInnerResize) slider.setValue(xOffset, false, false);
		}
		setOnResizeWidthSlider(this, function(_,_,_) {
			slider.setRange(xOffsetStart, xOffsetEnd, (width - ((maskSpace != null) ? maskSpace.left + maskSpace.right : 0)) / innerWidth, triggerOnResize, false);
			if (!triggerOnResize) slider.setValue(xOffset, false, false);
		});
	}
	
	public function bindVSlider(slider:peote.ui.interactive.UISlider, triggerOnInnerResize = true, triggerOnResize = true ) {
		// slider.setRange(0, Math.min(0, height - innerBottom - ((maskSpace != null) ? maskSpace.bottom : 0)), (height - ((maskSpace != null) ? maskSpace.top - maskSpace.bottom : 0)) / innerBottom , false, false);
		slider.setRange(yOffsetStart, yOffsetEnd, (height - ((maskSpace != null) ? maskSpace.top + maskSpace.bottom : 0)) / innerHeight, false, false);
		// slider.setValue(yOffset, false, false);
		
		slider._onChange = function(_,value:Float,_) _setYOffset(Math.round(value), true, false, true); // don't trigger internal _onChangeYOffset again!
		_onChangeYOffset = function (_,yOffset:Float,_) slider.setValue(yOffset, true, false); // trigger sliders _onChange and onChange						
		
		_onResizeInnerHeight = function(_,_,_) {
			// slider.setRange(0, Math.min(0, height - innerBottom - ((maskSpace != null) ? maskSpace.bottom : 0)), (height - ((maskSpace != null) ? maskSpace.top - maskSpace.bottom : 0)) / innerBottom , triggerOnInnerResize, false);
			slider.setRange(yOffsetStart, yOffsetEnd, (height - ((maskSpace != null) ? maskSpace.top + maskSpace.bottom : 0)) / innerHeight, triggerOnInnerResize, false);
			if (!triggerOnInnerResize) slider.setValue(yOffset, false, false);
		}
		setOnResizeHeightSlider(this, function(_,_,_) {
			// slider.setRange(0, Math.min(0, height - innerBottom - ((maskSpace != null) ? maskSpace.bottom : 0)), (height - ((maskSpace != null) ? maskSpace.top - maskSpace.bottom : 0)) / innerBottom , triggerOnResize, false);
			slider.setRange(yOffsetStart, yOffsetEnd, (height - ((maskSpace != null) ? maskSpace.top + maskSpace.bottom : 0)) / innerHeight, triggerOnResize, false);
			if (!triggerOnResize) slider.setValue(yOffset, false, false);
		});
	}
	
	public function unbindHSlider(slider:peote.ui.interactive.UISlider) {
		slider._onChange = null;
		_onChangeXOffset = null;
		setOnResizeWidthSlider(this, null);
		_onResizeInnerWidth = null;
	}
	
	public function unbindVSlider(slider:peote.ui.interactive.UISlider) {
		slider._onChange = null;
		_onChangeYOffset = null;
		setOnResizeHeightSlider(this, null);
		_onResizeInnerHeight = null;
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