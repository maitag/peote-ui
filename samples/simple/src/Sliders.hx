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
		
		uiDisplay = new PeoteUIDisplay(20, 20, window.width-40, window.height-40, Color.GREY1);
		peoteView.addDisplay(uiDisplay);
		
		var roundBorderStyle:RoundBorderStyle = {
			color: Color.GREY2,
			borderColor: Color.GREY4,
			borderSize: 3.0,
			borderRadius: 20.0
		}
		
		var sliderStyle:SliderStyle = {
			backgroundStyle: roundBorderStyle,
			draggerStyle: roundBorderStyle,
			//type: SliderType.VERTICAL,
			//minDraggerSize:0.1, 
			//draggable:true, // is default
		};
		
		var slider = new UISlider(10, 130, 350, 60, sliderStyle);
		
		slider.onPointerOver = function(uiSlider:UISlider, e:PointerEvent) {
			//uiSlider.backgroundStyle.color = Color.GREEN;
			//uiSlider.updateBackgroundStyle();
		}
		
/*		slider.onPointerOut = function(uiSlider:UISlider, e:PointerEvent) {
			uiSlider.backgroundStyle.color = Color.GREY2;
			uiSlider.updateBackgroundStyle();
		}
		
		slider.onDraggerPointerOver = function(uiSlider:UISlider, e:PointerEvent) {
			uiSlider.draggerStyle.color = Color.RED;
			uiSlider.updateDraggerStyle();
		}
		
		slider.onDraggerPointerOut = function(uiSlider:UISlider, e:PointerEvent) {
			uiSlider.draggerStyle.color = Color.BLUE;
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
		
		// if slider value is changing
		slider.onChange = function(uiSlider:UISlider, percent:Float) {
			trace( 'Slider at: ${percent*100}%' );
		}
		
		slider.onMouseWheel = function(uiSlider:UISlider, e:WheelEvent) {
			uiSlider.value += e.deltaX * 0.1;
		}
*/		
		uiDisplay.add(slider);
		
		
		
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
