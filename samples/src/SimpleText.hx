package;

import haxe.CallStack;
import haxe.Timer; 
import peote.ui.style.RoundBorderStyle;
import peote.ui.style.SimpleStyle;
import peote.ui.style.TextLineStyle;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Color;

import peote.text.Font;

import peote.ui.UIDisplay;
import peote.ui.interactive.InteractiveTextLine;
import peote.ui.event.PointerEvent;
//import peote.ui.event.WheelEvent;
import peote.ui.util.HAlign;
import peote.ui.util.VAlign;
import peote.ui.util.Unique;

import peote.ui.style.interfaces.Style;
import peote.ui.style.interfaces.FontStyle;
import peote.ui.style.interfaces.StyleID;


#if packed 
@packed // for ttfcompile types (gl3font)
#end
@:structInit
class MyFontStyle implements FontStyle implements StyleID
{
	public var color:Color = Color.GREEN;
	
	#if packed 
	public var width:Float = 38; // (<- is it still fixed to get from font-defaults if this is MISSING ?)
	public var height:Float = 36;
	@global public var weight = 0.5;
	#else
	public var width:Float = 20;
	public var height:Float = 36;
	#end
		
	// -----------------------------------------
	
	static var ID:Int = Unique.fontStyleID;
	public inline function getID():Int return ID;
	public var id(default, null):Int;
		
	public function new(id:Int = 0) {
		this.id = id;
	}
	
	public inline function copy():MyFontStyle {
		return new MyFontStyle(id);
	}
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
		// load the FONT:
		#if packed 
		new Font<MyFontStyle>("assets/fonts/packed/hack/config.json").load( onFontLoaded );
		#else
		new Font<MyFontStyle>("assets/fonts/tiled/hack_ascii.json").load( onFontLoaded );
		#end		
	}
		
	public function onFontLoaded(font:Font<MyFontStyle>) // don'T forget argument-type here !
	{					
		var fontStyle = new MyFontStyle();
		//fontStyle.height = 30;
		//fontStyle.width = 20;
		
		var backgroundStyle = new SimpleStyle(Color.BLACK);
		
		var textStyle:TextLineStyle = {
			backgroundStyle:backgroundStyle
		}
		
		peoteView = new PeoteView(window);
		uiDisplay = new UIDisplay(0, 0, window.width, window.height, Color.GREY1);
		//uiDisplay = new UIDisplay(0, 0, window.width, window.height, Color.GREY1, [backgroundStyle, fontStyle]);
		peoteView.addDisplay(uiDisplay);		
		
		var xOffset:Int = 300;
		var yOffset:Int = 70;
		var x:Int = 10; 
		var y:Int = -yOffset + 10;
				
		var textLine = new InteractiveTextLine<MyFontStyle>(x, y+=yOffset, "hello", font, fontStyle, textStyle);
		// alternatively it can also be:
		//var textLine = font.createInteractiveTextLine(x, y+=yOffset, "hello", fontStyle, Color.BLACK);
		addOverOut(textLine);
		//textLine.height = 50;
		//textLine.update();
		
		var textLine = new InteractiveTextLine<MyFontStyle>(x, y+=yOffset, {width:50, xOffset:10, yOffset:10}, "hello", font, textStyle);
		var timer = new Timer(200);
		timer.run = function() {
			textLine.xOffset--;
			textLine.yOffset--;
			textLine.update();
			if (textLine.xOffset == 0) timer.stop();
		}
		addOverOut(textLine);
			
		var textLine = new InteractiveTextLine<MyFontStyle>(x, y+=yOffset, {width:50, hAlign:HAlign.RIGHT}, "hello", font, textStyle);
		addOverOut(textLine);
			
		var textLine = new InteractiveTextLine<MyFontStyle>(x, y+=yOffset, {width:150, hAlign:HAlign.RIGHT}, "hello", font, textStyle);
		addOverOut(textLine);
			
		var textLine = new InteractiveTextLine<MyFontStyle>(x, y+=yOffset, {width:50, hAlign:HAlign.CENTER}, "hello", font, textStyle);
		addOverOut(textLine);
			
		var textLine = new InteractiveTextLine<MyFontStyle>(x, y+=yOffset, {width:150, hAlign:HAlign.CENTER}, "hello", font, textStyle);
		addOverOut(textLine);
			
		var textLine = new InteractiveTextLine<MyFontStyle>(x, y+=yOffset, {height:50, vAlign:VAlign.BOTTOM}, "hello", font, textStyle);
		addOverOut(textLine);
			
		var textLine = new InteractiveTextLine<MyFontStyle>(x, y+=yOffset, {height:20}, "hello", font, {backgroundStyle:backgroundStyle.copy()});
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
					textLine.backgroundStyle.color = Color.GREY2;
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
		
		var fontStyleInput = new MyFontStyle();
		fontStyleInput.color = Color.GREY5;
		//fontStyleInput.height = 30;
		//fontStyleInput.width = 20;
		
		var inputLine = new InteractiveTextLine<MyFontStyle>(x, y+=yOffset, "input", font, fontStyleInput, textStyle);
		//var inputLine = font.createInteractiveTextLine(x, y+=yOffset, "input", fontStyleInput, Color.BLACK);
		inputLine.cursor = 3;
		addInput(inputLine);
		
		var inputLine = new InteractiveTextLine<MyFontStyle>(x, y += yOffset, {width:50, xOffset:10, yOffset:10}, "input", font, fontStyleInput, textStyle);
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
		
		var inputLine = new InteractiveTextLine<MyFontStyle>(x, y+=yOffset, {width:50, hAlign:HAlign.RIGHT}, "input", font, fontStyleInput, textStyle);
		addInput(inputLine);
		
		var inputLine = new InteractiveTextLine<MyFontStyle>(x, y += yOffset, {width:150, hAlign:HAlign.RIGHT}, "input", font, fontStyleInput, textStyle);
		inputLine.select(1, 2);
		//inputLine.cursorShow();
		addInput(inputLine);
			
		var inputLine = new InteractiveTextLine<MyFontStyle>(x, y+=yOffset, {width:50, hAlign:HAlign.CENTER}, "input", font, fontStyleInput, textStyle);
		addInput(inputLine);
			
		var inputLine = new InteractiveTextLine<MyFontStyle>(x, y+=yOffset, {width:150, height:60, hAlign:HAlign.CENTER, vAlign:VAlign.TOP}, "input", font, fontStyleInput, textStyle);
		addInput(inputLine);
			
		var inputLine = new InteractiveTextLine<MyFontStyle>(x, y+=yOffset, {height:60}, "input", font, fontStyleInput, textStyle);
		addInput(inputLine);
			
		var inputLine = new InteractiveTextLine<MyFontStyle>(x, y += yOffset, {width:150, height:60, vAlign:VAlign.BOTTOM}, "input", font,
			new MyFontStyle(), {backgroundStyle:new RoundBorderStyle()}); // new MyFontStyle here and new TextLineStyle to not affect the other inputLines
		inputLine.backgroundStyle.color = Color.BLUE;
		addInput(inputLine);
		haxe.Timer.delay(function() {
			inputLine.hide();
			inputLine.backgroundStyle.color = Color.YELLOW;
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

		#if android
		uiDisplay.mouseEnabled = false;
		peoteView.zoom = 3;
		#end
		
		// TODO: set what events to register (mouse, touch, keyboard ...)
		UIDisplay.registerEvents(window);

	}
	
	public function addOverOut(textLine:InteractiveTextLine<MyFontStyle>)
	{
		textLine.onPointerOver = function(t:InteractiveTextLine<MyFontStyle>, e:PointerEvent) {
			//trace("onPointerOver");
			t.fontStyle.color = Color.YELLOW;
			t.updateStyle();
		}
		textLine.onPointerOut = function(t:InteractiveTextLine<MyFontStyle>, e:PointerEvent) {
			//trace("onPointerOut");
			t.fontStyle.color = Color.GREEN;
			t.updateStyle();
		}
		textLine.onPointerDown = function(t:InteractiveTextLine<MyFontStyle>, e:PointerEvent) {
			//trace("onPointerDown");
			t.startSelection(e);
		}
		textLine.onPointerUp = function(t:InteractiveTextLine<MyFontStyle>, e:PointerEvent) {
			//trace("onPointerUp");
			t.stopSelection(e);
		}
		uiDisplay.add(textLine);
	}
	
	public function addInput(textLine:InteractiveTextLine<MyFontStyle>) 
	{
		textLine.onPointerDown = function(t:InteractiveTextLine<MyFontStyle>, e:PointerEvent) {
			//trace("onPointerDown");
			t.setInputFocus(e); // alternatively: uiDisplay.setInputFocus(t);
			t.startSelection(e);
		}
		textLine.onPointerUp = function(t:InteractiveTextLine<MyFontStyle>, e:PointerEvent) {
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
