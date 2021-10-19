package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import peote.ui.skin.SkinType;

import peote.view.PeoteView;
import peote.view.Color;

import peote.ui.UIDisplay;
import peote.ui.interactive.InteractiveElement;

import peote.ui.skin.SimpleSkin;
import peote.ui.style.SimpleStyle;
import peote.ui.skin.RoundedSkin;
import peote.ui.style.RoundedStyle;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;


class MultiUIDisplays extends Application
{
	var peoteView:PeoteView;
	var uiDisplayLeft:UIDisplay;
	var uiDisplayRight:UIDisplay;
	
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

	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);

		var roundedSkin = new RoundedSkin();
		var myStyle = new RoundedStyle();
		myStyle.color = Color.GREY1;
		myStyle.borderColor = Color.GREY5;
		myStyle.borderSize = 4.0;
		myStyle.borderRadius = 40.0;
		
		
		
		// ----------------------------- left UIDisplay -----------------------------------
		uiDisplayLeft = new UIDisplay(25, 25, 350, 550, Color.GREY1);
		uiDisplayLeft.onPointerOver  = function(uiDisplay:UIDisplay, e:PointerEvent) { trace("uiDisplayLeft onPointerOver", e); uiDisplay.color = Color.GREY2; };
		uiDisplayLeft.onPointerOut   = function(uiDisplay:UIDisplay, e:PointerEvent) { trace("uiDisplayLeft onPointerOut", e); uiDisplay.color = Color.GREY1; };
		uiDisplayLeft.onPointerDown  = function(uiDisplay:UIDisplay, e:PointerEvent) { trace("uiDisplayLeft onPointerDown", e); };
		uiDisplayLeft.onPointerUp    = function(uiDisplay:UIDisplay, e:PointerEvent) { trace("uiDisplayLeft onPointerUp", e); };
		uiDisplayLeft.onPointerClick = function(uiDisplay:UIDisplay, e:PointerEvent) { trace("uiDisplayLeft onPointerClick", e); };
		peoteView.addDisplay(uiDisplayLeft);
		
		var buttonLeft1 = new InteractiveElement(20, 20, 200, 100, roundedSkin, myStyle);		
		buttonLeft1.onPointerOver = onOver.bind(Color.GREY2);
		buttonLeft1.onPointerOut = onOut.bind(Color.GREY1);
		buttonLeft1.onPointerDown = onDown.bind(Color.YELLOW);
		buttonLeft1.onPointerUp = onUp.bind(Color.GREY5);
		buttonLeft1.onPointerClick = onClick;
		
		uiDisplayLeft.add(buttonLeft1);
		
		// ----------------------------- right UIDisplay -----------------------------------

		uiDisplayRight = new UIDisplay(300, 125, 350, 550, Color.GREY2);
		uiDisplayRight.onPointerOver  = function(uiDisplay:UIDisplay, e:PointerEvent) { trace("uiDisplayRight onPointerOver", e); uiDisplay.color = Color.GREY3; };
		uiDisplayRight.onPointerOut   = function(uiDisplay:UIDisplay, e:PointerEvent) { trace("uiDisplayRight onPointerOut", e); uiDisplay.color = Color.GREY2; };
		uiDisplayRight.onPointerDown  = function(uiDisplay:UIDisplay, e:PointerEvent) { trace("uiDisplayRight onPointerDown", e); };
		uiDisplayRight.onPointerUp    = function(uiDisplay:UIDisplay, e:PointerEvent) { trace("uiDisplayRight onPointerUp", e); };
		uiDisplayRight.onPointerClick = function(uiDisplay:UIDisplay, e:PointerEvent) { trace("uiDisplayRight onPointerClick", e); };
		peoteView.addDisplay(uiDisplayRight);
		
		var buttonRight1 = new InteractiveElement(20, 20, 200, 100, roundedSkin, myStyle.copy());  // if sharing the same style and not copy here it result crazy behavior if not set all style-properties inside the eventhandler
		buttonRight1.onPointerOver = onOver.bind(Color.GREY2);
		buttonRight1.onPointerOut = onOut.bind(Color.GREY1);
		buttonRight1.onPointerDown = onDown.bind(Color.RED);
		buttonRight1.onPointerUp = onUp.bind(Color.GREY5);
		buttonRight1.onPointerClick = onClick;

		uiDisplayRight.add(buttonRight1);
		
		//peoteView.zoom = 0.5;
		//peoteView.xOffset = 300;
		
		//uiDisplayLeft.touchEnabled = false;
		#if android
		uiDisplayLeft.mouseEnabled = false;
		uiDisplayRight.mouseEnabled = false;
		peoteView.zoom = 3;
		#end
		
		uiDisplayLeft.pointerEnabled = true;
		uiDisplayRight.pointerEnabled = true;
		
		UIDisplay.registerEvents(window);
		
		//UIDisplay.unRegisterEvents(window);			
	}
	
	// ----------------- InteractiveElement Eventhandler ----------------------
	
	public inline function onOver(color:Color, uiElement:InteractiveElement, e:PointerEvent) {
		trace(" -----> onPointerOver", e);
		uiElement.style.color = color;
		if (uiElement.style.compatibleSkins & SkinType.Rounded > 0) {
			uiElement.style.borderColor = Color.GREY7;
		}
		uiElement.updateStyle();
	}
	
	public inline function onOut(color:Color, uiElement:InteractiveElement, e:PointerEvent) {
		trace(" -----> onPointerOut", e);
		uiElement.style.color = color;
		if (uiElement.style.compatibleSkins & SkinType.Rounded > 0) {
			uiElement.style.borderColor = Color.GREY5;
		}
		uiElement.updateStyle();
	}
	
	public inline function onMove(uiElement:InteractiveElement, e:PointerEvent) {
		trace(" -----> onPointerMove", e);
	}
	
	public inline function onDown(borderColor:Color, uiElement:InteractiveElement, e:PointerEvent) {
		trace(" -----> onPointerDown", e);
		if (uiElement.style.compatibleSkins & SkinType.Rounded > 0) {
			uiElement.style.borderColor = borderColor;
			//uiElement.x += 30;  uiElement.update();
			uiElement.updateStyle();
		}
	}
	
	public inline function onUp(borderColor:Color, uiElement:InteractiveElement, e:PointerEvent) {
		trace(" -----> onPointerUp", e);
		if (uiElement.style.compatibleSkins & SkinType.Rounded > 0) {
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
