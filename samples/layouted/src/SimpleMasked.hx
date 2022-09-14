package;

import haxe.CallStack;
import peote.ui.interactive.interfaces.TextLine;
import peote.ui.style.TextLineStyle;
import peote.ui.util.HAlign;
import peote.ui.util.VAlign;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.MouseButton;
import lime.ui.MouseWheelMode;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;

import peote.view.PeoteView;
import peote.view.Color;

import peote.layout.LayoutContainer;
import peote.layout.LayoutContainer.Box;
import peote.layout.LayoutContainer.HBox;
import peote.layout.LayoutContainer.VBox;
import peote.layout.Size;
import peote.layout.Align;

import peote.text.Font;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;
import peote.ui.interactive.InteractiveElement;

import peote.ui.style.FontStyleTiled;
import peote.ui.style.FontStylePacked;

import peote.ui.layouted.LayoutedUIDisplay;
import peote.ui.layouted.LayoutedElement;
import peote.ui.layouted.LayoutedTextLine;

import peote.ui.style.SimpleStyle;
import peote.ui.style.RoundBorderStyle;


class SimpleMasked extends Application
{
	var peoteView:PeoteView;
	var layoutedUIDisplay:LayoutedUIDisplay;
	
	var tiledFont:Font<FontStyleTiled>;
	var packedFont:Font<FontStylePacked>;
	
	var fontStyleTiled:FontStyleTiled;
	var fontStylePacked:FontStylePacked;
	
	var textStyle:TextLineStyle;
		
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
		fontStyleTiled = new FontStyleTiled();
		fontStyleTiled.height = 16.0;
		fontStyleTiled.width = 16.0;
		fontStyleTiled.color = Color.BLACK;
		
		fontStylePacked = new FontStylePacked();
		fontStylePacked.height = 30.0;
		fontStylePacked.width = 30.0;
		fontStylePacked.color = Color.BLACK;
		
		var backgroundStyle = new SimpleStyle(Color.GREEN);
		textStyle = {
			backgroundStyle:backgroundStyle
			,selectionStyle:RoundBorderStyle.createById(0, Color.GREY5)
			//,selectionStyle:SimpleStyle.createById(1, Color.GREY5)
		}

		
		peoteView = new PeoteView(window);
		//layoutedUIDisplay = new LayoutedUIDisplay(0, 0, window.width, window.height, Color.GREY3);
		layoutedUIDisplay = new LayoutedUIDisplay(0, 0, window.width, window.height, Color.GREY3, [backgroundStyle], true);
		peoteView.addDisplay(layoutedUIDisplay);
		
		// TODO: this is only need on neko to avoid bug if mouse is over application at start
		layoutedUIDisplay.mouseEnabled = false; // will be enabled after font is loaded and display is arranged into layout
		
		// load the FONTs:
		new Font<FontStyleTiled>("assets/fonts/tiled/hack_ascii.json").load( function(_tiledFont:Font<FontStyleTiled>) {
			tiledFont = _tiledFont;
			new Font<FontStylePacked>("assets/fonts/packed/hack/config.json").load( function(_packedFont:Font<FontStylePacked>) {
				packedFont = _packedFont;
				onAllFontLoaded();
			});				
		});
	}
	
	public function onAllFontLoaded() 
	{		
		var red   = new LayoutedElement(new RoundBorderStyle(Color.RED, Color.BLACK, 0, 10));
		layoutedUIDisplay.add(red);

				
		var redBoxes = new Array<Box>();
		for (i in 0...10) {
			var button = new LayoutedElement(new RoundBorderStyle(Color.YELLOW));
			button.onPointerOver = function(elem:InteractiveElement, e:PointerEvent) {
				elem.style.color = Color.YELLOW - 0x00550000;
				elem.updateStyle();
			}
			button.onPointerOut = function(elem:InteractiveElement, e:PointerEvent) {
				elem.style.color = Color.YELLOW;
				elem.updateStyle();
			}
			layoutedUIDisplay.add(button);
			
			button.wheelEventsBubbleTo = red;
			
			var textLineTiled = new LayoutedTextLine<FontStyleTiled>(0, 0, {hAlign:HAlign.CENTER, vAlign:VAlign.CENTER}, 'button${i+1}', tiledFont, fontStyleTiled, textStyle);
			//var textLinePacked = new LayoutedTextLine<FontStylePacked>(0, 0, 130, 25, 0, true, "packed font", packedFont, fontStylePacked);	// masked -> true		
			//trace("KK", textLineTiled.line.textSize); // TODO: line is null
			
			textLineTiled.select(1, 4);
			
			layoutedUIDisplay.add(textLineTiled);
			
			redBoxes.push(
				new Box( button,  { left:10, right:10, height:Size.limit(50, 80) }, [
					//new Box( textLineTiled, {  left:Size.min(10), width:Size.limit(95, 125), right:Size.min(10), height:18 })
					//new Box( textLineTiled, { left:Size.min(10), width:Size.limit(textLineTiled.width, 125), right:Size.min(10), height:18 })
					new Box( textLineTiled, { left:Size.min(10), width:Size.limit(50, 130), right:Size.min(10), height:40 })
				])
			);
		}

		
		
		var green = new LayoutedElement(new SimpleStyle(Color.GREEN));
		var blue  = new LayoutedElement(new RoundBorderStyle(Color.BLUE, Color.BLACK, 0, 10));
		
		layoutedUIDisplay.add(green);
		layoutedUIDisplay.add(blue);
		
		var inputLine = packedFont.createLayoutedTextLine(0, 0, {hAlign:HAlign.CENTER, vAlign:VAlign.CENTER}, 'input line', fontStylePacked);
		inputLine.onPointerOver = function(t:TextLine, e:PointerEvent) {
			trace("onPointerOver");
			t.setInputFocus(e); // alternatively: uiDisplay.setInputFocus(t);
			t.cursor = 2;
			t.cursorShow();
		}
		inputLine.onPointerOut = function(t:TextLine, e:PointerEvent) {
			trace("onPointerOut");
			t.cursorHide();
		}
		layoutedUIDisplay.add(inputLine);
		
		// ----------- LAYOUT ---------------
		
		uiLayoutContainer = new HBox( layoutedUIDisplay , { width:Size.max(650), relativeChildPositions:true },
		[                                                          
			new VBox( red ,  { top:40, bottom:20, width:Size.limit(100, 250),
				scrollY:true, // TODO: better error-handling if this is forgotten here!
				limitMinHeightToChilds:false, alignChildsOnOversizeY:Align.FIRST }, redBoxes ),
			new VBox( green, { top:40, bottom:20, width:Size.limit(100, 250) }, 
			[
				new Box( inputLine, { left:Size.min(10), width:Size.limit(50, 130), right:Size.min(10), top:10, height:Size.max(40), scrollY:true, limitMinHeightToChilds:false })
			]),							
			new VBox( blue,  { top:40, bottom:20, width:Size.limit(100, 250) }, [] ),						
		]);
		
		uiLayoutContainer.init();
		uiLayoutContainer.update(peoteView.width, peoteView.height);
		
		// scrolling
		
		red.onMouseWheel = function(b:InteractiveElement, e:WheelEvent) {
			if (e.deltaY != 0) {
				var yScroll = uiLayoutContainer.getChild(0).yScroll - e.deltaY*10;
				//if (xScroll >= 0 && xScroll <= uiLayoutContainer.getChild(0).xScrollMax) {
					uiLayoutContainer.getChild(0).yScroll = yScroll;
					uiLayoutContainer.update();
				//}
			}
		}
		
		
		// TODO: this is only need on neko to avoid bug if mouse is over application at start
		layoutedUIDisplay.mouseEnabled = true;

		
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
	
	override  function onMouseUp (x:Float, y:Float, button:MouseButton) {
		layoutedUIDisplay.mouseUp(x, y, button);
		sizeEmulation = !sizeEmulation; 
		if (sizeEmulation) uiLayoutContainer.update(x,y);
		else uiLayoutContainer.update(peoteView.width, peoteView.height);
	}

	override function onMouseWheel (dx:Float, dy:Float, mode:MouseWheelMode) layoutedUIDisplay.mouseWheel(dx, dy, mode);
	
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
