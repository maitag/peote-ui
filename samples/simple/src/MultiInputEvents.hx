package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Color;

import peote.ui.UIDisplay;
import peote.ui.interactive.InteractiveElement;

import peote.ui.style.SimpleStyle;
import peote.ui.style.RoundBorderStyle;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;


class MultiInputEvents extends Application
{
	var peoteView:PeoteView;
	var uiDisplay:UIDisplay;
	
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
		uiDisplay = new UIDisplay(0, 0, window.width, window.height, Color.GREY1);
		peoteView.addDisplay(uiDisplay);
		
		// mouse and touch
		uiDisplay.onPointerOver  = function(uiDisplay:UIDisplay, e:PointerEvent) { trace("uiDisplay onPointerOver",e); };
		uiDisplay.onPointerOut   = function(uiDisplay:UIDisplay, e:PointerEvent) { trace("uiDisplay onPointerOut",e); };
		uiDisplay.onPointerDown  = function(uiDisplay:UIDisplay, e:PointerEvent) { trace("uiDisplay onPointerDown",e); };
		uiDisplay.onPointerUp    = function(uiDisplay:UIDisplay, e:PointerEvent) { trace("uiDisplay onPointerUp",e);  };
		uiDisplay.onPointerClick = function(uiDisplay:UIDisplay, e:PointerEvent) { trace("uiDisplay onPointerClick",e); };
		
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
		
		
		var button1:InteractiveElement = new InteractiveElement(20, 0, 200, 100, style);
		
		//button1.overOutEventsBubbleToDisplay = false;
		//button1.upDownEventsBubbleToDisplay = true;
		uiDisplay.add(button1);
		
		button1.onPointerOver = onOver.bind(Color.GREY2);
		button1.onPointerOut = onOut.bind(Color.GREY1); // only fires if there was some over before!
		button1.onPointerDown = onDown.bind(Color.YELLOW);
		button1.onPointerUp = onUp.bind(Color.GREY5);   // only fires if there was some down before!
		button1.onPointerClick = onClick;
		
		
		
		// TODO: make uiElement to switch between
		//uiDisplay.mouseEnabled = false;
		//uiDisplay.touchEnabled = false;
		
		
		// TODO: set what events to register (mouse, touch, keyboard ...)
		UIDisplay.registerEvents(window);
			
	}
	
	// ----------------- InteractiveElement Eventhandler ----------------------
	
	public inline function onOver(color:Color, uiElement:InteractiveElement, e:PointerEvent) {
		trace(" -----> onPointerOver", e);
		uiElement.style.color = color;
		if ((uiElement.style is RoundBorderStyle)) {
			uiElement.style.borderColor = Color.GREY7;
		}
		uiElement.updateStyle();
	}
	
	public inline function onOut(color:Color, uiElement:InteractiveElement, e:PointerEvent) {
		trace(" -----> onPointerOut", e);
		uiElement.style.color = color;
		if ((uiElement.style is RoundBorderStyle)) {
			uiElement.style.borderColor = Color.GREY5;
		}
		uiElement.updateStyle();
	}
	
	public inline function onMove(uiElement:InteractiveElement, e:PointerEvent) {
		trace(" -----> onPointerMove", e);
	}
	
	public inline function onDown(borderColor:Color, uiElement:InteractiveElement, e:PointerEvent) {
		trace(" -----> onPointerDown", e);
		if ((uiElement.style is RoundBorderStyle)) {
			uiElement.style.borderColor = borderColor;
			//uiElement.x += 30;  uiElement.update();
			uiElement.updateStyle();
		}
	}
	
	public inline function onUp(borderColor:Color, uiElement:InteractiveElement, e:PointerEvent) {
		trace(" -----> onPointerUp", e);
		if ((uiElement.style is RoundBorderStyle)) {
			uiElement.style.borderColor = borderColor;
			uiElement.updateStyle();
		}
	}
	
	public inline function onClick(uiElement:InteractiveElement, e:PointerEvent) {
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
