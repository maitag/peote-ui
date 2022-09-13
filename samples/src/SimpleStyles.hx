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
		var simpleStyle  = new SimpleStyle(Color.RED);
		var roundBorderStyle = new RoundBorderStyle(Color.GREEN.setAlpha(0.6));
		// alternatively:
		// var roundBorderStyle:RoundBorderStyle = { color:Color.RED, borderColor:Color.YELLOW }; // borderSize, borderRadius
		
		var cursorStyle = SimpleStyle.createById(1); // different id is need if using more then one into available styles
		// alternatively:
/*		var cursorStyle = SimpleStyle.createById(1, new SimpleStyle(Color.BLUE)); 
		var cursorStyle = SimpleStyle.createById(1 , { color: Color.BLUE });
		var cursorStyle = SimpleStyle.createById(1, simpleStyle); cursorStyle.color = Color.BLUE;
*/
		//var fontStylePacked = new FontStylePacked();
		var fontStylePacked:FontStylePacked = {
			width:20, height:20,
			tilt: 0.6,
			letterSpace: 1.0
		};
		
		//var fontStyleTiled = new FontStyleTiled();
		var fontStyleTiled = fontTiled.createFontStyle(); // alternative way of creation
		fontStyleTiled.letterSpace = -2.0;

		var textStyle:TextLineStyle = {
			backgroundStyle:simpleStyle,
			selectionStyle:roundBorderStyle
		}

		peoteView = new PeoteView(window);
		uiDisplay = new UIDisplay(0, 0, window.width, window.height, Color.GREY1
		// available styles into render-order (without it will auto add at runtime and fontstyles allways on top)
			//,[ simpleStyle, roundBorderStyle, fontStylePacked, fontStyleTiled, cursorStyle]
			,[ simpleStyle, roundBorderStyle, fontStylePacked ], true // allow to auto add Styles
		);
		peoteView.addDisplay(uiDisplay);
		
		//uiDisplay.getStyleProgram(roundBorderStyle).alphaEnabled = false;
				
		uiDisplay.addFontStyleProgram(fontStyleTiled, fontTiled);		
		uiDisplay.addStyleProgram(cursorStyle, true).alphaEnabled = true;
		
		//var fontProgram:FontProgram<FontStylePacked> = cast uiDisplay.getFontStyleProgram(fontStylePacked, fontPacked);
		//fontProgram.createGlyph(65, 30, 25, fontStylePacked.copy(Color.RED));
		//trace(fontProgram.numberOfGlyphes());
		
		//uiDisplay.getFontStyleProgram(fontStyleTiled, fontTiled).alphaEnabled = false;				

		
		
		// ----------- create Buttons -----------
				
		var button0 = new InteractiveElement(10, 10, 100, 50, roundBorderStyle);
		uiDisplay.add(button0);
/*		haxe.Timer.delay(()->{
			if ((button0.style is RoundBorderStyle)) {
				button0.style.borderColor = Color.RED;
				button0.updateStyle();
			}
		}, 1000);
*/		
		var button1 = new InteractiveElement(40, 40, 200, 50, simpleStyle);
		uiDisplay.add(button1);
/*		haxe.Timer.delay(()->{
			// without these checks it will crash on Hashlink because SimpleStyle havn't borderColor
			if ((button1.style is RoundBorderStyle)) {
			//if (button1.style.borderColor != null) {
				button1.style.borderColor = Color.YELLOW;
				button1.updateStyle();
			}
		}, 4000);
*/
		
		// ----------- create TextLines -----------
				
		var textLine0 = new InteractiveTextLine<FontStylePacked>(30, 25, "hello ", fontPacked, fontStylePacked, textStyle);
		uiDisplay.add(textLine0);
		textLine0.select(1, 5);
		haxe.Timer.delay(()->{
			//textLine0.selectionStyle = roundBorderStyle.copy(Color.BLUE);
			textLine0.selectionStyle = SimpleStyle.createById(2, Color.BLUE);
		} , 500);
		//textLine0.hide();
		//textLine0.backgroundStyle.color = Color.YELLOW; textLine0.updateStyle();
		//textLine0.backgroundStyle = null;
		//textLine0.backgroundStyle = roundBorderStyle.copy(Color.YELLOW);
		//textLine0.backgroundStyle = simpleStyle.copy(Color.YELLOW);
		//textLine0.show();
/*		haxe.Timer.delay(()->{ uiDisplay.remove(textLine0); } , 500);
		haxe.Timer.delay(()->{ fontStylePacked.color = Color.YELLOW; textLine0.updateStyle(); }, 1000);
		haxe.Timer.delay(()->{ uiDisplay.add(textLine0); }, 1500);
		haxe.Timer.delay(()->{ textLine0.fontStyle.color = Color.BLUE; textLine0.updateStyle(); }, 2000);
		haxe.Timer.delay(()->{ textLine0.hide(); }, 2500);
		haxe.Timer.delay(()->{ textLine0.x += 100; textLine0.updateLayout(); }, 3000);
		haxe.Timer.delay(()->{ textLine0.show(); }, 3500);
*/		
		
		
		// or alternative way to create:
		var textLine1 = fontTiled.createInteractiveTextLine(50, 60, "Hi", fontStyleTiled);
		uiDisplay.add(textLine1);
		
		// or with default fontstyle way to create:
		var textLine2 = fontTiled.createInteractiveTextLine(100, 60, "there");
		uiDisplay.add(textLine2);

		// ----------- create Cursor -----------
		
		var cursor = new InteractiveElement(60, 55, 25, 25, SimpleStyle.createById(1, Color.YELLOW.setAlpha(0.7) ));
		uiDisplay.add(cursor);
		//trace(Type.getClassName(Type.getClass(button2.style)));
		

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
