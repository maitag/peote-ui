package;

import lime.app.Application;
import lime.graphics.RenderContext;
import lime.ui.MouseButton;
import lime.ui.MouseWheelMode;
import lime.ui.Touch;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;

#if ButtonEvents
typedef Sample = ButtonEvents;
#elseif JasperLayout
typedef Sample = JasperLayout;
#end 

class Main extends Application
{
	var sample:Sample = null;
	var init:Bool = false;

	public function new() {
		super();
	}
	
	public override function onWindowCreate():Void
	{
		trace (window.context.type +"" + window.context.version);
		
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES: sample = new Sample(window);
				
			default: throw("Sorry, only works with OpenGL.");
		}
		
		if (sample != null) init = true;
	}
	
	// ------------------------------------------------------------	
	// ----------- Render Loop ------------------------------------
	// ------------------------------------------------------------	
	
	public override function render(context:RenderContext):Void
	{	
		if (init) sample.render();
		#if (! html5)
		if (isMouseMove) onMouseMoveFrameSynced();
		#end
	}
	
	public override function update(deltaTime:Int):Void
	{
		if (init) sample.update(deltaTime);
	}

	// ------------------------------------------------------------
	// ----------- EVENT HANDLER ----------------------------------
	// ------------------------------------------------------------
	
	public override function onPreloadComplete ():Void {
		if (init) sample.onPreloadComplete();
	}
	public override function onPreloadProgress(loaded:Int, total:Int):Void {}
	
	
	public override function onRenderContextLost ():Void
	{		
		trace(" --------- ERROR :  LOST RENDERCONTEXT ----------- ");		
	}
	
	public override function onRenderContextRestored (context:RenderContext):Void
	{
		trace(" --------- onRenderContextRestored ----------- ");		
	}
		
	
	// ----------- mouse events -------------
	
	public override function onMouseMoveRelative (x:Float, y:Float):Void {
		//trace("onMouseMoveRelative", x, y ); 	
	}
	
	#if (! html5)
	var lastMoveX:Float = 0.0;
	var lastMoveY:Float = 0.0;
	#end
	public override function onMouseMove (x:Float, y:Float):Void
	{
		#if (html5)
		if (init) sample.onMouseMove(x, y);
		#else
		lastMoveX = x;
		lastMoveY = y;
		isMouseMove = true;
		#end
	}
	
	#if (! html5)
	var isMouseMove = false;
	function onMouseMoveFrameSynced():Void
	{
		isMouseMove = false;
		if (init) sample.onMouseMove(lastMoveX, lastMoveY);
	}
	#end
	
	public override function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{	
		if (init) sample.onMouseDown(x, y, button);
	}
	
	public override function onMouseUp (x:Float, y:Float, button:MouseButton):Void
	{	
		if (init) sample.onMouseUp(x, y, button);
	}
	
	public override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:MouseWheelMode):Void
	{	
		if (init) sample.onMouseWheel(deltaX, deltaY, deltaMode);
	}
	
	// ----------- touch events -------------

	public override function onTouchStart (touch:Touch):Void
	{
		if (init) sample.onTouchStart(touch);
	}
	
	public override function onTouchMove (touch:Touch):Void
	{
		if (init) sample.onTouchMove(touch);
	}
	
	public override function onTouchEnd (touch:Touch):Void
	{
		if (init) sample.onTouchEnd(touch);
	}
	
	public override function onTouchCancel(touch:Touch):Void 
	{
		if (init) sample.onTouchCancel(touch);
	}
	
	
	// ----------- keyboard and textinput events -------------

	public override function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		//trace("keydown",keyCode, modifier);
		#if (!sampleTextlineMasking)
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
		#end
		if (init) sample.onKeyDown(keyCode, modifier);
	}
	
	public override function onKeyUp (keyCode:KeyCode, modifier:KeyModifier):Void {
		if (init) sample.onKeyUp(keyCode, modifier);
	}

	public override function onTextEdit(text:String, start:Int, length:Int):Void {
		if (init) sample.onTextEdit(text, start, length);
	}
	
	public override function onTextInput (text:String):Void	{	
		if (init) sample.onTextInput(text);
	}
	

	// ----------- window events -------------
	
	public override function onWindowResize (width:Int, height:Int):Void {
		if (init) sample.resize(width, height);
		/*
		// hack for minimum width on cpp native
		var w = Math.floor(Math.max(200, width));
		var h = Math.floor(Math.max(200, height));
		
		if (w != width || h != height) window.resize(w, h);
		*/
	}
	
	public override function onWindowLeave ():Void {
		//trace("onWindowLeave"); 
		if (init) sample.onWindowLeave();
	}
	public override function onWindowActivate ():Void {
		//trace("onWindowActivate"); 
		if (init) sample.onWindowActivate();
	}
	/*
	public override function onWindowClose ():Void { trace("onWindowClose"); }
	public override function onWindowDeactivate ():Void { trace("onWindowDeactivate"); }
	public override function onWindowDropFile (file:String):Void { trace("onWindowDropFile"); }
	public override function onWindowEnter ():Void { trace("onWindowEnter"); }
	public override function onWindowExpose ():Void { trace("onWindowExpose"); }
	public override function onWindowFocusIn ():Void { trace("onWindowFocusIn"); }
	public override function onWindowFocusOut ():Void { trace("onWindowFocusOut"); }
	public override function onWindowFullscreen ():Void { trace("onWindowFullscreen"); }
	public override function onWindowMove (x:Float, y:Float):Void { trace("onWindowMove"); }
	public override function onWindowMinimize ():Void { trace("onWindowMinimize"); }
	public override function onWindowRestore ():Void { trace("onWindowRestore"); }
	*/
	
}
