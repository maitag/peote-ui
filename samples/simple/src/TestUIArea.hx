package;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.MouseCursor;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.Element;
import peote.view.Color;

import peote.ui.PeoteUIDisplay;
import peote.ui.interactive.UIElement;
import peote.ui.interactive.UIArea;
import peote.ui.interactive.UIDisplay;
import peote.ui.interactive.UISlider;

import peote.ui.style.BoxStyle;
import peote.ui.style.RoundBorderStyle;

import peote.ui.config.TextConfig;
import peote.ui.config.SliderConfig;
import peote.ui.config.HAlign;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;

import peote.ui.style.FontStyleTiled;

// using macro generated Font and Text-widgets
// -------------------------------------------
typedef Fnt = peote.text.Font<FontStyleTiled>;
typedef TextLine = peote.ui.interactive.UITextLine<FontStyleTiled>;
typedef TextPage = peote.ui.interactive.UITextPage<FontStyleTiled>;

// faster buildtime by using the pre generated:
// --------------------------------------------
// typedef Fnt = peote.ui.tiled.FontT;
// typedef TextLine = peote.ui.interactive.UITextLineT;
// typedef TextPage = peote.ui.interactive.UITextPageT;


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
				catch (_) trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}

	public function startSample(window:Window)
	{
		new Fnt("assets/fonts/tiled/hack_ascii.json").load( onFontLoaded );
	}
	
	public function onFontLoaded(font:Fnt) // don'T forget argument-type here !
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
		
		
		var textInputConfig:TextConfig = {
			backgroundStyle:boxStyle.copy(Color.GREY5),
			selectionStyle: selectionStyle,
			cursorStyle: cursorStyle
		}
		
		var sliderConfig:SliderConfig = {
			backgroundStyle: roundBorderStyle.copy(Color.GREY2),
			draggerStyle: roundBorderStyle.copy(Color.GREY3, Color.GREY2, 0.5),
			draggerSize:16,
			draggSpace:1,
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
		
		// ---- header textline (starts also area-dragging) ----		
		
		var header = new TextLine(0, 0, 500, 0, 1, "=== UIArea ===", font, fontStyleHeader, {
			backgroundStyle:roundBorderStyle,
			backgroundSpace:{left:5},
			hAlign:HAlign.CENTER
		});
		header.onPointerDown = (_, e:PointerEvent)-> area.startDragging(e);
		header.onPointerUp = (_, e:PointerEvent)-> area.stopDragging(e);
		area.add(header);				
		
		
		// ---------------------------------------------------------
		// ------- inner UIArea for some scrollable content --------
		// ---------------------------------------------------------
		
		// ---- inner UIArea for scrolling content ----
		
		var content = new UIArea(2, header.height, area.width-20-2, area.height-header.height-20, 0,
			{
				backgroundStyle:boxStyle,
				// backgroundSpace:{left:5},
				maskSpace:{left:10, right:20, top:20, bottom:30}
			});
		area.add(content);
		
		// ---- add content ----

		// add some fixed Element out of mask and area-offset
		var fixedButton = new TextLine(0, 0, 0, 0, 2, "Fixed Button", font, fontStyleInput, textInputConfig);
		content.addFixed(fixedButton);

		
		var uiDisplay = new UIDisplay(-100, 0, 200, 200, 1, Color.BLUE);
		uiDisplay.onPointerOver = (_,_)-> uiDisplay.display.color = Color.RED;
		uiDisplay.onPointerOut  = (_,_)-> uiDisplay.display.color = Color.BLUE;
		uiDisplay.onPointerDown = (_, e:PointerEvent)-> {
			uiDisplay.setDragArea(Std.int(content.x + content.maskSpace.left), Std.int(content.y + content.maskSpace.top), Std.int(content.width + uiDisplay.width - 50), Std.int(content.height + uiDisplay.height - 50));
			// uiDisplay.setDragArea(0, Std.int(content.y), Std.int(content.width + uiDisplay.width - 10), Std.int(content.height + uiDisplay.height - 10));
			uiDisplay.startDragging(e);
		}
		uiDisplay.onPointerUp = (_, e:PointerEvent)-> uiDisplay.stopDragging(e);
		uiDisplay.onDrag = (_, x:Float, y:Float) -> {
			content.updateInnerSize();
			uiDisplay.maskByElement(content, true, content.maskSpace);
		}
		content.add(uiDisplay);
		Elem.playIntoDisplay(uiDisplay.display);
		
		var uiElement = new UIElement(240, 0, 200, 200, 0, roundBorderStyle);
		uiElement.onPointerDown = (_, e:PointerEvent)-> {
			uiElement.setDragArea(Std.int(content.x + content.maskSpace.left), Std.int(content.y + content.maskSpace.top), Std.int(content.width + uiElement.width - 50), Std.int(content.height + uiElement.height - 50));
			uiElement.startDragging(e);
		}
		uiElement.onPointerUp = (_, e:PointerEvent)-> {
			uiElement.stopDragging(e);
		}
		uiElement.onDrag = (_, x:Float, y:Float) -> {
			content.updateInnerSize();
			uiElement.maskByElement(content, true, content.maskSpace);
		}
		content.add(uiElement);		

		var inputPage = new TextPage(250, 300, 0, 0, 1, "input\ntext by\nUIText\tPage", font, fontStyleInput, textInputConfig);
		inputPage.onPointerDown = function(t:TextPage, e:PointerEvent) {
			t.setInputFocus(e);			
			t.startSelection(e);
		}
		inputPage.onPointerUp = function(t:TextPage, e:PointerEvent) {
			t.stopSelection(e);
		}
		inputPage.onResizeWidth = (_, width:Int, deltaWidth:Int) -> {
			content.updateInnerSize();
			inputPage.maskByElement(content, true, content.maskSpace); // CHECK: need here ?
		}
		inputPage.onResizeHeight = (_, height:Int, deltaHeight:Int) -> {
			content.updateInnerSize();
			inputPage.maskByElement(content, true, content.maskSpace); // CHECK: need here ?
		}
		content.add(inputPage);

		// content.xOffset = content.xOffsetEnd;
		// content.updateLayout();

				
		// ---------------------------------------------------------
		// ---- Sliders to scroll the innerArea ----		
		// ---------------------------------------------------------
		
		var hSlider = new UISlider(0, area.height-20, area.width-20, 20, sliderConfig);
		hSlider.onMouseWheel = (_, e:WheelEvent) -> hSlider.setWheelDelta( e.deltaY );
		area.add(hSlider);		
		
		var vSlider = new UISlider(area.width-20, header.height, 20, area.height-header.height-20, sliderConfig);
		vSlider.onMouseWheel = (_, e:WheelEvent) -> vSlider.setWheelDelta( e.deltaY );
		area.add(vSlider);
		
		// bindings for sliders
		content.bindHSlider(hSlider);
		content.bindVSlider(vSlider);

		// scroll to start/end!
		trace(content.innerLeft, content.innerRight);
		trace(content.xOffsetStart, content.xOffsetEnd);
		// content.setXOffset(content.xOffsetEnd, true, true);
		content.setXOffset(content.xOffsetEnd, true, true);

		// all here automatic after binding content to sliders 
/*
		// ----- initial ranges for sliders ------
		hSlider.setRange( 0, Math.min(0, content.width - content.innerRight), content.width/content.innerRight, false, false );
		vSlider.setRange( 0, Math.min(0, content.height - content.innerBottom), content.height/content.innerBottom , false, false);		
	
		hSlider.onChange = (_, value:Float, percent:Float) -> {
			content.xOffset = Std.int(value);
			content.updateLayout();
		}
		vSlider.onChange = (_, value:Float, percent:Float) -> {
			content.yOffset = Std.int(value);
			content.updateLayout();
		}
		
		// ----- update Sliders if content size is changed -----
		
		content.onResizeInnerWidth = content.onResizeWidth = (_, width:Int, deltaWidth:Int) -> {
			hSlider.setRange( 0, Math.min(0, content.width - content.innerRight), content.width/content.innerRight, true, false );
			//hSlider.setRange( 0, content.width - content.innerRight, content.width/content.innerRight, true, false );
			//hSlider.setRange( content.xOffsetStart, content.xOffsetEnd, false, false );
		}
		
		content.onResizeInnerHeight = content.onResizeHeight = (_, height:Int, deltaHeight:Int) -> {
			vSlider.setRange( 0, Math.min(0, content.height - content.innerBottom), content.height/content.innerBottom, true, false );
			//vSlider.setRange( content.yOffsetStart, content.yOffsetEnd, false, false );
		}

		content.onChangeXOffset = (_, xOffset:Float, deltaXOffset:Float) -> {
			hSlider.setValue( xOffset);
		}
		content.onChangeYOffset = (_, yOffset:Float, deltaYOffset:Float) -> {
			vSlider.setValue( yOffset);
		}				
*/		
		
		// ---------------------------------------------
		// -------- button to change the size ----------		
		// ---------------------------------------------
		
		var resizerBottomRight:UIElement = new UIElement(area.width - 19, area.height - 19, 18, 18, 2, roundBorderStyle.copy(Color.GREY3, Color.GREY1));	
		
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
			area.rightSize  = resizerBottomRight.right + 1;
			area.bottomSize = resizerBottomRight.bottom + 1;
			area.updateLayout();
		};
		resizerBottomRight.onPointerOver = (_,_)-> window.cursor = MouseCursor.RESIZE_NWSE;
		resizerBottomRight.onPointerOut  = (_,_)-> window.cursor = MouseCursor.DEFAULT;
		
		area.add(resizerBottomRight);
		
		
		// --- arrange header and sliders if area size is changing ---
		
		area.onResizeWidth = (_, width:Int, deltaWidth:Int) -> {
			header.width = width;
			vSlider.right = area.right;
			content.rightSize = hSlider.rightSize = vSlider.left;
		}

		area.onResizeHeight = (_, height:Int, deltaHeight:Int) -> {
			hSlider.bottom = area.bottom;
			content.bottomSize = vSlider.bottomSize = hSlider.top;
		}

		
		
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
