package;

import lime.ui.MouseButton;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Color;

import peote.ui.PeoteUIDisplay;

import peote.ui.interactive.UIElement;

import peote.ui.style.RoundBorderStyle;

import peote.ui.config.HAlign;
import peote.ui.config.VAlign;

import peote.ui.event.PointerEvent;
import peote.ui.event.PointerType;

import peote.ui.style.FontStyleTiled;

// using macro generated Font and Text-widgets
// -------------------------------------------
typedef Fnt = peote.text.Font<FontStyleTiled>;
typedef TextLine = peote.ui.interactive.UITextLine<FontStyleTiled>;

// faster buildtime by using the pre generated:
// --------------------------------------------
// typedef Fnt = peote.ui.tiled.FontT;
// typedef TextLine = peote.ui.interactive.UITextLineT;

class TestEventBubbling extends Application
{
	var peoteView:PeoteView;
	var uiDisplayLeft:PeoteUIDisplay;
	var uiDisplayRight:PeoteUIDisplay;
	
	override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try startSample(window)
				catch (_) trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}

	var style = new RoundBorderStyle(Color.GREY1, Color.GREY5, 2.0, 20.0);
	
	var font:Fnt;
	var fontStyle:FontStyleTiled;
	
	public function startSample(window:Window)
	{
		// load the FONT:
		new Fnt("assets/fonts/tiled/hack_ascii.json").load( onFontLoaded );
	}
	
	public function onFontLoaded(font:Fnt)
	{
		peoteView = new PeoteView(window);

		this.font = font;

		fontStyle = new FontStyleTiled();
		fontStyle.color = Color.GREY6;
		fontStyle.height = 12;
		fontStyle.width = 8;
		
		// ----------------------------- left UIDisplay -----------------------------------
		
		uiDisplayLeft = new PeoteUIDisplay(25, 0, 350, 400, Color.GREY2);
		
		uiDisplayLeft.setDragArea(0, 0, window.width, window.height);
		
		uiDisplayLeft.onPointerOver  = function(uiDisplay:PeoteUIDisplay, e:PointerEvent) { trace("uiDisplayLeft onPointerOver");uiDisplay.color = Color.BLUE+0x33330000; };
		uiDisplayLeft.onPointerOut   = function(uiDisplay:PeoteUIDisplay, e:PointerEvent) { trace("uiDisplayLeft onPointerOut");uiDisplay.color = Color.GREY2; };
		uiDisplayLeft.onPointerDown  = function(uiDisplay:PeoteUIDisplay, e:PointerEvent) {
			trace("uiDisplayLeft onPointerDown");
			switch (e.type) {
				case PointerType.MOUSE:
					if (e.mouseButton == MouseButton.LEFT || e.mouseButton == MouseButton.MIDDLE) uiDisplay.startDragging(e); // only drag on left or middle
				default: //uiDisplay.startDragging(e);
			}
		};
		uiDisplayLeft.onPointerUp    = function(uiDisplay:PeoteUIDisplay, e:PointerEvent) { trace("uiDisplayLeft onPointerUp"); uiDisplay.stopDragging(e); };
		uiDisplayLeft.onPointerClick = function(uiDisplay:PeoteUIDisplay, e:PointerEvent) { trace("uiDisplayLeft onPointerClick"); };
		//uiDisplayLeft.onPointerMove =  function(uiDisplay:UIDisplay, e:PointerEvent) { trace("uiDisplayLeft onPointerMove"); };
		
		
		createButton(uiDisplayLeft, "hide/show right", 25, 0).onPointerClick = function onClick(uiElement:UIElement, e:PointerEvent) {
			if (uiDisplayRight.isVisible) uiDisplayRight.hide() else uiDisplayRight.show();
		};
		
		createButton(uiDisplayLeft, "de/activate right", 25, 53).onPointerClick = function onClick(uiElement:UIElement, e:PointerEvent) {
			if (uiDisplayRight.isActive) uiDisplayRight.deactivate() else uiDisplayRight.activate();
		};
		
		// bubbling to other Display on/off
		var bubbleToDisplay = new UIElement(290, 10, 50, 50, new RoundBorderStyle(Color.RED, Color.GREY5, 2.0, 20.0));
		bubbleToDisplay.onPointerClick = function onClick(uiElement:UIElement, e:PointerEvent) {
			// turn bubbling to display on/off
			uiDisplayLeft.moveEventsBubble = !uiDisplayLeft.moveEventsBubble;
			uiDisplayLeft.overOutEventsBubble = !uiDisplayLeft.overOutEventsBubble;
			uiDisplayLeft.upDownEventsBubble = !uiDisplayLeft.upDownEventsBubble;
			uiDisplayLeft.wheelEventsBubble = !uiDisplayLeft.wheelEventsBubble;
			if (uiDisplayLeft.moveEventsBubble) uiElement.style.color = Color.GREEN;
			else uiElement.style.color = Color.RED;
			uiElement.updateStyle();
		};
		uiDisplayLeft.add(bubbleToDisplay);

		createButton(uiDisplayLeft, "swap uiDisplays", 25, 106).onPointerClick = function onClick(uiElement:UIElement, e:PointerEvent) {
			uiDisplayLeft.swapDisplay(uiDisplayRight);
		};
		

		peoteView.addDisplay(uiDisplayLeft);
		

		// ----------------------------- right UIDisplay -----------------------------------

		uiDisplayRight = new PeoteUIDisplay(30, 50, 350, 400, Color.GREY3);

		uiDisplayRight.setDragArea(0, 0, window.width, window.height);
		
		uiDisplayRight.onPointerOver  = function(uiDisplay:PeoteUIDisplay, e:PointerEvent) { trace("uiDisplayRight onPointerOver"); uiDisplay.color = Color.BLUE; };
		uiDisplayRight.onPointerOut   = function(uiDisplay:PeoteUIDisplay, e:PointerEvent) { trace("uiDisplayRight onPointerOut"); uiDisplay.color = Color.GREY3; };
		uiDisplayRight.onPointerDown  = function(uiDisplay:PeoteUIDisplay, e:PointerEvent) {
			trace("uiDisplayRight onPointerDown");
			uiDisplay.startDragging(e);
		};
		uiDisplayRight.onPointerUp    = function(uiDisplay:PeoteUIDisplay, e:PointerEvent) { trace("uiDisplayRight onPointerUp"); uiDisplay.stopDragging(e); };
		uiDisplayRight.onPointerClick = function(uiDisplay:PeoteUIDisplay, e:PointerEvent) { trace("uiDisplayRight onPointerClick"); };
		//uiDisplayRight.onPointerMove  = function(uiDisplay:UIDisplay, e:PointerEvent) { trace("uiDisplayRight onPointerMove"); };
		
		// inserting before the left one into RenderList
		//peoteView.addDisplay(uiDisplayRight, uiDisplayLeft, true);
		
		createButton(uiDisplayRight, "hide/show left", 20, 0).onPointerClick = function onClick(uiElement:UIElement, e:PointerEvent) {
			if (uiDisplayLeft.isVisible) uiDisplayLeft.hide() else uiDisplayLeft.show();
		};
		
		createButton(uiDisplayRight, "de/activate left", 25, 53).onPointerClick = function onClick(uiElement:UIElement, e:PointerEvent) {
			if (uiDisplayLeft.isActive) uiDisplayLeft.deactivate() else uiDisplayLeft.activate();
		};
		
		// bubbling to other Display on/off
		var bubbleToDisplay = new UIElement(290, 10, 50, 50, new RoundBorderStyle(Color.RED, Color.GREY5, 2.0, 20.0));
		bubbleToDisplay.onPointerClick = function onClick(uiElement:UIElement, e:PointerEvent) {
			// turn bubbling to display on/off
			uiDisplayRight.moveEventsBubble = !uiDisplayRight.moveEventsBubble;
			uiDisplayRight.overOutEventsBubble = !uiDisplayRight.overOutEventsBubble;
			uiDisplayRight.upDownEventsBubble = !uiDisplayRight.upDownEventsBubble;
			uiDisplayRight.wheelEventsBubble = !uiDisplayRight.wheelEventsBubble;
			if (uiDisplayRight.wheelEventsBubble) uiElement.style.color = Color.GREEN;
			else uiElement.style.color = Color.RED;
			uiElement.updateStyle();
		};
		uiDisplayRight.add(bubbleToDisplay);
		//uiDisplayRight.moveEventsBubble = true;
		
		createButton(uiDisplayRight, 0, 140, 300, 250, true,
			createButton(uiDisplayRight, 0, 240, 250, 150, 1, true,
				createButton(uiDisplayRight, 0, 290, 150, 100, 2, true)	
			)	
		);

		peoteView.addDisplay(uiDisplayRight);
		
		// -----------------------------------------------------------------------------------
		
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
		
		PeoteUIDisplay.registerEvents(window);
		
		//UIDisplay.unRegisterEvents(window);			
	}
	
	public function createButton(uiDisplay:PeoteUIDisplay, text = "", x:Int, y:Int, w:Int = 200, h:Int = 50, z:Int = 0, helpers = false, child:UIElement = null ):UIElement {
		var button = new UIElement(x, y, w, h, z, style.copy());
		button.onPointerOver = onOver.bind(Color.GREY2);
		button.onPointerOut = onOut.bind(Color.GREY1);
		button.onPointerDown = onDown.bind(Color.YELLOW);
		button.onPointerUp = onUp.bind(Color.GREY5);
		button.onPointerClick = function(uiElement:UIElement, e:PointerEvent) { trace("uiElement onPointerClick"); };
		uiDisplay.add(button);
		
		if (text != "") {
			var textLine = new TextLine(x, y, w, h, z, text, font, fontStyle, {hAlign:HAlign.CENTER, vAlign:VAlign.CENTER});
			uiDisplay.add(textLine);
		}
		
		if (helpers) 
		{
			var bubbleStyle = style.copy();
			bubbleStyle.color = Color.RED;
			
			var lw = Std.int(Math.max(10, Math.min(50, Std.int(w / 4))));
			var lh = Std.int(Math.max(10, Math.min(50, h / 2.75)));
			var gap =Std.int(Math.min(10, (h - 2 * lh) / 3));
			
			var bubbleToDisplay = new UIElement(x + w - lw - gap, y + gap, lw, lh, z, bubbleStyle);
			button.overOutEventsBubbleToDisplay = false;
			bubbleToDisplay.onPointerClick = function onClick(uiElement:UIElement, e:PointerEvent) {
				// turn bubbling to display on/off
				button.moveEventsBubbleToDisplay = !button.moveEventsBubbleToDisplay;
				button.overOutEventsBubbleToDisplay = !button.overOutEventsBubbleToDisplay;
				button.upDownEventsBubbleToDisplay = !button.upDownEventsBubbleToDisplay;
				button.wheelEventsBubbleToDisplay = !button.wheelEventsBubbleToDisplay;
				
				if (button.moveEventsBubbleToDisplay) uiElement.style.color = Color.GREEN;
				else uiElement.style.color = Color.RED;
				
				uiElement.updateStyle();
			};
			uiDisplay.add(bubbleToDisplay);
		}
		
		if (child != null)
		{
			var bubbleStyle = style.copy();
			bubbleStyle.color = Color.RED;
			bubbleStyle.borderRadius = 0;
			
			var lw = Std.int(Math.max(10, Math.min(50, child.width / 4)));			
			var lh = Std.int(Math.max(10, Math.min(50, child.height / 2.75)));
			var gap =Std.int(Math.min(10, (child.height - 2 * lh) / 3));
		
			var bubbleToParent = new UIElement(child.x + child.width - lw - gap, child.y + gap + lh, lw, lh, child.z, bubbleStyle);
			bubbleToParent.onPointerClick = function onClick(uiElement:UIElement, e:PointerEvent) {
				// turn bubbling to parent on/off				
				if (child.moveEventsBubbleTo == null) {
					child.moveEventsBubbleTo = button;
					child.overOutEventsBubbleTo = button;
					child.upDownEventsBubbleTo = button;
					child.wheelEventsBubbleTo = button;
					uiElement.style.color = Color.GREEN;
				}
				else {
					child.moveEventsBubbleTo = null;
					child.overOutEventsBubbleTo = null;
					child.upDownEventsBubbleTo = null;
					child.wheelEventsBubbleTo = null;
					uiElement.style.color = Color.RED;
				}
				uiElement.updateStyle();
			};
			uiDisplay.add(bubbleToParent);
		}
		
		return button;
	}
	
	// ----------------- InteractiveElement Eventhandler ----------------------
	
	public inline function onOver(color:Color, uiElement:UIElement, e:PointerEvent) {
		//trace(" -----> onPointerOver", e);
		uiElement.style.color = color;
		if ((uiElement.style is RoundBorderStyle)) {
			uiElement.style.borderColor = Color.GREY7;
		}
		uiElement.updateStyle();
	}
	
	public inline function onOut(color:Color, uiElement:UIElement, e:PointerEvent) {
		//trace(" -----> onPointerOut", e);
		uiElement.style.color = color;
		if ((uiElement.style is RoundBorderStyle)) {
			uiElement.style.borderColor = Color.GREY5;
		}
		uiElement.updateStyle();
	}
	
	public inline function onMove(uiElement:UIElement, e:PointerEvent) {
		//trace(" -----> onPointerMove", e);
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
		
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	// override function onPreloadComplete() {}
	// override function update(deltaTime:Int) {}
	// override function onRenderContextLost ():Void trace(" --- WARNING: LOST RENDERCONTEXT --- ");		
	// override function onRenderContextRestored (context:RenderContext):Void trace(" --- onRenderContextRestored --- ");		

	override function onKeyDown(keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier) {
		switch (keyCode) {
			case lime.ui.KeyCode.NUMBER_1:
				if (uiDisplayLeft.isVisible) uiDisplayLeft.hide() else uiDisplayLeft.show();
			case lime.ui.KeyCode.NUMBER_2:
				if (uiDisplayRight.isVisible) uiDisplayRight.hide() else uiDisplayRight.show();
			default:
		}
	}

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
