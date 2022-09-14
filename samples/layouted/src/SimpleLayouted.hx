package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.MouseButton;
import lime.graphics.RenderContext;

import peote.view.PeoteView;
import peote.view.Color;

import peote.layout.LayoutContainer;
import peote.layout.Size;

import peote.text.Font;

import peote.ui.event.PointerEvent;
import peote.ui.style.FontStyleTiled;
import peote.ui.interactive.InteractiveTextLine;
import peote.ui.interactive.InteractiveElement;
import peote.ui.layouted.LayoutedUIDisplay;
import peote.ui.layouted.LayoutedElement;
import peote.ui.layouted.LayoutedTextLine;

import peote.ui.style.SimpleStyle;
import peote.ui.style.RoundBorderStyle;


class SimpleLayouted extends Application
{
	var uiLayoutContainer:LayoutContainer;
	
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
		new Font<FontStyleTiled>("assets/fonts/tiled/hack_ascii.json").load( onFontLoaded );
	}
	
	public function onFontLoaded(font:Font<FontStyleTiled>) // if not forcing font to <FontStyleTiled> type here it have to be at least for the textLines
	{
		var peoteView = new PeoteView(window);

		// create layoutable UIDisplay 
		var layoutedUIDisplay = new LayoutedUIDisplay(0, 0, window.width, window.height, Color.GREY3);
		peoteView.addDisplay(layoutedUIDisplay);
		
		
		// create layoutable ui-elements
		var red   = new LayoutedElement(new SimpleStyle(Color.RED));
		var green = new LayoutedElement(new SimpleStyle(Color.GREEN));
		var blue  = new LayoutedElement(new SimpleStyle(Color.BLUE));
		var yellow = new LayoutedElement(new SimpleStyle(Color.YELLOW));
		
		var textLine1 = font.createLayoutedTextLine( 0, 0, 0, "hello world" );			
		var textLine2 = font.createLayoutedTextLine( 0, 0, {width:300, height:25}, 0, "hello", new FontStyleTiled(Color.BLUE) );
		// alternatively
		//var textLine1 = new LayoutedTextLine<FontStyleTiled>( 0, 0, 0, "hello world", font );
		//var textLine2 = new LayoutedTextLine<FontStyleTiled>( 0, 0, {width:300, height:25}, 0, "hello", font, new FontStyleTiled(Color.BLUE) );
		
		
		// add the elements to LayoutedUIDisplay		
		layoutedUIDisplay.add(red);
		layoutedUIDisplay.add(green);
		layoutedUIDisplay.add(blue);
		layoutedUIDisplay.add(yellow);		
		layoutedUIDisplay.add(textLine1);
		layoutedUIDisplay.add(textLine2);
		
		
		
		// create the peote-layout containers what is bind to the layouted ui-elements
		uiLayoutContainer = new Box( layoutedUIDisplay , { width:Size.limit(100,700) },
		[                                                          
			new Box( red , { width:Size.limit(100,600) },
			[                                                      
				new Box( green,  { width:Size.limit(50, 300), height:Size.limit(100, 400) }),							
				new HBox( blue,   { width:Size.span(50, 150), height:Size.limit(100, 300), left:Size.min(50) },
				[
					// childs here would be horizontal arranged
				]),
				new Box( yellow, { width:Size.limit(30, 200), height:Size.limit(200, 200), left:Size.span(0, 100), right:50 },
				[
					new Box( textLine1, {width:Size.min(130), height:30, top: 5, left:5, bottom:Size.min(5) }),
					new Box( textLine2, {width:Size.min( 30), height:30, top:50, left:5, bottom:Size.min(5) }),					
				]),
			])
		]);
		
		
		uiLayoutContainer.init(); // init cassowary constraints
		uiLayoutContainer.update(window.width, window.height); // calculate layout and updates all Elements 
		
		
		
		// add over/out events to the yellow element		
		yellow.onPointerOver = function(elem:InteractiveElement, e:PointerEvent) {
			elem.style.color = Color.YELLOW - 0x00550000;
			elem.updateStyle();
		}
		yellow.onPointerOut = function(elem:InteractiveElement, e:PointerEvent) {
			elem.style.color = Color.YELLOW;
			elem.updateStyle();
		}
		
		// add over/out events to the first textline
		textLine1.onPointerOver = function(t:InteractiveTextLine<FontStyleTiled>, e:PointerEvent) {
			t.fontStyle.color = Color.RED;
			t.updateStyle();
		}
		textLine1.onPointerOut = function(t:InteractiveTextLine<FontStyleTiled>, e:PointerEvent) {
			t.fontStyle.color = Color.BLACK;
			t.updateStyle();
		}
		// bubble the events of textLine1 to the yellow element behind
		textLine1.overOutEventsBubbleTo = yellow;
		
		
		
		// delegating lime events to all added UIDisplays and LayoutedUIDisplay
		LayoutedUIDisplay.registerEvents(window);
	}

	
	
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	
	
	var sizeEmulation = false;
	
	override function onMouseMove (x:Float, y:Float) {
		if (sizeEmulation) uiLayoutContainer.update(x, y);
	}
	
	override function onMouseUp (x:Float, y:Float, button:MouseButton) {
		sizeEmulation = !sizeEmulation; 
		if (sizeEmulation) uiLayoutContainer.update(x, y);
		else uiLayoutContainer.update(window.width, window.height);
	}

	override function onWindowResize (width:Int, height:Int) {
		if (uiLayoutContainer != null) uiLayoutContainer.update(width, height);
	}

}
