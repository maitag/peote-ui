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

		var bgDisplay = new peote.view.Display(10, 10, window.width-20, window.height-20, Color.GREY1);
		//peoteView.addDisplay(bgDisplay);
		
		var roundedSkin = new RoundedSkin();
		var myStyle = new RoundedStyle();
		myStyle.color = Color.GREY1;
		myStyle.borderColor = Color.GREY5;
		myStyle.borderSize = 4.0;
		myStyle.borderRadius = 40.0;
		
		
		
		// ----------------------------- left UIDisplay -----------------------------------
		uiDisplayLeft = new UIDisplay(25, 25, 350, 550, Color.GREY2);
		uiDisplayLeft.onPointerOver  = function(uiDisplay:UIDisplay, e:PointerEvent) { uiDisplay.color = Color.RED; };
		uiDisplayLeft.onPointerOut   = function(uiDisplay:UIDisplay, e:PointerEvent) { uiDisplay.color = Color.GREY2; };
		uiDisplayLeft.onPointerDown  = function(uiDisplay:UIDisplay, e:PointerEvent) { trace("uiDisplayLeft onPointerDown"); };
		uiDisplayLeft.onPointerUp    = function(uiDisplay:UIDisplay, e:PointerEvent) { trace("uiDisplayLeft onPointerUp"); };
		uiDisplayLeft.onPointerClick = function(uiDisplay:UIDisplay, e:PointerEvent) { trace("uiDisplayLeft onPointerClick"); };
		
		peoteView.addDisplay(uiDisplayLeft);
		
		var buttonLeft1 = new InteractiveElement(20, 20, 200, 100, roundedSkin, myStyle);		
		buttonLeft1.onPointerOver = onOver.bind(Color.GREY2);
		buttonLeft1.onPointerOut = onOut.bind(Color.GREY1);
		buttonLeft1.onPointerDown = onDown.bind(Color.YELLOW);
		buttonLeft1.onPointerUp = onUp.bind(Color.GREY5);
		buttonLeft1.onPointerClick = function onClick(uiElement:InteractiveElement, e:PointerEvent) {
			// show or hide the other display
			if (uiDisplayRight.isVisible) uiDisplayRight.hide() else uiDisplayRight.show();
		};
		uiDisplayLeft.add(buttonLeft1);
		
		var buttonLeft2 = new InteractiveElement(20, 120, 200, 100, roundedSkin, myStyle);		
		buttonLeft2.onPointerClick = function onClick(uiElement:InteractiveElement, e:PointerEvent) {
			// swap the displays order
			uiDisplayLeft.swapDisplay(uiDisplayRight);
		};
		uiDisplayLeft.add(buttonLeft2);
		

		
		// ----------------------------- right UIDisplay -----------------------------------

		uiDisplayRight = new UIDisplay(300, 125, 350, 550, Color.GREY3);
		uiDisplayRight.onPointerOver  = function(uiDisplay:UIDisplay, e:PointerEvent) { uiDisplay.color = Color.BLUE; };
		uiDisplayRight.onPointerOut   = function(uiDisplay:UIDisplay, e:PointerEvent) { uiDisplay.color = Color.GREY3; };
		uiDisplayRight.onPointerDown  = function(uiDisplay:UIDisplay, e:PointerEvent) { trace("uiDisplayRight onPointerDown"); };
		uiDisplayRight.onPointerUp    = function(uiDisplay:UIDisplay, e:PointerEvent) { trace("uiDisplayRight onPointerUp"); };
		uiDisplayRight.onPointerClick = function(uiDisplay:UIDisplay, e:PointerEvent) { trace("uiDisplayRight onPointerClick"); };
		
		peoteView.addDisplay(uiDisplayRight);
		// inserting before the left one into RenderList
		//peoteView.addDisplay(uiDisplayRight, uiDisplayLeft, true);
		
		// let mouse Event bubble to the UIDisplays behind
		// uiDisplayRight.upDownEventsBubble = true;
		// uiDisplayRight.overOutEventsBubble = true;
		
		var buttonRight1 = new InteractiveElement(20, -1, 200, 100, roundedSkin, myStyle.copy());  // if sharing the same style and not copy here it result crazy behavior if not set all style-properties inside the eventhandler
		buttonRight1.onPointerOver = onOver.bind(Color.GREY2);
		buttonRight1.onPointerOut = onOut.bind(Color.GREY1);
		buttonRight1.onPointerDown = onDown.bind(Color.RED);
		buttonRight1.onPointerUp = onUp.bind(Color.GREY5);
		buttonRight1.onPointerClick = function onClick(uiElement:InteractiveElement, e:PointerEvent) {
			// show or hide the other display
			if (uiDisplayLeft.isVisible) uiDisplayLeft.hide() else uiDisplayLeft.show();
		};
		
		buttonRight1.upDownEventsBubbleToDisplay = true; // bubble the over/out events of this button to the UIDisplay		
		//buttonRight1.overOutEventsBubbleToDisplay = false; // don't bubble the over/out events of this button to the UIDisplay

		uiDisplayRight.add(buttonRight1);
		
		var buttonRight2 = new InteractiveElement(30, 25, 180, 50, roundedSkin, myStyle.copy());  // if sharing the same style and not copy here it result crazy behavior if not set all style-properties inside the eventhandler
		buttonRight2.onPointerOver = onOver.bind(Color.GREY2);
		buttonRight2.onPointerOut = onOut.bind(Color.GREY1);
		buttonRight2.onPointerDown = onDown.bind(Color.RED);
		buttonRight2.onPointerUp = onUp.bind(Color.GREY5);
		buttonRight2.onPointerClick = function onClick(uiElement:InteractiveElement, e:PointerEvent) {
			uiDisplayRight.overOutEventsBubble = !uiDisplayRight.overOutEventsBubble;
			uiDisplayRight.upDownEventsBubble = !uiDisplayRight.upDownEventsBubble;
		};
		
		//buttonRight2.overOutEventsBubbleToDisplay = false; // don't bubble the over/out events of this button to the UIDisplay
		buttonRight2.overOutEventsBubbleTo = buttonRight1; // bubble the over/out events of this button to the underlaying Button

		uiDisplayRight.add(buttonRight2);
		
		//peoteView.zoom = 0.5;
		//peoteView.xOffset = 300;
		
		//uiDisplayLeft.touchEnabled = false;
		#if android
		uiDisplayLeft.mouseEnabled = false;
		uiDisplayRight.mouseEnabled = false;
		peoteView.zoom = 3;
		#end
		
		//uiDisplayLeft.pointerEnabled = true;
		//uiDisplayRight.pointerEnabled = true;
		
		UIDisplay.registerEvents(window);
		
		//UIDisplay.unRegisterEvents(window);			
	}
	
	// ----------------- InteractiveElement Eventhandler ----------------------
	
	public inline function onOver(color:Color, uiElement:InteractiveElement, e:PointerEvent) {
		//trace(" -----> onPointerOver", e);
		uiElement.style.color = color;
		if (uiElement.style.compatibleSkins & SkinType.Rounded > 0) {
			uiElement.style.borderColor = Color.GREY7;
		}
		uiElement.updateStyle();
	}
	
	public inline function onOut(color:Color, uiElement:InteractiveElement, e:PointerEvent) {
		//trace(" -----> onPointerOut", e);
		uiElement.style.color = color;
		if (uiElement.style.compatibleSkins & SkinType.Rounded > 0) {
			uiElement.style.borderColor = Color.GREY5;
		}
		uiElement.updateStyle();
	}
	
	public inline function onMove(uiElement:InteractiveElement, e:PointerEvent) {
		//trace(" -----> onPointerMove", e);
	}
	
	public inline function onDown(borderColor:Color, uiElement:InteractiveElement, e:PointerEvent) {
		//trace(" -----> onPointerDown", e);
		if (uiElement.style.compatibleSkins & SkinType.Rounded > 0) {
			uiElement.style.borderColor = borderColor;
			//uiElement.x += 30;  uiElement.update();
			uiElement.updateStyle();
		}
	}
	
	public inline function onUp(borderColor:Color, uiElement:InteractiveElement, e:PointerEvent) {
		//trace(" -----> onPointerUp", e);
		if (uiElement.style.compatibleSkins & SkinType.Rounded > 0) {
			uiElement.style.borderColor = borderColor;
			uiElement.updateStyle();
		}
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
