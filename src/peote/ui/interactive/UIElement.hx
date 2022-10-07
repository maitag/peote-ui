package peote.ui.interactive;

import peote.ui.interactive.Interactive;
import peote.ui.style.interfaces.Style;
import peote.ui.style.interfaces.StyleProgram;
import peote.ui.style.interfaces.StyleElement;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;

private typedef UIElementEventParams = UIElement->PointerEvent->Void;
private typedef UIElementWheelEventParams = UIElement->WheelEvent->Void;
private typedef UIElementDragEventParams = UIElement->Float->Float->Void;
private typedef UIElementFocusEventParams = UIElement->Void;

class UIElement extends Interactive
#if peote_layout
implements peote.layout.ILayoutElement
#end
{	
	var styleProgram:StyleProgram = null;
	var styleElement:StyleElement = null;	
	public var style(default, set):Dynamic = null;
	inline function set_style(_style:Dynamic):Dynamic {
		if (styleElement == null) { // not added to Display yet
			style = _style;
			if (_style != null && uiDisplay != null) createStyle(isVisible && styleIsVisible);
		}
		else { // already have styleprogram and element
			if (_style != null) {
				if (_style.getID() | (_style.id << 16) != style.getID() | (style.id << 16))
				{	// if is need of another styleprogram
					if (isVisible && styleIsVisible) styleProgram.removeElement(styleElement);
					styleProgram = null;
					style = _style;
					createStyle(isVisible && styleIsVisible);
				} 
				else { // styleprogram is of same type
					style = _style;
					styleElement.setStyle(_style);
					if (isVisible && styleIsVisible) styleProgram.update(styleElement);
				}
			}
			else { // remove style
				if (isVisible && styleIsVisible) styleProgram.removeElement(styleElement);
				style = null; styleProgram = null; styleElement = null;
			}
		}		
		return style;
	}
	
	public var styleIsVisible(default, set):Bool = true;
	inline function set_styleIsVisible(b:Bool):Bool {
		if (style != null && uiDisplay != null) {
			if (b && !styleIsVisible) {
				if (styleElement == null) createStyle(isVisible); // create new selectElement
				else if (isVisible) styleProgram.addElement(styleElement);
			}
			else if (!b && styleIsVisible && styleElement != null && isVisible) styleProgram.removeElement(styleElement);
		}
		return styleIsVisible = b;
	}	
	public inline function styleShow():Void styleIsVisible = true;
	public inline function styleHide():Void styleIsVisible = false;
		
	public function new(xPosition:Int=0, yPosition:Int=0, width:Int=100, height:Int=100, zIndex:Int=0, style:Style=null)
	{
		super(xPosition, yPosition, width, height, zIndex);		
		this.style = style;	
	}
	
	
	override inline function updateVisibleStyle():Void
	{
		if (styleElement != null) {
			styleElement.setStyle(style);
			if (isVisible && styleIsVisible) styleProgram.update(styleElement);
		}
	}
	
	override inline function updateVisibleLayout():Void
	{
		if (styleElement != null) {
			styleElement.setLayout(this);
			if (isVisible && styleIsVisible) styleProgram.update(styleElement);
		}
	}
	
	override inline function updateVisible():Void
	{
		if (styleElement != null) {
			styleElement.setStyle(style);
			styleElement.setLayout(this);
			if (isVisible && styleIsVisible) styleProgram.update(styleElement);
		}
	}
	
	override inline function onAddVisibleToDisplay():Void
	{
		if (styleElement != null) {
			if (styleIsVisible) styleProgram.addElement(styleElement);
		}
		else if (style != null) createStyle(styleIsVisible);
	}
	
	inline function createStyle(addUpdate:Bool)
	{
		var stylePos = uiDisplay.usedStyleID.indexOf( style.getID() | (style.id << 16) );
		if (stylePos < 0) {
			if (uiDisplay.autoAddStyles) uiDisplay.autoAddStyleProgram(cast styleProgram = style.createStyleProgram(), style.getID() | (style.id << 16) );
			else throw('Error by creating new InteractiveElement. The style "${Type.getClassName(Type.getClass(style))}" id=${style.id} is not inside the availableStyle list of UIDisplay.');
		} else {
			styleProgram = cast uiDisplay.usedStyleProgram[stylePos];
			if (styleProgram == null) uiDisplay.addProgramAtStylePos(cast styleProgram = style.createStyleProgram(), stylePos);				
		}
		styleElement = styleProgram.createElement(this, style);
		if (addUpdate) styleProgram.addElement(styleElement);		
	}
	
	override inline function onRemoveVisibleFromDisplay()
	{		
		if (styleIsVisible && styleElement != null) styleProgram.removeElement(styleElement);
	}

	
	// ---------- Events --------------------
	
	public var onPointerOver(never, set):UIElementEventParams;
	inline function set_onPointerOver(f:UIElementEventParams):UIElementEventParams return setOnPointerOver(this, f);
	
	public var onPointerOut(never, set):UIElementEventParams;
	inline function set_onPointerOut(f:UIElementEventParams):UIElementEventParams return setOnPointerOut(this, f);
	
	public var onPointerMove(never, set):UIElementEventParams;
	inline function set_onPointerMove(f:UIElementEventParams):UIElementEventParams return setOnPointerMove(this, f);
	
	public var onPointerDown(never, set):UIElementEventParams;
	inline function set_onPointerDown(f:UIElementEventParams):UIElementEventParams return setOnPointerDown(this, f);
	
	public var onPointerUp(never, set):UIElementEventParams;
	inline function set_onPointerUp(f:UIElementEventParams):UIElementEventParams return setOnPointerUp(this, f);
	
	public var onPointerClick(never, set):UIElementEventParams;
	inline function set_onPointerClick(f:UIElementEventParams):UIElementEventParams return setOnPointerClick(this, f);
		
	public var onMouseWheel(never, set):UIElementWheelEventParams;
	inline function set_onMouseWheel(f:UIElementWheelEventParams):UIElementWheelEventParams return setOnMouseWheel(this, f);
	
	public var onDrag(never, set):UIElementDragEventParams;
	inline function set_onDrag(f:UIElementDragEventParams):UIElementDragEventParams return setOnDrag(this, f);
	
	public var onFocus(never, set):UIElementFocusEventParams;
	inline function set_onFocus(f:UIElementFocusEventParams):UIElementFocusEventParams return setOnFocus(this, f);
	
}