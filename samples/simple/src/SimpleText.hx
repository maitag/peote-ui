package;

import haxe.CallStack;
import haxe.Timer; 
import peote.ui.style.RoundBorderStyle;
import peote.ui.style.SimpleStyle;
import peote.ui.style.TextLineStyle;
import peote.ui.util.TextSize;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Color;

import peote.text.Font;

import peote.ui.PeoteUIDisplay;
import peote.ui.interactive.UITextLine;
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
	var uiDisplay:PeoteUIDisplay;
	
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
		
		var simpleStyle = new SimpleStyle(Color.BLACK);
		
		peoteView = new PeoteView(window);
		uiDisplay = new PeoteUIDisplay(0, 0, window.width, window.height, Color.GREY1);
		peoteView.addDisplay(uiDisplay);		
		
				
		// --------------------------------------------------------------
		// ------ simple TextLine with autosize and no textStyle --------
		// --------------------------------------------------------------

		var textLine = new UITextLine<MyFontStyle>(20, 20, "hello", font, fontStyle);
		// alternatively it can also be:
		//var textLine = font.createUITextLine(x, y+=yOffset, "hello", fontStyle, Color.BLACK);
		
		// set events
		textLine.onPointerOver = function(t:UITextLine<MyFontStyle>, e:PointerEvent) {
			t.fontStyle.color = Color.YELLOW;
			t.updateStyle();
		}
		textLine.onPointerOut = function(t:UITextLine<MyFontStyle>, e:PointerEvent) {
			t.fontStyle.color = Color.GREEN;
			t.updateStyle();
		}
		uiDisplay.add(textLine);			

		
		// --------------------------------------------------------------
		// ------------------- input TextLine ---------------------------
		// --------------------------------------------------------------
				
		var fontStyleInput = new MyFontStyle();
		fontStyleInput.color = Color.GREY5;
		//fontStyleInput.height = 30;
		//fontStyleInput.width = 20;
		
		var textStyle:TextLineStyle = {
			backgroundStyle:simpleStyle,
			selectionStyle:SimpleStyle.createById(1, Color.GREY3), // new ID for new Layer
			cursorStyle:SimpleStyle.createById(2, Color.RED)       // new ID for new Layer
		}
		
		var inputLine = new UITextLine<MyFontStyle>(300, 20, "input", font, fontStyleInput, textStyle);

		// set events
		inputLine.onPointerDown = function(t:UITextLine<MyFontStyle>, e:PointerEvent) {
			t.setInputFocus(e); // alternatively: uiDisplay.setInputFocus(t);
			t.startSelection(e);
		}
		inputLine.onPointerUp = function(t:UITextLine<MyFontStyle>, e:PointerEvent) {
			t.stopSelection(e);
		}
		uiDisplay.add(inputLine);
		

		
		
		#if android
		uiDisplay.mouseEnabled = false;
		peoteView.zoom = 3;
		#end
		
		// TODO: set what events to register (mouse, touch, keyboard ...)
		PeoteUIDisplay.registerEvents(window);

	}
	
}
