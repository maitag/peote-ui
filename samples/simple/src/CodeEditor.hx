package;

import haxe.CallStack;
import lime.ui.MouseCursor;
import peote.ui.util.ResizeType;

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


class CodeEditor extends Application
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
		
		// -----------------------------------------------------------
		// ---- creating an Area, header and Content-Area ------------
		// -----------------------------------------------------------
		
		var sliderSize:Int = 20;
		var headerSize:Int = 20;
		
		var area = new UIArea(50, 50, 500, 500, roundBorderStyle, ResizeType.ALL);
		// to let the area drag
		area.setDragArea(0, 0, peoteUiDisplay.width, peoteUiDisplay.height);
		peoteUiDisplay.add(area);
		
		
		// --------------------------
		// ---- header textline -----		
		// --------------------------
		
		var header = new UITextLine<FontStyleTiled>(0, 0,
			{width:500, height:headerSize, hAlign:HAlign.CENTER}, 
			"=== Edit Code ===", font, fontStyleHeader, roundBorderStyle
		);
		// start/stop area-dragging
		header.onPointerDown = (_, e:PointerEvent)-> area.startDragging(e);
		header.onPointerUp = (_, e:PointerEvent)-> area.stopDragging(e);
		area.add(header);				
		
		
		// --------------------------
		// ------- edit area --------
		// --------------------------
		
		var editArea = new UITextPage<FontStyleTiled>(0, headerSize,
			{ width: area.width - sliderSize, height: area.height - headerSize - sliderSize},
			"input\ntext by\nUIText\tPage", font, fontStyleInput, textStyleInput
		);
			
		// TODO: make UITextPage "selectable" to automatic set internal onPointerDown/Up for selection
		editArea.onPointerDown = function(t, e) {
			t.setInputFocus(e);			
			t.startSelection(e);
		}
		
		editArea.onPointerUp = function(t, e) {
			t.stopSelection(e);
		}
		area.add(editArea);
		
				
		// ------------------------------------
		// ---- sliders to scroll editArea ----		
		// ------------------------------------
		
		var hSlider = new UISlider(0, area.height-sliderSize, area.width-sliderSize, sliderSize, sliderStyle);
		hSlider.onMouseWheel = (_, e:WheelEvent) -> hSlider.setWheelDelta( e.deltaY );
		area.add(hSlider);		
		
		var vSlider = new UISlider(area.width-20, headerSize, sliderSize, area.height-headerSize-sliderSize, sliderStyle);
		vSlider.onMouseWheel = (_, e:WheelEvent) -> vSlider.setWheelDelta( e.deltaY );
		area.add(vSlider);
				
		// bind editArea to sliders
		editArea.bindHSlider(hSlider);
		editArea.bindVSlider(vSlider);

		
		// ---------------------------------------------
		// -------- button to change the size ----------		
		// ---------------------------------------------
		
/*		// TODO: put this inside of UIArea.hx but for all directions of ResizeType
		var resizerSize:Int = 18;
		var minWidth:Int = 100;var maxWidth:Int = 600;
		var minHeight:Int = 100; var maxHeight:Int = 500;
		
		var resizerBottomRight:UIElement = new UIElement(area.width - 19, area.height - 19, resizerSize, resizerSize, 2, roundBorderStyle.copy(Color.GREY3, Color.GREY1));	
		
		
		resizerBottomRight.onPointerDown = (_, e:PointerEvent)-> {
			resizerBottomRight.setDragArea(
				area.x + minWidth,
				area.y + minHeight,
				Std.int(Math.min( maxWidth - minWidth, peoteUiDisplay.width  - (area.x + minWidth) )),
				Std.int(Math.min( maxHeight - minHeight, peoteUiDisplay.height - (area.y + minHeight) ))
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
*/		
		
		// --- arrange header and sliders if area size is changing ---
		
		area.onResizeWidth = (_, width:Int, deltaWidth:Int) -> {
			header.width = width;
			vSlider.right = area.right;
			editArea.width = hSlider.width = width - sliderSize;
		}

		area.onResizeHeight = (_, height:Int, deltaHeight:Int) -> {
			hSlider.bottom = area.bottom;
			editArea.height = vSlider.height = height - headerSize - sliderSize;
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
