package;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.ui.MouseWheelMode;
import lime.ui.Touch;
import peote.layout.ContainerType;
import peote.layout.LayoutContainer;

import peote.view.PeoteView;
import peote.view.Color;

import peote.text.Font;
import peote.ui.text.FontStyleTiled;

import peote.ui.skin.RoundedSkin;
import peote.ui.skin.RoundedStyle;

import peote.ui.PeoteUI;
import peote.ui.interactive.LayoutTextLine;
import peote.ui.event.PointerEvent;
import peote.ui.widget.Div;
import peote.ui.widget.TextLine;

import peote.ui.interactive.Button;

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
			
			// load the FONT:
			new Font<FontStyleTiled>("assets/fonts/tiled/hack_ascii.json").load( onFontLoaded );
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}
	
	public function onFontLoaded(font:Font<FontStyleTiled>) {
		try {
			
			var mySkin = new RoundedSkin();
			
			var myStyle = new RoundedStyle();
			myStyle.color = Color.GREY1;
			myStyle.borderColor = Color.GREY5;
			myStyle.borderSize = 4.0;
			myStyle.borderRadius = 40.0;

			var fontStyleTiled = new FontStyleTiled();
			fontStyleTiled.height = 25;
			fontStyleTiled.width = 25;
			fontStyleTiled.color = Color.WHITE;
			
			ui = new PeoteUI(ContainerType.BOX, {
				bgColor:Color.GREY1,
				//left:10,
				//right:10,
			},
			[
				
				// later into widget -> new LabelButton<FontStyleTiled>()
				new Div(
				{
					//layout:{
						top:20,
						//left:20,
						width:Size.limit(200, 300),
						height:50,
					//},
					skin:mySkin,
					style:myStyle,
					
					onPointerOver:onOverOut.bind(Color.BLUE),
					onPointerOut:onOverOut.bind(Color.GREY1),
					//onPointerClick: function(widget:Widget, e:PointerEvent) {
						//widget.style.color = Color.RED;
						//widget.parent.style.color = Color.RED;
						//widget.child[0].style.color = Color.RED;
					//},
					
				},
				[   // TODO:
					new TextLine( font, fontStyleTiled, "TextLine",
					{
						width:Size.limit(100, 200),
						top:Size.span(0.2),
						bottom:Size.span(0.2),
						
						onPointerOver:
							function (t:TextLine, e:PointerEvent) {
								trace("onOverTextfield");
								
								//var fontStyle:FontStyleTiled = t.getFontStyle();
								//var fontStyle = t.getFontStyle();
								//fontStyle.color = Color.RED;
								
								var layoutTextLine:LayoutTextLine<FontStyleTiled> = t.getLayoutTextLine();
								layoutTextLine.fontStyle.color = Color.RED;
								layoutTextLine.updateStyle();
								
								layoutTextLine.update();
							}
						,	
						onPointerOut:
							function (t:TextLine, e:PointerEvent) {
								trace("onOutTextfield");
								
								//var fontStyle:FontStyleTiled = t.getFontStyle();
								//var fontStyle = t.getFontStyle();
								//fontStyle.color = Color.RED;
								
								var layoutTextLine:LayoutTextLine<FontStyleTiled> = t.getLayoutTextLine();
								layoutTextLine.fontStyle.color = Color.WHITE;
								layoutTextLine.updateStyle();
								
								layoutTextLine.update();
							}
							
					})
						
					
					
					
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
			ui.pointerEnabled = true;
			
			
			//TODO:
			//ui.registerLimeEvents(window); //-> window.onFocusOut.add(...)
			
			
			// TODO: better need a resizable-widget-container!
			// oder einfach nur rechts-unten einen button und ein onMove auf die gesammte peote-ui!
			trace("NEW DragArea -----");

			var roundedSkin = new RoundedSkin();
			
			var myStyle4 = new RoundedStyle();
			myStyle4.color = Color.GREY1;
			myStyle4.borderColor = Color.GREY5;
			myStyle4.borderSize = 3.0;
			myStyle4.borderRadius = 20.0;
			
			var draggerSize:Int = 25;
			var draggArea = new Button(ui.display.width-draggerSize, ui.display.height-draggerSize, draggerSize, draggerSize, roundedSkin, myStyle4);
			
			draggArea.onPointerDown = function(b:Button, e:PointerEvent) {
				trace(" -----> startDragging", e);
				b.startDragging(e);
				b.style.color = Color.YELLOW;
				b.update();
			}
			draggArea.onPointerUp = function(b:Button, e:PointerEvent) {
				trace(" -----> stopDragging", e);
				b.stopDragging(e);
				b.style.color = Color.GREY1;
				b.update();
				ui.update(b.x +draggerSize, b.y + draggerSize);
			}
			draggArea.onPointerMove = function(b:Button, e:PointerEvent) {
				//trace(" -----> onPointerMove", e.x, e.y);
				if (b.isDragging) {
					trace(b.x +draggerSize, b.y + draggerSize);
					//draggArea.setDragArea(0, 0, ui.display.width+10, ui.display.height+10); // x, y, width, height
					ui.update(b.x +draggerSize, b.y + draggerSize);
				}
			}
			
			draggArea.setDragArea(0, 0, ui.display.width, ui.display.height); // x, y, width, height

			ui.display.add(draggArea);
			
			
			
			
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}

	// --------------------------------------------------
	public inline function onOverOut(color:Color, widget:Div, e:PointerEvent) {
		//trace(widget.parent);
		
		//widget.parent.uiElement.color = Color.RED;
		
		//switch(widged.Type) {
		//	case(WidgetType.TextLine) 
		
		widget.style.color = color;
		widget.style.borderColor = Color.GREY7;
		//TODO: widget.updateStyle();
		widget.layoutElement.update();
		//TODO: widget.updateLayout();
		//TODO: widget.update();
	}

	

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
		PeoteUI.mouseMove(x, y);
	}
	public override function onMouseDown (x:Float, y:Float, button:MouseButton) PeoteUI.mouseDown(x, y, button);
	public override function onMouseUp (x:Float, y:Float, button:MouseButton) PeoteUI.mouseUp(x, y, button);
	public override function onMouseWheel (dx:Float, dy:Float, mode:MouseWheelMode) PeoteUI.mouseWheel(dx, dy, mode);
	// public override function onMouseMoveRelative (x:Float, y:Float):Void {}

	// ----------------- TOUCH EVENTS ------------------------------
	public override function onTouchStart (touch:Touch) PeoteUI.touchStart(touch);
	public override function onTouchMove (touch:Touch) PeoteUI.touchMove(touch);
	public override function onTouchEnd (touch:Touch) PeoteUI.touchEnd(touch);
	public override function onTouchCancel (touch:Touch) PeoteUI.touchCancel(touch);
	
	// ----------------- KEYBOARD EVENTS ---------------------------
	public override function onKeyDown (keyCode:KeyCode, modifier:KeyModifier) {
		switch (keyCode) {
			#if html5
			case KeyCode.TAB: untyped __js__('event.preventDefault();');
			#end
			case KeyCode.F: window.fullscreen = !window.fullscreen;
			default:
		}
		//PeoteUI.keyDown(keyCode, modifier);
	}
	
	//public override function onKeyUp (keyCode:KeyCode, modifier:KeyModifier) PeoteUI.keyUp(keyCode, modifier);
	//public override function onTextEdit(text:String, start:Int, length:Int) PeoteUI.textEdit(text, start, length);
	//public override function onTextInput (text:String):Void PeoteUI.textInput(text);

	// ----------------- WINDOWS EVENTS ----------------------------
	public override function onWindowResize (width:Int, height:Int) {
		peoteView.resize(width, height);
		
		// TODO
		ui.update(width, height);
	}

	public override function onWindowLeave() {
		#if (! html5)
		lastMouseMoveX = lastMouseMoveY = -1; // fix for another onMouseMoveFrameSynced() by render-loop
		#end
		PeoteUI.windowLeave();
	}
	
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
