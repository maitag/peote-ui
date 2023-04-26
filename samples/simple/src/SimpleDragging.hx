package;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Color;

import peote.ui.PeoteUIDisplay;
import peote.ui.interactive.UIElement;
import peote.ui.style.RoundBorderStyle;
import peote.ui.event.PointerEvent;


class SimpleDragging extends Application
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
		//peoteView.zoom = 0.8;
		
		uiDisplay = new PeoteUIDisplay(20, 20, window.width-40, window.height-40, Color.GREY1);
		peoteView.addDisplay(uiDisplay);
		//uiDisplay.zoom = 0.5;
		
		var style = new RoundBorderStyle();
		style.color = Color.GREY1;
		style.borderColor = Color.GREY5;
		style.borderSize = 3.0;
		style.borderRadius = 40.0;
		
		// ------ background for dragging area ------
		var draggArea = new UIElement(10, 10, 360, 300, style);
		uiDisplay.add(draggArea);

		
		// ------ element to drag -----
		var dragger = new UIElement(100, 100, 80, 80, style);
		uiDisplay.add(dragger);
		
		dragger.setDragArea(draggArea.x, draggArea.y, draggArea.width, draggArea.height);
		
		dragger.onPointerDown = function(uiElement:UIElement, e:PointerEvent) {
			uiElement.startDragging(e);
			uiElement.style.color = Color.YELLOW;
			uiElement.updateStyle();
		}
		dragger.onPointerUp = function(uiElement:UIElement, e:PointerEvent) {
			uiElement.stopDragging(e);
			uiElement.style.color = Color.GREY1;
			uiElement.updateStyle();
		}
		
		// onDrag event
		dragger.onDrag = function(uiElement:UIElement, percentX:Float, percentY:Float) {
			trace( 'Dragger at: x:${percentX*100}%, y:${percentY*100}%' );
		}
		
		
		
		//uiDisplay.mouseEnabled = false;
		//uiDisplay.touchEnabled = false;
		peoteView.zoom = 0.8;
		peoteView.xOffset = 30;
		uiDisplay.zoom = 1.7;
		uiDisplay.xOffset = 50;
		
		#if android
		uiDisplay.mouseEnabled = false;
		peoteView.zoom = 3;
		#end
		
		// TODO: set what events to register (mouse, touch, keyboard ...)
		PeoteUIDisplay.registerEvents(window);
			
	}
	
}
