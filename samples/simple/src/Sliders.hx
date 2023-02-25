package;

import haxe.CallStack;
import peote.ui.style.SliderStyle;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Color;

import peote.ui.PeoteUIDisplay;

import peote.ui.interactive.UISlider;

import peote.ui.style.RoundBorderStyle;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;


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
				catch (_) trace(CallStack.toString(CallStack.exceptionStack()), _);
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
		
		var sliderStyle:SliderStyle = {
			backgroundStyle: roundBorderStyle,
			draggerStyle: roundBorderStyle.copy(Color.YELLOW),
			//vertical:true,
			draggerSize:50,
			draggerLength:100,
		};
		
		var hSlider = new UISlider(80, 10, 500, 60, sliderStyle);
		setSliderEvents(hSlider);
		uiDisplay.add(hSlider);
		
		
		var vSlider = new UISlider(10, 10, 60, 500, sliderStyle);
		setSliderEvents(vSlider);
		uiDisplay.add(vSlider);
		
		hSlider.onChange = function(uiSlider:UISlider, percent:Float) {
			trace( 'hSlider at: ${percent*100}%' );
			vSlider.value = percent;
		}
		
		vSlider.onChange = function(uiSlider:UISlider, percent:Float) {
			trace( 'vSlider at: ${percent*100}%' );
			hSlider.value = percent;
			//hSlider.x = 100 + Std.int(percent * 500);
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
