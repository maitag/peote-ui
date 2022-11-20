package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Color;

import peote.text.Font;

import peote.ui.PeoteUIDisplay;
import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;
import peote.ui.util.HAlign;
import peote.ui.interactive.*;
import peote.ui.style.*;


class TestUIArea extends Application
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
		
		var boxStyle  = new BoxStyle(Color.GREY4);

		var roundBorderStyle:RoundBorderStyle = {
			color: Color.GREY2,
			borderColor: Color.GREY4,
			borderSize: 3.0,
			borderRadius: 20.0
		}
		
		var fontStyle = new FontStyleTiled();

		
		// -----------------------------------
		// --- creating PeoteUIDisplay with some styles in Order ---
		// -----------------------------------
		
		uiDisplay = new PeoteUIDisplay(10, 10, window.width-20, window.height-20, Color.GREY1, [roundBorderStyle, boxStyle, fontStyle]);
		peoteView.addDisplay(uiDisplay);
		
		
		// -----------------------------------
		// -- creating some text and slider styles --
		// -----------------------------------
		
		var textStyle:TextLineStyle = {
			backgroundStyle:roundBorderStyle.copy(Color.GREY3),
			selectionStyle:boxStyle,
			cursorStyle:boxStyle.copy(Color.RED)
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
		
		var area = new UIArea(60, 60, 500, 500, new BoxStyle() );
		uiDisplay.add(area);
		
		
		// header textline what starts dragging

		var textLine = new UITextLine<FontStyleTiled>(0, 0, {width:500, hAlign:HAlign.CENTER}, 1, "=== UIArea ===", font, fontStyle, roundBorderStyle.copy(Color.GREY3));
		textLine.onPointerOver = (_, _)-> trace("textLine onPointerOver");
		textLine.onPointerOut  = (_, _)-> trace("textLine onPointerOut");
		textLine.onPointerClick  = (t, e:PointerEvent)-> {
			trace("textLine onPointerClick", e);
		}
		textLine.onPointerDown = (t, e:PointerEvent)-> {
			trace("textLine onPointerDown");
		}
		textLine.onPointerUp = (t, e:PointerEvent)-> {
			trace("textLine onPointerUp");
		}
		area.add(textLine);

		
		// uiElement button to change the size
		
		var uiElement = new UIElement(480, 480, 20, 20, roundBorderStyle);	
		area.add(uiElement);
		
		
		// ---------------------------------------------------------
		// inner UIArea for some scrollable content
		
		var content = new UIArea(0, 20, 480, 460, roundBorderStyle);
		area.add(content);

		// put things into content:
		var uiElement = new UIElement(0, 0, 100, 30, roundBorderStyle);	
		content.add(uiElement);
		
		
		// ---------------------------------------------------------

		
		// Sliders to scroll innerArea	
		
		var hSlider = new UISlider(0, 480, 480, 20, sliderStyle);
		setSliderEvents(hSlider);
		hSlider.onChange = function(uiSlider:UISlider, percent:Float) {
			content.xOffset =  -Std.int(300 * percent); area.update();
		}
		area.add(hSlider);
		
		var vSlider = new UISlider(480, 20, 20, 460, sliderStyle);
		setSliderEvents(vSlider);
		vSlider.onChange = function(uiSlider:UISlider, percent:Float) {
			content.yOffset = - Std.int(300 * percent ) ; area.updateLayout();
		}
		area.add(vSlider);
		
		
		
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
			uiSlider.setDelta( ((e.deltaY > 0) ? 1 : -1 )* 0.05 );
		}
		
	}
	
}
