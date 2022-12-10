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
import peote.ui.interactive.UIElement;

import peote.ui.style.*;


class TestStyles extends Application
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
		
		
		// ----------- create InteractiveElement -----------
		
		var element = new UIElement(10, 10, 250, 50, boxStyle);
		element.onPointerOver = (_, _)-> trace("on element over");
		element.onPointerOut  = (_, _)-> trace("on element out");
		
		// ----------- create UITextLine -----------
		
		var backgroundSimpleStyle = boxStyle.copy(Color.YELLOW);
		var backgroundRoundStyle = roundBorderStyle.copy(Color.YELLOW);		
		var selectionSimpleStyle = boxStyle.copy(Color.GREY4);
		var selectionRoundStyle = roundBorderStyle.copy(Color.GREY4);		
		//var cursorSimpleStyle = boxStyle.copy();
		var cursorSimpleStyle = cursorStyle.copy(Color.RED.setAlpha(0.5));
		var cursorRoundStyle = roundBorderStyle.copy();
		
		var textStyle:TextStyle = {
			backgroundStyle:backgroundSimpleStyle,
			selectionStyle:selectionSimpleStyle,
			cursorStyle:cursorSimpleStyle
		}

		var textLine = new UITextLine<FontStylePacked>(240, 25, "Hello World", fontPacked, fontStylePacked, textStyle);
		textLine.onPointerOver = (_, _)-> trace("textLine onPointerOver");
		textLine.onPointerOut  = (_, _)-> trace("textLine onPointerOut");
		textLine.onPointerClick  = (t, e:PointerEvent)-> {
			trace("textLine onPointerClick", e);
		}
		textLine.onPointerDown = function(t, e:PointerEvent) {
			trace("textLine onPointerDown");
			t.setInputFocus(e); // alternatively: uiDisplay.setInputFocus(t);
			t.startSelection(e);
		}
		textLine.onPointerUp = function(t, e:PointerEvent) {
			trace("textLine onPointerUp");
			t.stopSelection(e);
		}
		textLine.maskWidth = 100;
		textLine.maskHeight = 20;
				
		// ----------------------------------------------------------
		// -------------------- LEFT BUTTONS ROW --------------------
		// ----------------------------------------------------------
		buttonX = 8; buttonY = 72;		
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
		
				
		// ----------------------------------------------------------
		// -------------------- MIDDLE BUTTONS ROW ------------------
		// ----------------------------------------------------------
		buttonX = 240; buttonY = 72;
		button(
			"add/remove", ()-> if (!textLine.isVisible) uiDisplay.add(textLine) else uiDisplay.remove(textLine),
		    "show",       ()-> textLine.show(), "hide",       ()-> textLine.hide()
		);
		
		// ------------ background Style ------------
		buttonY += 12;
		button(
			"backgroundShow/Hide", ()-> if (textLine.backgroundIsVisible) textLine.backgroundHide() else textLine.backgroundShow(),	
			"color", ()-> { textLine.backgroundStyle.color = Color.random(); textLine.updateStyle(); }
		);			
		button("set boxStyle", ()-> textLine.backgroundStyle = backgroundSimpleStyle);
		button("set roundStyle",  ()-> textLine.backgroundStyle = backgroundRoundStyle);
		button("remove style",    ()-> textLine.backgroundStyle = null);
				
		// ------------ selection Style ------------
		buttonY += 12;
		button(
			"select 0-8",  ()-> textLine.select(0,8),
		    "4-10", ()-> textLine.select(4,10),
		    "5-2", ()-> textLine.select(5,2)
		);
		button(
			"selectionShow/Hide", ()-> if (textLine.selectionIsVisible) textLine.selectionHide() else textLine.selectionShow(),
			"color", ()-> { textLine.selectionStyle.color = Color.random(); textLine.updateStyle(); }
		);		
		button("set simplestyle", ()-> textLine.selectionStyle = selectionSimpleStyle);
		button("set roundStyle", ()-> textLine.selectionStyle = selectionRoundStyle);
		button("remove style", ()-> textLine.selectionStyle = null);

		// ------------- cursor Style -------------
		buttonY += 12;
		button(
			"cursorShow/Hide", ()->if (textLine.cursorIsVisible) textLine.cursorHide() else textLine.cursorShow(),
			"color", ()-> { textLine.cursorStyle.color = Color.random(); textLine.updateStyle(); } 
		);		
		button("set simplestyle", ()-> textLine.cursorStyle = cursorSimpleStyle);
		button("set roundStyle", ()-> textLine.cursorStyle = cursorRoundStyle);
		button("remove style", ()-> textLine.cursorStyle = null);

		
		// ----------------------------------------------------------
		// -------------------- RIGHT BUTTONS ROW -------------------
		// ----------------------------------------------------------
		buttonX = 516; 
		
		// ------- text and fontStyle -------
		buttonY = 6;	
		button(
			"text1", ()-> textLine.setText("Hello World", textLine.autoWidth, textLine.autoHeight, true),
			"text2", ()-> textLine.setText("testing more", textLine.autoWidth, textLine.autoHeight, true),
			"text3", ()-> textLine.setText("ui stuff", textLine.autoWidth, textLine.autoHeight, true)
		);		
		button(
			"fontStyle color", ()-> { textLine.fontStyle = fontStylePacked.copy(Color.random().setAlpha(1.0)); textLine.updateStyle(); },
			"size", ()-> {
				if (textLine.fontStyle.width == 20) textLine.fontStyle.width = textLine.fontStyle.height = 30;
				else textLine.fontStyle.width = textLine.fontStyle.height = 20; 
				textLine.update();
			}
		);		
		
		// ------- position -------
		buttonY = 72;
		button(
			"x+=5", ()-> { textLine.x += 5; textLine.updateLayout(); },
			"x-=5", ()-> { textLine.x -= 5; textLine.updateLayout(); },
			"y+=5", ()-> { textLine.y += 5; textLine.updateLayout(); },
			"y-=5", ()-> { textLine.y -= 5; textLine.updateLayout(); }
		);
		
		// ------- horizontal size, space and align -------
		buttonY += 12;
		button(
			"w+=5",      ()-> { textLine.autoWidth = false; textLine.width += 5; textLine.maskWidth += 5; textLine.updateLayout(); },
			"w-=5",      ()-> { textLine.autoWidth = false; textLine.width -= 5; textLine.maskWidth -= 5; textLine.updateLayout(); },
			"autoWidth", ()-> { textLine.autoWidth = true; textLine.updateLayout(); }
		);
		button(
			"left"  , ()-> { textLine.hAlign = HAlign.LEFT;   textLine.updateLayout(); },
			"center", ()-> { textLine.hAlign = HAlign.CENTER; textLine.updateLayout(); },
			"right" , ()-> { textLine.hAlign = HAlign.RIGHT;  textLine.updateLayout(); }
		);		
		button(
			"leftSpace++", ()-> { textLine.leftSpace++; textLine.updateLayout(); },
			"leftSpace--", ()-> { textLine.leftSpace--; textLine.updateLayout(); }
		);
		button(
			"rightSpace++", ()-> { textLine.rightSpace++; textLine.updateLayout(); },
			"rightSpace--", ()-> { textLine.rightSpace--; textLine.updateLayout(); }
		);
		
		// ------- vertical size, space and align -------
		buttonY += 12;
		button(
			"h+=5",       ()-> { textLine.autoHeight = false; textLine.height += 5; textLine.maskHeight += 5; textLine.updateLayout(); },
			"h-=5",       ()-> { textLine.autoHeight = false; textLine.height -= 5; textLine.maskHeight -= 5; textLine.updateLayout(); },
			"autoHeight", ()-> { textLine.autoHeight = true; textLine.updateLayout(); }
		);
		button(
			"top"  ,   ()-> { textLine.vAlign = VAlign.TOP;   textLine.updateLayout(); },
			"center",  ()-> { textLine.vAlign = VAlign.CENTER; textLine.updateLayout(); },
			"bottom" , ()-> { textLine.vAlign = VAlign.BOTTOM;  textLine.updateLayout(); }
		);		
		button(
			"topSpace++", ()-> { textLine.topSpace++; textLine.updateLayout(); },
			"topSpace--", ()-> { textLine.topSpace--; textLine.updateLayout(); }
		);
		button(
			"bottomSpace++", ()-> { textLine.bottomSpace++; textLine.updateLayout(); },
			"bottomSpace--", ()-> { textLine.bottomSpace--; textLine.updateLayout(); }
		);
		
		// -------- text offset ------------
		buttonY += 12;
		button(
			"xOffset+=5", ()-> { textLine.xOffset += 5; textLine.updateLayout(); },
			"xOffset-=5", ()-> { textLine.xOffset -= 5; textLine.updateLayout(); }
		);		
		button(
			"yOffset+=5", ()-> { textLine.yOffset += 5; textLine.updateLayout(); },
			"yOffset-=5", ()-> { textLine.yOffset -= 5; textLine.updateLayout(); }
		);
		
		// -------- layout masking ------------
		buttonY += 12;
		button("mask on/off" , ()-> { textLine.masked = !textLine.masked; textLine.updateLayout(); });		
		button(
			"leftMask++", ()-> { textLine.maskX++; textLine.maskWidth--; textLine.updateLayout(); },
			"leftMask--", ()-> { textLine.maskX--; textLine.maskWidth++; textLine.updateLayout(); }
		);
		button(
			"rightMask++", ()-> { textLine.maskWidth++; textLine.updateLayout(); },
			"rightMask--", ()-> { textLine.maskWidth--; textLine.updateLayout(); }
		);
		button(
			"topMask++", ()-> { textLine.maskY++; textLine.maskHeight--; textLine.updateLayout(); },
			"topMask--", ()-> { textLine.maskY--; textLine.maskHeight++; textLine.updateLayout(); }
		);
		button(
			"bottomMask++", ()-> { textLine.maskHeight++; textLine.updateLayout(); },
			"bottomMask--", ()-> { textLine.maskHeight--; textLine.updateLayout(); }
		);
		
		
		PeoteUIDisplay.registerEvents(window);
	}
	

}
