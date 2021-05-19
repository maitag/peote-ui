package peote.ui;
import haxe.Constraints.Function;
import lime.ui.MouseButton;
import lime.ui.MouseWheelMode;
import lime.ui.Touch;
import peote.layout.LayoutContainer;
import peote.layout.LayoutOptions;
import peote.layout.ContainerType;
import peote.ui.interactive.UIDisplay;
import peote.view.Color;

typedef PeoteUILayoutOptions = {
	> LayoutOptions,
	?bgColor:Color,
}

@:access(peote.layout.LayoutContainer.childs)
@:forward
abstract PeoteUI(LayoutContainer) from LayoutContainer to LayoutContainer {
	public inline function new(containerType = ContainerType.BOX, peoteUiLayout:PeoteUILayoutOptions = null, innerLayoutContainer:Array<LayoutContainer> = null) 
	{
		if (peoteUiLayout == null) peoteUiLayout = {relativeChildPositions:true};
		else peoteUiLayout.relativeChildPositions = true;
		
		this = new LayoutContainer(containerType, new UIDisplay(0, 0, 0, 0, (peoteUiLayout.bgColor != null) ? peoteUiLayout.bgColor : Color.BLACK), peoteUiLayout, innerLayoutContainer);
		addChildsToDisplay(this);
	}
	
	function addChildsToDisplay(lc:LayoutContainer) {
		if (lc.childs != null)
			for (child in lc.childs) {
				display.add(cast child.layoutElement);
				addChildsToDisplay(child);
			}
	}
	
	public var display(get, never):UIDisplay;
	public inline function get_display():UIDisplay return cast this.layoutElement;
	
	@:to public inline function toUIDisplay():UIDisplay return display;
	
	public var mouseEnabled(get, set):Bool;
	public inline function get_mouseEnabled():Bool return display.mouseEnabled;
	public inline function set_mouseEnabled(b:Bool):Bool return display.mouseEnabled = b;
	public var touchEnabled(get, set):Bool;
	public inline function get_touchEnabled():Bool return display.touchEnabled;
	public inline function set_touchEnabled(b:Bool):Bool return display.touchEnabled = b;
	
	
	
	public inline function mouseMove(mouseX:Float, mouseY:Float) display.mouseMove(mouseX, mouseY);	
	public inline function mouseDown(mouseX:Float, mouseY:Float, button:MouseButton) display.mouseDown(mouseX, mouseY, button);
	public inline function mouseUp(mouseX:Float, mouseY:Float, button:MouseButton) display.mouseUp(mouseX, mouseY, button);
	public inline function mouseWheel (dx:Float, dy:Float, mode:MouseWheelMode) display.mouseWheel(dx, dy, mode);
	
	public inline function touchStart (touch:Touch) display.touchStart(touch);
	public inline function touchMove (touch:Touch) display.touchMove(touch);
	public inline function touchEnd (touch:Touch) display.touchEnd(touch);
	public inline function touchCancel (touch:Touch) display.touchCancel(touch);

	public inline function windowLeave() display.windowLeave();
	
}
