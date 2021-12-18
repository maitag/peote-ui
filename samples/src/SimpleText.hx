package;

import haxe.CallStack;
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
		
		var xOffset:Int = 200;
		var yOffset:Int = 70;
		var x:Int = 0; 
		var y:Int = -yOffset;
		
		var textLine = new InteractiveTextLine<FontStyle>(x, y+=yOffset, "hello", font, fontStyle, Color.BLACK); //, selectionFontStyle
		//var textLine = font.createInteractiveTextLine(x, y+=yOffset, "hello", fontStyle, 0);
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
			
			
			
			
			
/*		haxe.Timer.delay(function() {
			//trace("change style after");
			//textLine2.fontStyle = fontStyleTiled;
			//textLine2.updateStyle();				
			uiDisplay.remove(textLine);
			// TODO
			// textLine.set("new Text", 0, 0, fontStyle);
			// textLine.setStyle(fontStyle, 1, 4);
			haxe.Timer.delay(function() {
				uiDisplay.add(textLine);
				textLine.height = 50;
				textLine.update();
			}, 1000);
			
		}, 1000);
*/
			
/*		// input line
		
		var fontStyleInput = new FontStyle();
		fontStyleInput.height = 25;
		fontStyleInput.width = 20;
		fontStyleInput.color = Color.BLACK;
		
		var inputLine = font.createInteractiveTextLine(0, 50, 112, 25, 0, "input line", fontStyleInput, Color.WHITE); //, selectionFontStyle
		uiDisplay.add(inputLine);
		
		inputLine.onPointerDown = function(t:InteractiveTextLine<FontStyle>, e:PointerEvent) {
			trace("onPointerDown");
			//t.setInputFocus();
			//uiDisplay.setInputFocus(t);
		}
*/
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
