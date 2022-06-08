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


class SimpleElements extends Application
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

	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);
		uiDisplay = new UIDisplay(20, 20, window.width-40, window.height-40, Color.GREY1);
		peoteView.addDisplay(uiDisplay);
		
		uiDisplay.onPointerOver  = function(uiDisplay:UIDisplay, e:PointerEvent) { trace("uiDisplay onPointerOver",e); };
		uiDisplay.onPointerOut   = function(uiDisplay:UIDisplay, e:PointerEvent) { trace("uiDisplay onPointerOut",e); };
		uiDisplay.onPointerDown  = function(uiDisplay:UIDisplay, e:PointerEvent) { trace("uiDisplay onPointerDown",e); };
		uiDisplay.onPointerUp    = function(uiDisplay:UIDisplay, e:PointerEvent) { trace("uiDisplay onPointerUp",e);  };
		uiDisplay.onPointerClick = function(uiDisplay:UIDisplay, e:PointerEvent) { trace("uiDisplay onPointerClick",e); };
		//uiDisplay.onPointerMove =  function(uiDisplay:UIDisplay, e:PointerEvent) { trace("uiDisplayLeft onPointerMove",e); };
		
		
		var simpleSkin = new SimpleSkin();
		var roundedSkin = new RoundedSkin();
		
		
		// Take care that every Button have its own Style if changing style-params into eventhandler
		// or alternatively create different styles for over/out/click and so on
		
		var myStyle = new RoundedStyle();
		myStyle.color = Color.GREY1;
		myStyle.borderColor = Color.GREY5;
		myStyle.borderSize = 4.0;
		myStyle.borderRadius = 40.0;
		
		trace("NEW BUTTON -----");
		var button1:InteractiveElement = new InteractiveElement(20, 0, 200, 100, roundedSkin, myStyle);
		//var button1:InteractiveElement = new InteractiveElement(20, 0, 200, 100, roundedSkin, new SimpleStyle(Color.GREY1));
		
		button1.overOutEventsBubbleToDisplay = false;
		button1.upDownEventsBubbleToDisplay = true;
		uiDisplay.add(button1);
		
		button1.onPointerOver = onOver.bind(Color.GREY2);
		button1.onPointerOut = onOut.bind(Color.GREY1); // only fires if there was some over before!
		button1.onPointerDown = onDown.bind(Color.YELLOW);
		button1.onPointerUp = onUp.bind(Color.GREY5);   // only fires if there was some down before!
		button1.onPointerClick = onClick;
		
		var myStyle2 = new RoundedStyle(Color.GREY1, Color.GREY5);
		myStyle2.borderSize = 2.0;

		trace("NEW BUTTON -----");
		var button2:InteractiveElement = new InteractiveElement(120, 60, 200, 100, roundedSkin, myStyle2);
		uiDisplay.add(button2);
		
		// to bubble up/down and click-events up to button1
		button2.upDownEventsBubbleTo = button1; 
		
		button2.onPointerOver = onOver.bind(Color.GREY3);
		button2.onPointerOut = onOut.bind(Color.GREY1); // only fire if there was some over before!
		button2.onPointerMove = onMove;
		button2.onPointerDown = onDown.bind(Color.RED);
		button2.onPointerUp = onUp.bind(Color.GREY5);   // only fire if there was some down before!
		button2.onPointerClick = onClick;
		
		//trace("REMOVE onPointerClick -----"); button1.onPointerClick = null;
		//uiDisplay.remove(button1);
		//uiDisplay.add(button1);
					
		//uiDisplay.update(button1);
		//uiDisplay.updateAll();
		
		
		// -------------- Dragging -------------------
		
		trace("NEW SLIDER -----");
		var myStyle3:RoundedStyle = {
			color: Color.GREY2,
			borderColor: Color.GREY5,
			borderSize: 3.0,
			borderRadius: 20.0
		}
		
		//var background = new InteractiveElement(10, 140, 350, 60, simpleSkin, new SimpleStyle(Color.GREEN));
		var dragBackground = new InteractiveElement(10, 140, 350, 60, simpleSkin, myStyle3);
		dragBackground.onPointerOver = onOver.bind(Color.GREY3);
		dragBackground.onPointerOut = onOut.bind(Color.GREY2);
		uiDisplay.add(dragBackground);
		
		//var dragger = new InteractiveElement(10, 140, 100, 60, 1, simpleSkin, myStyle3);
		//var dragger = new InteractiveElement(dragBackground.x, dragBackground.y, 100, 60, 1, roundedSkin, myStyle2);
		var dragger = new InteractiveElement(dragBackground.x, dragBackground.y, 100, 60, 1, roundedSkin,  new RoundedStyle(Color.BLUE,Color.GREY5));
		//var dragger = new InteractiveElement(dragBackground.x, dragBackground.y, 100, 60, 1, simpleSkin, new SimpleStyle(Color.GREEN));
		
		dragBackground.onMouseWheel = function(b:InteractiveElement, e:WheelEvent) {
			trace("MouseWheel:", e);
			dragger.x = Std.int(Math.max(dragBackground.x, Math.min(dragBackground.x+dragBackground.width-dragger.width, (dragger.x + e.deltaY * 20))));
			dragger.updateLayout();
			// trigger mouse-move here also for html5 (maybe also x and y position forlastMouseMoveX)!
			//uiDisplay.mouseMove(lastMouseMoveX, lastMouseMoveY);
		}
		
		
		// to bubble over-event up to the dragBackground
		dragger.overOutEventsBubbleTo = dragBackground;
		dragger.wheelEventsBubbleTo = dragBackground;
		//dragger.onMouseWheel = InteractiveElement.noWheelOperation;
		// testing bubble move-events
		//dragger.moveEventsBubbleTo = button2;
		
		
		dragger.onPointerOver = onOver.bind(Color.RED);
		dragger.onPointerOut = onOut.bind(Color.BLUE);

		dragger.setDragArea(10, 140, 350, 60); // x, y, width, height
		dragger.onPointerDown = function(b:InteractiveElement, e:PointerEvent) {
			trace(" -----> onPointerDown", e);
			b.startDragging(e);
			b.style.borderColor = Color.YELLOW;
			b.updateStyle();
		}
		dragger.onPointerUp = function(b:InteractiveElement, e:PointerEvent) {
			trace(" -----> onPointerUp", e);
			b.style.borderColor = Color.GREY7;
			b.updateStyle();
			b.stopDragging(e); // this need to be at End because it can be trigger the OUT-event after
		}
		uiDisplay.add(dragger);

		// ------ DragArea ------
		
		trace("NEW DragArea -----");
		var myStyle4 = new RoundedStyle();
		myStyle4.color = Color.GREY1;
		myStyle4.borderColor = Color.GREY5;
		myStyle4.borderSize = 3.0;
		myStyle4.borderRadius = 40.0;
		
		var draggAreaBG = new InteractiveElement(10, 200, 350, 350, roundedSkin, myStyle4);
		uiDisplay.add(draggAreaBG);

		var draggArea = new InteractiveElement(250, 250, 80, 80, roundedSkin, myStyle4);
		draggArea.setDragArea(10, 200, 350, 350); // x, y, width, height
		draggArea.onPointerDown = function(b:InteractiveElement, e:PointerEvent) {
			trace(" -----> onPointerDown", e);
			b.startDragging(e);
			b.style.color = Color.YELLOW;
			b.updateStyle();
		}
		draggArea.onPointerUp = function(b:InteractiveElement, e:PointerEvent) {
			trace(" -----> onPointerUp", e);
			b.stopDragging(e);
			b.style.color = Color.GREY1;
			b.updateStyle();
		}
		uiDisplay.add(draggArea);
		
		
		// TODO: make uiElement to switch between
		//uiDisplay.mouseEnabled = false;
		//uiDisplay.touchEnabled = false;
		peoteView.zoom = 0.8;
		peoteView.xOffset = 30;
		uiDisplay.zoom = 1.7;
		uiDisplay.xOffset = 50;
		
		#if android
		uiDisplay.mouseEnabled = false;
		peoteView.zoom = 3;
		#end
		
		// TODO: set what events to register (mouse, touch, keyboard ...)
		UIDisplay.registerEvents(window);
			
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
		trace(" -----> onPointerMove", e, uiElement.localX(e.x), uiElement.localY(e.y));
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
