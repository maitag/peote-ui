package;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.MouseCursor;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.Element;
import peote.view.Color;

import peote.text.Font;

import peote.ui.PeoteUIDisplay;
import peote.ui.interactive.*;
import peote.ui.style.*;
import peote.ui.config.*;
import peote.ui.event.*;

import peote.ui.interactive.interfaces.ParentElement;

class CustomSelect extends Application
{
	var peoteView:PeoteView;
	var peoteUiDisplay:PeoteUIDisplay;
	
	override function onWindowCreate():Void
	{
		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES:
				try startSample(window)
				catch (_) trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}

	public function startSample(window:Window)
	{
		new Font<FontStyleTiled>("assets/fonts/tiled/hack_ascii.json").load( onFontLoaded );
	}
	
	public function onFontLoaded(font:Font<FontStyleTiled>) // don'T forget argument-type here !
	{
		peoteView = new PeoteView(window);
		peoteView.start();


		// ---- background layer styles -----

		var boxStyle  = BoxStyle.createById(0);
		var fontStyle = FontStyleTiled.createById(0);
		
		var textConfig:TextConfig = {
			backgroundStyle:boxStyle.copy(Color.GREY5),
			textSpace: {left:10},
		}
		
		// ---- foreground layer styles -----
		
		var boxStyleFront = BoxStyle.createById(1);
		var fontStyleFront = FontStyleTiled.createById(1);

		var textConfigFront:TextConfig = {
			backgroundStyle:boxStyleFront.copy(Color.GREY5),
			textSpace: {left:10},
		}
		
		// -------------------------------------------------------
		// --- PeoteUIDisplay with styles in Layer-Depth-Order ---
		// -------------------------------------------------------
		
		peoteUiDisplay = new PeoteUIDisplay(0, 0, window.width, window.height,
			[ boxStyle, fontStyle, boxStyleFront, fontStyleFront ]
		);
		peoteView.addDisplay(peoteUiDisplay);
		
		// --------------------------------
		// ---- creating Select-Area ------
		// --------------------------------
		
		var itemHeight:Int = 20;
		var itemGap:Int = 1;

		var selectArea = new UISelectArea(100, 100, 160, itemHeight, itemGap, 1,
			["item 0", "item 1", "item 2", "item 3", "item 4"],
			font, fontStyleFront, textConfigFront,
			boxStyleFront 
		);		
		peoteUiDisplay.add(selectArea);
		selectArea.hide(); // hide it instantly
		
		
		// ----------------------------------
		// ---- creating Selector-Button ----
		// ----------------------------------
		
		var selector = new UITextLine<FontStyleTiled>(100, 100, 160, itemHeight, 0, "item 0", font, fontStyle, textConfig);
		selector.onPointerDown = function(t:UITextLine<FontStyleTiled>, e:PointerEvent)
		{
			selectArea.show();
		};				
		peoteUiDisplay.add(selector);
		
		
		// -- change selector text on select --
		
		selectArea.onSelect = (area:UISelectArea, item:Int, text:String) -> {
			trace('item $item selected -> $text');
			selector.setText(text);
			// selector.vAlign = VAlign.CENTER;
			// selector.hAlign = HAlign.LEFT;
			selector.setXOffset(0);
			selector.updateLayout();

			area.hide();
		}
		
		
		// ---------------------------------------------------------
		PeoteUIDisplay.registerEvents(window);
	}	

	
}


// ---------------------------------------------------------
// ---------------------------------------------------------
// ---------------------------------------------------------
// TODO: SelectAreaConfig !

class UISelectArea extends UIArea implements ParentElement
{
	public function new(xPosition:Int, yPosition:Int, width:Int, itemHeight:Int, itemGap:Int, zIndex:Int = 0,
		items:Array<String>, font:Font<FontStyleTiled>, fontStyle:FontStyleTiled,
		textConfig:TextConfig,
		?config:AreaConfig
	) 
	{
		super(xPosition, yPosition, width, (itemHeight + itemGap)*items.length - itemGap, zIndex, config);
		
		
		var yPos:Int = 0;
		
		for (i in 0...items.length)
		{
			var textline = new UITextLine<FontStyleTiled>(0, yPos, width, itemHeight, 1, items[i], font, fontStyle, textConfig);
			yPos += itemHeight + itemGap;
			
			textline.onPointerDown = _onSelect.bind(i, _, _);

			// TODO
			textline.onPointerOver = function(t:UITextLine<FontStyleTiled>, e:PointerEvent) { t.backgroundStyle.color = Color.GREY7; t.updateStyle(); };
			textline.onPointerOut  = function(t:UITextLine<FontStyleTiled>, e:PointerEvent) { t.backgroundStyle.color = Color.GREY5; t.updateStyle(); };
			
			add(textline);
		}
		
		this.height = innerHeight;
	}
	
	inline function _onSelect(index:Int, t:UITextLine<FontStyleTiled>, e:PointerEvent) {
		if (onSelect != null) onSelect(this, index, t.text);
	}
	
	// events
	public var onSelect:UISelectArea -> Int -> String ->Void = null;
	
}
