package;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.KeyCode;

import peote.view.PeoteView;
import peote.view.Color;

import input2action.Input2Action;
import input2action.ActionConfig;
import input2action.ActionMap;
import input2action.KeyboardAction;
import peote.ui.interactive.input2action.InputTextLine;

import peote.ui.PeoteUIDisplay;
import peote.ui.interactive.*;
import peote.ui.style.*;
import peote.ui.config.*;
import peote.ui.event.*;


import peote.ui.packed.FontP;
import peote.ui.style.FontStylePacked;


// ------------------------------------
// -------- application start  --------
// ------------------------------------

class SimpleTextPregenerated extends Application
{
	var peoteView:PeoteView;
	var uiDisplay:PeoteUIDisplay;
	
	override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try startSample(window)
				catch (_) trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}

	// ---------------------------------------------------------------------------
	// --- before starting PeoteUIDisplay, it have to load the fonts at first  ---
	// ---------------------------------------------------------------------------

	public function startSample(window:Window)
	{
		new FontP("assets/fonts/packed/hack/config.json").load( onFontLoaded );
	}
	
	public function onFontLoaded(font:FontP)
	{					
		var fontStyle = new FontStylePacked();
		fontStyle.color = Color.GREEN;
		fontStyle.width = 38;
		fontStyle.height = 36;
		
		var boxStyle = new BoxStyle(Color.BLACK);
		
		peoteView = new PeoteView(window);
		uiDisplay = new PeoteUIDisplay(0, 0, 1600, 1200, Color.GREY1);
		peoteView.addDisplay(uiDisplay);		
		
				
		// --------------------------------------------------------------
		// ---- simple TextLine with autosize and default textConfig ----
		// --------------------------------------------------------------

		var textLine = new UITextLineP(20, 20, 0, 0, "UITextLine", font, fontStyle);
		// alternatively it can also be:
		// var textLine = font.createUITextLine(20, 20, 0, 0, "UITextLine", fontStyle);
		
		// set events
		textLine.onPointerOver = function(t:UITextLineP, e:PointerEvent) {
			t.fontStyle.color = Color.YELLOW;
			t.updateStyle();
		}
		textLine.onPointerOut = function(t:UITextLineP, e:PointerEvent) {
			t.fontStyle.color = Color.GREEN;
			t.updateStyle();
		}
		uiDisplay.add(textLine);			

		
		// --------------------------------------------------------------
		// ------------------- input TextLine ---------------------------
		// --------------------------------------------------------------
				
		var fontStyleInput = new FontStylePacked();
		fontStyleInput.color = Color.GREY5;
		fontStyleInput.height = 38;
		fontStyleInput.width = 36;
		
		var textConfig:TextConfig = {
			backgroundStyle:boxStyle,
			selectionStyle:BoxStyle.createById(1, Color.GREY3), // new ID for new Layer
			cursorStyle:BoxStyle.createById(2, Color.RED),       // new ID for new Layer
			//hAlign:HAlign.RIGHT,
			undoBufferSize: 30
		}
		
		var inputLine = new UITextLineP(300, 20, 0, 0, "input UITextLine", font, fontStyleInput, textConfig);

		// set events
		inputLine.onPointerDown = function(t:UITextLineP, e:PointerEvent) {
			t.setInputFocus(e); // alternatively: uiDisplay.setInputFocus(t);
			//t.setInputFocus(e, true); // to also set the cursor
			
			t.startSelection(e);
			
			// to only set the cursor:
			//t.setCursorToPointer(e); // set cursor to pointer-down position
			//uiDisplay.onPointerMove = (_,e)->t.setCursorToPointer(e); // also move the cursor while dragging!
		}
		inputLine.onPointerUp = function(t:UITextLineP, e:PointerEvent) {
			t.stopSelection(e);
			//uiDisplay.onPointerMove = null; // stops moving the cursor while dragging
		}
		uiDisplay.add(inputLine);

		// restrict the chars what is allowed for input
		inputLine.restrictedChars = "a-zA-Z0-9+-*~/\\^.,;:§$%&=?_#\"'`[](){}%&<>|";
		

		// --------------------------------------------------------------
		// ---- simple TextPage with autosize and default textConfig ----
		// --------------------------------------------------------------

		// var textPage = new UITextPageP(20, 100, 0, 0, "UITextPage\ncan contain\nlinebreaks", font, fontStyle);
		// alternatively it can also be:
		var textPage = font.createUITextPage(20, 100, 0, 0, "This text\ncontains\nlinebreaks", fontStyle);
		
		// set events
		textPage.onPointerOver = function(t:UITextPageP, e:PointerEvent) {
			t.fontStyle.color = Color.YELLOW;
			t.updateStyle();
		}
		textPage.onPointerOut = function(t:UITextPageP, e:PointerEvent) {
			t.fontStyle.color = Color.GREEN;
			t.updateStyle();
		}
		
		uiDisplay.add(textPage);			

		
		
		
		// -------------------------------------------
		// ----------- input TextPage ----------------
		// -------------------------------------------
				
		var fontStyleInput = new FontStylePacked();
		fontStyleInput.color = Color.GREY5;
		fontStyleInput.height = 38;
		fontStyleInput.width = 36;
		
		var textConfig:TextConfig = {
			backgroundStyle:boxStyle,
			selectionStyle:BoxStyle.createById(1, Color.GREY3), // new ID for new Layer
			cursorStyle:BoxStyle.createById(2, Color.RED),      // new ID for new Layer
			undoBufferSize: 30
		}
		
		var inputPage = new UITextPageP(300, 100, 0, 0, "input\ntext by\nUIText\tPage", font, fontStyleInput, textConfig);

		// set events
		inputPage.onPointerDown = function(t:UITextPageP, e:PointerEvent) {
			//t.setInputFocus(e, true);			
			t.setInputFocus(e);			
			t.startSelection(e);
		}
		inputPage.onPointerUp = function(t:UITextPageP, e:PointerEvent) {
			t.stopSelection(e);
		}
		
		uiDisplay.add(inputPage);
		




		// ---------------------------------------------------------
		// ---- input TextLine with custom keyboard handling -------
		// ---------------------------------------------------------
			
		var inputLineKeys = new UITextLineP(300, 500, 0, 0, "custom keyhandling", font, fontStyleInput, textConfig);

		// set events
		inputLineKeys.onPointerDown = function(t:UITextLineP, e:PointerEvent) {
			t.setInputFocus(e); // alternatively: uiDisplay.setInputFocus(t);
			//t.setInputFocus(e, true); // to also set the cursor
			t.startSelection(e);
		}
		inputLineKeys.onPointerUp = function(t:UITextLineP, e:PointerEvent) {
			t.stopSelection(e);
		}
		uiDisplay.add(inputLineKeys);
		
		// use custom keyboard-control via input2action
		// look at peote/ui/interactive/input2action/InputTextLine.hx for default action-names
		var actionConfig:ActionConfig = [
			{ action: "cursorUp" , keyboard: KeyCode.UP, single:true },
			{ action: "cursorDown", keyboard: KeyCode.DOWN, single:true },
			{ action: "return" , keyboard: KeyCode.RETURN, single:true },
		];
		
		var actionMap:ActionMap = [
			"cursorUp" => {
				action:(_, _) -> { 
					trace("cursor up"); 
				},
				repeatKeyboardDefault:true
			},

			"cursorDown" => {
				action:(_, _) -> {
					trace("cursor down");
				},
				repeatKeyboardDefault:true
			},
			"return" => { 
				action:(_, _) -> {
					trace("return");
					// to check which textline if used globally
					// trace( (cast uiDisplay.inputFocusElement : UITextLineP).text);
					// trace( (cast InputTextLine.focusElement : UITextLineP).text);
				},
				repeatKeyboardDefault:false
			},			
		];

		// to use globally add the custom actionConfig and actionMap to ALL InputTextLines defaults:
		// InputTextLine.actionConfig.add(actionConfig);
		// InputTextLine.actionMap.add(actionMap);
		// InputTextLine.init(); // this only after instanzing the first uiDisplay


		// this adds the InputTextLines defaults to custom actionConfig/Map
		actionConfig.add(InputTextLine.actionConfig, false); // don't replace existing values (false parameter)
		actionMap.add(InputTextLine.actionMap, false); // don't replace existing values (false parameter)

		// set keyboard bindings
		var keyboardAction = new KeyboardAction(actionConfig, actionMap);

		// create new Input2Action instanze
		var input2Action:Input2Action = new Input2Action();
		
		// add the keyboard actions
		input2Action.addKeyboard(keyboardAction);
				
		// add custom input2action to UITextLines ".input2Action" property
		inputLineKeys.input2Action = input2Action;
		


		// testing zoom and offsets
		// peoteView.zoom = 0.7;
		// peoteView.xOffset = 50;
		// peoteView.yOffset = 50;
		// uiDisplay.zoom = 0.5;
		// uiDisplay.xOffset = 100;
		// uiDisplay.yOffset = 100;




		// -----------------------------------------------------------------
		// -----------------------------------------------------------------
		// -----------------------------------------------------------------

		#if android
		uiDisplay.mouseEnabled = false;
		peoteView.zoom = 3;
		#end
		
		// TODO: set what events to register (mouse, touch, keyboard ...)
		PeoteUIDisplay.registerEvents(window);

	}
	
}
