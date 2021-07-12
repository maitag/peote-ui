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
import peote.ui.interactive.InteractiveElement;
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
		
		var layoutElement:ILayoutElement = new LayoutDisplay(0, 0, 0, 0, (peoteUiOptions.bgColor != null) ? peoteUiOptions.bgColor : Color.BLACK);
		this = new LayoutContainer(
			containerType, 
			layoutElement,
			peoteUiOptions,
			widgets
		);
			
		addChildsToDisplay(this);
	}
	
	function addChildsToDisplay(lc:LayoutContainer,
		_overOutEventsBubbleTo:InteractiveElement = null,
		_moveEventsBubbleTo:InteractiveElement = null,
		_wheelEventsBubbleTo:InteractiveElement = null
		)
	{		
		if (lc.childs != null)
			for (child in lc.childs) {
				
				// TODO: if child it is a DISPLAY -> add it to peote-view
				var widget:Widget = child;
				var elem:InteractiveElement = widget.interactiveElement;
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
		public inline function get_pointerEnabled():Bool return (activeUI == this);
		
		static var activeUI:PeoteUI;

		static public function activate(peoteUI:PeoteUI) {
			activeUI = peoteUI;
		}
		static public function deactivate(peoteUI:PeoteUI) {
			activeUI = null;
		}
		
		static public inline function mouseMove(mouseX:Float, mouseY:Float) if (activeUI!=null) activeUI.display.mouseMove(mouseX, mouseY);	
		static public inline function mouseDown(mouseX:Float, mouseY:Float, button:MouseButton) if (activeUI!=null) activeUI.display.mouseDown(mouseX, mouseY, button);
		static public inline function mouseUp(mouseX:Float, mouseY:Float, button:MouseButton) if (activeUI!=null) activeUI.display.mouseUp(mouseX, mouseY, button);
		static public inline function mouseWheel (dx:Float, dy:Float, mode:MouseWheelMode) if (activeUI!=null) activeUI.display.mouseWheel(dx, dy, mode);
		
		static public inline function touchStart (touch:Touch) if (activeUI!=null) activeUI.display.touchStart(touch);
		static public inline function touchMove (touch:Touch) if (activeUI!=null) activeUI.display.touchMove(touch);
		static public inline function touchEnd (touch:Touch) if (activeUI!=null) activeUI.display.touchEnd(touch);
		static public inline function touchCancel (touch:Touch) if (activeUI!=null) activeUI.display.touchCancel(touch);

		static public inline function windowResize(width:Int, height:Int) if (activeUI != null) activeUI.update(width, height);
		static public inline function windowLeave() if (activeUI!=null) activeUI.display.windowLeave();

	#else
		public inline function get_pointerEnabled():Bool return (activeUI.indexOf(this) >= 0);

		static var activeUI = new Array<PeoteUI>();
		
		static public function activate(peoteUI:PeoteUI) {
			if (activeUI.indexOf(peoteUI) < 0) activeUI.push(peoteUI);
		}
		static public function deactivate(peoteUI:PeoteUI) {
			activeUI.remove(peoteUI);
		}
		
		static public inline function mouseMove(mouseX:Float, mouseY:Float) for (ui in activeUI) ui.display.mouseMove(mouseX, mouseY);	
		static public inline function mouseUp(mouseX:Float, mouseY:Float, button:MouseButton) for (ui in activeUI) ui.display.mouseUp(mouseX, mouseY, button);
		static public inline function mouseDown(mouseX:Float, mouseY:Float, button:MouseButton) for (ui in activeUI) ui.display.mouseDown(mouseX, mouseY, button);
		static public inline function mouseWheel (dx:Float, dy:Float, mode:MouseWheelMode) for (ui in activeUI) ui.display.mouseWheel(dx, dy, mode);
		
		static public inline function touchStart (touch:Touch) for (ui in activeUI) ui.display.touchStart(touch);
		static public inline function touchMove (touch:Touch) for (ui in activeUI) ui.display.touchMove(touch);
		static public inline function touchEnd (touch:Touch) for (ui in activeUI) ui.display.touchEnd(touch);
		static public inline function touchCancel (touch:Touch) for (ui in activeUI) ui.display.touchCancel(touch);

		static public inline function windowResize(width:Int, height:Int) for (ui in activeUI) ui.update(width, height);
		static public inline function windowLeave() for (ui in activeUI) ui.display.windowLeave();
	#end

	// -------- register Events from Lime Application ----------
	
	public static function registerEvents(window:Window) {
		
		window.onMouseUp.add(mouseUp);
		window.onMouseDown.add(mouseDown);
		window.onMouseWheel.add(mouseWheel);
		
		window.onResize.add(windowResize);

		// TODO: keyboard & text
		
		Touch.onStart.add(touchStart);
		Touch.onMove.add(touchMove);
		Touch.onEnd.add(touchEnd);
		Touch.onCancel.add(touchCancel);

		#if (! html5)
		window.onRender.add(_mouseMoveFrameSynced);
		window.onMouseMove.add(_mouseMove);
		window.onLeave.add(_windowLeave);
		#else
		window.onMouseMove.add(mouseMove);
		window.onLeave.add(windowLeave);
		#end
	}
	
	#if (! html5)
		static var isMouseMove = false;
		static var lastMouseMoveX:Float = 0.0;
		static var lastMouseMoveY:Float = 0.0;
		
		static inline function _mouseMove (x:Float, y:Float) {
			lastMouseMoveX = x;
			lastMouseMoveY = y;
			isMouseMove = true;
		}
		
		static inline function _mouseMoveFrameSynced(context:RenderContext):Void {
			if (isMouseMove) {
				isMouseMove = false;
				mouseMove(lastMouseMoveX, lastMouseMoveY);
			}
		}
		
		static inline function _windowLeave() {
			lastMouseMoveX = lastMouseMoveY = -1; // fix for another onMouseMoveFrameSynced() by render-loop
			windowLeave();
		}
	#end
	
	
	// TODO:
	public static function unRegisterEvents(window:Window) {
		
		
	}
		
	
}
