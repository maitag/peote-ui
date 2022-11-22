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

import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.Element;

class Elem implements Element {
    @posX
    @anim("Position", "pingpong")
    public var x:Int;
    
    @posY
    public var y:Int;

    @sizeX
    public var w = 50;

    @sizeY
    public var h:Int = 50;

    @color
    public var color:Color = 0xffffffff;

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
	var uiDisplay:PeoteUIDisplay;
	
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
		
		var boxStyle  = new BoxStyle(Color.GREY2);

		var roundBorderStyle:RoundBorderStyle = {
			color: Color.GREY2,
			borderColor: Color.GREY4,
			borderSize: 3.0,
			borderRadius: 20.0
		}
		
		var fontStyle = new FontStyleTiled();

		var sliderStyle:SliderStyle = {
			backgroundStyle: roundBorderStyle.copy(),
			draggerStyle: roundBorderStyle.copy(Color.YELLOW),
		};
		
		// ---------------------------------------------------------
		// --- creating PeoteUIDisplay with some styles in Order ---
		// ---------------------------------------------------------
		
		uiDisplay = new PeoteUIDisplay(10, 10, window.width-20, window.height-20, Color.GREY1, [roundBorderStyle, boxStyle, fontStyle]);
		peoteView.addDisplay(uiDisplay);
		
		
		// -----------------------------------
		// ---- creating an Area ------------
		// -----------------------------------
		
		var area = new UIArea(60, 60, 500, 500, roundBorderStyle );
		var textLine = new UITextLine<FontStyleTiled>(0, 0, {width:500, hAlign:HAlign.CENTER}, 1, "=== UIArea ===", font, fontStyle, roundBorderStyle.copy(Color.GREY3));
		var hSlider = new UISlider(0, 480, 480, 20, sliderStyle);
		var vSlider = new UISlider(480, 20, 20, 460, sliderStyle);

		// ---- uiElement button to change the size ----		
		var resizerBottomRight:UIElement = new UIElement(area.x + area.width - 20, area.x + area.height - 20, 20, 20, 2, roundBorderStyle);	
		resizerBottomRight.setDragArea(60, 60, uiDisplay.width, uiDisplay.height);
		resizerBottomRight.onPointerDown = (_, e:PointerEvent)-> resizerBottomRight.startDragging(e);
		resizerBottomRight.onPointerUp = (_, e:PointerEvent)-> resizerBottomRight.stopDragging(e);
		resizerBottomRight.onDrag = (_, x:Float, y:Float) -> {
			area.width = resizerBottomRight.x + resizerBottomRight.width - area.x;
			area.height = resizerBottomRight.y + resizerBottomRight.height - area.y;
			area.updateLayout();
			textLine.width = area.width;
			textLine.updateLayout();
			// TODO: sliders not updating!
			hSlider.width = area.width - 20;
			hSlider.updateLayout();
		};
		uiDisplay.add(resizerBottomRight);
		
		// to let the area drag
		area.setDragArea(0, 0, uiDisplay.width, uiDisplay.height);
		// update the resizers if area is dragging
		area.onDrag = (_, x:Float, y:Float) -> {
			resizerBottomRight.x = area.x + area.width - resizerBottomRight.width;
			resizerBottomRight.y = area.y + area.height - resizerBottomRight.height;
			resizerBottomRight.updateLayout();
		};
		uiDisplay.add(area);
		
		// ---- header textline what starts dragging ----		
		textLine.onPointerDown = (_, e:PointerEvent)-> area.startDragging(e);
		textLine.onPointerUp = (_, e:PointerEvent)-> area.stopDragging(e);
		area.add(textLine);		
		
		
		// ---------------------------------------------------------
		// -----  inner UIArea for some scrollable content ---------
		// ---------------------------------------------------------
		
		var content = new UIArea(3, 20, 477, 460, boxStyle);
		area.add(content);

		// put things into content:
		var uiDisplay = new UIDisplay(0, 0, 200, 200, Color.BLUE);	
		content.add(uiDisplay);
		Elem.playIntoDisplay(uiDisplay.display);

		
		
		
		
		// ---------------------------------------------------------
		
		// ---- Sliders to scroll the innerArea ----		
		hSlider.onMouseWheel = (_, e:WheelEvent) -> hSlider.setDelta( ((e.deltaY > 0) ? 1 : -1 )* 0.05 );
		hSlider.onChange = (_, percent:Float) -> {content.xOffset =  -Std.int(300 * percent); content.updateLayout();}
		area.add(hSlider);
		
		vSlider.onMouseWheel = (_, e:WheelEvent) -> vSlider.setDelta( ((e.deltaY > 0) ? 1 : -1 )* 0.05 );
		vSlider.onChange = (_, percent:Float) -> {content.yOffset = - Std.int(300 * percent ) ; content.updateLayout();}
		area.add(vSlider);
		
		
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
