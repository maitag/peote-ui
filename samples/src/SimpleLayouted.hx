package;

import lime.ui.Window;
import lime.ui.MouseButton;
import lime.app.Application;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.graphics.RenderContext;
import peote.ui.event.PointerEvent;
import peote.ui.interactive.InteractiveElement;

import peote.view.PeoteView;
import peote.view.Color;

import peote.text.Font;
import peote.ui.fontstyle.FontStyleTiled;

import peote.ui.layouted.LayoutedUIDisplay;
import peote.ui.layouted.LayoutedElement;
import peote.ui.layouted.LayoutedTextLine;

import peote.ui.skin.SimpleSkin;
import peote.ui.style.SimpleStyle;
import peote.ui.skin.RoundedSkin;
import peote.ui.style.RoundedStyle;

import peote.layout.LayoutContainer;
import peote.layout.Size;


class SimpleLayouted extends Application
{
	var peoteView:PeoteView;
	var layoutedUIDisplay:LayoutedUIDisplay;
	
	var simlpeSkin = new SimpleSkin();
	var roundedSkin = new RoundedSkin();
		
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
			new Font<FontStyleTiled>("assets/fonts/tiled/hack_ascii.json").load( onFontLoaded );
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}
	
	public function onFontLoaded(font:Font<FontStyleTiled>) { // don'T forget argument-type or force at least the style to FontStyleTiled-Type (see below!)
	//public function onFontLoaded(font) {
		try {			
			var red   = new LayoutedElement(simlpeSkin, new SimpleStyle(Color.RED));
			var green = new LayoutedElement(simlpeSkin, new SimpleStyle(Color.GREEN));
			var blue  = new LayoutedElement(roundedSkin, new SimpleStyle(Color.BLUE));
			var yellow= new LayoutedElement(roundedSkin, new SimpleStyle(Color.YELLOW));
			yellow.onPointerOver = function(elem:InteractiveElement, e:PointerEvent) {
				elem.style.color = Color.YELLOW - 0x00550000;
				elem.update();
			}
			
			yellow.onPointerOut = function(elem:InteractiveElement, e:PointerEvent) {
				elem.style.color = Color.YELLOW;
				elem.update();
			}
			
			layoutedUIDisplay.add(red);
			layoutedUIDisplay.add(green);
			layoutedUIDisplay.add(blue);
			layoutedUIDisplay.add(yellow);

			var fontStyleTiled:FontStyleTiled = font.createFontStyle(); // (at least here it needs the FontStyleTiled Type!)
			//var fontStyleTiled = font.createFontStyle();
			//var fontStyleTiled = new FontStyleTiled();
			fontStyleTiled.height = 30.0;
			fontStyleTiled.width = 30.0;
			fontStyleTiled.color = Color.BLACK;
			
			//var textLine1 = new LayoutedTextLine<FontStyleTiled>(0, 0, 112, 25, 0, "hello", font, fontStyleTiled);
			var textLine1:LayoutedTextLine<FontStyleTiled> = font.createLayoutedTextLine(0, 0, 300, 25, 0, false, "hello world", fontStyleTiled);
			layoutedUIDisplay.add(textLine1);
			
			// masked -> true
			var textLine2 = font.createLayoutedTextLine(0, 0, 300, 25, 0, true, "hello world", font.createFontStyle());			
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
				textLine2.fontStyle.height = 30;
				textLine2.updateStyle();
				textLine2.update();
				
			}, 1000);
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
