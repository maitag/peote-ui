package;

import peote.view.Texture;
import peote.view.Buffer;
import peote.view.Element;
import peote.view.Program;
import peote.view.Display;
import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Color;

import peote.ui.PeoteUIDisplay;
import peote.ui.interactive.UIElement;
import peote.ui.style.RoundBorderStyle;

class TestUIDisplayFramebuffer extends Application
{
	var peoteView:PeoteView;
	var uiDisplay:PeoteUIDisplay;
	
	override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try startSample(window)
				catch (_) trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}

	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);

		uiDisplay = new PeoteUIDisplay(0, 0, window.width, window.height);

		// extra "view"-Display to render the UIDisplay into
		var display = new Display(0, 0, window.width, window.height);
		peoteView.addDisplay(display);

		var texture = new Texture(window.width, window.height);
		var view_buffer = new Buffer<ViewElement>(1);
		var view_program = new Program(view_buffer);
		view_program.addTexture(texture, "view", true);
		display.addProgram(view_program);

		var view = new ViewElement(400,0,window.width, window.height);
		view_buffer.addElement(view);

		// add to peote-view fb-list
		peoteView.addFramebufferDisplay(uiDisplay);
		uiDisplay.setFramebuffer(texture, peoteView);

		// add to peote-view
		peoteView.addDisplay(uiDisplay);
		
		var roundBorderStyle = new RoundBorderStyle();
		roundBorderStyle.color = Color.GREY1;
		roundBorderStyle.borderColor = Color.GREY5;
		roundBorderStyle.borderSize = 14.0;
		roundBorderStyle.borderRadius = 40.0;
		
		var button = new UIElement(20, 20, 200, 100, roundBorderStyle);
		uiDisplay.add(button);
		
		button.onPointerOver = (element, event) -> {
			element.style.color = Color.CYAN;
			element.updateStyle();
		}

		button.onPointerOut = (element, event) -> {
			element.style.color = Color.GREY1;
			element.updateStyle();
		}

		button.onPointerDown = (element, event) -> {
			element.style.borderColor = Color.YELLOW;
			element.updateStyle();
		}

		button.onPointerUp = (element, event) -> {
			element.style.borderColor = Color.GREY5;
			element.updateStyle();
		}

		PeoteUIDisplay.registerEvents(window);
	}
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	// override function onPreloadComplete() {}
	// override function update(deltaTime:Int) {}
	// public override function onRenderContextLost ():Void trace(" --- WARNING: LOST RENDERCONTEXT --- ");		
	// public override function onRenderContextRestored (context:RenderContext):Void trace(" --- onRenderContextRestored --- ");		

	// override function onWindowResize (width:Int, height:Int) { trace("onWindowResize"); }
	// override function onWindowActivate():Void { trace("onWindowActivate"); }
	// override function onWindowDeactivate():Void { trace("onWindowDeactivate"); }
	// override function onWindowClose():Void { trace("onWindowClose"); }
	// override function onWindowDropFile(file:String):Void { trace("onWindowDropFile"); }
	// override function onWindowEnter():Void { trace("onWindowEnter"); }
	// override function onWindowExpose():Void { trace("onWindowExpose"); }
	// override function onWindowFocusIn():Void { trace("onWindowFocusIn"); }
	// override function onWindowFocusOut():Void { trace("onWindowFocusOut"); }
	// override function onWindowFullscreen():Void { trace("onWindowFullscreen"); }
	// override function onWindowMove(x:Float, y:Float):Void { trace("onWindowMove"); }
	// override function onWindowMinimize():Void { trace("onWindowMinimize"); }
	// override function onWindowRestore():Void { trace("onWindowRestore"); }
}


class ViewElement implements Element
{
	@posX public var x: Int;
	@posY public var y: Int;
	@sizeX public var width: Int;
	@sizeY public var height: Int;
	@color public var tint: Color = 0xffff00FF;

	public function new(x: Int, y: Int, width: Int, height: Int)
	{
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}
}