package;

import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;
import peote.ui.util.TextSize;

import peote.view.PeoteView;
import peote.view.Color;

import peote.text.Font;

import peote.ui.UIDisplay;
import peote.ui.interactive.InteractiveTextLine;
import peote.ui.interactive.InteractiveElement;

import peote.ui.style.*;


class TestStyles extends Application
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
		var roundBorderStyle = new RoundBorderStyle(Color.GREEN);
		// alternatively:
		// var roundBorderStyle:RoundBorderStyle = { color:Color.RED, borderColor:Color.YELLOW }; // borderSize, borderRadius
		var textBgStyle = roundBorderStyle.copy(Color.GREY4);
		
		
		var cursorStyle = SimpleStyle.createById(1); // different id is need if using more then one into available styles
		// alternatively:
/*		var cursorStyle = SimpleStyle.createById(1, new SimpleStyle(Color.BLUE)); 
		var cursorStyle = SimpleStyle.createById(1 , { color: Color.BLUE });
		var cursorStyle = SimpleStyle.createById(1, simpleStyle); cursorStyle.color = Color.BLUE;
*/
		//var fontStylePacked = new FontStylePacked();
		var fontStylePacked:FontStylePacked = {
			width:20, height:20,
			//tilt: 0.6,
			//letterSpace: 1.0
		};
		
		//var fontStyleTiled = new FontStyleTiled();
		var fontStyleTiled = fontTiled.createFontStyle(); // alternative way of creation
		fontStyleTiled.letterSpace = -2.0;

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

		
		// ------------------------------------------
		// ----------- InteractiveElement -----------
		// ------------------------------------------
		
		var element = new InteractiveElement(10, 10, 300, 50, roundBorderStyle);
		element.onPointerOver = (_, _)-> trace("on element over");
		element.onPointerOut  = (_, _)-> trace("on element out");
		
		var x = 10;
		var y = 40;
		var h = 30;
		var size:TextSize = {height:25}
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "add/remove", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			if (!element.isVisible) uiDisplay.add(element) else uiDisplay.remove(element);
		}
		
		var b = fontTiled.createInteractiveTextLine(b.x+5+b.width, y, size, "show", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> element.show();
		
		var b = fontTiled.createInteractiveTextLine(b.x+5+b.width, y, size, "hide", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> element.hide();

		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "remove style", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			element.style = null;
		}
		
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "style on", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			// TODO
		}
		var b = fontTiled.createInteractiveTextLine(x+5+b.width, y, size, "style off", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			// TODO
		}
				
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "set simplestyle", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			element.style = simpleStyle;
		}
		
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "set roundBorderStyle", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			element.style = roundBorderStyle;
		}
		
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "change style color", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			element.style.color = Color.random();
			element.updateStyle();
		}
		
		// -------------------------------------------
		// ----------- InteractiveTextLine -----------
		// -------------------------------------------
		var backgroundSimpleStyle = simpleStyle.copy();
		var backgroundRoundStyle = roundBorderStyle.copy();
		
		var selectionSimpleStyle = simpleStyle.copy();
		var selectionRoundStyle = roundBorderStyle.copy();
		
		var cursorSimpleStyle = simpleStyle.copy();
		var cursorRoundStyle = roundBorderStyle.copy();
		
		var textStyle:TextLineStyle = {
			backgroundStyle:backgroundSimpleStyle,
			selectionStyle:selectionSimpleStyle,
			cursorStyle:cursorSimpleStyle
		}

		var textLine = new InteractiveTextLine<FontStylePacked>(250, 25, "Hello World", fontPacked, fontStylePacked, textStyle);
		
		x = 270;
		y = 40;
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "add/remove", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			if (!textLine.isVisible) uiDisplay.add(textLine) else uiDisplay.remove(textLine);
		}
		
		var b = fontTiled.createInteractiveTextLine(b.x+5+b.width, y, size, "show", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> textLine.show();
		
		var b = fontTiled.createInteractiveTextLine(b.x+5+b.width, y, size, "hide", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> textLine.hide();

		// ------------ background Style ------------
		
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "bg remove style", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			textLine.backgroundStyle = null;
		}
		
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "bg style on", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			// TODO
		}
		var b = fontTiled.createInteractiveTextLine(x+5+b.width, y, size, "bg style off", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			// TODO
		}
		
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "bg set simplestyle", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			textLine.backgroundStyle = backgroundSimpleStyle;
		}
		
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "bg set roundBorderStyle", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			textLine.backgroundStyle = backgroundRoundStyle;
		}
		
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "bg style change color", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			textLine.backgroundStyle.color = Color.random();
			textLine.updateStyle();
		}
		
		// ------------ selection Style ------------
		y += 10;
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "selection remove style", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			textLine.selectionStyle = null;
		}
		
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "selection on", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			textLine.selectionShow();
		}
		var b = fontTiled.createInteractiveTextLine(x+5+b.width, y, size, "selection off", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			textLine.selectionHide();
		}
		
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "selection set simplestyle", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			textLine.selectionStyle = selectionSimpleStyle;
		}
		
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "selection set roundBorderStyle", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			textLine.selectionStyle = selectionRoundStyle;
		}
		
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "selection style change color", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			textLine.selectionStyle.color = Color.random();
			textLine.updateStyle();
		}
			
		// ------------ cursor Style ------------
		
		y += 10;
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "cursor remove style", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			//textLine.selectionStyle = null;
		}
		
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "cursor on", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			//textLine.selectionShow();
		}
		var b = fontTiled.createInteractiveTextLine(x+5+b.width, y, size, "cursor off", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			//textLine.selectionHide();
		}
		
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "cursor set simplestyle", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			textLine.selectionStyle = cursorSimpleStyle;
		}
		
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "cursor set roundBorderStyle", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			//textLine.selectionStyle = cursorRoundStyle;
		}
		
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "cursor style change color", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			//textLine.selectionStyle.color = Color.random();
			//textLine.updateStyle();
		}
		
		// set text
		x = 600;
		y = 40;
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "changeText", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			if (textLine.text == "Hello World") textLine.setText("Hallo Welt", true, true, true) else textLine.setText("Hello World", true, true, true);
		}
		
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "change fontStyle color", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			textLine.fontStyle = fontStylePacked.copy(Color.random().setAlpha(1.0));
			textLine.updateStyle();
		}
		
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "change fontStyle big", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			textLine.fontStyle = fontStylePacked.copy(null, 30, 30);
			textLine.update();
		}
		
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "change fontStyle small", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			textLine.fontStyle = fontStylePacked.copy(null, 20, 20);
			textLine.update();
		}
		
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "E", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			
		}
		
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "F", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			
		}
		
		// set selection
		y += 10;		
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "select from 0 to 8", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			textLine.select(0,8);
		}
		
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "select from 4 to 10", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			textLine.select(4,10);
		}
		
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "select from 4 to 4", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			textLine.select(4,4);
		}
		
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "A", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			
		}
		
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "B", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			
		}
		
		y += 10;		
		// set cursor
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "set cursor to 0", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			// TODO
		}
		
		var b = fontTiled.createInteractiveTextLine(x, y+=h, size, "set cursor to 2", textBgStyle);
		uiDisplay.add(b);
		b.onPointerClick = (_, _)-> {
			// TODO
		}
		
		
		
/*
		// ----------- create Cursor -----------
		
		var cursor = new InteractiveElement(60, 55, 25, 25, SimpleStyle.createById(1, Color.YELLOW.setAlpha(0.7) ));
		uiDisplay.add(cursor);
		//trace(Type.getClassName(Type.getClass(button2.style)));
*/			

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
