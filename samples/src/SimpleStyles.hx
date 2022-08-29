package;

import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Color;

import peote.text.Font;

import peote.ui.UIDisplay;
import peote.ui.interactive.InteractiveTextLine;
import peote.ui.interactive.InteractiveElement;

import peote.ui.util.HAlign;
import peote.ui.util.VAlign;

import peote.ui.style.*;


class SimpleStyles extends Application
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
		// load the FONTs:
		new Font<FontStylePacked>("assets/fonts/packed/hack/config.json").load( 
			function(fontPacked:Font<FontStylePacked>) {
				new Font<FontStyleTiled>("assets/fonts/tiled/hack_ascii.json").load(
					function(fontTiled:Font<FontStyleTiled>) {
						onFontLoaded(fontPacked, fontTiled);
					}
				);
			}
		);
	}
		
	public function onFontLoaded(fontPacked:Font<FontStylePacked>, fontTiled:Font<FontStyleTiled>) // font needs type here !
	{							
		var roundBorderStyle = new RoundBorderStyle();
		var simpleStyle  = new SimpleStyle();  // id is 0 by default
		var cursorStyle  = new SimpleStyle(1); // if using multiple times into new UIDisplays availableStyles they need different id 

		var fontStylePacked = new FontStylePacked();
		var fontStyleTiled = fontTiled.createFontStyle(); // alternative way of creation

		peoteView = new PeoteView(window);
		uiDisplay = new UIDisplay(0, 0, window.width, window.height, Color.GREY1 ,
			[ roundBorderStyle, simpleStyle, fontStylePacked, fontStyleTiled, cursorStyle]
		);
		peoteView.addDisplay(uiDisplay);
		
				
		// set different style properties
		roundBorderStyle.color = Color.BLUE;
		simpleStyle.color = Color.GREEN;
		//cursorStyle.color = Color.RED;

		var button0 = new InteractiveElement(100, 0, 100, 50, roundBorderStyle);
		uiDisplay.add(button0);
		haxe.Timer.delay(()->{
			if ((button0.style is RoundBorderStyle)) {
				button0.style.borderColor = Color.RED;
				button0.updateStyle();
			}
		}, 1000);
		
		var button1 = new InteractiveElement(100, 100, 100, 50, simpleStyle);
		uiDisplay.add(button1);
		haxe.Timer.delay(()->{ uiDisplay.remove(button1); } , 500);
		haxe.Timer.delay(()->{ simpleStyle.color = Color.RED; button1.updateStyle(); }, 1000);
		haxe.Timer.delay(()->{ uiDisplay.add(button1); }, 1500);
		haxe.Timer.delay(()->{ button1.style.color = Color.BLUE; button1.updateStyle(); }, 2000);
		haxe.Timer.delay(()->{ button1.hide(); }, 2500);
		haxe.Timer.delay(()->{ button1.x += 100; button1.updateLayout(); }, 3000);
		haxe.Timer.delay(()->{ button1.show(); }, 3500);
		haxe.Timer.delay(()->{
			// without these check or (button1.style.borderColor != null) it will crash on Hashlink because SimpleStyle havn't borderColor
			if ((button1.style is RoundBorderStyle)) {
				button1.style.borderColor = Color.YELLOW;
				button1.updateStyle();
			}
		}, 4000);

		// to make style unique (e.g. for changing by event)
		var simpleStyle1 = new SimpleStyle(1); //cursorStyle.copy();
		simpleStyle1.color = Color.YELLOW;
		var button2 = new InteractiveElement(100, 200, 100, 50, simpleStyle1);
		uiDisplay.add(button2);
		//trace(Type.getClassName(Type.getClass(button2.style)));
		
		// set different fontStyle properties
		//fontStylePacked.backgroundStyle = roundedStyle;
		//fontStylePacked.selectionStyle = simpleStyle;
		//fontStylePacked.cursorStyle = cursorStyle;
		fontStylePacked.color = Color.RED;
				
		var textLine0 = new InteractiveTextLine<FontStylePacked>(10, 100, "hello", fontPacked, fontStylePacked);
		uiDisplay.add(textLine0);
		haxe.Timer.delay(()->{ uiDisplay.remove(textLine0); } , 500);
		haxe.Timer.delay(()->{ fontStylePacked.color = Color.YELLOW; textLine0.updateStyle(); }, 1000);
		haxe.Timer.delay(()->{ uiDisplay.add(textLine0); }, 1500);
		haxe.Timer.delay(()->{ textLine0.fontStyle.color = Color.BLUE; textLine0.updateStyle(); }, 2000);
		haxe.Timer.delay(()->{ textLine0.hide(); }, 2500);
		haxe.Timer.delay(()->{ textLine0.x += 100; textLine0.updateLayout(); }, 3000);
		haxe.Timer.delay(()->{ textLine0.show(); }, 3500);
		
		
		
		// or alternative way to create:
		fontStyleTiled.color = Color.RED;
		var textLine1 = fontTiled.createInteractiveTextLine(20, 110, "hello", fontStyleTiled);
		uiDisplay.add(textLine1);

		
		// or with default fontstyle way to create:
		var textLine2 = fontTiled.createInteractiveTextLine(20, 220, "hello again");
		uiDisplay.add(textLine2);

		
		//uiDisplay.x = 50;
		//uiDisplay.zoom = 1.2;
		//uiDisplay.xOffset = 100;
		//peoteView.zoom = 1.3;
		//peoteView.xOffset = -170;
		
		//peoteView.zoom = 2;

		#if android
		uiDisplay.mouseEnabled = false;
		peoteView.zoom = 3;
		#end
		
		// TODO: set what events to register (mouse, touch, keyboard ...)
		UIDisplay.registerEvents(window);
	}
	

	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	// override function onWindowResize (width:Int, height:Int) { trace("onWindowResize"); }
	// override function onWindowEnter():Void { trace("onWindowEnter"); }
	// override function onWindowActivate():Void { trace("onWindowActivate"); }
	// override function onWindowDeactivate():Void { trace("onWindowDeactivate"); }
	// override function onWindowClose():Void { trace("onWindowClose"); }
	// override function onWindowDropFile(file:String):Void { trace("onWindowDropFile"); }
	// override function onWindowExpose():Void { trace("onWindowExpose"); }
	// override function onWindowFocusIn():Void { trace("onWindowFocusIn"); }
	// override function onWindowFocusOut():Void { trace("onWindowFocusOut"); }
	// override function onWindowFullscreen():Void { trace("onWindowFullscreen"); }
	// override function onWindowMove(x:Float, y:Float):Void { trace("onWindowMove"); }
	// override function onWindowMinimize():Void { trace("onWindowMinimize"); }
	// override function onWindowRestore():Void { trace("onWindowRestore"); }
}
