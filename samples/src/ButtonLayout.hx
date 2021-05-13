package;

import lime.ui.Window;
import lime.ui.MouseButton;
import lime.app.Application;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.graphics.RenderContext;

import peote.view.PeoteView;
import peote.view.Color;

import peote.ui.interactive.UIDisplay;
import peote.ui.interactive.Button;
import peote.ui.skin.Skin;
import peote.ui.skin.Style;

import peote.layout.LayoutContainer;
import peote.layout.Size;


class ButtonLayout extends Application
{
	var peoteView:PeoteView;
	var uiDisplay:UIDisplay;
	var mySkin = new Skin();
		
	var uiLayoutContainer:LayoutContainer;
	
	public function new() super();
	
	public override function onWindowCreate():Void {
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
			
			var red   = new Button(mySkin, new Style(Color.RED));
			var green = new Button(mySkin, new Style(Color.GREEN));
			var blue  = new Button(mySkin, new Style(Color.BLUE));
			var yellow= new Button(mySkin, new Style(Color.YELLOW));

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
		uiDisplay.onMouseMove(x, y);
		if (sizeEmulation) uiLayoutContainer.update(Std.int(x),Std.int(y));
	}
	
	public override  function onMouseUp (x:Float, y:Float, button:MouseButton) {
		uiDisplay.onMouseUp(x, y, button);
		sizeEmulation = !sizeEmulation; 
		if (sizeEmulation) uiLayoutContainer.update(x,y);
		else uiLayoutContainer.update(peoteView.width, peoteView.height);
	}

	// ----------------- KEYBOARD EVENTS ---------------------------
	public override function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void {
		switch (keyCode) {
			#if html5
			case KeyCode.TAB: untyped __js__('event.preventDefault();');
			case KeyCode.F:
				var e:Dynamic = untyped __js__("document.getElementById('content').getElementsByTagName('canvas')[0]");
				var noFullscreen:Dynamic = untyped __js__("(!document.fullscreenElement && !document.mozFullScreenElement && !document.webkitFullscreenElement && !document.msFullscreenElement)");
				
				if ( noFullscreen)
				{	// enter fullscreen
					if (e.requestFullScreen) e.requestFullScreen();
					else if (e.msRequestFullScreen) e.msRequestFullScreen();
					else if (e.mozRequestFullScreen) e.mozRequestFullScreen();
					else if (e.webkitRequestFullScreen) e.webkitRequestFullScreen();
				}
				else
				{	// leave fullscreen
					var d:Dynamic = untyped __js__("document");
					if (d.exitFullscreen) d.exitFullscreen();
					else if (d.msExitFullscreen) d.msExitFullscreen();
					else if (d.mozCancelFullScreen) d.mozCancelFullScreen();
					else if (d.webkitExitFullscreen) d.webkitExitFullscreen();					
				}
			#else
			case KeyCode.F: window.fullscreen = !window.fullscreen;
			#end
			default:
		}
		uiDisplay.onKeyDown(keyCode, modifier);
	}
	
	// ----------------- WINDOWS EVENTS ----------------------------
	public override function onWindowResize (width:Int, height:Int) {
		peoteView.resize(width, height);
		
		// calculates new Layout and updates all Elements 
		uiLayoutContainer.update(width, height);
	}

}
