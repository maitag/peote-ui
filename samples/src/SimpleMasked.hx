package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.MouseButton;
import lime.ui.MouseWheelMode;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.graphics.RenderContext;

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

import peote.ui.fontstyle.FontStyleTiled;
import peote.ui.fontstyle.FontStylePacked;

import peote.ui.layouted.LayoutedUIDisplay;
import peote.ui.layouted.LayoutedElement;
import peote.ui.layouted.LayoutedTextLine;

import peote.ui.skin.SimpleSkin;
import peote.ui.style.SimpleStyle;
import peote.ui.skin.RoundedSkin;
import peote.ui.style.RoundedStyle;


class SimpleMasked extends Application
{
	var peoteView:PeoteView;
	var layoutedUIDisplay:LayoutedUIDisplay;
	
	var simpleSkin = new SimpleSkin();
	var roundedSkin = new RoundedSkin();
	
	var tiledFont:Font<FontStyleTiled>;
	var packedFont:Font<FontStylePacked>;
		
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
		layoutedUIDisplay = new LayoutedUIDisplay(0, 0, window.width, window.height, Color.GREY3);
		
		// TODO: this is only need on neko to avoid bug if mouse is over application at start
		layoutedUIDisplay.mouseEnabled = false; // will be enabled after font is loaded and display is arranged into layout
		
		peoteView.addDisplay(layoutedUIDisplay);
		
		// load the FONT:
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
		var fontStyleTiled = new FontStyleTiled();
		fontStyleTiled.height = 16.0;
		fontStyleTiled.width = 16.0;
		fontStyleTiled.color = Color.BLACK;
		
		var fontStylePacked = new FontStylePacked();
		fontStylePacked.height = 30.0;
		fontStylePacked.width = 30.0;
		fontStylePacked.color = Color.WHITE;
		
		
		var red   = new LayoutedElement(roundedSkin, new RoundedStyle(Color.RED, Color.BLACK, 0, 10));
		layoutedUIDisplay.add(red);

				
		var redBoxes = new Array<Box>();
		for (i in 0...6) {
			var button = new LayoutedElement(roundedSkin, new RoundedStyle(Color.YELLOW));
			button.onPointerOver = function(elem:InteractiveElement, e:PointerEvent) {
				elem.style.color = Color.YELLOW - 0x00550000;
				elem.update();
			}
			button.onPointerOut = function(elem:InteractiveElement, e:PointerEvent) {
				elem.style.color = Color.YELLOW;
				elem.update();
			}
			layoutedUIDisplay.add(button);
			
			button.wheelEventsBubbleTo = red;
			
			// TODO: Textlinemasking 
			var textLineTiled = new LayoutedTextLine<FontStyleTiled>(0, 0, 130, 16, 0, false, 'button $i', tiledFont, fontStyleTiled);
			//var textLinePacked = new LayoutedTextLine<FontStylePacked>(0, 0, 130, 25, 0, true, "packed font", packedFont, fontStylePacked);	// masked -> true		
			layoutedUIDisplay.add(textLineTiled);
			
			redBoxes.push(
				new Box( button,  { left:10, right:10, height:Size.limit(50, 80) }, [
					new Box( textLineTiled, { width:130, height:30 })
				])
			);
		}

		
		
		var green = new LayoutedElement(simpleSkin, new SimpleStyle(Color.GREEN));
		var blue  = new LayoutedElement(roundedSkin, new RoundedStyle(Color.BLUE, Color.BLACK, 0, 10));
		
		layoutedUIDisplay.add(green);
		layoutedUIDisplay.add(blue);
		
		
		// ----------- LAYOUT ---------------
		
		uiLayoutContainer = new HBox( layoutedUIDisplay , { width:Size.max(650), relativeChildPositions:true },
		[                                                          
			new VBox( red ,  { top:40, bottom:20, width:Size.limit(100, 200),
				scrollY:true, // TODO: better error-handling if this is forgotten here!
				limitMinHeightToChilds:false, alignChildsOnOversizeY:Align.LAST }, redBoxes ),
			new VBox( green, { top:40, bottom:20, width:Size.limit(100, 200) }, [] ),							
			new VBox( blue,  { top:40, bottom:20, width:Size.limit(100, 200) }, [] ),						
		]);
		
		uiLayoutContainer.init();
		uiLayoutContainer.update(peoteView.width, peoteView.height);
		
		// scrolling
		
		red.onMouseWheel = function(b:InteractiveElement, e:WheelEvent) {
			if (e.deltaY != 0) {
				var yScroll = uiLayoutContainer.getChild(0).yScroll + e.deltaY*5;
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
