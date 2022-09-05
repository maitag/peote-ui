package peote.ui.interactive;

import peote.ui.interactive.Interactive;
import peote.ui.style.interfaces.Style;
import peote.ui.style.interfaces.StyleProgram;
import peote.ui.style.interfaces.StyleElement;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;

private typedef IAElementEventParams = InteractiveElement->PointerEvent->Void;
private typedef IAElementWheelEventParams = InteractiveElement->WheelEvent->Void;

class InteractiveElement extends Interactive
{	
	var styleProgram:StyleProgram = null;
	var styleElement:StyleElement = null;
	
	public var style(default, set):Dynamic = null;
	inline function set_style(_style:Dynamic):Dynamic {
		if (styleElement == null) { // not added to Display yet
			if (_style != null) { // add new style
				style = _style;
				if (isVisible) addStyle();
			}
		}
		else { // already have styleprogram and element
			if (_style != null) {
				if (_style.getID() | (_style.id << 16) != style.getID() | (style.id << 16))
				{	// if is need of another styleprogram
					if (isVisible) styleProgram.removeElement(styleElement);
					styleProgram = null;
					style = _style;
					if (isVisible) addStyle();
				} 
				else { // styleprogram is of same type
					style = _style;
					styleElement.setStyle(_style);
					if (isVisible) styleProgram.update(styleElement);
				}
			}
			else { // remove style
				if (isVisible) styleProgram.removeElement(styleElement);
				styleElement = null;
				styleProgram = null;
				style = null;
			}
		}		
		return style;
	}
	
		
	public function new(xPosition:Int=0, yPosition:Int=0, width:Int=100, height:Int=100, zIndex:Int=0, style:Style=null)
	{
		super(xPosition, yPosition, width, height, zIndex);		
		this.style = style;		
	}
	
	
	override inline function updateVisibleStyle():Void
	{
		if (style != null) {
			styleElement.setStyle(style);
			if (isVisible) styleProgram.update(styleElement);
		}
	}
	
	override inline function updateVisibleLayout():Void
	{
		if (style != null) {
			styleElement.setLayout(this);
			if (isVisible) styleProgram.update(styleElement);
		}
	}
	
	override inline function updateVisible():Void
	{
		if (style != null) {
			styleElement.setStyle(style);
			styleElement.setLayout(this);
			if (isVisible) styleProgram.update(styleElement);
		}
	}
	
	override inline function onAddVisibleToDisplay():Void
	{
		if (styleElement != null) styleProgram.addElement(styleElement);
		else if (style != null) addStyle();
	}
	
	inline function addStyle()
	{
		var stylePos = uiDisplay.usedStyleID.indexOf( style.getID() | (style.id << 16) );
		if (stylePos < 0) {
			if (uiDisplay.autoAddStyles) uiDisplay.autoAddStyleProgram(cast styleProgram = style.createStyleProgram(), style.getID() | (style.id << 16) );
			else throw('Error by creating new InteractiveElement. The style "${Type.getClassName(Type.getClass(style))}" id=${style.id} is not inside the availableStyle list of UIDisplay.');
		} else {
			styleProgram = cast uiDisplay.usedStyleProgram[stylePos];
			if (styleProgram == null) uiDisplay.addProgramAtStylePos(cast styleProgram = style.createStyleProgram(), stylePos);				
		}
		styleProgram.addElement(styleElement = styleProgram.createElement(this, style));		
	}
	
	override inline function onRemoveVisibleFromDisplay()
	{		
		//if (isVisible && styleElement != null) styleProgram.removeElement(styleElement);
		if (styleElement != null) styleProgram.removeElement(styleElement);
	}

	
	// ---------- Events --------------------
	
	public var onPointerOver(never, set):IAElementEventParams;
	inline function set_onPointerOver(f:IAElementEventParams):IAElementEventParams return setOnPointerOver(this, f);
	
	public var onPointerOut(never, set):IAElementEventParams;
	inline function set_onPointerOut(f:IAElementEventParams):IAElementEventParams return setOnPointerOut(this, f);
	
	public var onPointerMove(never, set):IAElementEventParams;
	inline function set_onPointerMove(f:IAElementEventParams):IAElementEventParams return setOnPointerMove(this, f);
	
	public var onPointerDown(never, set):IAElementEventParams;
	inline function set_onPointerDown(f:IAElementEventParams):IAElementEventParams return setOnPointerDown(this, f);
	
	public var onPointerUp(never, set):IAElementEventParams;
	inline function set_onPointerUp(f:IAElementEventParams):IAElementEventParams return setOnPointerUp(this, f);
	
	public var onPointerClick(never, set):IAElementEventParams;
	inline function set_onPointerClick(f:IAElementEventParams):IAElementEventParams return setOnPointerClick(this, f);
		
	public var onMouseWheel(default, set):IAElementWheelEventParams;
	inline function set_onMouseWheel(f:IAElementWheelEventParams):IAElementWheelEventParams  return setOnMouseWheel(this, f);
	
}