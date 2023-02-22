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
	var uiElements = new Array<Interactive>();

	public var xOffset:Int = 0;
	public var yOffset:Int = 0;
	
	var last_x:Int;
	var last_y:Int;
			
	public function new(xPosition:Int=0, yPosition:Int=0, width:Int=100, height:Int=100, zIndex:Int=0, backgroundStyle:Style=null) 
	{
		super(xPosition, yPosition, width, height, zIndex, backgroundStyle);
		
		last_x = xPosition;
		last_y = yPosition;
	}
	
	public function add(uiElement:Interactive)
	{
		uiElements.push(uiElement);
		
		// to bubble events down to the elements
		uiElement.overOutEventsBubbleTo = this;
		uiElement.upDownEventsBubbleTo = this;
		uiElement.wheelEventsBubbleTo = this;
		
		uiElement.setParentPosOffset(this);
		
		if (isVisible) {
			uiDisplay.add(uiElement);
			uiElement.maskByElement(this);
			uiElement.updateLayout(); // need if the child is a parent itself
		}
	}
	
	public function remove(uiElement:Interactive) 
	{
		if (isVisible) uiDisplay.remove(uiElement);
		uiElements.remove(uiElement);
		uiElement.removeParentPosOffset(this);
	}
	
	
	// ---------------------------------------
	
	override inline function updateUIElementLayout():Void
	{
		if (!isVisible) return;

		var deltaX = x + xOffset - last_x;
		var deltaY = y + yOffset - last_y;
		last_x = x + xOffset;
		last_y = y + yOffset;
		
		for (uiElement in uiElements) {
			uiElement.x += deltaX;
			uiElement.y += deltaY;
			uiElement.maskByElement(this);
			uiElement.updateLayout();
		}
	}

	override inline function updateUIElement():Void
	{
		updateUIElementLayout();
	}
	
	// -----------------
	
	override inline function onAddUIElementToDisplay()
	{
		for (uiElement in uiElements) {
			uiDisplay.add(uiElement);
			//uiElement.updateLayout(); // need if the child is a parent itself
		}
	}
	
	override inline function onRemoveUIElementFromDisplay()
	{	
		for (uiElement in uiElements) 
			if (uiElement.isVisible) uiDisplay.remove(uiElement);
	}	
	
	// ------- UIArea Events ----------------
	
	

}