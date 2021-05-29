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

import peote.ui.skin.RoundedSkin;
import peote.ui.skin.Style;

import peote.ui.PeoteUI;
import peote.ui.widget.container.*;
import peote.ui.widget.*;

import peote.layout.Size;


class WidgetLayout extends Application
{
	var peoteView:PeoteView;
	var mySkin = new RoundedSkin();
		
	var ui:PeoteUI;
	
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
			
			var mySkin = new RoundedSkin();
			
			var myStyle = new Style();
			myStyle.color = Color.GREY1;
			myStyle.borderColor = Color.GREY5;
			myStyle.borderSize = 4.0;
			myStyle.borderRadius = 40.0;

			
			ui = new PeoteUI({
				bgColor:Color.GREY1,
				left:10,
				right:10,
			},
			[
				
				// later into widget -> new LabelButton()
				new Box(
				{
					top:20,
					left:20,
					width:200,
					height:50,
					skin:mySkin,
					style:myStyle, // default Style (if myStyle changed it needs a update of all elements that using this!)
					// To overwrite all of "myStyle"
					//	color:Color.GREY1,
					//	borderColor:Color.GREY5,
					//	borderSize:4.0,
					//	borderRadius:40.0,
					}
					//onPointerOver:onOver.bind(Color.BLUE),
					//onPointerClick: function(widget:Widget, e:PointerEvent) {
						//widget.style.color = Color.RED;
						//widget.skin = mySkin1;
						//widget.parent.style.color = Color.RED;
						//widget.child[0].style.color = Color.RED;
					//},
					
				},
				[
					//new TextLine(),
				]),
			
			
			
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
/*	public inline function onOver(color:Color, widget:Widget, e:PointerEvent) {
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

	public override function onPreloadComplete() {
		// access embeded assets here
	}

	public override function update(deltaTime:Int) {
		// for game-logic update
	}

	public override function render(context:lime.graphics.RenderContext)
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
		_onMouseMove(x, y);
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
			_onMouseMove(lastMouseMoveX, lastMouseMoveY);
		}
	}
	#end
	
	inline function _onMouseMove (x:Float, y:Float) {
		ui.mouseMove(x, y);
	}
	public override function onMouseDown (x:Float, y:Float, button:MouseButton) ui.mouseDown(x, y, button);
	public override function onMouseUp (x:Float, y:Float, button:MouseButton) ui.mouseUp(x, y, button);
	public override function onMouseWheel (dx:Float, dy:Float, mode:MouseWheelMode) ui.mouseWheel(dx, dy, mode);
	// public override function onMouseMoveRelative (x:Float, y:Float):Void {}

	// ----------------- TOUCH EVENTS ------------------------------
	public override function onTouchStart (touch:Touch) ui.touchStart(touch);
	public override function onTouchMove (touch:Touch) ui.touchMove(touch);
	public override function onTouchEnd (touch:Touch) ui.touchEnd(touch);
	public override function onTouchCancel (touch:Touch) ui.touchCancel(touch);
	
	// ----------------- KEYBOARD EVENTS ---------------------------
	public override function onKeyDown (keyCode:KeyCode, modifier:KeyModifier) {
		switch (keyCode) {
			#if html5
			case KeyCode.TAB: untyped __js__('event.preventDefault();');
			#end
			case KeyCode.F: window.fullscreen = !window.fullscreen;
			default:
		}
		//ui.keyDown(keyCode, modifier);
	}
	
	//public override function onKeyUp (keyCode:KeyCode, modifier:KeyModifier) ui.keyUp(keyCode, modifier);
	//public override function onTextEdit(text:String, start:Int, length:Int) ui.textEdit(text, start, length);
	//public override function onTextInput (text:String):Void ui.textInput(text);

	// ----------------- WINDOWS EVENTS ----------------------------
	public override function onWindowResize (width:Int, height:Int) {
		peoteView.resize(width, height);
		ui.update(width, height);
	}
	public override function onWindowLeave() ui.windowLeave();
	
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
