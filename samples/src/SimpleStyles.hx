package;

import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Color;

import peote.text.Font;

import peote.ui.UIDisplay;
import peote.ui.interactive.InteractiveTextLine;

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
		
		//var roundedStyle = new RoundedStyle();
		var simpleStyle  = new SimpleStyle();
		//var cursorStyle  = new SimpleStyle();

		//var fontStylePacked = new FontStylePacked(fontPacked);
		var fontStylePacked = new FontStylePacked(); trace(fontStylePacked.id);
		//var fontStyleTiled = new FontStyleTiled(fontTiled);

		//var fontStylePacked = fontPacked.createFontStyle();
		var fontStyleTiled = fontTiled.createFontStyle(); trace(fontStyleTiled.id);

		peoteView = new PeoteView(window);
		uiDisplay = new UIDisplay(0, 0, window.width, window.height, Color.GREY1 ,
			[simpleStyle, fontStylePacked, fontStyleTiled]
		);
		peoteView.addDisplay(uiDisplay);
		
/*		// set different style properties
		roundedStyle.color = Color.BLUE;
		simpleStyle.color = Color.GREEN;
		cursorStyle.color = Color.RED;

		var button0 = new InteractiveElement(x, y, w, h, roundedStyle);
		var button1 = new InteractiveElement(x, y, w, h, simpleStyle);

		// to make style unique (e.g. for changing by event)
		var simpleStyle1 = simpleStyle.clone();
		simpleStyle1.color = Color.YELLOW;
		var button2 = new InteractiveElement(x, y, w, h, simpleStyle1);

		// set different style properties
		fontStylePacked.backgroundStyle = roundedStyle;
		fontStylePacked.selectionStyle = simpleStyle;
		fontStylePacked.cursorStyle = cursorStyle;
*/		fontStylePacked.color = Color.RED;
				
		var textLine0 = new InteractiveTextLine<FontStylePacked>(10, 100, "hello", fontPacked, fontStylePacked);
		uiDisplay.add(textLine0);
		// or alternative way to create:
		var textLine1 = fontTiled.createInteractiveTextLine(20, 110, "hello", fontStyleTiled);		
		uiDisplay.add(textLine1);

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
