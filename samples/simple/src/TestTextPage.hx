package;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Color;

import peote.ui.PeoteUIDisplay;

import peote.ui.style.RoundBorderStyle;
import peote.ui.style.BoxStyle;

import peote.ui.config.TextConfig;
import peote.ui.config.HAlign;
import peote.ui.config.VAlign;

import peote.ui.event.PointerEvent;

import peote.ui.style.FontStylePacked;
import peote.ui.style.FontStyleTiled;

// using macro generated Font and Text-widgets
// -------------------------------------------
typedef FntP = peote.text.Font<FontStylePacked>;
typedef FntT = peote.text.Font<FontStyleTiled>;
typedef TextLineT = peote.ui.interactive.UITextLine<FontStyleTiled>;
typedef TextPageP = peote.ui.interactive.UITextPage<FontStylePacked>;

// faster buildtime by using the pre generated:
// --------------------------------------------
// typedef FntP = peote.ui.packed.FontP;
// typedef FntT = peote.ui.tiled.FontT;
// typedef TextLineT = peote.ui.interactive.UITextLineT;
// typedef TextPageP = peote.ui.interactive.UITextPageP;

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
				catch (_) trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}

	public function startSample(window:Window)
	{
		// trace("window.display", window.display );
		
		// load the FONTs:
		new FntP("assets/fonts/packed/hack/config.json").load( 
			function(fontPacked:FntP) {
				new FntT("assets/fonts/tiled/hack_ascii.json").load(
					function(fontTiled:FntT) {
						onFontLoaded(fontPacked, fontTiled);
					}
				);
			}
		);
	}
		
	// ------------------ Create a Button  ------------------------
	
	var buttonX:Int = 0;
	var buttonY:Int = 0;
	var fntButtons:FntT;
	var buttonBackgroundStyle:TextConfig = {
		backgroundStyle: new RoundBorderStyle(Color.GREY5, Color.BLACK, 1.0, 9.0), 
		textSpace: { left:6, right:6, top:3, bottom:3 }
	};
	var buttonStyle:FontStyleTiled = {letterSpace:-0.5};

	public function button(
		s1:String = null, f1:Void->Void = null,
		s2:String = null, f2:Void->Void = null,
		s3:String = null, f3:Void->Void = null,
		s4:String = null, f4:Void->Void = null)
	{
		var b:TextLineT = null;
		var hgap:Int = 5; var vgap:Int = 30;
		if (s1 != null) uiDisplay.add(b = fntButtons.createUITextLine(buttonX             , buttonY, 0, 0, s1, buttonStyle, buttonBackgroundStyle));
		if (f1 != null) { b.onPointerClick = (_, _)-> f1(); b.onPointerOver = buttonOver; b.onPointerOut = buttonOut; }
		if (s2 != null) uiDisplay.add(b = fntButtons.createUITextLine(b.x + hgap + b.width, buttonY, 0, 0, s2, buttonStyle, buttonBackgroundStyle));
		if (f2 != null) { b.onPointerClick = (_,_)-> f2(); b.onPointerOver = buttonOver; b.onPointerOut = buttonOut; }
		if (s3 != null) uiDisplay.add(b = fntButtons.createUITextLine(b.x + hgap + b.width, buttonY, 0, 0, s3, buttonStyle, buttonBackgroundStyle));
		if (f3 != null) { b.onPointerClick = (_,_)-> f3(); b.onPointerOver = buttonOver; b.onPointerOut = buttonOut; }
		if (s4 != null) uiDisplay.add(b = fntButtons.createUITextLine(b.x + hgap + b.width, buttonY, 0, 0, s4, buttonStyle, buttonBackgroundStyle));
		if (f4 != null) { b.onPointerClick = (_, _)-> f4(); b.onPointerOver = buttonOver; b.onPointerOut = buttonOut; }
		buttonY += vgap;
	}
	
	function buttonOver(b:TextLineT, _) {
		b.backgroundStyle.color = Color.GREY7;
		b.updateStyle();
	}
	function buttonOut(b:TextLineT, _) {
		b.backgroundStyle.color = Color.GREY5;
		b.updateStyle();
	}
	
	// ---------------- all Fonts are loaded  ----------------------
	
	public function onFontLoaded(fontPacked:FntP, fontTiled:FntT) // font needs type here !
	{
		fntButtons = fontTiled; // make global for the button() function
		
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
		
		uiDisplay.addStyleProgram(cursorStyle, true).blendEnabled = true;
		
		
		
		// ----------- create UITextLine -----------
		
		var backgroundSimpleStyle = boxStyle.copy(Color.YELLOW);
		var backgroundRoundStyle = roundBorderStyle.copy(Color.YELLOW);		
		var selectionSimpleStyle = boxStyle.copy(Color.GREY4);
		var selectionRoundStyle = roundBorderStyle.copy(Color.GREY4);		
		//var cursorSimpleStyle = boxStyle.copy();
		var cursorSimpleStyle = cursorStyle.copy(Color.FloatRGBA(1.0, 0.0, 0.0, 0.5));
		var cursorRoundStyle = roundBorderStyle.copy();
		
		var textConfig:TextConfig = {
			backgroundStyle:backgroundSimpleStyle,
			selectionStyle:selectionSimpleStyle,
			cursorStyle:cursorSimpleStyle,
			undoBufferSize:20
		}

		var textPage = new TextPageP(240, 5, 0, 0,
			"Hello World\nTesting UITextPage\nabdefg\n123456789",
			fontPacked, fontStylePacked, textConfig
		);
		textPage.onPointerOver = (_, _)-> trace("textPage onPointerOver");
		textPage.onPointerOut  = (_, _)-> trace("textPage onPointerOut");
		textPage.onPointerClick  = (t, e:PointerEvent)-> {
			//trace("textPage onPointerClick", e);
		}
		textPage.onPointerDown = function(t, e:PointerEvent) {
			trace("textPage onPointerDown");
			t.setInputFocus(e, true); // alternatively: uiDisplay.setInputFocus(t);
			t.startSelection(e);
		}
		textPage.onPointerUp = function(t, e:PointerEvent) {
			trace("textPage onPointerUp");
			t.stopSelection(e);
		}
		textPage.maskWidth = 100;
		textPage.maskHeight = 40;
				
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
		buttonX = 240; buttonY = 122;
		button(
			"add/remove", ()-> if (!textPage.isVisible) uiDisplay.add(textPage) else uiDisplay.remove(textPage),
		    "show",       ()-> textPage.show(), "hide",       ()-> textPage.hide()
		);
		
		// ------------ background Style ------------
		buttonY += 12;
		button(
			"backgroundShow/Hide", ()-> if (textPage.backgroundIsVisible) textPage.backgroundHide() else textPage.backgroundShow(),	
			"color", ()-> { if (textPage.backgroundStyle != null) {textPage.backgroundStyle.color = Color.random(); textPage.updateStyle();} }
		);			
		button("set boxStyle", ()-> textPage.backgroundStyle = backgroundSimpleStyle);
		button("set roundStyle",  ()-> textPage.backgroundStyle = backgroundRoundStyle);
		button("remove style",    ()-> textPage.backgroundStyle = null);
				
		// ------------ selection Style ------------
		buttonY += 12;
		button(
			"select 1", ()-> textPage.select(2, 5, 0, 1),
		    "select 2", ()-> textPage.select(2, 5, 0, 2),
		    "select 3", ()-> textPage.select(2, 5, 0, 3)
		);
		button(
			"selectionShow/Hide", ()-> if (textPage.selectionIsVisible) textPage.selectionHide() else textPage.selectionShow(),
			"color", ()-> { if (textPage.selectionStyle != null) {textPage.selectionStyle.color = Color.random(); textPage.updateStyle();} }
		);		
		button("set simplestyle", ()-> textPage.selectionStyle = selectionSimpleStyle);
		button("set roundStyle", ()-> textPage.selectionStyle = selectionRoundStyle);
		button("remove style", ()-> textPage.selectionStyle = null);

		// ------------- cursor Style -------------
		buttonY += 12;
		button(
			"cursorShow/Hide", ()->if (textPage.cursorIsVisible) textPage.cursorHide() else textPage.cursorShow(),
			"color", ()-> { if (textPage.cursorStyle != null) {textPage.cursorStyle.color = Color.random(); textPage.updateStyle();} } 
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
			"text1", ()-> textPage.setText("Hello World\nline1", textPage.autoWidth, textPage.autoHeight, true),
			"text2", ()-> textPage.setText("a\nb\nc", textPage.autoWidth, textPage.autoHeight, true),
			"text3", ()-> textPage.setText("only one line", textPage.autoWidth, textPage.autoHeight, true)
		);		
		button(
			"fontStyle color", ()-> { textPage.fontStyle = fontStylePacked.copy(Color.random(255)); textPage.updateStyle(); },
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
			"autoWidth", ()-> { textPage.autoWidth = true; textPage.xOffset = 0; textPage.updateLayout(); }
		);
		button(
			"left"  , ()-> { textPage.hAlign = HAlign.LEFT;   textPage.setXOffset(0); textPage.updateLayout(); },
			"center", ()-> { textPage.hAlign = HAlign.CENTER; textPage.setXOffset(0); textPage.updateLayout(); },
			"right" , ()-> { textPage.hAlign = HAlign.RIGHT;  textPage.setXOffset(0); textPage.updateLayout(); }
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
			"autoHeight", ()-> { textPage.autoHeight = true;  textPage.yOffset = 0; textPage.updateLayout(); }
		);
		button(
			"top"  ,   ()-> { textPage.vAlign = VAlign.TOP;    textPage.setYOffset(0); textPage.updateLayout(); },
			"center",  ()-> { textPage.vAlign = VAlign.CENTER; textPage.setYOffset(0); textPage.updateLayout(); },
			"bottom" , ()-> { textPage.vAlign = VAlign.BOTTOM; textPage.setYOffset(0); textPage.updateLayout(); }
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
			"xOffset+=5", ()-> { textPage.autoWidth = false; textPage.setXOffset(textPage.xOffset + 5); },
			//"xOffset+=5", ()-> { textPage.autoWidth = false; textPage.xOffset += 5; textPage.updateLayout(); },
			"xOffset-=5", ()-> { textPage.autoWidth = false; textPage.xOffset -= 5; textPage.updateLayout(); }
		);		
		button(
			"yOffset+=5", ()-> { textPage.autoHeight = false; textPage.yOffset += 5; textPage.updateLayout(); },
			"yOffset-=5", ()-> { textPage.autoHeight = false; textPage.yOffset -= 5; textPage.updateLayout(); }
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
