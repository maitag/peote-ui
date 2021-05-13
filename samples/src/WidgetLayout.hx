package;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.ui.MouseWheelMode;
import lime.ui.Touch;

import peote.view.PeoteView;
import peote.view.Color;

import peote.ui.skin.Skin;
import peote.ui.skin.Style;

import peote.ui.PeoteUI;
import peote.ui.widget.*;

import peote.layout.Size;


class WidgetLayout extends Application
{
	var peoteView:PeoteView;
	var mySkin = new Skin();
		
	var ui:PeoteUI;
	
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
			
			var mySkin = new Skin();
			
			var myStyle = new Style();
			myStyle.color = Color.GREY1;
			myStyle.borderColor = Color.GREY5;
			myStyle.borderSize = 4.0;
			myStyle.borderRadius = 40.0;

			
			ui = new PeoteUI({
				left:10,
				right:10,
			},
			[
				
				// later into widget -> new LabelButton()
	/*			new Box(
				{
					//onPointerOver:onOver.bind(Color.BLUE),
					onPointerClick: function(uiElement:UIElement, e:PointerEvent) {
						uiElement.child[0].style.color = Color.RED;
					},
					
				},
				[
					new TextLine(),
				]),
	*/		
			
			
	/*			// later into widget -> new VScrollArea()
				new HBox(
				[
					new VScroll(),
					new VSlider({width:30}),
				]),
	*/			
			]);
			
			ui.init();
			ui.update(peoteView.width, peoteView.height);
			peoteView.addDisplay(ui);
			
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}

	// --------------------------------------------------
/*	public inline function onOver(color:Color, uiElement:UIElement, e:PointerEvent) {
		uiElement.style.color = color;
		uiElement.style.borderColor = Color.GREY7;
		uiElement.updateStyle();
		//uiElement.updateLayout();
		trace(" -----> onPointerOver", e);
	}
*/
	

	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	public override function onPreloadComplete():Void {
		// access embeded assets here
	}

	public override function update(deltaTime:Int):Void {
		// for game-logic update
	}

	public override function render(context:lime.graphics.RenderContext):Void
	{
		#if (! html5)
		onMouseMoveFrameSynced();
		#end
		peoteView.render(); // rendering all Displays -> Programs - Buffer
	}
	
	// public override function onRenderContextLost ():Void trace(" --- WARNING: LOST RENDERCONTEXT --- ");		
	// public override function onRenderContextRestored (context:lime.graphics.RenderContext):Void trace(" --- onRenderContextRestored --- ");		

	// ----------------- MOUSE EVENTS ------------------------------
	public override function onMouseMove (x:Float, y:Float) {
		#if (html5)
		//ui.onMouseMove(x, y);
		#else
		lastMouseMoveX = x;
		lastMouseMoveY = y;
		isMouseMove = true;
		#end		
	}
	
	#if (! html5)
	var isMouseMove = false;
	var lastMouseMoveX:Float = 0.0;
	var lastMouseMoveY:Float = 0.0;
	inline function onMouseMoveFrameSynced():Void
	{
		if (isMouseMove) {
			isMouseMove = false;
			//ui.onMouseMove(lastMouseMoveX, lastMouseMoveY);
		}
	}
	#end
	
	//public override function onMouseDown (x:Float, y:Float, button:MouseButton) ui.onMouseDown(x, y, button);
	//public override function onMouseUp (x:Float, y:Float, button:MouseButton) ui.onMouseUp(x, y, button);
	//public override function onMouseWheel (dx:Float, dy:Float, mode:MouseWheelMode) ui.onMouseWheel(dx, dy, mode);
	// public override function onMouseMoveRelative (x:Float, y:Float):Void {}

	// ----------------- TOUCH EVENTS ------------------------------
	//public override function onTouchStart (touch:Touch):Void ui.onTouchStart(touch);
	//public override function onTouchMove (touch:Touch):Void	 ui.onTouchMove(touch);
	//public override function onTouchEnd (touch:Touch):Void  ui.onTouchEnd(touch);
	//public override function onTouchCancel (touch:Touch):Void ui.onTouchCancel(touch);
	
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
		//ui.onKeyDown(keyCode, modifier);
	}
	
	//public override function onKeyUp (keyCode:KeyCode, modifier:KeyModifier) ui.onKeyUp(keyCode, modifier);
	//public override function onTextEdit(text:String, start:Int, length:Int) ui.onTextEdit(text, start, length);
	//public override function onTextInput (text:String):Void ui.onTextInput(text);

	// ----------------- WINDOWS EVENTS ----------------------------
	public override function onWindowResize (width:Int, height:Int) {
		peoteView.resize(width, height);
		ui.update(width, height);
	}
	//public override function onWindowLeave():Void ui.onWindowLeave();
	
	// public override function onWindowActivate():Void { trace("onWindowActivate"); }
	// public override function onWindowDeactivate():Void { trace("onWindowDeactivate"); }
	// public override function onWindowClose():Void { trace("onWindowClose"); }
	// public override function onWindowDropFile(file:String):Void { trace("onWindowDropFile"); }
	// public override function onWindowEnter():Void { trace("onWindowEnter"); }
	// public override function onWindowExpose():Void { trace("onWindowExpose"); }
	// public override function onWindowFocusIn():Void { trace("onWindowFocusIn"); }
	// public override function onWindowFocusOut():Void { trace("onWindowFocusOut"); }
	// public override function onWindowFullscreen():Void { trace("onWindowFullscreen"); }
	// public override function onWindowMove(x:Float, y:Float):Void { trace("onWindowMove"); }
	// public override function onWindowMinimize():Void { trace("onWindowMinimize"); }
	// public override function onWindowRestore():Void { trace("onWindowRestore"); }
}
