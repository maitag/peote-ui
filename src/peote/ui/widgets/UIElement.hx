package peote.ui.widgets;

import lime.ui.MouseWheelMode;

import peote.ui.skin.Skin;
import peote.ui.skin.Style;

@:allow(peote.ui.widgets.UIElement)
class Pickable implements peote.view.Element
{
	public var uiElement:UIElement; 
	
	@posX public var x:Int=0;
	@posY public var y:Int=0;	
	@sizeX public var w:Int=100;
	@sizeY public var h:Int=100;
	@zIndex public var z:Int = 0;
	
	var OPTIONS = { picking:true };
	
	private function new( uiElement:UIElement )
	{
		this.uiElement = uiElement;
		update(uiElement);
	}

	private inline function update( uiElement:UIElement ):Void
	{
		this.uiElement = uiElement;
		x = uiElement.x;
		y = uiElement.y;
		w = uiElement.width;
		h = uiElement.height;
		z = uiElement.z;
	}

}

// ---------------------------------------------------------------

private typedef UIEventParams = Int->Int->Void;

@:enum private abstract UIEventMove(Int) from Int to Int {

	public static inline var mouseOver :Int = 1;
	public static inline var mouseOut  :Int = 2;
	public static inline var mouseMove :Int = 4;
	public static inline var mouseWheel:Int = 8;
}
@:enum private abstract UIEventClick(Int) from Int to Int {

	public static inline var mouseDown :Int = 1;
	public static inline var mouseUp   :Int = 2;
	public static inline var mouseClick:Int = 4;
}

// ---------------------------------------------------------------
// ---------------------------------------------------------------
// ---------------------------------------------------------------

@:allow(peote.ui)
class UIElement
{
	var uiDisplay:UIDisplay = null;
	
	public var skin:Skin = null;
	public var style(default, set):Style = null;
	inline function set_style(s:Style):Style {
		//trace("set style");
		if (skin == null) {
			if (style != null) throw ("Error, for styling the widget needs a skin");
		} 
		else if (s == null) {
			s = skin.createDefaultStyle();
		}
		return style = s;
	}
	
	
	var skinElementIndex:Int;
	var pickableMove:Pickable = null;
	var pickableClick:Pickable = null;
	
	public var x:Int;
	public var y:Int;
	public var width:Int;
	public var height:Int;
	public var z:Int;
	
	#if jasper // cassowary constraints (jasper lib)
	public var layout(default, null):peote.ui.layout.LayoutElement;
	public function updateLayout() {
		//trace("update element");
		if (uiDisplay != null)
			if (x != Math.round(layout.x.m_value) - uiDisplay.x ||
				y != Math.round(layout.y.m_value) - uiDisplay.y || 
				width != Math.round(layout.width.m_value) ||
				height != Math.round(layout.height.m_value))
			{
				x = Math.round(layout.x.m_value) - uiDisplay.x;
				y = Math.round(layout.y.m_value) - uiDisplay.y;
				width = Math.round(layout.width.m_value);
				height = Math.round(layout.height.m_value);
				update();
			}
/*			if (x != Std.int(layout.x.m_value) - uiDisplay.x ||
				y != Std.int(layout.y.m_value) - uiDisplay.y || 
				width != Std.int(layout.width.m_value) ||
				height != Std.int(layout.height.m_value))
			{
				x = Std.int(layout.x.m_value) - uiDisplay.x;
				y = Std.int(layout.y.m_value) - uiDisplay.y;
				width = Std.int(layout.width.m_value);
				height = Std.int(layout.height.m_value);
				update();
			}
*/	}
	#end
	
	var mouseOver :UIEventParams;
	var mouseOut  :UIEventParams;
	var mouseMove :UIEventParams;
	var mouseWheel:Float->Float->MouseWheelMode->Void;
	var hasMoveEvent :Int = 0;
	
	var mouseUp   :UIEventParams;
	var mouseDown :UIEventParams;
	var mouseClick:UIEventParams;
	var hasClickEvent:Int = 0;
	
	public function new(xPosition:Int=0, yPosition:Int=0, width:Int=100, height:Int=100, zIndex:Int=0, skin:Skin=null, style:Style=null) 
	{
		#if jasper // cassowary constraints (jasper lib)
		//layout.update = updateLayout;
		layout = new peote.ui.layout.LayoutElement(updateLayout);
		#end
		x = xPosition;
		y = yPosition;
		this.width  = width;
		this.height = height;
		z = zIndex;
				
		this.skin = skin;
		this.style = style;
		
		mouseOver  = noOperation;
		mouseOut   = noOperation;
		mouseMove  = noOperation;
		mouseWheel = noWheelOperation;
		
		mouseDown  = noOperation;
		mouseUp    = noOperation;
		mouseClick = noOperation;
	}
	
	
	public function update():Void
	{
		if (uiDisplay != null) 
		{
			if (skin != null) skin.updateElement(uiDisplay, this);
			if ( hasMoveEvent  != 0 ) {
				pickableMove.update(this);
				uiDisplay.movePickBuffer.updateElement( pickableMove );
			}
			if ( hasClickEvent != 0 ) {
				pickableClick.update(this);
				uiDisplay.clickPickBuffer.updateElement( pickableClick );		
			}
		}
	}
	
	// -----------------
	
	private function onAddToDisplay(uiDisplay:UIDisplay)
	{
		this.uiDisplay = uiDisplay;
		
		if (skin != null) skin.addElement(uiDisplay, this);
		if ( hasMoveEvent  != 0 ) addPickableMove();	
		if ( hasClickEvent != 0 ) addPickableClick();
	}
	
	private function onRemoveFromDisplay(uiDisplay:UIDisplay)
	{		
		if (uiDisplay != this.uiDisplay) throw('Error, $this is not inside uiDisplay: $uiDisplay');
		
		if (skin != null) skin.removeElement(uiDisplay, this);
		if ( hasMoveEvent  != 0 ) removePickableMove();
		if ( hasClickEvent != 0 ) removePickableClick();
		
		uiDisplay = null;
	}
	
	// ----------------- Dragging ----------------------------
	
	var dragMinX:Int = -0x7fff;
	var dragMinY:Int = -0x7fff;
	var dragMaxX:Int = 0x7fff;
	var dragMaxY:Int = 0x7fff;
	
	public var isDragging(default, null):Bool = false;
	
	var dragOriginX:Int = 0;
	var dragOriginY:Int = 0;
	
	public function setDragArea(dragAreaX:Int, dragAreaY:Int, dragAreaWidth:Int, dragAreaHeight:Int) {
		dragMinX = dragAreaX;
		dragMinY = dragAreaY;
		dragMaxX = dragAreaX + dragAreaWidth;
		dragMaxY = dragAreaY + dragAreaHeight;
	}
	
	private function dragTo(dragToX:Int, dragToY:Int)
	{
		if (dragToX >= dragMinX + dragOriginX) {
			if (dragToX < dragMaxX - width + dragOriginX) x = dragToX - dragOriginX;
			else x = dragMaxX - width;
		} else x = dragMinX;
		
		if (dragToY >= dragMinY + dragOriginY) {
			if (dragToY < dragMaxY - height + dragOriginY) y = dragToY - dragOriginY;
			else y = dragMaxY - height;
		} else y = dragMinY;
	}
	
	public function startDragging(dragOriginX:Int, dragOriginY:Int)
	{
		if (uiDisplay != null) {
			this.dragOriginX = dragOriginX - x;
			this.dragOriginY = dragOriginY - y;
			uiDisplay.startDragging(this);
		}
	}
	
	public function stopDragging()
	{
		if (uiDisplay != null) uiDisplay.stopDragging(this);
	}
	
	// ----------------- Event-Bindings ----------------------

	private function noOperation(x:Int, y:Int):Void {}
	private function noWheelOperation(dx:Float, dy:Float, deltaMode:MouseWheelMode):Void {}
	
	private function rebindMouseOver(newBinding:UIEventParams, isNull:Bool):Void {
		if ( !isNull ) {
			mouseOver = newBinding;
			if ( hasMoveEvent == 0 ) addPickableMove();
			hasMoveEvent |= UIEventMove.mouseOver;
		}
		else {
			hasMoveEvent &= ~UIEventMove.mouseOver;
			if ( hasMoveEvent == 0 ) removePickableMove();
			mouseOver = noOperation;
		}
	}

	private function rebindMouseOut(newBinding:UIEventParams, isNull:Bool):Void {
		if ( !isNull ) {
			mouseOut = newBinding;
			if ( hasMoveEvent == 0 ) addPickableMove();
			hasMoveEvent |= UIEventMove.mouseOut;
		}
		else {
			hasMoveEvent &= ~UIEventMove.mouseOut;
			if ( hasMoveEvent == 0 ) removePickableMove();
			mouseOut = noOperation;
		}
	}

	private function rebindMouseMove(newBinding:UIEventParams, isNull:Bool):Void {
		if ( !isNull ) {
			mouseMove = newBinding;
			if ( hasMoveEvent == 0 ) addPickableMove();
			hasMoveEvent |= UIEventMove.mouseMove;
		}
		else {
			hasMoveEvent &= ~UIEventMove.mouseMove;
			if ( hasMoveEvent == 0 ) removePickableMove();
			mouseMove = noOperation;
		}
	}

	private function rebindMouseWheel(newBinding:Float->Float->MouseWheelMode->Void, isNull:Bool):Void {
		if ( !isNull ) {
			mouseWheel = newBinding;
			if ( hasMoveEvent == 0 ) addPickableMove();
			hasMoveEvent |= UIEventMove.mouseWheel;
		}
		else {
			hasMoveEvent &= ~UIEventMove.mouseWheel;
			if ( hasMoveEvent == 0 ) removePickableMove();
			mouseWheel = noWheelOperation;
		}
	}

	// -----------------

	private function rebindMouseUp(newBinding:UIEventParams, isNull:Bool):Void {
		if ( !isNull ) {
			mouseUp = newBinding;
			if ( hasClickEvent == 0 ) addPickableClick();
			hasClickEvent |= UIEventClick.mouseUp;
		}
		else {
			hasClickEvent &= ~UIEventClick.mouseUp;
			if ( hasClickEvent == 0 ) removePickableClick();
			mouseUp = noOperation;
		}
	}
	
	private function rebindMouseDown(newBinding:UIEventParams, isNull:Bool):Void {
		if ( !isNull ) {
			mouseDown = newBinding;
			if ( hasClickEvent == 0 ) addPickableClick();
			hasClickEvent |= UIEventClick.mouseDown;
		}
		else {
			hasClickEvent &= ~UIEventClick.mouseDown;
			if ( hasClickEvent == 0 ) removePickableClick();
			mouseDown = noOperation;
		}
	}
	
	private function rebindMouseClick(newBinding:UIEventParams, isNull:Bool):Void {
		if ( !isNull ) {
			mouseClick = newBinding;
			if ( hasClickEvent == 0 ) addPickableClick();
			hasClickEvent |= UIEventClick.mouseClick;
		}
		else {
			hasClickEvent &= ~UIEventClick.mouseClick;
			if ( hasClickEvent == 0 ) removePickableClick();
			mouseClick = noOperation;
		}
	}
	
	// -----------------
		
	private function addPickableMove()
	{
		trace("addPickableOver");
		if (pickableMove==null) pickableMove = new Pickable(this);
		if (uiDisplay!=null) uiDisplay.movePickBuffer.addElement( pickableMove );
	}
	
	private function removePickableMove()
	{
		trace("removePickableOver");
		if (uiDisplay!=null) uiDisplay.movePickBuffer.removeElement( pickableMove );  //pickableOver=null
	}
	
	private function addPickableClick()
	{
		trace("addPickableClick");
		if (pickableClick==null) pickableClick = new Pickable(this);
		if (uiDisplay!=null) uiDisplay.clickPickBuffer.addElement( pickableClick );
	}
	
	private function removePickableClick()
	{
		trace("removePickableClick");
		if (uiDisplay!=null) uiDisplay.clickPickBuffer.removeElement( pickableClick ); //pickableClick=null
	}
		
}