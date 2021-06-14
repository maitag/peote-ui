package peote.ui;

import lime.ui.MouseButton;
import lime.ui.MouseWheelMode;
import lime.ui.Touch;
import peote.layout.LayoutContainer;
import peote.layout.LayoutElement;
import peote.layout.LayoutOptions;
import peote.layout.ContainerType;
import peote.view.Color;

import peote.ui.interactive.LayoutDisplay;
import peote.ui.widget.Widget;

typedef PeoteUIOptions = {
	> LayoutOptions,
	?bgColor:Color,
}

class PeoteUIParams {
	
}

@:access(peote.layout.LayoutContainer.childs)
@:forward
abstract PeoteUI(LayoutContainer) from LayoutContainer to LayoutContainer {
	public inline function new(containerType = ContainerType.BOX, peoteUiOptions:PeoteUIOptions = null, widgets:Array<Widget> = null) 
	{
		if (peoteUiOptions == null) peoteUiOptions = {relativeChildPositions:true};
		else peoteUiOptions.relativeChildPositions = true;
		
		//var layoutElement:LayoutElement = new UIDisplay<PeoteUIOptions, PeoteUIParams>(0, 0, 0, 0, (peoteUiOptions.bgColor != null) ? peoteUiOptions.bgColor : Color.BLACK);
		var layoutElement:LayoutElement = new LayoutDisplay(0, 0, 0, 0, (peoteUiOptions.bgColor != null) ? peoteUiOptions.bgColor : Color.BLACK);
		this = new LayoutContainer(
			containerType, 
			layoutElement,
			peoteUiOptions,
			widgets
		);
			
		addChildsToDisplay(this);
	}
	
	function addChildsToDisplay(lc:LayoutContainer) {
		if (lc.childs != null)
			for (child in lc.childs) {
				// TODO: if child it is a DISPLAY -> add it to peote-view
				display.add(cast child.layoutElement);
				
				addChildsToDisplay(child);
			}
	}
	
	public var display(get, never):LayoutDisplay;
	public inline function get_display():LayoutDisplay return cast this.layoutElement;
	
	@:to public inline function toLayoutDisplay():LayoutDisplay return display;
	
	// ------------------------------------------------------------
	
	public var mouseEnabled(get, set):Bool;
	public inline function get_mouseEnabled():Bool return display.mouseEnabled;
	public inline function set_mouseEnabled(b:Bool):Bool return display.mouseEnabled = b;
	public var touchEnabled(get, set):Bool;
	public inline function get_touchEnabled():Bool return display.touchEnabled;
	public inline function set_touchEnabled(b:Bool):Bool return display.touchEnabled = b;
	
	public var pointerEnabled(get, set):Bool;
	public inline function set_pointerEnabled(b:Bool):Bool {
		if (b) activate(this) else deactivate(this);
		return b;
	}
	
	// ---------------- global Input-Eventhandlers ----------------
	
	#if (peoteui_maxDisplays == "1")
		public inline function get_pointerEnabled():Bool return (interactiveDisplay == display);
		
		static var interactiveDisplay:LayoutDisplay;

		static public function activate(peoteUI:PeoteUI) {
			interactiveDisplay = peoteUI.display;
		}
		static public function deactivate(peoteUI:PeoteUI) {
			interactiveDisplay = null;
		}
		
		static public inline function mouseMove(mouseX:Float, mouseY:Float) if (interactiveDisplay!=null) interactiveDisplay.mouseMove(mouseX, mouseY);	
		static public inline function mouseDown(mouseX:Float, mouseY:Float, button:MouseButton) if (interactiveDisplay!=null) interactiveDisplay.mouseDown(mouseX, mouseY, button);
		static public inline function mouseUp(mouseX:Float, mouseY:Float, button:MouseButton) if (interactiveDisplay!=null) interactiveDisplay.mouseUp(mouseX, mouseY, button);
		static public inline function mouseWheel (dx:Float, dy:Float, mode:MouseWheelMode) if (interactiveDisplay!=null) interactiveDisplay.mouseWheel(dx, dy, mode);
		
		static public inline function touchStart (touch:Touch) if (interactiveDisplay!=null) interactiveDisplay.touchStart(touch);
		static public inline function touchMove (touch:Touch) if (interactiveDisplay!=null) interactiveDisplay.touchMove(touch);
		static public inline function touchEnd (touch:Touch) if (interactiveDisplay!=null) interactiveDisplay.touchEnd(touch);
		static public inline function touchCancel (touch:Touch) if (interactiveDisplay!=null) interactiveDisplay.touchCancel(touch);

		static public inline function windowLeave() if (interactiveDisplay!=null) interactiveDisplay.windowLeave();

	#else
		public inline function get_pointerEnabled():Bool return (interactiveDisplay.indexOf(this.display)>=0);

		static var interactiveDisplay = new Array<LayoutDisplay>();
		
		static public function activate(peoteUI:PeoteUI) {
			if (interactiveDisplay.indexOf(peoteUI.display)<0) interactiveDisplay.push(peoteUI.display);
		}
		static public function deactivate(peoteUI:PeoteUI) {
			interactiveDisplay.remove(peoteUI.display);
		}
		
		static public inline function mouseMove(mouseX:Float, mouseY:Float) for (d in interactiveDisplay) d.mouseMove(mouseX, mouseY);	
		static public inline function mouseDown(mouseX:Float, mouseY:Float, button:MouseButton) for (d in interactiveDisplay) d.mouseDown(mouseX, mouseY, button);
		static public inline function mouseUp(mouseX:Float, mouseY:Float, button:MouseButton) for (d in interactiveDisplay) d.mouseUp(mouseX, mouseY, button);
		static public inline function mouseWheel (dx:Float, dy:Float, mode:MouseWheelMode) for (d in interactiveDisplay) d.mouseWheel(dx, dy, mode);
		
		static public inline function touchStart (touch:Touch) for (d in interactiveDisplay) d.touchStart(touch);
		static public inline function touchMove (touch:Touch) for (d in interactiveDisplay) d.touchMove(touch);
		static public inline function touchEnd (touch:Touch) for (d in interactiveDisplay) d.touchEnd(touch);
		static public inline function touchCancel (touch:Touch) for (d in interactiveDisplay) d.touchCancel(touch);

		static public inline function windowLeave() for (d in interactiveDisplay) d.windowLeave();
	#end

}
