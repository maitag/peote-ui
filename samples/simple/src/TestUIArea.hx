package;

import haxe.CallStack;
import lime.ui.MouseCursor;

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

import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.Element;

class Elem implements Element {
	@posX @anim("Position", "pingpong") public var x:Int;
	@posY public var y:Int;
	@sizeX public var w = 50;
	@sizeY public var h:Int = 50;
	@color public var color:Color = 0xffffffff;

	public function new(x:Int, y:Int, color:Color, timeStart:Float, timeDuration:Float = 3.0) {
		this.x = x;
		this.y = y;
		this.color = color;
		animPosition(x, x + 150);
		timePosition(timeStart, timeDuration);
	}
	
	// -------------------
	
	static var buffer:Buffer<Elem>;
	static var program:Program;
	
	public static function playIntoDisplay(display:Display) {
		buffer = new peote.view.Buffer<Elem>(16);
		program = new peote.view.Program(buffer);
		display.addProgram(program);
		for (i in 0...4) buffer.addElement(new Elem(0, 50 * i, Color.random(), i));
	}	
}

class TestUIArea extends Application
{
	var peoteView:PeoteView;
	var peoteUiDisplay:PeoteUIDisplay;
	
	override function onWindowCreate():Void
	{
		switch (window.context.type) {
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
		peoteView.start();

		// ---- setting up some styles -----

		var boxStyle  = new BoxStyle(0x041144ff);
		
		var roundBorderStyle = RoundBorderStyle.createById(0);		
		
		var cursorStyle = BoxStyle.createById(1, Color.RED);
		var selectionStyle = BoxStyle.createById(2, Color.GREY3);
		
		var fontStyleHeader = FontStyleTiled.createById(0);
		var fontStyleInput = FontStyleTiled.createById(1);
		
		
		var textStyleInput:TextStyle = {
			backgroundStyle:boxStyle.copy(Color.GREY5),
			selectionStyle: selectionStyle,
			cursorStyle: cursorStyle
		}
		
		var sliderStyle:SliderStyle = {
			backgroundStyle: roundBorderStyle.copy(Color.GREY2),
			draggerStyle: roundBorderStyle.copy(Color.GREY4, Color.GREY3),
			draggerSize:18,
			draggerLength:30,
		};
		
		// ---------------------------------------------------------
		// --- creating PeoteUIDisplay with some styles in Order ---
		// ---------------------------------------------------------
		
		peoteUiDisplay = new PeoteUIDisplay(10, 10, window.width - 20, window.height - 20, Color.GREY1,
			[roundBorderStyle, boxStyle, selectionStyle, fontStyleInput, fontStyleHeader, cursorStyle]
		);
		peoteView.addDisplay(peoteUiDisplay);
		//peoteUiDisplay.zoom = 0.75;
		//peoteUiDisplay.xOffset = 30;
		//peoteView.zoom = 0.75;
		//peoteView.xOffset = 20;

		
		// -----------------------------------------------------------
		// ---- creating an Area, header and Content-Area ------------
		// -----------------------------------------------------------
		
		var area = new UIArea(50, 50, 500, 500, roundBorderStyle );
		peoteUiDisplay.add(area);
		// to let the area drag
		area.setDragArea(
			Std.int(-peoteUiDisplay.xOffset / peoteUiDisplay.xz),
			Std.int(-peoteUiDisplay.yOffset / peoteUiDisplay.yz),
			Std.int(peoteUiDisplay.width    / peoteUiDisplay.xz),
			Std.int(peoteUiDisplay.height   / peoteUiDisplay.yz)
		);
		
		// ---- header textline what starts dragging ----		
		var header = new UITextLine<FontStyleTiled>(0, 0, {width:500, hAlign:HAlign.CENTER}, 1, "=== UIArea ===", font, fontStyleHeader, roundBorderStyle);
		area.add(header);				
		header.onPointerDown = (_, e:PointerEvent)-> area.startDragging(e);
		header.onPointerUp = (_, e:PointerEvent)-> area.stopDragging(e);
		
		// inner UIArea for scrolling content
		var content = new UIArea(2, 18, 478, 462, boxStyle);
		area.add(content);
		
		// ---------------------------------------------------------
		// ---- Sliders to scroll the innerArea ----		
		// ---------------------------------------------------------
		
		var hSlider = new UISlider(0, 480, 480, 20, sliderStyle);
		area.add(hSlider);
		
		hSlider.onMouseWheel = (_, e:WheelEvent) -> hSlider.setWheelDelta( e.deltaY );
		hSlider.onChange = (_, percent:Float) -> {
			content.xOffset =  -Std.int(420 * percent);
			content.updateLayout();
		}
		
		var vSlider = new UISlider(480, 18, 20, 462, sliderStyle);
		area.add(vSlider);
		
		vSlider.onMouseWheel = (_, e:WheelEvent) -> vSlider.setWheelDelta( e.deltaY );
		vSlider.onChange = (_, percent:Float) -> {
			content.yOffset = - Std.int(420 * percent );
			content.updateLayout();
		}
		
		
		// ---------------------------------------------
		// -------- button to change the size ----------		
		// ---------------------------------------------
		
		var resizerBottomRight:UIElement = new UIElement(area.width - 19, area.height - 19, 18, 18, 2, roundBorderStyle.copy(Color.GREY3, Color.GREY1));	
		area.add(resizerBottomRight);
		
		resizerBottomRight.onPointerDown = (_, e:PointerEvent)-> {
			resizerBottomRight.setDragArea(
				Std.int(area.x + 240),
				Std.int(area.y + 140),
				Std.int((peoteUiDisplay.width  - peoteUiDisplay.xOffset) / peoteUiDisplay.xz  - area.x - 240),
				Std.int((peoteUiDisplay.height - peoteUiDisplay.yOffset) / peoteUiDisplay.yz  - area.y - 140)
			);
			resizerBottomRight.startDragging(e);
		}
		resizerBottomRight.onPointerUp = (_, e:PointerEvent)-> resizerBottomRight.stopDragging(e);
		
		resizerBottomRight.onDrag = (_, x:Float, y:Float) -> {
			area.width = resizerBottomRight.right + 1 - area.x;
			area.height = resizerBottomRight.bottom + 1 - area.y;
			
			header.width = area.width;
			
			content.width = area.width - 22;
			content.height = area.height - 38;
			
			hSlider.width = area.width - 20;
			hSlider.bottom = area.bottom;
			
			vSlider.height = content.height;
			vSlider.right = area.right;
			
			area.updateLayout();
		};
		resizerBottomRight.onPointerOver = (_,_)-> window.cursor = MouseCursor.RESIZE_NWSE;
		resizerBottomRight.onPointerOut  = (_,_)-> window.cursor = MouseCursor.DEFAULT;
		
		
		
		// ---------------------------------------------------------
		// -----  inner UIArea for some scrollable content ---------
		// ---------------------------------------------------------
		
		// put things into content:
		var uiDisplay = new UIDisplay(20, 20, 200, 200, 1, Color.BLUE);
		uiDisplay.onPointerOver = (_,_)-> uiDisplay.display.color = Color.RED;
		uiDisplay.onPointerOut  = (_,_)-> uiDisplay.display.color = Color.BLUE;
		uiDisplay.onPointerDown = (_, e:PointerEvent)-> {
			uiDisplay.setDragArea(Std.int(content.x), Std.int(content.y), Std.int(content.width), Std.int(content.height));
			uiDisplay.startDragging(e);
		}
		uiDisplay.onPointerUp = (_, e:PointerEvent)-> uiDisplay.stopDragging(e);
		uiDisplay.onDrag = (_, x:Float, y:Float) -> uiDisplay.maskByElement(content, true);
		content.add(uiDisplay);
		Elem.playIntoDisplay(uiDisplay.display);

		
		var uiElement = new UIElement(220, 20, 200, 200, 0, roundBorderStyle);
		uiElement.onPointerDown = (_, e:PointerEvent)-> {
			uiElement.setDragArea(Std.int(content.x), Std.int(content.y), Std.int(content.width), Std.int(content.height));
			uiElement.startDragging(e);
		}
		uiElement.onPointerUp = (_, e:PointerEvent)-> uiElement.stopDragging(e);
		uiElement.onDrag = (_, x:Float, y:Float) -> uiElement.maskByElement(content, true);
		content.add(uiElement);
		

		var inputPage = new UITextPage<FontStyleTiled>(300, 100, 1, "input\ntext by\nUIText\tPage", font, fontStyleInput, textStyleInput);
		inputPage.onPointerDown = function(t:UITextPage<FontStyleTiled>, e:PointerEvent) {
			//t.setInputFocus(e, true);			
			t.setInputFocus(e);			
			t.startSelection(e);
		}
		inputPage.onPointerUp = function(t:UITextPage<FontStyleTiled>, e:PointerEvent) {
			t.stopSelection(e);
		}		
		content.add(inputPage);
		

		
		
		// ---------------------------------------------------------
	
		// TODO: make uiElement to switch between
		//uiDisplay.mouseEnabled = false;
		//uiDisplay.touchEnabled = false;
				
		#if android
		uiDisplay.mouseEnabled = false;
		peoteView.zoom = 3;
		#end
		
		PeoteUIDisplay.registerEvents(window);			
	}	

	
}
