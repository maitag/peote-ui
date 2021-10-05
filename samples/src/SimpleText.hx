package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.graphics.RenderContext;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.ui.MouseWheelMode;
import lime.ui.Touch;

import peote.view.PeoteView;
import peote.view.Color;

import peote.text.Font;

import peote.ui.fontstyle.FontStyleTiled;
import peote.ui.fontstyle.FontStylePacked;

import peote.ui.UIDisplay;
import peote.ui.interactive.InteractiveTextLine;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;

class SimpleText extends Application
{
	var peoteView:PeoteView;
	var uiDisplay:UIDisplay;
	
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
		uiDisplay = new UIDisplay(0, 0, window.width, window.height, Color.GREY1);
		peoteView.addDisplay(uiDisplay);
			
		// load the FONT:
		new Font<FontStyleTiled>("assets/fonts/tiled/hack_ascii.json").load( onTiledFontLoaded );
		new Font<FontStylePacked>("assets/fonts/packed/hack/config.json").load( onPackedFontLoaded );
					
		//peoteView.zoom = 2;

		#if android
		uiDisplay.mouseEnabled = false;
		peoteView.zoom = 3;
		#end
	}
		
	public function onTiledFontLoaded(font:Font<FontStyleTiled>) { // don'T forget argument-type here !
						
			var fontStyleTiled = new FontStyleTiled();
			fontStyleTiled.height = 25;
			fontStyleTiled.width = 25;
			
			var textLine = new InteractiveTextLine<FontStyleTiled>(0, 0, 10, 25, 0, "hello", font, fontStyleTiled); //, selectionFontStyle
			//var textLine = font.createInteractiveTextLine(0, 0, 112, 25, 0, "hello", fontStyleTiled); //, selectionFontStyle
						
			textLine.onPointerOver = function(t:InteractiveTextLine<FontStyleTiled>, e:PointerEvent) {
				trace("onPointerOver");
				t.fontStyle.color = Color.YELLOW;
				t.updateStyle();
			}
			textLine.onPointerOut = function(t:InteractiveTextLine<FontStyleTiled>, e:PointerEvent) {
				trace("onPointerOut");
				t.fontStyle.color = Color.GREEN;
				t.updateStyle();
			}
						
			uiDisplay.add(textLine);
			
			haxe.Timer.delay(function() {
				//trace("change style after");
				//textLine2.fontStyle = fontStyleTiled;
				//textLine2.updateStyle();				
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
			
			//var textLine = new InteractiveTextLine<FontStylePacked>(0, 80, 112, 25, "hello Button", fontPacked, fontStylePacked); //, selectionFontStyle
			var textLine = font.createInteractiveTextLine(250, 0, 70, 18, 0, true, "Masked", fontStylePacked); //, selectionFontStyle

			textLine.onPointerOver = function(t:InteractiveTextLine<FontStylePacked>, e:PointerEvent) {
				trace("onPointerOver");
				t.fontStyle.color = Color.YELLOW;
				t.updateStyle();
			}
			textLine.onPointerOut = function(t:InteractiveTextLine<FontStylePacked>, e:PointerEvent) {
				trace("onPointerOut");
				t.fontStyle.color = Color.GREEN;
				t.updateStyle();
			}
						
			uiDisplay.add(textLine);
			
			haxe.Timer.delay(function() {
				//trace("change style after");
				//textLine2.fontStyle = fontStyleTiled;
				//textLine2.updateStyle();				
				uiDisplay.remove(textLine);
				haxe.Timer.delay(function() {
					uiDisplay.add(textLine);
				}, 1000);
				
			}, 1000);
	}
	
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	// override function onPreloadComplete() {}
	// override function update(deltaTime:Int) {}
	// public override function onRenderContextLost ():Void trace(" --- WARNING: LOST RENDERCONTEXT --- ");		
	// public override function onRenderContextRestored (context:RenderContext):Void trace(" --- onRenderContextRestored --- ");		


	// ----------------- MOUSE EVENTS ------------------------------
	#if (! html5)
		var isMouseMove = false;
		var lastMouseMoveX:Float = 0.0;
		var lastMouseMoveY:Float = 0.0;
		override function render(context:RenderContext)
		{
			if (isMouseMove) {
				isMouseMove = false;
				onMouseMoveFrameSynced(lastMouseMoveX, lastMouseMoveY);
			}
		}
	#end
	
	override function onMouseMove (x:Float, y:Float) {
		#if (html5)
		onMouseMoveFrameSynced(x, y);
		#else
		lastMouseMoveX = x;
		lastMouseMoveY = y;
		isMouseMove = true;
		#end		
	}
		
	inline function onMouseMoveFrameSynced (x:Float, y:Float) uiDisplay.mouseMove(x, y);
	
	override function onMouseDown (x:Float, y:Float, button:MouseButton) uiDisplay.mouseDown(x, y, button);
	override function onMouseUp (x:Float, y:Float, button:MouseButton) uiDisplay.mouseUp(x, y, button);
	override function onMouseWheel (dx:Float, dy:Float, mode:MouseWheelMode) uiDisplay.mouseWheel(dx, dy, mode);
	// public override function onMouseMoveRelative (x:Float, y:Float):Void {}

	// ----------------- TOUCH EVENTS ------------------------------
	override function onTouchStart (touch:Touch) uiDisplay.touchStart(touch);
	override function onTouchMove (touch:Touch)	 uiDisplay.touchMove(touch);
	override function onTouchEnd (touch:Touch)  uiDisplay.touchEnd(touch);
	override function onTouchCancel (touch:Touch)  uiDisplay.touchCancel(touch);
	
	// ----------------- KEYBOARD EVENTS ---------------------------
	override function onKeyDown (keyCode:KeyCode, modifier:KeyModifier) {
		switch (keyCode) {
			#if html5
			case KeyCode.TAB: untyped __js__('event.preventDefault();');
			#end
			case KeyCode.F: window.fullscreen = !window.fullscreen;
			default:
		}
		uiDisplay.keyDown(keyCode, modifier);
	}
	
	override function onKeyUp (keyCode:KeyCode, modifier:KeyModifier) uiDisplay.keyUp(keyCode, modifier);
	// public override function onTextEdit(text:String, start:Int, length:Int) {}
	// public override function onTextInput (text:String)	{}

	// ----------------- WINDOWS EVENTS ----------------------------
	public override function onWindowLeave() {
		#if (! html5)
		lastMouseMoveX = lastMouseMoveY = -1; // fix for another onMouseMoveFrameSynced() by render-loop
		#end
		uiDisplay.windowLeave();
	}
	// override function onWindowResize (width:Int, height:Int) { trace("onWindowResize"); }
	// override function onWindowEnter():Void { trace("onWindowEnter"); }
	// override function onWindowActivate():Void { trace("onWindowActivate"); }
	// override function onWindowDeactivate():Void { trace("onWindowDeactivate"); }
	// override function onWindowClose():Void { trace("onWindowClose"); }
	// override function onWindowDropFile(file:String):Void { trace("onWindowDropFile"); }
	// override function onWindowExpose():Void { trace("onWindowExpose"); }
	// override function onWindowFocusIn():Void { trace("onWindowFocusIn"); }
	// override function onWindowFocusOut():Void { trace("onWindowFocusOut"); }
	// override function onWindowFullscreen():Void { trace("onWindowFullscreen"); }
	// override function onWindowMove(x:Float, y:Float):Void { trace("onWindowMove"); }
	// override function onWindowMinimize():Void { trace("onWindowMinimize"); }
	// override function onWindowRestore():Void { trace("onWindowRestore"); }
}
