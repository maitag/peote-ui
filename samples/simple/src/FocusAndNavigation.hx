package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Color;

import peote.ui.PeoteUIDisplay;
import peote.ui.interactive.UIElement;

import peote.ui.style.BoxStyle;
import peote.ui.style.RoundBorderStyle;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;


class FocusAndNavigation extends Application
{
	var peoteView:PeoteView;
	var peoteUiDisplay:PeoteUIDisplay;
	
	override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try startSample(window)
				catch (_) trace(CallStack.toString(CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}

	var style = new RoundBorderStyle();
		
	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);
		peoteUiDisplay = new PeoteUIDisplay(0, 0, window.width, window.height, Color.GREY1);
		peoteView.addDisplay(peoteUiDisplay);
		
		
		// TODO: keyboard, gamepad and joystick buttons
		// via "input2action" !
/*		var actionMapFocus = [
			"focus_prev" => { action:focusPrevious },
			"focus_next" => { action:focusNext },
		];
		
		var actionConfigFocus:ActionConfig = [
			{	action: "focus_prev",
				keyboard: KeyCode.UP,
				gamepad:  GamepadButton.DPAD_UP
			},
		]
*/		
		
		
		var buttonLeft_1:UIElement = new UIElement(20, 20, 200, 100, style);		
		peoteUiDisplay.add(buttonLeft_1);
		
		var buttonLeft_2:UIElement = new UIElement(20, 130, 200, 100, style);		
		peoteUiDisplay.add(buttonLeft_2);
		
		var buttonLeft_3:UIElement = new UIElement(20, 240, 200, 100, style);		
		peoteUiDisplay.add(buttonLeft_3);
		
		// ------------
		
		var buttonMiddle_1:UIElement = new UIElement(260, 20, 200, 100, style);		
		peoteUiDisplay.add(buttonMiddle_1);
		
		var buttonMiddle_2:UIElement = new UIElement(260, 130, 200, 100, style);		
		peoteUiDisplay.add(buttonMiddle_2);
		
		
		// TODO: let navigate the focus between them by keyboard and controller
		
		// best would be a new ADT -> NavigationGraph <- where it can be also a node itself !
		// to bind easy to input2action and peoteUIDisplay to set "focus" by keyboard/gamepad/...
		
		
		// TODO: make uiElement to switch between
		//uiDisplay.mouseEnabled = false;
		//uiDisplay.touchEnabled = false;
		
		
		// TODO: set what events to register (mouse, touch, keyboard ...)
		PeoteUIDisplay.registerEvents(window);
			
	}
	
	// ----------------- InteractiveElement Eventhandler ----------------------
	
	public inline function onOver(color:Color, uiElement:UIElement, e:PointerEvent) {
		trace(" -----> onPointerOver", e);
		uiElement.style.color = color;
		if ((uiElement.style is RoundBorderStyle)) {
			uiElement.style.borderColor = Color.GREY7;
		}
		uiElement.updateStyle();
	}
	
	public inline function onOut(color:Color, uiElement:UIElement, e:PointerEvent) {
		trace(" -----> onPointerOut", e);
		uiElement.style.color = color;
		if ((uiElement.style is RoundBorderStyle)) {
			uiElement.style.borderColor = Color.GREY5;
		}
		uiElement.updateStyle();
	}
	
	public inline function onMove(uiElement:UIElement, e:PointerEvent) {
		trace(" -----> onPointerMove", e);
	}
	
	public inline function onDown(borderColor:Color, uiElement:UIElement, e:PointerEvent) {
		trace(" -----> onPointerDown", e);
		if ((uiElement.style is RoundBorderStyle)) {
			uiElement.style.borderColor = borderColor;
			//uiElement.x += 30;  uiElement.update();
			uiElement.updateStyle();
		}
	}
	
	public inline function onUp(borderColor:Color, uiElement:UIElement, e:PointerEvent) {
		trace(" -----> onPointerUp", e);
		if ((uiElement.style is RoundBorderStyle)) {
			uiElement.style.borderColor = borderColor;
			uiElement.updateStyle();
		}
	}
	
	public inline function onClick(uiElement:UIElement, e:PointerEvent) {
		trace(" -----> onPointerClick", e);
		//uiElement.y += 30; uiElement.updateLayout();
	}
	
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	// override function onPreloadComplete() {}
	// override function update(deltaTime:Int) {}
	// public override function onRenderContextLost ():Void trace(" --- WARNING: LOST RENDERCONTEXT --- ");		
	// public override function onRenderContextRestored (context:RenderContext):Void trace(" --- onRenderContextRestored --- ");		

	// override function onWindowResize (width:Int, height:Int) { trace("onWindowResize"); }
	// override function onWindowActivate():Void { trace("onWindowActivate"); }
	// override function onWindowDeactivate():Void { trace("onWindowDeactivate"); }
	// override function onWindowClose():Void { trace("onWindowClose"); }
	// override function onWindowDropFile(file:String):Void { trace("onWindowDropFile"); }
	// override function onWindowEnter():Void { trace("onWindowEnter"); }
	// override function onWindowExpose():Void { trace("onWindowExpose"); }
	// override function onWindowFocusIn():Void { trace("onWindowFocusIn"); }
	// override function onWindowFocusOut():Void { trace("onWindowFocusOut"); }
	// override function onWindowFullscreen():Void { trace("onWindowFullscreen"); }
	// override function onWindowMove(x:Float, y:Float):Void { trace("onWindowMove"); }
	// override function onWindowMinimize():Void { trace("onWindowMinimize"); }
	// override function onWindowRestore():Void { trace("onWindowRestore"); }
}
