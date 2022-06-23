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
		
		var xOffset:Int = 300;
		var yOffset:Int = 70;
		var x:Int = 10; 
		var y:Int = -yOffset + 10;
				
		var textLine = new InteractiveTextLine<FontStyle>(x, y+=yOffset, "hello", font, fontStyle, Color.BLACK); //, selectionFontStyle
		//var textLine = font.createInteractiveTextLine(x, y+=yOffset, "hello", fontStyle, Color.BLACK);
		addOverOut(textLine);
		//textLine.height = 50;
		//textLine.update();
		
		var textLine = new InteractiveTextLine<FontStyle>(x, y+=yOffset, {width:50, xOffset:10, yOffset:10}, "hello", font, fontStyle, Color.BLACK);
		var timer = new Timer(200);
		timer.run = function() {
			textLine.xOffset--;
			textLine.yOffset--;
			textLine.update();
			if (textLine.xOffset == 0) timer.stop();
		}
		addOverOut(textLine);
			
		var textLine = new InteractiveTextLine<FontStyle>(x, y+=yOffset, {width:50, hAlign:HAlign.RIGHT}, "hello", font, fontStyle, Color.BLACK);
		addOverOut(textLine);
			
		var textLine = new InteractiveTextLine<FontStyle>(x, y+=yOffset, {width:150, hAlign:HAlign.RIGHT}, "hello", font, fontStyle, Color.BLACK);
		addOverOut(textLine);
			
		var textLine = new InteractiveTextLine<FontStyle>(x, y+=yOffset, {width:50, hAlign:HAlign.CENTER}, "hello", font, fontStyle, Color.BLACK);
		addOverOut(textLine);
			
		var textLine = new InteractiveTextLine<FontStyle>(x, y+=yOffset, {width:150, hAlign:HAlign.CENTER}, "hello", font, fontStyle, Color.BLACK);
		addOverOut(textLine);
			
		var textLine = new InteractiveTextLine<FontStyle>(x, y+=yOffset, {height:50, vAlign:VAlign.BOTTOM}, "hello", font, fontStyle, Color.BLACK);
		addOverOut(textLine);
			
		var textLine = new InteractiveTextLine<FontStyle>(x, y+=yOffset, {height:20}, "hello", font, fontStyle, Color.BLACK);
		// all changings also should work if is hidden or not added!
		addOverOut(textLine);
		//textLine.hide();
		
		textLine.cursorShow();
		var timer = new Timer(500);
		timer.run = function() {
			textLine.cursorIsVisible = !textLine.cursorIsVisible;
		}
			
		// changing textlines afterwards
		haxe.Timer.delay(function() {
			//trace("change style after");
			//textLine.fontStyle = fontStyleTiled;
			//textLine.updateStyle();				
			
			//textLine.width = 200;
			textLine.setText("new Text", true, true); // forceAutoWidth and forceAutoHeight Booleans to fit size to textline-size
			
			textLine.select(4,6);
			
			// textLine.setStyle(fontStyle, 1, 4);
			textLine.cursor = 3;
			textLine.updateLayout();
			
			//uiDisplay.remove(textLine);
			haxe.Timer.delay(function() {
				textLine.height = 60; textLine.autoHeight = false;
				textLine.text = "larger Text";
				
				textLine.hAlign = HAlign.RIGHT;
				textLine.cursor += 4;
				
				textLine.updateLayout(); // updates style and layout
				
				textLine.selectionHide();
				
				//textLine.hide();
				//trace(textLine.text);
				//uiDisplay.add(textLine);
				
				haxe.Timer.delay(function() {
					textLine.backgroundColor = Color.GREY2;
					textLine.hAlign = HAlign.LEFT;
					textLine.cursor -= 4;
					textLine.fontStyle.color = Color.BLUE;
					textLine.update(); // updates style and layout
					
					haxe.Timer.delay(function() {
						textLine.autoWidth = false;
						textLine.width = 100;
						textLine.hAlign = HAlign.CENTER;
						textLine.cursor += 1;
						textLine.updateLayout(); // updates layout (including size-changes)
						
						haxe.Timer.delay(function() {
							textLine.selectionShow();

							textLine.cursor -= 1;
							textLine.vAlign = VAlign.BOTTOM;
							textLine.hAlign = HAlign.LEFT;
							textLine.xOffset = -10;
							textLine.updateLayout();
							
							haxe.Timer.delay(function() {
								textLine.select(4,1);
								textLine.width = 200;
								textLine.vAlign = VAlign.TOP;
								textLine.updateLayout(); // updates layout (including size-changes)
								
								haxe.Timer.delay(function() {
									textLine.setText("smaller", true, true, true); // last param for autoupdate
									
									//textLine.show();
									//addOverOut(textLine);
									//timer.stop(); textLine.cursorHide();
								}, 1000);								
							}, 1000);								
						}, 1000);
					}, 1000);
				}, 1000);
			}, 1000);
		}, 1000);

		
		// ---------------------------------------------------------------
		// ----------------------- input lines ---------------------------
		// ---------------------------------------------------------------
		
		x += xOffset;
		y = -yOffset + 10;
		
		var fontStyleInput = new FontStyle();
		//fontStyleInput.height = 30;
		fontStyleInput.width = 20;
		fontStyleInput.color = Color.GREY5;
		
		var inputLine = new InteractiveTextLine<FontStyle>(x, y+=yOffset, "input", font, fontStyleInput, Color.BLACK);
		//var inputLine = font.createInteractiveTextLine(x, y+=yOffset, "input", fontStyleInput, Color.BLACK);
		inputLine.cursor = 3;
		addInput(inputLine);
		
		var inputLine = new InteractiveTextLine<FontStyle>(x, y += yOffset, {width:50, xOffset:10, yOffset:10}, "input", font, fontStyleInput, 0x00000055);
		//inputLine.cursor = 3;
		inputLine.cursorShow();
		//inputLine.select(0,3);
		inputLine.select(3,0);
		addInput(inputLine);
		var timer = new Timer(400);
		timer.run = function() {
			inputLine.xOffset--;
			inputLine.yOffset--;
			inputLine.updateLayout();
			if (inputLine.xOffset == 5) inputLine.select(3, 1);
			if (inputLine.xOffset == 3) inputLine.hide();
			if (inputLine.xOffset == 1) inputLine.show();
			if (inputLine.xOffset == -3) inputLine.cursor = 1;
			if (inputLine.xOffset == -25) timer.stop();
		}
		
		var inputLine = new InteractiveTextLine<FontStyle>(x, y+=yOffset, {width:50, hAlign:HAlign.RIGHT}, "input", font, fontStyleInput, Color.BLACK);
		addInput(inputLine);
		
		var inputLine = new InteractiveTextLine<FontStyle>(x, y += yOffset, {width:150, hAlign:HAlign.RIGHT}, "input", font, fontStyleInput, 0x00000055);
		inputLine.select(1, 2);
		//inputLine.cursorShow();
		addInput(inputLine);
			
		var inputLine = new InteractiveTextLine<FontStyle>(x, y+=yOffset, {width:50, hAlign:HAlign.CENTER}, "input", font, fontStyleInput, Color.BLACK);
		addInput(inputLine);
			
		var inputLine = new InteractiveTextLine<FontStyle>(x, y+=yOffset, {width:150, height:60, hAlign:HAlign.CENTER, vAlign:VAlign.TOP}, "input", font, fontStyleInput, Color.BLACK);
		addInput(inputLine);
			
		var inputLine = new InteractiveTextLine<FontStyle>(x, y+=yOffset, {height:60}, "input", font, fontStyleInput, Color.BLACK);
		addInput(inputLine);
			
		var inputLine = new InteractiveTextLine<FontStyle>(x, y+=yOffset, {width:150, height:60, vAlign:VAlign.BOTTOM}, "input", font, new FontStyle()); // new FontStyle here to not affect the other inputLines
		addInput(inputLine);
		inputLine.backgroundColor = Color.BLUE;
		haxe.Timer.delay(function() {
			inputLine.hide();
			inputLine.backgroundColor = Color.YELLOW;
			haxe.Timer.delay(function() {
				inputLine.show();
				inputLine.fontStyle.color = Color.BLACK;
				inputLine.updateStyle();
			}, 1000);
		}, 1000);
		
		//uiDisplay.x = 50;
		//uiDisplay.zoom = 1.2;
		//uiDisplay.xOffset = 100;
		//peoteView.zoom = 1.3;
		//peoteView.xOffset = -170;
	}
	
	public function addOverOut(textLine:InteractiveTextLine<FontStyle>)
	{
		textLine.onPointerOver = function(t:InteractiveTextLine<FontStyle>, e:PointerEvent) {
			//trace("onPointerOver");
			t.fontStyle.color = Color.YELLOW;
			t.updateStyle();
		}
		textLine.onPointerOut = function(t:InteractiveTextLine<FontStyle>, e:PointerEvent) {
			//trace("onPointerOut");
			t.fontStyle.color = Color.GREEN;
			t.updateStyle();
		}
		textLine.onPointerDown = function(t:InteractiveTextLine<FontStyle>, e:PointerEvent) {
			//trace("onPointerDown");
			t.startSelection(e);
		}
		textLine.onPointerUp = function(t:InteractiveTextLine<FontStyle>, e:PointerEvent) {
			//trace("onPointerUp");
			t.stopSelection(e);
		}
		uiDisplay.add(textLine);
	}
	
	public function addInput(textLine:InteractiveTextLine<FontStyle>) 
	{
		textLine.onPointerDown = function(t:InteractiveTextLine<FontStyle>, e:PointerEvent) {
			//trace("onPointerDown");
			t.setInputFocus(e); // alternatively: uiDisplay.setInputFocus(t);
			t.startSelection(e);
		}
		textLine.onPointerUp = function(t:InteractiveTextLine<FontStyle>, e:PointerEvent) {
			//trace("onPointerUp");
			t.stopSelection(e);
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
