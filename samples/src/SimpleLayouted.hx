package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.MouseButton;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.graphics.RenderContext;

import peote.view.PeoteView;
import peote.view.Color;

import peote.layout.LayoutContainer;
import peote.layout.Size;

import peote.text.Font;

import peote.ui.event.PointerEvent;
import peote.ui.interactive.InteractiveElement;
import peote.ui.style.FontStyleTiled;

import peote.ui.layouted.LayoutedUIDisplay;
import peote.ui.layouted.LayoutedElement;
import peote.ui.layouted.LayoutedTextLine;

import peote.ui.style.SimpleStyle;
import peote.ui.style.RoundBorderStyle;


class SimpleLayouted extends Application
{
	var peoteView:PeoteView;
	var layoutedUIDisplay:LayoutedUIDisplay;
	
	var fontStyleTiled:FontStyleTiled;
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
		peoteView = new PeoteView(window);
		
		fontStyleTiled = new FontStyleTiled(); // (at least here it needs the FontStyleTiled Type!)
		fontStyleTiled.height = 30.0;
		fontStyleTiled.width = 30.0;
		fontStyleTiled.color = Color.BLACK;

		layoutedUIDisplay = new LayoutedUIDisplay(0, 0, window.width, window.height, Color.GREY3, [new SimpleStyle(0), fontStyleTiled]);
		peoteView.addDisplay(layoutedUIDisplay);
		
		// load the FONT:
		new Font<FontStyleTiled>("assets/fonts/tiled/hack_ascii.json").load( onFontLoaded );
	}
	
	public function onFontLoaded(font:Font<FontStyleTiled>) { // don'T forget argument-type or force at least the style to FontStyleTiled-Type (see below!)
	//public function onFontLoaded(font) {

		var red   = new LayoutedElement(new SimpleStyle(0, Color.RED));
		var green = new LayoutedElement(new SimpleStyle(0, Color.GREEN));
		var blue  = new LayoutedElement(new SimpleStyle(0, Color.BLUE));
		var yellow= new LayoutedElement(new SimpleStyle(0, Color.YELLOW));
		yellow.onPointerOver = function(elem:InteractiveElement, e:PointerEvent) {
			elem.style.color = Color.YELLOW - 0x00550000;
			elem.updateStyle();
		}
		
		yellow.onPointerOut = function(elem:InteractiveElement, e:PointerEvent) {
			elem.style.color = Color.YELLOW;
			elem.updateStyle();
		}
		
		layoutedUIDisplay.add(red);
		layoutedUIDisplay.add(green);
		layoutedUIDisplay.add(blue);
		layoutedUIDisplay.add(yellow);

		
		//var textLine1 = new LayoutedTextLine<FontStyleTiled>(0, 0, 112, 25, 0, "hello", font, fontStyleTiled, Color.BLUE);
		var textLine1:LayoutedTextLine<FontStyleTiled> = font.createLayoutedTextLine(0, 0, {width:300, height:25}, 0, "hello world", fontStyleTiled);
		layoutedUIDisplay.add(textLine1);
		
		// masked -> true
		var textLine2 = font.createLayoutedTextLine(0, 0, 0, "hello world", font.createFontStyle());			
		layoutedUIDisplay.add(textLine2);
		
		uiLayoutContainer = new Box( layoutedUIDisplay , { width:Size.limit(100,700), relativeChildPositions:true },
		[                                                          
			new Box( red , { width:Size.limit(100,600) },
			[                                                      
				new Box( green,  { width:Size.limit(50, 300), height:Size.limit(100,400) }),							
				new HBox( blue,   { width:Size.span(50, 150), height:Size.limit(100, 300), left:Size.min(50) },
				[
				]),
				new Box( yellow, { width:Size.limit(30, 200), height:Size.limit(200, 200), left:Size.span(0, 100), right:50 },
				[
					new Box( textLine1, {width:Size.min(130), height:30, top:5, left:5, bottom:Size.min(5) }),
					new Box( textLine2, {width:Size.min(30), height:30, top:50, left:5, bottom:Size.min(5) }),					
				]),
			])
		]);
		
		uiLayoutContainer.init();
		uiLayoutContainer.update(peoteView.width, peoteView.height);
		
		haxe.Timer.delay(function() {
			//trace("change style after");
			textLine2.fontStyle.color = Color.RED;
			//textLine2.fontStyle.height = 30;
			textLine2.updateStyle();
		}, 1000);
	
	}

	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	
	
	// ----------------- MOUSE EVENTS ------------------------------
	var sizeEmulation = false;
	
	override function onMouseMove (x:Float, y:Float) {
		layoutedUIDisplay.mouseMove(x, y);
		if (sizeEmulation) uiLayoutContainer.update(Std.int(x),Std.int(y));
	}
	
	override function onMouseUp (x:Float, y:Float, button:MouseButton) {
		layoutedUIDisplay.mouseUp(x, y, button);
		sizeEmulation = !sizeEmulation; 
		if (sizeEmulation) uiLayoutContainer.update(x,y);
		else uiLayoutContainer.update(peoteView.width, peoteView.height);
	}

	// ----------------- KEYBOARD EVENTS ---------------------------
	override function onKeyDown (keyCode:KeyCode, modifier:KeyModifier) {
		switch (keyCode) {
			#if html5
			case KeyCode.TAB: untyped __js__('event.preventDefault();');
			#end
			case KeyCode.F: window.fullscreen = !window.fullscreen;
			default:
		}
		layoutedUIDisplay.keyDown(keyCode, modifier);
	}
	
	// ----------------- WINDOWS EVENTS ----------------------------
	override function onWindowResize (width:Int, height:Int) {
		// calculates new Layout and updates all Elements 
		if (uiLayoutContainer != null) uiLayoutContainer.update(width, height);
	}

}
