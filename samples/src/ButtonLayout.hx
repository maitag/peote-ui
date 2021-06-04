package;

import lime.ui.Window;
import lime.ui.MouseButton;
import lime.app.Application;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.graphics.RenderContext;

import peote.view.PeoteView;
import peote.view.Color;

import peote.ui.widget.UIDisplay;
import peote.ui.widget.UIElement;
import peote.ui.skin.RoundedSkin;
import peote.ui.skin.SimpleStyle;

import peote.layout.LayoutContainer;
import peote.layout.Size;


class ButtonLayout extends Application
{
	var peoteView:PeoteView;
	var uiDisplay:UIDisplay;
	var mySkin = new RoundedSkin();
		
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
			uiDisplay = new UIDisplay(0, 0, window.width, window.height, Color.GREY3);
			peoteView.addDisplay(uiDisplay);
			
			var red   = new UIElement(mySkin, new SimpleStyle(Color.RED));
			var green = new UIElement(mySkin, new SimpleStyle(Color.GREEN));
			var blue  = new UIElement(mySkin, new SimpleStyle(Color.BLUE));
			var yellow= new UIElement(mySkin, new SimpleStyle(Color.YELLOW));

			uiDisplay.add(red);
			uiDisplay.add(green);
			uiDisplay.add(blue);
			uiDisplay.add(yellow);
			
			uiLayoutContainer = new Box( uiDisplay , { width:Size.limit(100,700), relativeChildPositions:true },
			[                                                          
				new Box( red , { width:Size.limit(100,600) },
				[                                                      
					new Box( green,  { width:Size.limit(50, 300), height:Size.limit(100,400) }),							
					new Box( blue,   { width:Size.span(50, 150), height:Size.limit(100,300), left:Size.min(50) } ),
					new Box( yellow, { width:Size.limit(50, 150), height:Size.limit(200,200), left:Size.span(0,100), right:50 } ),
				])
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
		uiDisplay.mouseMove(x, y);
		if (sizeEmulation) uiLayoutContainer.update(Std.int(x),Std.int(y));
	}
	
	public override  function onMouseUp (x:Float, y:Float, button:MouseButton) {
		uiDisplay.mouseUp(x, y, button);
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
		uiDisplay.keyDown(keyCode, modifier);
	}
	
	// ----------------- WINDOWS EVENTS ----------------------------
	public override function onWindowResize (width:Int, height:Int) {
		peoteView.resize(width, height);
		
		// calculates new Layout and updates all Elements 
		uiLayoutContainer.update(width, height);
	}

}
