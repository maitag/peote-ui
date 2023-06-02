package;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Color;

import peote.ui.PeoteUIDisplay;
import peote.ui.interactive.UISlider;
import peote.ui.style.*;
import peote.ui.config.*;
import peote.ui.event.*;


class Sliders extends Application
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
		//peoteView.zoom = 0.5;
		
		uiDisplay = new PeoteUIDisplay(10, 10, window.width - 20, window.height - 20, Color.GREY1);
		//uiDisplay.zoom = 0.5;
		peoteView.addDisplay(uiDisplay);
		
		var roundBorderStyle:RoundBorderStyle = {
			color: Color.GREY2,
			borderColor: Color.GREY4,
			borderSize: 3.0,
			borderRadius: 20.0
		}
		
		var sliderConfig:SliderConfig = {
			backgroundStyle: roundBorderStyle,
			draggerStyle: roundBorderStyle.copy(Color.YELLOW),
			
			//vertical:true,
			//reverse:true,
			//value: -2,
			//valueStart: -5,
			//valueEnd: 10,
			
			//draggerSpace:{left:15, right:15},
			//backgroundSpace:{left:50},

			//backgroundLengthPercent:0.9,
			backgroundSizePercent:0.3,
			
			draggerLength:50,
			draggerLengthPercent:0.1,
			
			draggerSize:20,
			draggerSizePercent:0.75,
			
			//draggerOffset:0,
			draggerOffsetPercent:0.5,
			
			draggSpaceStart:40,
			draggSpaceEnd:20,
		};
		
		var hSlider = new UISlider(80, 10, 500, 40, sliderConfig);
		//hSlider.valueStart = -5;
		//hSlider.valueEnd = 10;
		setSliderEvents(hSlider);
		uiDisplay.add(hSlider);
		
		//hSlider.reverse = true;
		//hSlider.value = -2;
		hSlider.updateDragger();
		
		
		var vSlider = new UISlider(10, 10, 60, 500, sliderConfig);
		setSliderEvents(vSlider);
		uiDisplay.add(vSlider);
		
		hSlider.onChange = function(uiSlider:UISlider, value:Float, percent:Float) {
			trace( 'hSlider value:$value, percent:$percent' );
			vSlider.percent = percent;
		}
		
		vSlider.onChange = function(uiSlider:UISlider, value:Float, percent:Float) {
			trace( 'vSlider value:$value, percent:$percent' );
			hSlider.percent = percent;
			//hSlider.x = 100 + Std.int(percent * 500);
			//hSlider.height = 40 + Std.int(percent * 100);
			//hSlider.updateLayout();
		}
		
				
		// TODO: make uiElement to switch between
		//uiDisplay.mouseEnabled = false;
		//uiDisplay.touchEnabled = false;
		
		//peoteView.zoom = 0.5;
		//uiDisplay.zoom = 0.5;
		
		#if android
		uiDisplay.mouseEnabled = false;
		peoteView.zoom = 3;
		#end
		
		PeoteUIDisplay.registerEvents(window);			
	}	

	public function setSliderEvents(slider:UISlider) 
	{
		slider.onPointerOver = function(uiSlider:UISlider, e:PointerEvent) {
			uiSlider.backgroundStyle.color = Color.GREEN;
			uiSlider.updateBackgroundStyle();
		}
		
		slider.onPointerOut = function(uiSlider:UISlider, e:PointerEvent) {
			uiSlider.backgroundStyle.color = Color.GREY2;
			uiSlider.updateBackgroundStyle();
		}
		
		slider.onDraggerPointerOver = function(uiSlider:UISlider, e:PointerEvent) {
			uiSlider.draggerStyle.color = Color.RED;
			uiSlider.updateDraggerStyle();
		}
		
		slider.onDraggerPointerOut = function(uiSlider:UISlider, e:PointerEvent) {
			uiSlider.draggerStyle.color = Color.YELLOW;
			uiSlider.updateDraggerStyle();
		}
		
		slider.onDraggerPointerDown = function(uiSlider:UISlider, e:PointerEvent) {
			uiSlider.draggerStyle.borderColor = Color.YELLOW;
			uiSlider.updateDraggerStyle();			
		}
		
		slider.onDraggerPointerUp = function(uiSlider:UISlider, e:PointerEvent) {
			uiSlider.draggerStyle.borderColor = Color.GREY4;
			uiSlider.updateDraggerStyle();		
		}
		
		slider.onMouseWheel = function(uiSlider:UISlider, e:WheelEvent) {
			//uiSlider.value += e.deltaY * 0.1;
			//uiSlider.setValue (uiSlider.value - e.deltaY * 0.05);
			uiSlider.setWheelDelta(e.deltaY);
		}
		
	}
	
}
