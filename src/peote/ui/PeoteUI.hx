package peote.ui;

import lime.graphics.RenderContext;
import lime.ui.Window;
import lime.ui.MouseButton;
import lime.ui.MouseWheelMode;
import lime.ui.Touch;

import peote.layout.LayoutContainer;
import peote.layout.ILayoutElement;
import peote.layout.LayoutOptions;
import peote.layout.ContainerType;
import peote.ui.interactive.Interactive;
import peote.view.Color;

import peote.ui.layouted.LayoutedUIDisplay;
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
		
		var layoutElement:ILayoutElement = new LayoutedUIDisplay(0, 0, 0, 0, (peoteUiOptions.bgColor != null) ? peoteUiOptions.bgColor : Color.BLACK);
		this = new LayoutContainer(
			containerType, 
			layoutElement,
			peoteUiOptions,
			widgets
		);
		
		// TODO: only if visible
		PeoteUI.activate(this);
			
		addChildsToDisplay(this);
	}
	
	function addChildsToDisplay(lc:LayoutContainer,
		_overOutEventsBubbleTo:Interactive = null,
		_moveEventsBubbleTo:Interactive = null,
		_wheelEventsBubbleTo:Interactive = null
		)
	{		
		if (lc.childs != null)
			for (child in lc.childs) {
				
				// TODO: if child it is a DISPLAY -> add it to peote-view
				var widget:Widget = child;
				var elem:Interactive = widget.interactiveElement;
				display.add(elem);
				
				
				// delegate the last used events for bubbling to the childs
				if (elem.hasOverOutMoveWheel) {
					elem.overOutEventsBubbleTo = _overOutEventsBubbleTo;
					elem.moveEventsBubbleTo = _moveEventsBubbleTo;
					elem.wheelEventsBubbleTo = _wheelEventsBubbleTo;
				}
					
				addChildsToDisplay( child,
					(elem.hasPointerOver || elem.hasPointerOut) ? elem : _overOutEventsBubbleTo,
					(elem.hasPointerMove) ? elem : _moveEventsBubbleTo,
					(elem.hasMouseWheel)  ? elem : _wheelEventsBubbleTo
				);
			}
	}
	
	public var display(get, never):LayoutedUIDisplay;
	public inline function get_display():LayoutedUIDisplay return cast this.layoutElement;
	
	@:to public inline function toLayoutDisplay():LayoutedUIDisplay return display;
	
	// ------------------------------------------------------------
	
	public var mouseEnabled(get, set):Bool;
	public inline function get_mouseEnabled():Bool return display.mouseEnabled;
	public inline function set_mouseEnabled(b:Bool):Bool return display.mouseEnabled = b;
	
	public var touchEnabled(get, set):Bool;
	public inline function get_touchEnabled():Bool return display.touchEnabled;
	public inline function set_touchEnabled(b:Bool):Bool return display.touchEnabled = b;
	
	public var pointerEnabled(get, set):Bool;
	public inline function get_pointerEnabled():Bool return display.pointerEnabled;
	public inline function set_pointerEnabled(b:Bool):Bool return display.pointerEnabled = b;
	
	public static function registerEvents(window:Window) {
		UIDisplay.registerEvents(window);
		window.onResize.add(windowResize);
	}
	public static function unRegisterEvents(window:Window) {
		UIDisplay.unRegisterEvents(window);
		window.onResize.remove(windowResize);
	}
	
// ---------------- global Input-Eventhandlers ----------------
	
	#if (peoteui_maxDisplays == "1")
		static var activeUI:PeoteUI;

		static public function activate(peoteUI:PeoteUI) {
			activeUI = peoteUI;
		}
		static public function deactivate(peoteUI:PeoteUI) {
			activeUI = null;
		}
		
		static public inline function windowResize(width:Int, height:Int) if (activeUI != null) activeUI.update(width, height);

	#else
		static var activeUI = new Array<PeoteUI>();
		
		static public function activate(peoteUI:PeoteUI) {
			if (activeUI.indexOf(peoteUI) < 0) activeUI.push(peoteUI);
		}
		static public function deactivate(peoteUI:PeoteUI) {
			activeUI.remove(peoteUI);
		}
		
		static public inline function windowResize(width:Int, height:Int) for (ui in activeUI) ui.update(width, height);
	#end
	
}
