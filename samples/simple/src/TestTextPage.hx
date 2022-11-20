package;

import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;
import peote.ui.event.PointerEvent;
import peote.ui.util.HAlign;
import peote.ui.util.TextSize;
import peote.ui.util.VAlign;

import peote.view.PeoteView;
import peote.view.Color;

import peote.text.Font;

import peote.ui.PeoteUIDisplay;
import peote.ui.interactive.UITextLine;
import peote.ui.interactive.UITextPage;

import peote.ui.style.*;


class TestTextPage extends Application
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
		// load the FONTs:
		new Font<FontStylePacked>("assets/fonts/packed/hack/config.json").load( 
			function(fontPacked:Font<FontStylePacked>) {
				new Font<FontStyleTiled>("assets/fonts/tiled/hack_ascii.json").load(
					function(fontTiled:Font<FontStyleTiled>) {
						onFontLoaded(fontPacked, fontTiled);
					}
				);
			}
		);
	}
		
	// ------------------ Create a Button  ------------------------
	
	var buttonX:Int = 0;
	var buttonY:Int = 0;
	var fontButtons:Font<FontStyleTiled>;
	var buttonBackgroundStyle = new RoundBorderStyle(Color.GREY5, Color.BLACK, 1.0, 9.0);
	var buttonSize:TextSize = {leftSpace:6, rightSpace:6, topSpace:3, bottomSpace:3 }; //height:23
	var buttonStyle:FontStyleTiled = {letterSpace:-0.5};

	public function button(
		s1:String = null, f1:Void->Void = null,
		s2:String = null, f2:Void->Void = null,
		s3:String = null, f3:Void->Void = null,
		s4:String = null, f4:Void->Void = null)
	{
		var b:UITextLine<FontStyleTiled> = null;
		var hgap:Int = 5; var vgap:Int = 30;
		if (s1 != null) uiDisplay.add(b = fontButtons.createUITextLine(buttonX             , buttonY, buttonSize, s1, buttonStyle, buttonBackgroundStyle));
		if (f1 != null) { b.onPointerClick = (_, _)-> f1(); b.onPointerOver = buttonOver; b.onPointerOut = buttonOut; }
		if (s2 != null) uiDisplay.add(b = fontButtons.createUITextLine(b.x + hgap + b.width, buttonY, buttonSize, s2, buttonStyle, buttonBackgroundStyle));
		if (f2 != null) { b.onPointerClick = (_,_)-> f2(); b.onPointerOver = buttonOver; b.onPointerOut = buttonOut; }
		if (s3 != null) uiDisplay.add(b = fontButtons.createUITextLine(b.x + hgap + b.width, buttonY, buttonSize, s3, buttonStyle, buttonBackgroundStyle));
		if (f3 != null) { b.onPointerClick = (_,_)-> f3(); b.onPointerOver = buttonOver; b.onPointerOut = buttonOut; }
		if (s4 != null) uiDisplay.add(b = fontButtons.createUITextLine(b.x + hgap + b.width, buttonY, buttonSize, s4, buttonStyle, buttonBackgroundStyle));
		if (f4 != null) { b.onPointerClick = (_, _)-> f4(); b.onPointerOver = buttonOver; b.onPointerOut = buttonOut; }
		buttonY += vgap;
	}
	
	function buttonOver(b:UITextLine<FontStyleTiled>, _) {
		b.backgroundStyle.color = Color.GREY7;
		b.updateStyle();
	}
	function buttonOut(b:UITextLine<FontStyleTiled>, _) {
		b.backgroundStyle.color = Color.GREY5;
		b.updateStyle();
	}
	
	// ---------------- all Fonts are loaded  ----------------------
	
	public function onFontLoaded(fontPacked:Font<FontStylePacked>, fontTiled:Font<FontStyleTiled>) // font needs type here !
	{
		fontButtons = fontTiled; // make global for the button() function
		
		var boxStyle  = new BoxStyle(Color.RED);
		var roundBorderStyle = new RoundBorderStyle(Color.GREEN);
		var cursorStyle = BoxStyle.createById(1); // different id is need if using more then one into available styles
		
		
		var fontStylePacked:FontStylePacked = { width:20, height:20 };		
		var fontStyleTiled = fontTiled.createFontStyle(); // alternative way of creation
		
		peoteView = new PeoteView(window);
		uiDisplay = new PeoteUIDisplay(0, 0, window.width, window.height, Color.GREY1
		// available styles into render-order (without it will auto add at runtime and fontstyles allways on top)
			//,[ boxStyle, roundBorderStyle, fontStylePacked, fontStyleTiled, cursorStyle]
			,[ boxStyle, roundBorderStyle, fontStylePacked ], true // allow to auto add Styles
		);
		peoteView.addDisplay(uiDisplay);
		
		
		//uiDisplay.getStyleProgram(roundBorderStyle).alphaEnabled = false;				
		uiDisplay.addFontStyleProgram(fontStyleTiled, fontTiled);
		
		uiDisplay.addStyleProgram(cursorStyle, true).alphaEnabled = true;
		
		
		
		// ----------- create UITextLine -----------
		
		var backgroundSimpleStyle = boxStyle.copy(Color.YELLOW);
		var backgroundRoundStyle = roundBorderStyle.copy(Color.YELLOW);		
		var selectionSimpleStyle = boxStyle.copy(Color.GREY4);
		var selectionRoundStyle = roundBorderStyle.copy(Color.GREY4);		
		//var cursorSimpleStyle = boxStyle.copy();
		var cursorSimpleStyle = cursorStyle.copy(Color.RED.setAlpha(0.5));
		var cursorRoundStyle = roundBorderStyle.copy();
		
		var textStyle:TextLineStyle = {
			backgroundStyle:backgroundSimpleStyle,
			selectionStyle:selectionSimpleStyle,
			cursorStyle:cursorSimpleStyle
		}

		var textPage = new UITextPage<FontStylePacked>(240, 5, "Hello World\nTesting UITextPAge", fontPacked, fontStylePacked, textStyle);
		textPage.onPointerOver = (_, _)-> trace("textPage onPointerOver");
		textPage.onPointerOut  = (_, _)-> trace("textPage onPointerOut");
		textPage.onPointerClick  = (t, e:PointerEvent)-> {
			trace("textPage onPointerClick", e);
		}
		textPage.onPointerDown = function(t, e:PointerEvent) {
			trace("textPage onPointerDown");
			t.setInputFocus(e); // alternatively: uiDisplay.setInputFocus(t);
			t.startSelection(e);
		}
		textPage.onPointerUp = function(t, e:PointerEvent) {
			trace("textPage onPointerUp");
			t.stopSelection(e);
		}
		textPage.maskWidth = 100;
		textPage.maskHeight = 20;
				
		// ----------------------------------------------------------
		// -------------------- LEFT BUTTONS ROW --------------------
		// ----------------------------------------------------------
/*		buttonX = 8; buttonY = 72;		
		button(
			"add/remove", ()-> if (!element.isVisible) uiDisplay.add(element) else uiDisplay.remove(element),
		    "show", ()-> element.show(), "hide", ()-> element.hide()
		);
		
		// ------------ background Style ------------
		buttonY += 12;
		button(
			"styleShow/Hide",  ()-> element.styleIsVisible = !element.styleIsVisible,		
			"color", ()-> {	element.style.color = Color.random(); element.updateStyle(); }
		);
		button("set simplestyle", ()-> element.style = boxStyle);
		button("set roundStyle", ()-> element.style = roundBorderStyle);
		button("remove style", ()-> element.style = null);
		
*/				
		// ----------------------------------------------------------
		// -------------------- MIDDLE BUTTONS ROW ------------------
		// ----------------------------------------------------------
		buttonX = 240; buttonY = 72;
		button(
			"add/remove", ()-> if (!textPage.isVisible) uiDisplay.add(textPage) else uiDisplay.remove(textPage),
		    "show",       ()-> textPage.show(), "hide",       ()-> textPage.hide()
		);
		
		// ------------ background Style ------------
		buttonY += 12;
		button(
			"backgroundShow/Hide", ()-> if (textPage.backgroundIsVisible) textPage.backgroundHide() else textPage.backgroundShow(),	
			"color", ()-> { textPage.backgroundStyle.color = Color.random(); textPage.updateStyle(); }
		);			
		button("set boxStyle", ()-> textPage.backgroundStyle = backgroundSimpleStyle);
		button("set roundStyle",  ()-> textPage.backgroundStyle = backgroundRoundStyle);
		button("remove style",    ()-> textPage.backgroundStyle = null);
				
		// ------------ selection Style ------------
		buttonY += 12;
/*		button(
			"select 0-8",  ()-> textPage.select(0,8),
		    "4-10", ()-> textPage.select(4,10),
		    "5-2", ()-> textPage.select(5,2)
		);
		button(
			"selectionShow/Hide", ()-> if (textPage.selectionIsVisible) textPage.selectionHide() else textPage.selectionShow(),
			"color", ()-> { textPage.selectionStyle.color = Color.random(); textPage.updateStyle(); }
		);		
		button("set simplestyle", ()-> textPage.selectionStyle = selectionSimpleStyle);
		button("set roundStyle", ()-> textPage.selectionStyle = selectionRoundStyle);
		button("remove style", ()-> textPage.selectionStyle = null);

*/		// ------------- cursor Style -------------
		buttonY += 12;
		button(
			"cursorShow/Hide", ()->if (textPage.cursorIsVisible) textPage.cursorHide() else textPage.cursorShow(),
			"color", ()-> { textPage.cursorStyle.color = Color.random(); textPage.updateStyle(); } 
		);		
		button("set simplestyle", ()-> textPage.cursorStyle = cursorSimpleStyle);
		button("set roundStyle", ()-> textPage.cursorStyle = cursorRoundStyle);
		button("remove style", ()-> textPage.cursorStyle = null);

		
		// ----------------------------------------------------------
		// -------------------- RIGHT BUTTONS ROW -------------------
		// ----------------------------------------------------------
		buttonX = 516; 
		
		// ------- text and fontStyle -------
		buttonY = 6;	
		button(
			"text1", ()-> textPage.setText("Hello World", textPage.autoWidth, textPage.autoHeight, true),
			"text2", ()-> textPage.setText("testing more", textPage.autoWidth, textPage.autoHeight, true),
			"text3", ()-> textPage.setText("ui stuff", textPage.autoWidth, textPage.autoHeight, true)
		);		
		button(
			"fontStyle color", ()-> { textPage.fontStyle = fontStylePacked.copy(Color.random().setAlpha(1.0)); textPage.updateStyle(); },
			"size", ()-> {
				if (textPage.fontStyle.width == 20) textPage.fontStyle.width = textPage.fontStyle.height = 30;
				else textPage.fontStyle.width = textPage.fontStyle.height = 20; 
				textPage.update();
			}
		);		
		
		// ------- position -------
		buttonY = 72;
		button(
			"x+=5", ()-> { textPage.x += 5; textPage.updateLayout(); },
			"x-=5", ()-> { textPage.x -= 5; textPage.updateLayout(); },
			"y+=5", ()-> { textPage.y += 5; textPage.updateLayout(); },
			"y-=5", ()-> { textPage.y -= 5; textPage.updateLayout(); }
		);
		
		// ------- horizontal size, space and align -------
		buttonY += 12;
		button(
			"w+=5",      ()-> { textPage.autoWidth = false; textPage.width += 5; textPage.maskWidth += 5; textPage.updateLayout(); },
			"w-=5",      ()-> { textPage.autoWidth = false; textPage.width -= 5; textPage.maskWidth -= 5; textPage.updateLayout(); },
			"autoWidth", ()-> { textPage.autoWidth = true; textPage.updateLayout(); }
		);
		button(
			"left"  , ()-> { textPage.xOffset = 0; textPage.hAlign = HAlign.LEFT;   textPage.updateLayout(); },
			"center", ()-> { textPage.xOffset = 0; textPage.hAlign = HAlign.CENTER; textPage.updateLayout(); },
			"right" , ()-> { textPage.xOffset = 0; textPage.hAlign = HAlign.RIGHT;  textPage.updateLayout(); }
		);		
		button(
			"leftSpace++", ()-> { textPage.leftSpace++; textPage.updateLayout(); },
			"leftSpace--", ()-> { textPage.leftSpace--; textPage.updateLayout(); }
		);
		button(
			"rightSpace++", ()-> { textPage.rightSpace++; textPage.updateLayout(); },
			"rightSpace--", ()-> { textPage.rightSpace--; textPage.updateLayout(); }
		);
		
		// ------- vertical size, space and align -------
		buttonY += 12;
		button(
			"h+=5",       ()-> { textPage.autoHeight = false; textPage.height += 5; textPage.maskHeight += 5; textPage.updateLayout(); },
			"h-=5",       ()-> { textPage.autoHeight = false; textPage.height -= 5; textPage.maskHeight -= 5; textPage.updateLayout(); },
			"autoHeight", ()-> { textPage.autoHeight = true; textPage.updateLayout(); }
		);
		button(
			"top"  ,   ()-> { textPage.yOffset = 0; textPage.vAlign = VAlign.TOP;   textPage.updateLayout(); },
			"center",  ()-> { textPage.yOffset = 0; textPage.vAlign = VAlign.CENTER; textPage.updateLayout(); },
			"bottom" , ()-> { textPage.yOffset = 0; textPage.vAlign = VAlign.BOTTOM;  textPage.updateLayout(); }
		);		
		button(
			"topSpace++", ()-> { textPage.topSpace++; textPage.updateLayout(); },
			"topSpace--", ()-> { textPage.topSpace--; textPage.updateLayout(); }
		);
		button(
			"bottomSpace++", ()-> { textPage.bottomSpace++; textPage.updateLayout(); },
			"bottomSpace--", ()-> { textPage.bottomSpace--; textPage.updateLayout(); }
		);
		
		// -------- text offset ------------
		buttonY += 12;
		button(
			"xOffset+=5", ()-> { textPage.xOffset += 5; textPage.updateLayout(); },
			"xOffset-=5", ()-> { textPage.xOffset -= 5; textPage.updateLayout(); }
		);		
		button(
			"yOffset+=5", ()-> { textPage.yOffset += 5; textPage.updateLayout(); },
			"yOffset-=5", ()-> { textPage.yOffset -= 5; textPage.updateLayout(); }
		);
		
		// -------- layout masking ------------
		buttonY += 12;
		button("mask on/off" , ()-> { textPage.masked = !textPage.masked; textPage.updateLayout(); });		
		button(
			"leftMask++", ()-> { textPage.maskX++; textPage.maskWidth--; textPage.updateLayout(); },
			"leftMask--", ()-> { textPage.maskX--; textPage.maskWidth++; textPage.updateLayout(); }
		);
		button(
			"rightMask++", ()-> { textPage.maskWidth++; textPage.updateLayout(); },
			"rightMask--", ()-> { textPage.maskWidth--; textPage.updateLayout(); }
		);
		button(
			"topMask++", ()-> { textPage.maskY++; textPage.maskHeight--; textPage.updateLayout(); },
			"topMask--", ()-> { textPage.maskY--; textPage.maskHeight++; textPage.updateLayout(); }
		);
		button(
			"bottomMask++", ()-> { textPage.maskHeight++; textPage.updateLayout(); },
			"bottomMask--", ()-> { textPage.maskHeight--; textPage.updateLayout(); }
		);
		
		
		PeoteUIDisplay.registerEvents(window);
	}
	

}
