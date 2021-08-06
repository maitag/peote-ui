package;

import lime.ui.Window;
import lime.ui.MouseButton;
import lime.app.Application;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.graphics.RenderContext;
import peote.layout.Align;
import peote.ui.event.PointerEvent;
import peote.ui.interactive.InteractiveElement;

import peote.view.PeoteView;
import peote.view.Color;

import peote.text.Font;
import peote.ui.fontstyle.FontStyleTiled;
import peote.ui.fontstyle.FontStylePacked;

import peote.ui.layouted.LayoutedUIDisplay;
import peote.ui.layouted.LayoutedElement;
import peote.ui.layouted.LayoutedTextLine;

import peote.ui.skin.SimpleSkin;
import peote.ui.style.SimpleStyle;
import peote.ui.skin.RoundedSkin;
import peote.ui.style.RoundedStyle;

import peote.layout.LayoutContainer;
import peote.layout.LayoutContainer.Box;
import peote.layout.LayoutContainer.HBox;
import peote.layout.LayoutContainer.VBox;
import peote.layout.Size;


class SimpleMasked extends Application
{
	var peoteView:PeoteView;
	var layoutedUIDisplay:LayoutedUIDisplay;
	
	var simpleSkin = new SimpleSkin();
	var roundedSkin = new RoundedSkin();
	
	var tiledFont:Font<FontStyleTiled>;
	var packedFont:Font<FontStylePacked>;
		
	var uiLayoutContainer:LayoutContainer;
	
	public function new() super();
	
	public override function onWindowCreate() {
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES: initPeoteView(window); // start sample
			default: throw("Sorry, only works with OpenGL.");
		}
	}
	
	public function initPeoteView(window:Window) {
		try {			
			peoteView = new PeoteView(window.context, window.width, window.height);
			layoutedUIDisplay = new LayoutedUIDisplay(0, 0, window.width, window.height, Color.GREY3);
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
		catch (e:Dynamic) trace("ERROR:", e);
	}
	
	public function onAllFontLoaded() {
		try {			
			var fontStyleTiled = new FontStyleTiled();
			fontStyleTiled.height = 16.0;
			fontStyleTiled.width = 16.0;
			fontStyleTiled.color = Color.BLACK;
			
			var fontStylePacked = new FontStylePacked();
			fontStylePacked.height = 30.0;
			fontStylePacked.width = 30.0;
			fontStylePacked.color = Color.WHITE;
			
			var textLinePacked = new LayoutedTextLine<FontStylePacked>(0, 0, 300, 25, 0, true, "packed font", packedFont, fontStylePacked);	// masked -> true		
			
			var red   = new LayoutedElement(roundedSkin, new RoundedStyle(Color.RED, Color.BLACK, 0, 10));
			var green = new LayoutedElement(simpleSkin, new SimpleStyle(Color.GREEN));
			var blue  = new LayoutedElement(roundedSkin, new RoundedStyle(Color.BLUE, Color.BLACK, 0, 10));
			
					
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
				
				// TODO: Textlinemasking 
				//var textLineTiled = new LayoutedTextLine<FontStyleTiled>(0, 0, 130, 16, 0, false, 'button $i', tiledFont, fontStyleTiled);
				//layoutedUIDisplay.add(textLineTiled);
				
				redBoxes.push(
					new Box( button,  { left:10, right:10, height:Size.limit(50, 80) }, [
						//new Box( textLineTiled, { width:130, height:30 })
					])
				);
			}

			
			
			layoutedUIDisplay.add(red);
			layoutedUIDisplay.add(green);
			layoutedUIDisplay.add(blue);
			//layoutedUIDisplay.add(yellow);
			//layoutedUIDisplay.add(textLineTiled);
			//layoutedUIDisplay.add(textLinePacked);

			
			uiLayoutContainer = new HBox( layoutedUIDisplay , { width:Size.max(650), relativeChildPositions:true },
			[                                                          
				new VBox( red ,  { top:20, bottom:20, width:Size.limit(100, 200), limitMinHeightToChilds:false, alignChildsOnOversizeY:Align.LAST }, redBoxes ),
				new VBox( green, { top:20, bottom:20, width:Size.limit(100, 200) }, [] ),							
				new VBox( blue,  { top:20, bottom:20, width:Size.limit(100, 200) }, [] ),						
			]);
			
			uiLayoutContainer.init();
			uiLayoutContainer.update(peoteView.width, peoteView.height);
			
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}

	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	
	
	public override function render(context:RenderContext) peoteView.render();
	
	// ----------------- MOUSE EVENTS ------------------------------
	var sizeEmulation = false;
	
	public override function onMouseMove (x:Float, y:Float) {
		layoutedUIDisplay.mouseMove(x, y);
		if (sizeEmulation) uiLayoutContainer.update(Std.int(x),Std.int(y));
	}
	
	public override  function onMouseUp (x:Float, y:Float, button:MouseButton) {
		layoutedUIDisplay.mouseUp(x, y, button);
		sizeEmulation = !sizeEmulation; 
		if (sizeEmulation) uiLayoutContainer.update(x,y);
		else uiLayoutContainer.update(peoteView.width, peoteView.height);
	}

	// ----------------- KEYBOARD EVENTS ---------------------------
	public override function onKeyDown (keyCode:KeyCode, modifier:KeyModifier) {
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
	public override function onWindowResize (width:Int, height:Int) {
		peoteView.resize(width, height);
		
		// calculates new Layout and updates all Elements 
		if (uiLayoutContainer != null) uiLayoutContainer.update(width, height);
	}

}
