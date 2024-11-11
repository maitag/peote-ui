package;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Color;

import peote.text.Font;

import peote.ui.PeoteUIDisplay;
import peote.ui.interactive.UIElement;
import peote.ui.interactive.UITextPage;
import peote.ui.interactive.UIArea;
import peote.ui.style.BoxStyle;
import peote.ui.style.RoundBorderStyle;
import peote.ui.style.FontStyleTiled;
import peote.ui.config.ResizeType;
import peote.ui.config.TextConfig;
import peote.ui.event.PointerEvent;

import interactive.UIAreaList;
import interactive.AreaListConfig;

class TestUIAreaList extends Application
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
		
		var fontStyleInput = FontStyleTiled.createById(1);
				
		var textInputConfig:TextConfig = {
			backgroundStyle:boxStyle.copy(Color.GREY5),
			selectionStyle: selectionStyle,
			cursorStyle: cursorStyle
		}
			
		// ---------------------------------------------------------
		// --- creating PeoteUIDisplay with some styles in Order ---
		// ---------------------------------------------------------
		
		peoteUiDisplay = new PeoteUIDisplay(10, 10, window.width - 20, window.height - 20, Color.GREY1,
			[roundBorderStyle, boxStyle, selectionStyle, fontStyleInput, cursorStyle]
		);
		peoteView.addDisplay(peoteUiDisplay);
		//peoteUiDisplay.zoom = 0.75;
		//peoteUiDisplay.xOffset = 30;
		//peoteView.zoom = 0.75;
		//peoteView.xOffset = 20;
		

		// ---------------------------------------------------------
		// ------------------- UIAreaList --------------------------
		// ---------------------------------------------------------
				
		// var areaList = new UIAreaList(10, 10, 200, 400);
		var areaList = new UIAreaList(10, 10, 200, 400, 0, { backgroundStyle:boxStyle, resizeType:ResizeType.ALL, maskSpace:{left:10} });
		peoteUiDisplay.add(areaList);
		
		// ---- add content ----
		
		
		var uiElement0 = new UIElement(0, 0, 0, 50, 0, roundBorderStyle.copy(Color.GREEN2));
		uiElement0.onPointerDown = (elem:UIElement, e:PointerEvent)-> {areaList.remove(elem);}
		areaList.add(uiElement0);

		var uiElement1 = new UIElement(0, 0, 0, 100, 0, roundBorderStyle);		
		uiElement1.onPointerDown = (elem:UIElement, e:PointerEvent)-> {areaList.remove(elem);}
		areaList.add(uiElement1);

		var inputPage = new UITextPage<FontStyleTiled>(0, 0, 200, 0, 1, "input\ntext by\nUITextPage", font, fontStyleInput, textInputConfig);
		inputPage.onPointerDown = function(t:UITextPage<FontStyleTiled>, e:PointerEvent) {
			t.setInputFocus(e);
			t.startSelection(e);
		}
		inputPage.onPointerUp = function(t:UITextPage<FontStyleTiled>, e:PointerEvent) {
			t.stopSelection(e);
		}
		areaList.add(inputPage);


		var innerArea = new UIArea(0, 0, 0, 100, {backgroundStyle:roundBorderStyle.copy(Color.BLUE2), resizeType:ResizeType.BOTTOM});
		areaList.add(innerArea);


		// -------------------------------
		var innerAreaList = new UIAreaList(0, 0, 0, 100, {backgroundStyle:roundBorderStyle.copy(Color.RED2), resizeType:ResizeType.BOTTOM});
		areaList.add(innerAreaList);

			// inner content of innerAreaList
			var uiElement00 = new UIElement(0, 0, 0, 20, 0, roundBorderStyle.copy(Color.LIME));
			uiElement00.onPointerDown = (elem:UIElement, e:PointerEvent)-> {innerAreaList.remove(elem);}
			innerAreaList.add(uiElement00);

			var uiElement01 = new UIElement(0, 0, 0, 30, 0, roundBorderStyle.copy(Color.MAGENTA));		
			uiElement01.onPointerDown = (elem:UIElement, e:PointerEvent)-> {innerAreaList.remove(elem);}
			innerAreaList.add(uiElement01);
		
		// -------------------------------

		
		var uiElement2 = new UIElement(0, 0, 0, 100, 0, roundBorderStyle);		
		uiElement2.onPointerDown = (elem:UIElement, e:PointerEvent)-> {areaList.remove(elem);}
		areaList.add(uiElement2);


		
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
