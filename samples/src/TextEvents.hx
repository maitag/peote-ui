package;

import lime.app.Application;
import lime.graphics.RenderContext;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.ui.MouseWheelMode;
import lime.ui.Touch;

import peote.view.PeoteView;
import peote.view.Color;

import peote.text.Font;
import peote.ui.text.FontStyleTiled;
import peote.ui.text.FontStylePacked;

import peote.ui.interactive.UIDisplay;
import peote.ui.interactive.TextLine;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;

class TextEvents extends Application
{
	var peoteView:PeoteView;
	var uiDisplay:UIDisplay;
	
	public function new() super();
	
	public override function onWindowCreate() {
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES: initPeoteView();
			default: throw("Sorry, only works with OpenGL.");
		}
	}
	
	public function initPeoteView() {

		peoteView = new PeoteView(window.context, window.width, window.height);
		uiDisplay = new UIDisplay(0, 0, window.width, window.height, Color.GREY1);
		peoteView.addDisplay(uiDisplay);
			
		try {			
			// load the FONT:
			new Font<FontStyleTiled>("assets/fonts/tiled/hack_ascii.json").load( onTiledFontLoaded );
			new Font<FontStylePacked>("assets/fonts/packed/hack/config.json").load( onPackedFontLoaded );
						
			//peoteView.zoom = 2;

			#if android
			uiDisplay.mouseEnabled = false;
			peoteView.zoom = 3;
			#end
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}
		
	public function onTiledFontLoaded(font:Font<FontStyleTiled>) { // don'T forget argument-type here !
						
			var fontStyleTiled = new FontStyleTiled();
			fontStyleTiled.height = 25;
			fontStyleTiled.width = 25;
			
			var textLine = new TextLine<FontStyleTiled>(0, 0, 10, 25, 0, "hello", font, fontStyleTiled); //, selectionFontStyle
			//var textLine = font.createTextLine(0, 0, 112, 25, 0, "hello", fontStyleTiled); //, selectionFontStyle
						
			textLine.onPointerOver = function(t:TextLine<FontStyleTiled>, e:PointerEvent) {
				trace("onPointerOver");
				t.fontStyle.color = Color.YELLOW;
				t.updateStyle();
				t.update();
			}
			textLine.onPointerOut = function(t:TextLine<FontStyleTiled>, e:PointerEvent) {
				trace("onPointerOut");
				t.fontStyle.color = Color.GREEN;
				t.updateStyle();
				t.update();
			}
						
			uiDisplay.add(textLine);
			
			haxe.Timer.delay(function() {
				//trace("change style after");
				//textLine2.fontStyle = fontStyleTiled;
				//textLine2.updateStyle();
				//textLine2.update();
				
				uiDisplay.remove(textLine);
				haxe.Timer.delay(function() {					
					uiDisplay.add(textLine);
				}, 1000);
				
			}, 1000);

			
			// TODO
			// line.set("new Text", 0, 0, fontStyle);
			// line.setStyle(fontStyle, 1, 4);			
	}
	
	public function onPackedFontLoaded(font:Font<FontStylePacked>) {
						
			var fontStylePacked = new FontStylePacked();
			fontStylePacked.height = 25;
			fontStylePacked.width = 25;
			
			//var textLine = new TextLine<FontStylePacked>(0, 80, 112, 25, "hello Button", fontPacked, fontStylePacked); //, selectionFontStyle
			var textLine = font.createTextLine(250, 0, 50, 25, 0, true, "Masked", fontStylePacked); //, selectionFontStyle

			textLine.onPointerOver = function(t:TextLine<FontStylePacked>, e:PointerEvent) {
				trace("onPointerOver");
				t.fontStyle.color = Color.YELLOW;
				t.updateStyle();
				t.update();
			}
			textLine.onPointerOut = function(t:TextLine<FontStylePacked>, e:PointerEvent) {
				trace("onPointerOut");
				t.fontStyle.color = Color.GREEN;
				t.updateStyle();
				t.update();
			}
						
			uiDisplay.add(textLine);
	}
	
	
	// ----------------- Eventhandler ----------------------
	
/*	public inline function onOver(color:Color, uiElement:UIButton, e:PointerEvent) {
		uiElement.style.color = color;
		uiElement.style.borderColor = Color.GREY7;
		uiElement.update();
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

	public override function render(context:RenderContext)
	{
		#if (! html5)
		onMouseMoveFrameSynced();
		#end
		peoteView.render(); // rendering all Displays -> Programs - Buffer
	}
	
	// public override function onRenderContextLost ():Void trace(" --- WARNING: LOST RENDERCONTEXT --- ");		
	// public override function onRenderContextRestored (context:RenderContext):Void trace(" --- onRenderContextRestored --- ");		

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
	inline function onMouseMoveFrameSynced()
	{
		if (isMouseMove) {
			isMouseMove = false;
			_onMouseMove(lastMouseMoveX, lastMouseMoveY);
		}
	}
	#end
	
	inline function _onMouseMove (x:Float, y:Float) uiDisplay.mouseMove(x, y);
	
	public override function onMouseDown (x:Float, y:Float, button:MouseButton) uiDisplay.mouseDown(x, y, button);
	public override function onMouseUp (x:Float, y:Float, button:MouseButton) uiDisplay.mouseUp(x, y, button);
	public override function onMouseWheel (dx:Float, dy:Float, mode:MouseWheelMode) uiDisplay.mouseWheel(dx, dy, mode);
	// public override function onMouseMoveRelative (x:Float, y:Float):Void {}

	// ----------------- TOUCH EVENTS ------------------------------
	public override function onTouchStart (touch:Touch) uiDisplay.touchStart(touch);
	public override function onTouchMove (touch:Touch)	 uiDisplay.touchMove(touch);
	public override function onTouchEnd (touch:Touch)  uiDisplay.touchEnd(touch);
	public override function onTouchCancel (touch:Touch)  uiDisplay.touchCancel(touch);
	
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
	
	public override function onKeyUp (keyCode:KeyCode, modifier:KeyModifier) uiDisplay.keyUp(keyCode, modifier);
	// public override function onTextEdit(text:String, start:Int, length:Int) {}
	// public override function onTextInput (text:String)	{}

	// ----------------- WINDOWS EVENTS ----------------------------
	public override function onWindowResize (width:Int, height:Int) peoteView.resize(width, height);
	public override function onWindowLeave() {
		#if (! html5)
		lastMouseMoveX = lastMouseMoveY = -1; // fix for another onMouseMoveFrameSynced() by render-loop
		#end
		uiDisplay.windowLeave();
	}
	// public override function onWindowEnter():Void { trace("onWindowEnter"); }
	// public override function onWindowActivate():Void { trace("onWindowActivate"); }
	// public override function onWindowDeactivate():Void { trace("onWindowDeactivate"); }
	// public override function onWindowClose():Void { trace("onWindowClose"); }
	// public override function onWindowDropFile(file:String):Void { trace("onWindowDropFile"); }
	// public override function onWindowExpose():Void { trace("onWindowExpose"); }
	// public override function onWindowFocusIn():Void { trace("onWindowFocusIn"); }
	// public override function onWindowFocusOut():Void { trace("onWindowFocusOut"); }
	// public override function onWindowFullscreen():Void { trace("onWindowFullscreen"); }
	// public override function onWindowMove(x:Float, y:Float):Void { trace("onWindowMove"); }
	// public override function onWindowMinimize():Void { trace("onWindowMinimize"); }
	// public override function onWindowRestore():Void { trace("onWindowRestore"); }
}
