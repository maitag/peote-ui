package;

import haxe.CallStack;
import peote.ui.interactive.UIElement;
import peote.ui.style.SliderStyle;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Color;

import peote.ui.PeoteUIDisplay;

import peote.ui.interactive.UIArea;
import peote.ui.interactive.UISlider;

import peote.ui.style.RoundBorderStyle;
import peote.ui.style.SimpleStyle;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;


class Areas extends Application
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
		
		uiDisplay = new PeoteUIDisplay(10, 10, window.width-20, window.height-20, Color.GREY1);
		peoteView.addDisplay(uiDisplay);
		
		// ---- setting up some styles -------
		
		var roundBorderStyle:RoundBorderStyle = {
			color: Color.GREY2,
			borderColor: Color.GREY4,
			borderSize: 3.0,
			borderRadius: 20.0
		}
		
		var sliderStyle:SliderStyle = {
			backgroundStyle: roundBorderStyle.copy(),
			draggerStyle: roundBorderStyle.copy(Color.YELLOW),
		};
		
		var sliderStyle1:SliderStyle = {
			backgroundStyle: roundBorderStyle.copy(),
			draggerStyle: roundBorderStyle.copy(Color.YELLOW),
		};
		
		// -----------------------------------
		// ---- creating an Area ------------
		// -----------------------------------
		
		var area = new UIArea(60, 60, 500, 500, new SimpleStyle() );
		uiDisplay.add(area);
		
		
		// fill into some uiElements:
		var uiElement = new UIElement(0, 0, 80, 80, roundBorderStyle);
		uiElement.onPointerOver = function(uiElement:UIElement, e:PointerEvent) {
			uiElement.style.color = Color.GREEN;
			uiElement.updateStyle();
		}
		
		uiElement.onPointerOut = function(uiElement:UIElement, e:PointerEvent) {
			uiElement.style.color = Color.GREY2;
			uiElement.updateStyle();
		}
		area.add(uiElement);
		
		var sliderInside = new UISlider(0, 100, 200, 30, sliderStyle1);
		setSliderEvents(sliderInside);
		area.add(sliderInside);
		
		
		// -----------------------------------
		// ---- creating the Sliders ---------
		// -----------------------------------
		
		
		var hSlider = new UISlider(60, 15, 500, 40, sliderStyle);
		setSliderEvents(hSlider);
		uiDisplay.add(hSlider);
		
		
		var vSlider = new UISlider(15, 60, 40, 500, sliderStyle);
		setSliderEvents(vSlider);
		uiDisplay.add(vSlider);
		
		hSlider.onChange = function(uiSlider:UISlider, percent:Float) {
			//area.x = 60 + Std.int(300 * percent); area.updateLayout();
			//uiElement.x =  Std.int(700 * percent-100); area.updateLayout();
			area.xOffset = -100 + Std.int(700 * percent); area.updateLayout();
		}
		
		vSlider.onChange = function(uiSlider:UISlider, percent:Float) {
			//uiElement.y =  Std.int(700 * percent-100); area.updateLayout();
			area.yOffset = -100 + Std.int(700 * percent); area.updateLayout();
		}
		
		
		
		// TODO: make uiElement to switch between
		//uiDisplay.mouseEnabled = false;
		//uiDisplay.touchEnabled = false;
		
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
			uiSlider.setDelta( e.deltaY * 0.1 );
		}
		
	}
	
}
