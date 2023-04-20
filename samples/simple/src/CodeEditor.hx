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
		
		var cursorStyle = BoxStyle.createById(1, 0xaa2211ff);
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
		var gap:Int = 3;
		
		var area = new UIArea(50, 50, 500, 500, roundBorderStyle, ResizeType.ALL);
		// to let the area drag
		area.setDragArea(0, 0, peoteUiDisplay.width, peoteUiDisplay.height);
		peoteUiDisplay.add(area);
		
		
		// --------------------------
		// ---- header textline -----		
		// --------------------------
		
		var header = new UITextLine<FontStyleTiled>(gap, gap,
			{width:area.width - gap - gap, height:headerSize, hAlign:HAlign.CENTER}, 
			"=== Edit Code ===", font, fontStyleHeader, roundBorderStyle
		);
		// start/stop area-dragging
		header.onPointerDown = (_, e:PointerEvent)-> area.startDragging(e);
		header.onPointerUp = (_, e:PointerEvent)-> area.stopDragging(e);
		area.add(header);
		
		
		// --------------------------
		// ------- edit area --------
		// --------------------------
		
		var editArea = new UITextPage<FontStyleTiled>(gap, headerSize + gap + 1, {
				width: area.width - sliderSize - gap - gap - 1,
				height: area.height - headerSize - sliderSize - 2 - gap - gap,
				leftSpace: 3, rightSpace:1, topSpace:1, bottomSpace:1
			},
			"class Test {\n\tstatic function main() {\n\t\ttrace(\"Haxe is great!\");\n\t}\n}", font, fontStyleInput, textStyleInput
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
		
		var hSlider = new UISlider(gap, area.height-sliderSize-gap, editArea.width, sliderSize, sliderStyle);
		hSlider.onMouseWheel = (_, e:WheelEvent) -> hSlider.setWheelDelta( e.deltaY );
		area.add(hSlider);		
		
		var vSlider = new UISlider(area.width-sliderSize-gap, headerSize + gap + 1, sliderSize, editArea.height, sliderStyle);
		vSlider.onMouseWheel = (_, e:WheelEvent) -> vSlider.setWheelDelta( e.deltaY );
		area.add(vSlider);
				
		// bind editArea to sliders
		editArea.bindHSlider(hSlider);
		editArea.bindVSlider(vSlider);

				
		// --- arrange header and sliders if area size is changing ---
		
		area.onResizeWidth = (_, width:Int, deltaWidth:Int) -> {
			header.width = width - gap - gap;
			vSlider.right = area.right - gap;
			editArea.rightSize = vSlider.left - 1;
			hSlider.width = editArea.width;
		}

		area.onResizeHeight = (_, height:Int, deltaHeight:Int) -> {
			hSlider.bottom = area.bottom - gap;
			editArea.bottomSize = hSlider.top - 1;
			vSlider.height = editArea.height;
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
