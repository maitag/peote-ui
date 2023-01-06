package;

import haxe.CallStack;
import peote.ui.util.HAlign;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Color;

import peote.text.Font;

import peote.ui.PeoteUIDisplay;

import peote.ui.interactive.UITextLine;
import peote.ui.interactive.UITextPage;
import peote.ui.event.PointerEvent;
//import peote.ui.event.WheelEvent;

//import peote.ui.util.TextSize;
//import peote.ui.util.HAlign;
//import peote.ui.util.VAlign;

//import peote.ui.style.RoundBorderStyle;
import peote.ui.style.BoxStyle;
import peote.ui.style.TextStyle;

import peote.ui.style.interfaces.FontStyle;

// ------------------------------------------
// --- using a custom FontStyle here --------
// ------------------------------------------

@packed // this is need for ttfcompile fonts (gl3font)
@globalLineSpace // all pageLines using the same page.lineSpace (gap to next line into page)
@:structInit
class MyFontStyle implements FontStyle
{
	public var color:Color = Color.GREEN;
	public var width:Float = 38; // (<- is it still fixed to get from font-defaults if this is MISSING ?)
	public var height:Float = 36;
	@global public var weight = 0.5; //0.49 <- more thick (only for ttfcompiled fonts)
}

// ------------------------------------
// -------- application start  --------
// ------------------------------------

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

	// ---------------------------------------------------------------------------
	// --- before starting PeoteUIDisplay, it have to load the fonts at first  ---
	// ---------------------------------------------------------------------------

	public function startSample(window:Window)
	{
		new Font<MyFontStyle>("assets/fonts/packed/hack/config.json").load( onFontLoaded );
	}
	
	public function onFontLoaded(font:Font<MyFontStyle>) // don'T forget argument-type here !
	{					
		var fontStyle = new MyFontStyle();
		
		var boxStyle = new BoxStyle(Color.BLACK);
		
		peoteView = new PeoteView(window);
		uiDisplay = new PeoteUIDisplay(0, 0, window.width, window.height, Color.GREY1);
		peoteView.addDisplay(uiDisplay);		
		
				
		// --------------------------------------------------------------
		// ------ simple TextLine with autosize and no textStyle --------
		// --------------------------------------------------------------

		var textLine = new UITextLine<MyFontStyle>(20, 20, "hello", font, fontStyle);
		// alternatively it can also be:
		//var textLine = font.createUITextLine(x, y+=yOffset, "hello", fontStyle);
		
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
		
		var textStyle:TextStyle = {
			backgroundStyle:boxStyle,
			selectionStyle:BoxStyle.createById(1, Color.GREY3), // new ID for new Layer
			cursorStyle:BoxStyle.createById(2, Color.RED)       // new ID for new Layer
		}
		
		var inputLine = new UITextLine<MyFontStyle>(300, 20, "input", font, fontStyleInput, textStyle);
		//var inputLine = new UITextLine<MyFontStyle>(300, 20, {width:200, hAlign:HAlign.CENTER}, "input", font, fontStyleInput, textStyle);

		// set events
		inputLine.onPointerDown = function(t:UITextLine<MyFontStyle>, e:PointerEvent) {
			t.setInputFocus(e); // alternatively: uiDisplay.setInputFocus(t);
			//t.setInputFocus(e, true); // to also set the cursor
			
			t.startSelection(e);
			
			// to only set the cursor:
			//t.setCursorToPointer(e); // set cursor to pointer-down position
			//uiDisplay.onPointerMove = (_,e)->t.setCursorToPointer(e); // also move the cursor while dragging!
		}
		inputLine.onPointerUp = function(t:UITextLine<MyFontStyle>, e:PointerEvent) {
			t.stopSelection(e);
			//uiDisplay.onPointerMove = null; // stops moving the cursor while dragging
		}
		uiDisplay.add(inputLine);
		

		// -------------------------------
		// ------ simple TextPage --------
		// -------------------------------

		var textPage = new UITextPage<MyFontStyle>(20, 100, "This text\ncontains\nlinebreaks", font, fontStyle);
		// alternatively it can also be:
		//var textPage = font.createUITextPage(20, 100, "This text\ncontains\nlinebreaks", fontStyle);
		
		// set events
		textPage.onPointerOver = function(t:UITextPage<MyFontStyle>, e:PointerEvent) {
			t.fontStyle.color = Color.YELLOW;
			t.updateStyle();
		}
		textPage.onPointerOut = function(t:UITextPage<MyFontStyle>, e:PointerEvent) {
			t.fontStyle.color = Color.GREEN;
			t.updateStyle();
		}
		uiDisplay.add(textPage);			

		
		// -------------------------------------------
		// ----------- input TextPage ----------------
		// -------------------------------------------
				
		var fontStyleInput = new MyFontStyle();
		fontStyleInput.color = Color.GREY5;
		//fontStyleInput.height = 30;
		//fontStyleInput.width = 20;
		
		var textStyle:TextStyle = {
			backgroundStyle:boxStyle,
			selectionStyle:BoxStyle.createById(1, Color.GREY3), // new ID for new Layer
			cursorStyle:BoxStyle.createById(2, Color.RED)       // new ID for new Layer
		}
		
		var inputPage = new UITextPage<MyFontStyle>(300, 100, "input-\ntext", font, fontStyleInput, textStyle);

		// set events
		inputPage.onPointerDown = function(t:UITextPage<MyFontStyle>, e:PointerEvent) {
			t.setInputFocus(e); // alternatively: uiDisplay.setInputFocus(t);
			t.startSelection(e);
		}
		inputPage.onPointerUp = function(t:UITextPage<MyFontStyle>, e:PointerEvent) {
			t.stopSelection(e);
		}
		uiDisplay.add(inputPage);
		

		
		
		
		#if android
		uiDisplay.mouseEnabled = false;
		peoteView.zoom = 3;
		#end
		
		// TODO: set what events to register (mouse, touch, keyboard ...)
		PeoteUIDisplay.registerEvents(window);

	}
	
}
