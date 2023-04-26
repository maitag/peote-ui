package;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Color;

import peote.ui.PeoteUIDisplay;
import peote.ui.interactive.UIElement;
import peote.ui.style.RoundBorderStyle;
import peote.ui.event.*;


class CustomSlider extends Application
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
		
		uiDisplay = new PeoteUIDisplay(20, 20, window.width-40, window.height-40, Color.GREY1);
		peoteView.addDisplay(uiDisplay);
		
		var roundBorderStyle:RoundBorderStyle = {
			color: Color.GREY2,
			borderColor: Color.GREY4,
			borderSize: 3.0,
			borderRadius: 20.0
		}
		
		// ------------ background element for the slider -------------------

		var slider = new UIElement(10, 130, 350, 60, roundBorderStyle);
		
		slider.onPointerOver = function(uiElement:UIElement, e:PointerEvent) {
			uiElement.style.color = Color.GREEN;
			uiElement.updateStyle();
		}
		
		slider.onPointerOut = function(uiElement:UIElement, e:PointerEvent) {
			uiElement.style.color = Color.GREY2;
			uiElement.updateStyle();
		}
		
		uiDisplay.add(slider);
		
		
		// ------------ element to drag -------------------
		
		var dragger = new UIElement(slider.x, slider.y, 100, 60, 1, roundBorderStyle.copy(Color.BLUE,Color.GREY5));
		uiDisplay.add(dragger);
						
		// to bubble onOver-event down to the slider
		dragger.overOutEventsBubbleTo = slider;
		dragger.wheelEventsBubbleTo = slider;
		
		
		dragger.onPointerOver = function(uiElement:UIElement, e:PointerEvent) {
			uiElement.style.color = Color.RED;
			uiElement.updateStyle();
		}
		
		dragger.onPointerOut = function(uiElement:UIElement, e:PointerEvent) {
			uiElement.style.color = Color.BLUE;
			uiElement.updateStyle();
		}

		// set the drag-area to same size as the slider
		dragger.setDragArea(slider.x, slider.y, slider.width, slider.height);
		
		// start/stop dragging
		dragger.onPointerDown = function(uiElement:UIElement, e:PointerEvent) {
			uiElement.style.borderColor = Color.YELLOW;
			uiElement.updateStyle();			
			uiElement.startDragging(e); // <----- start dragging
		}
		
		dragger.onPointerUp = function(uiElement:UIElement, e:PointerEvent) {
			uiElement.style.borderColor = Color.GREY4;
			uiElement.updateStyle();		
			uiElement.stopDragging(e);  // <----- stop dragging
		}
		
		// onDrag event
		dragger.onDrag = function(uiElement:UIElement, percentX:Float, percentY:Float) {
			trace( 'Slider at: ${percentX*100}%' );
		}
		
		
		// ----- to move the dragger also by mousewheel -----------		
		
		// store coordinates into onPointerMove-event
		var lastPointerEvent = {x:0, y:0};
		slider.onPointerMove = function(b:UIElement, e:PointerEvent) lastPointerEvent = e;
		
		slider.onMouseWheel = function(uiElement:UIElement, e:WheelEvent) {
			dragger.x = Std.int(Math.max(slider.x, Math.min(slider.x+slider.width-dragger.width, (dragger.x + e.deltaY * 20))));
			dragger.updateLayout();
			trace( 'Slider at: ${ (dragger.x - slider.x) / (slider.width - dragger.width) *100 }%' );
			
			// dispatch mouseMove-event to trigger onOver/onOut also while moving the dragger
			uiDisplay.mouseMove(lastPointerEvent.x, lastPointerEvent.y);
		}
		

		
		
		// TODO: make uiElement to switch between
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
		
		PeoteUIDisplay.registerEvents(window);			
	}	

}
