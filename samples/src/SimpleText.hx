package;

import haxe.CallStack;
import haxe.Timer;

import peote.ui.util.HAlign;
import peote.ui.util.VAlign;

import lime.app.Application;
import lime.ui.Window;
import lime.graphics.RenderContext;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.ui.MouseWheelMode;
import lime.ui.Touch;

import peote.view.PeoteView;
import peote.view.Color;

import peote.text.Font;

import peote.ui.fontstyle.FontStyleTiled;
import peote.ui.fontstyle.FontStylePacked;

import peote.ui.UIDisplay;
import peote.ui.interactive.InteractiveTextLine;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;

#if packed 
@packed // for ttfcompile types (gl3font)
#end
class FontStyle
{
	public var color:Color = Color.GREEN;
	public var width:Float = 20; // <- if this is MISSING -> TODO !!!!!!!!!!!!!!
	
	//public var height:Float = 25;
	
	#if packed 
	@global public var weight = 0.48;
	#end	
	
	public function new() {}
}

class SimpleText extends Application
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
		uiDisplay = new UIDisplay(0, 0, window.width, window.height, Color.GREY1);
		peoteView.addDisplay(uiDisplay);
			
		// load the FONT:
		#if packed 
		new Font<FontStyle>("assets/fonts/packed/hack/config.json").load( onFontLoaded );
		#else
		new Font<FontStyle>("assets/fonts/tiled/hack_ascii.json").load( onFontLoaded );
		#end
		
		//peoteView.zoom = 2;

		#if android
		uiDisplay.mouseEnabled = false;
		peoteView.zoom = 3;
		#end
		
		// TODO: set what events to register (mouse, touch, keyboard ...)
		UIDisplay.registerEvents(window);

	}
		
	public function onFontLoaded(font:Font<FontStyle>) // don'T forget argument-type here !
	{					
		var fontStyle = new FontStyle();
		//fontStyleInput.height = 30;
		//fontStyleInput.width = 20;
		
		var xOffset:Int = 200;
		var yOffset:Int = 60;
		var x:Int = 0; 
		var y:Int = -yOffset;
				
		var textLine = new InteractiveTextLine<FontStyle>(x, y+=yOffset, "hello", font, fontStyle, Color.BLACK); //, selectionFontStyle
		//var textLine = font.createInteractiveTextLine(x, y+=yOffset, "hello", fontStyle, Color.BLACK);
		addAndSetEvents(textLine);
		//textLine.height = 50;
		//textLine.update();
		
		var textLine = new InteractiveTextLine<FontStyle>(x, y+=yOffset, {width:50}, "hello", font, fontStyle, Color.BLACK);
		addAndSetEvents(textLine);
			
		var textLine = new InteractiveTextLine<FontStyle>(x, y+=yOffset, {width:50, hAlign:HAlign.RIGHT}, "hello", font, fontStyle, Color.BLACK);
		addAndSetEvents(textLine);
			
		var textLine = new InteractiveTextLine<FontStyle>(x, y+=yOffset, {width:150, hAlign:HAlign.RIGHT}, "hello", font, fontStyle, Color.BLACK);
		addAndSetEvents(textLine);
			
		var textLine = new InteractiveTextLine<FontStyle>(x, y+=yOffset, {width:50, hAlign:HAlign.CENTER}, "hello", font, fontStyle, Color.BLACK);
		addAndSetEvents(textLine);
			
		var textLine = new InteractiveTextLine<FontStyle>(x, y+=yOffset, {width:150, hAlign:HAlign.CENTER}, "hello", font, fontStyle, Color.BLACK);
		addAndSetEvents(textLine);
			
		var textLine = new InteractiveTextLine<FontStyle>(x, y+=yOffset, {height:50, vAlign:VAlign.BOTTOM}, "hello", font, fontStyle, Color.BLACK);
		addAndSetEvents(textLine);
			
		var textLine = new InteractiveTextLine<FontStyle>(x, y+=yOffset, {width:50, height:20}, "hello", font, fontStyle, Color.BLACK);
		addAndSetEvents(textLine);
		textLine.cursorShow();
		textLine.cursor = 2;
			
		// changing textlines afterwards
		haxe.Timer.delay(function() {
			//trace("change style after");
			//textLine.fontStyle = fontStyleTiled;
			//textLine.updateStyle();				
			
			textLine.width = 200;
			textLine.setText("new Text", false, true); //textLine.text = "new Text";
			
			textLine.hAlign = HAlign.RIGHT;
			// textLine.setStyle(fontStyle, 1, 4);
			textLine.update();
			
			//uiDisplay.remove(textLine);
			haxe.Timer.delay(function() {
				textLine.width = 140;
				textLine.height = 50;
				textLine.hAlign = HAlign.CENTER;
				textLine.update();
					
				//trace(textLine.text);
				//uiDisplay.add(textLine);
				
				haxe.Timer.delay(function() {
					textLine.setAutoHeight();
					textLine.backgroundColor = Color.GREY2;
					textLine.update();
				}, 1000);
				
				
			}, 1000);
			
		}, 1000);

			
		// --------- InteractiveTextLine cursor, selection and editing ------------
		var textLine = new InteractiveTextLine<FontStyle>(x, y+=yOffset, {width:50, height:20}, "hello", font, fontStyle, Color.BLACK);
		addAndSetEvents(textLine);
		
		textLine.cursorShow();
		textLine.cursorHide();
		var timer = new Timer(500);
		timer.run = function() {
			textLine.cursorIsVisible = !textLine.cursorIsVisible;
		}
		
		textLine.cursor = 2;
		//textLine.cursorToStart();
		//textLine.cursorToEnd();
		
		var timer = new Timer(1000); Timer.delay(function() timer.stop(), 4100);
		timer.run = function() {
			//textLine.cursorRight();
			var timer = new Timer(1000); Timer.delay(function() timer.stop(), 4100);
			timer.run = function() {
				//textLine.cursorLeft();
			}		
		}		
		
		// ---------------- input lines ---------------------
		y = -yOffset;
		
		var fontStyleInput = new FontStyle();
		//fontStyleInput.height = 30;
		fontStyleInput.width = 20;
		fontStyleInput.color = Color.GREY5;
		
		var inputLine = new InteractiveTextLine<FontStyle>(x+=xOffset, y+=yOffset, {width:250}, "input line", font, fontStyleInput, Color.BLACK);
		//var inputLine = font.createInteractiveTextLine(x+=xOffset, y+=yOffset, {width:250}, "input line", fontStyleInput, Color.BLACK); //, selectionFontStyle
		uiDisplay.add(inputLine);
		
		inputLine.onPointerDown = function(t:InteractiveTextLine<FontStyle>, e:PointerEvent) {
			trace("onPointerDown");
			t.setInputFocus();
			//uiDisplay.setInputFocus(t);
		}

	}
	
	public function addAndSetEvents(textLine:InteractiveTextLine<FontStyle>) 
	{
			textLine.onPointerOver = function(t:InteractiveTextLine<FontStyle>, e:PointerEvent) {
				trace("onPointerOver");
				t.fontStyle.color = Color.YELLOW;
				t.updateStyle();
			}
			textLine.onPointerOut = function(t:InteractiveTextLine<FontStyle>, e:PointerEvent) {
				trace("onPointerOut");
				t.fontStyle.color = Color.GREEN;
				t.updateStyle();
			}
			uiDisplay.add(textLine);
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
