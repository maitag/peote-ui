package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Color;

import peote.ui.PeoteUIDisplay;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;

import peote.text.Font;

import peote.ui.interactive.*;
import peote.ui.style.*;


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
		new Font<FontStyleTiled>("assets/fonts/tiled/hack_ascii.json").load( onFontLoaded );
	}
	
	public function onFontLoaded(font:Font<FontStyleTiled>) // don'T forget argument-type here !
	{
		peoteView = new PeoteView(window);
		
		// ---- setting up some styles -----
		
		var simpleStyle  = new SimpleStyle(Color.GREY4);

		var roundBorderStyle:RoundBorderStyle = {
			color: Color.GREY2,
			borderColor: Color.GREY4,
			borderSize: 3.0,
			borderRadius: 20.0
		}
		
		var fontStyle = new FontStyleTiled();

		
		// --- creating PeoteUIDisplay with some styles in Order ---
		
		uiDisplay = new PeoteUIDisplay(10, 10, window.width-20, window.height-20, Color.GREY1, [roundBorderStyle, simpleStyle, fontStyle]);
		peoteView.addDisplay(uiDisplay);
		
		
		// -- creating some text and slider styles --
		
		var textStyle:TextLineStyle = {
			backgroundStyle:roundBorderStyle.copy(Color.GREY3),
			selectionStyle:simpleStyle,
			cursorStyle:simpleStyle.copy(Color.RED)
		}
		
		var sliderStyle:SliderStyle = {
			backgroundStyle: roundBorderStyle.copy(),
			draggerStyle: roundBorderStyle.copy(Color.YELLOW),
		};
		
		var sliderInsideStyle:SliderStyle = {
			backgroundStyle: roundBorderStyle.copy(),
			draggerStyle: roundBorderStyle.copy(Color.YELLOW),
		};

		
		// -----------------------------------
		// ---- creating an Area ------------
		// -----------------------------------
		
		var area = new UIArea(60, 60, 500, 500, new SimpleStyle() );
		uiDisplay.add(area);
		
		
		// fill into some uiElements:
		
		var uiElement = new UIElement(0, 0, 80, 30, roundBorderStyle);
		uiElement.onPointerOver = function(uiElement:UIElement, e:PointerEvent) {
			uiElement.style.color = Color.GREEN;
			uiElement.updateStyle();
		}
	
		uiElement.onPointerOut = function(uiElement:UIElement, e:PointerEvent) {
			uiElement.style.color = Color.GREY2;
			uiElement.updateStyle();
		}
		uiElement.onPointerUp = function(uiElement:UIElement, e:PointerEvent) {
			uiElement.style.borderColor = Color.GREY4;
			uiElement.updateStyle();
		}
		uiElement.onPointerDown = function(uiElement:UIElement, e:PointerEvent) {
			uiElement.style.borderColor = Color.RED;
			uiElement.updateStyle();
		}
		area.add(uiElement);
		
		
		// fill into some textlines

		var textLine = new UITextLine<FontStyleTiled>(85, 0, 1, "Hello World", font, fontStyle, textStyle);
		textLine.onPointerOver = (_, _)-> trace("textLine onPointerOver");
		textLine.onPointerOut  = (_, _)-> trace("textLine onPointerOut");
		textLine.onPointerClick  = (t, e:PointerEvent)-> {
			trace("textLine onPointerClick", e);
		}
		textLine.onPointerDown = function(t, e:PointerEvent) {
			trace("textLine onPointerDown");
			t.setInputFocus(e); // alternatively: uiDisplay.setInputFocus(t);
			t.startSelection(e);
		}
		textLine.onPointerUp = function(t, e:PointerEvent) {
			trace("textLine onPointerUp");
			t.stopSelection(e);
		}
		area.add(textLine);

		
		// fill in sliders
		
		for (i in 0...100) {
			var sliderInside = new UISlider(0, 30+30*i, 200, 30, sliderInsideStyle);
			setSliderEvents(sliderInside);
			area.add(sliderInside);
		}
	

		
		// -----------------------------------------------
		// ---- creating the Scrollbar - Sliders ---------
		// -----------------------------------------------
		
		
		var hSlider = new UISlider(60, 15, 500, 40, sliderStyle);
		setSliderEvents(hSlider);
		uiDisplay.add(hSlider);
		hSlider.onChange = function(uiSlider:UISlider, percent:Float) {
			//area.x = 60 + Std.int(250 * percent); area.update();
			//uiElement.x =  Std.int(700 * percent-100); area.updateLayout();
			area.xOffset =  Std.int(500 * percent); area.update();
		}
		
		
		var vSlider = new UISlider(15, 60, 40, 500, sliderStyle);
		setSliderEvents(vSlider);
		uiDisplay.add(vSlider);
		
		
		vSlider.onChange = function(uiSlider:UISlider, percent:Float) {
			//uiElement.xLocal =  Std.int(500 * percent); uiElement.updateLayout();
			//textLine.yLocal =  Std.int(500 * percent); textLine.updateLayout();
			//sliderInside.xLocal =  Std.int(500 * percent); sliderInside.updateLayout();
			area.yOffset = -Std.int(3000 * percent); area.updateLayout();
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
