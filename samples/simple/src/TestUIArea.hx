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
		
		peoteUiDisplay = new PeoteUIDisplay(10, 10, window.width-20, window.height-20, Color.GREY1, [roundBorderStyle, boxStyle, fontStyle]);
		peoteView.addDisplay(peoteUiDisplay);
		//peoteUiDisplay.zoom = 0.75;
		//peoteUiDisplay.xOffset = 30;
		//peoteView.zoom = 0.75;
		//peoteView.xOffset = 20;

		
		// -----------------------------------
		// ---- creating an Area ------------
		// -----------------------------------
		
		var area = new UIArea(0, 0, 500, 500, roundBorderStyle );
		peoteUiDisplay.add(area);
		var textLine = new UITextLine<FontStyleTiled>(0, 0, {width:500, hAlign:HAlign.CENTER}, 1, "=== UIArea ===", font, fontStyle, roundBorderStyle.copy(Color.GREY3));
		area.add(textLine);		
		var hSlider = new UISlider(0, 480, 480, 20, sliderStyle);
		area.add(hSlider);
		var vSlider = new UISlider(480, 20, 20, 460, sliderStyle);
		area.add(vSlider);
		var content = new UIArea(3, 20, 477, 460, boxStyle);
		area.add(content);
		
		// ---- uiElement button to change the size ----		
		var resizerBottomRight:UIElement = new UIElement(area.x + area.width - 20, area.x + area.height - 20, 20, 20, 2, roundBorderStyle);	
		peoteUiDisplay.add(resizerBottomRight);
		var resizerBottomRightSetDragArea = () -> {
			resizerBottomRight.setDragArea(
				Std.int(area.x + 240),
				Std.int(area.y + 140),
				Std.int((peoteUiDisplay.width  - peoteUiDisplay.xOffset) / peoteUiDisplay.xz  - area.x - 240),
				Std.int((peoteUiDisplay.height - peoteUiDisplay.yOffset) / peoteUiDisplay.yz  - area.y - 140)
			);
		};
		resizerBottomRightSetDragArea();
		resizerBottomRight.onPointerDown = (_, e:PointerEvent)-> resizerBottomRight.startDragging(e);
		resizerBottomRight.onPointerUp = (_, e:PointerEvent)-> resizerBottomRight.stopDragging(e);
		resizerBottomRight.onDrag = (_, x:Float, y:Float) -> {
			area.width = resizerBottomRight.x + resizerBottomRight.width - area.x;
			area.height = resizerBottomRight.y + resizerBottomRight.height - area.y;
			area.updateLayout();
			textLine.width = area.width;
			textLine.updateLayout();
			content.width = area.width - 23;
			content.height = area.height - 40;
			content.updateLayout();
			hSlider.width = area.width - 20;
			hSlider.y = area.y + area.height - hSlider.height;
			hSlider.updateLayout();
			vSlider.height = content.height;
			vSlider.x = area.x + area.width - vSlider.width;
			vSlider.updateLayout();
		};
		resizerBottomRight.onPointerOver = (_,_)-> window.cursor = MouseCursor.RESIZE_NWSE;
		resizerBottomRight.onPointerOut  = (_,_)-> window.cursor = MouseCursor.DEFAULT;
		
		// to let the area drag
		area.setDragArea(
			Std.int(-peoteUiDisplay.xOffset / peoteUiDisplay.xz),
			Std.int(-peoteUiDisplay.yOffset / peoteUiDisplay.yz),
			Std.int(peoteUiDisplay.width    / peoteUiDisplay.xz),
			Std.int(peoteUiDisplay.height   / peoteUiDisplay.yz)
		);
		// update the resizers if area is dragging
		area.onDrag = (_, x:Float, y:Float) -> {
			resizerBottomRight.x = area.x + area.width - resizerBottomRight.width;
			resizerBottomRight.y = area.y + area.height - resizerBottomRight.height;
			resizerBottomRight.updateLayout();
		};
		
		// ---- header textline what starts dragging ----		
		textLine.onPointerDown = (_, e:PointerEvent)-> area.startDragging(e);
		textLine.onPointerUp = (_, e:PointerEvent)-> {
			area.stopDragging(e);
			resizerBottomRightSetDragArea();
		}
		
		
		// ---------------------------------------------------------
		// -----  inner UIArea for some scrollable content ---------
		// ---------------------------------------------------------
		

		// put things into content:
		var uiDisplay = new UIDisplay(20, 20, 200, 200, Color.BLUE);
		uiDisplay.onPointerOver = (_,_)-> uiDisplay.display.color = Color.RED;
		uiDisplay.onPointerOut  = (_,_)-> uiDisplay.display.color = Color.BLUE;
		content.add(uiDisplay);
		Elem.playIntoDisplay(uiDisplay.display);

		
		var uiElement = new UIElement(220, 20, 200, 200, roundBorderStyle);
		content.add(uiElement);
		
		
		
		// ---------------------------------------------------------
		
		// ---- Sliders to scroll the innerArea ----		
		hSlider.onMouseWheel = (_, e:WheelEvent) -> hSlider.setDelta( ((e.deltaY > 0) ? 1 : -1 )* 0.05 );
		hSlider.onChange = (_, percent:Float) -> {content.xOffset =  -Std.int(420 * percent); content.updateLayout(); }
		
		vSlider.onMouseWheel = (_, e:WheelEvent) -> vSlider.setDelta( ((e.deltaY > 0) ? 1 : -1 )* 0.05 );
		vSlider.onChange = (_, percent:Float) -> {content.yOffset = - Std.int(420 * percent ); content.updateLayout();}
		
		
		// ---------------------------------------------------------
	
		// TODO: make uiElement to switch between
		//uiDisplay.mouseEnabled = false;
		//uiDisplay.touchEnabled = false;
		
		//peoteUiDisplay.zoom = 0.5;
		
		#if android
		uiDisplay.mouseEnabled = false;
		peoteView.zoom = 3;
		#end
		
		PeoteUIDisplay.registerEvents(window);			
	}	

	
}
