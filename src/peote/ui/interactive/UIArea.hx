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

	public var xOffset:Int = 0;
	public var yOffset:Int = 0;
	
	var last_x:Int;
	var last_y:Int;
	
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
		if (childs.length == 0) {
			innerLeft = child.left;
			innerRight = child.right;
			innerTop = child.top;
			innerBottom = child.bottom;
		} else {
			if (child.left < innerLeft) innerLeft = child.left;
			if (child.right > innerRight) innerRight = child.right;
			if (child.top < innerTop) innerTop = child.top;
			if (child.bottom > innerBottom) innerBottom = child.bottom;
		}
		
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
		
		if (child.left >= innerLeft || child.right >= innerRight || child.top >= innerTop || child.bottom >= innerBottom) updateInnerSize();
		
		child.removeParentPosOffset(this);
	}
	
	// ---------------------------------------
	public function updateInnerSize() 
	{
		if (childs.length == 0) {
			innerLeft = 0;
			innerRight = 0;
			innerTop = 0;
			innerBottom = 0;
		}
		else {
			innerLeft = childs[0].left;
			innerRight = childs[0].right;
			innerTop = childs[0].top;
			innerBottom = childs[0].bottom;
			var child:Interactive;
			for (i in 1...childs.length) {
				child = childs[i];
				if (child.left < innerLeft) innerLeft = child.left;
				if (child.right > innerRight) innerRight = child.right;
				if (child.top < innerTop) innerTop = child.top;
				if (child.bottom > innerBottom) innerBottom = child.bottom;
			}
		}
		
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
	
	// ------- UIArea Events ----------------
	
	

}