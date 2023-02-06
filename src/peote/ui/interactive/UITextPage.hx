package peote.ui.interactive;

#if !macro
@:genericBuild(peote.ui.interactive.UITextPage.UITextPageMacro.build("UITextPage"))
class UITextPage<T> extends peote.ui.interactive.Interactive {}
#else

import haxe.macro.Expr;
import haxe.macro.Context;
import peote.text.util.Macro;
//import peote.text.util.GlyphStyleHasField;
//import peote.text.util.GlyphStyleHasMeta;

class UITextPageMacro
{
	static public function build(name:String):ComplexType return Macro.build(name, buildClass);
	static public function buildClass(className:String, classPackage:Array<String>, stylePack:Array<String>, styleModule:String, styleName:String, styleSuperModule:String, styleSuperName:String, styleType:ComplexType, styleField:Array<String>):ComplexType
	{
		className += Macro.classNameExtension(styleName, styleModule);
		
		if ( Macro.isNotGenerated(className) )
		{
			Macro.debug(className, classPackage, stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType, styleField);
			
			//var glyphType = peote.text.Glyph.GlyphMacro.buildClass("Glyph", ["peote","text"], stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType);
			//var fontType = peote.text.Font.FontMacro.buildClass("Font", ["peote","text"], stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType, styleField);
			//var fontProgramType = peote.text.FontProgram.FontProgramMacro.buildClass("FontProgram", ["peote","text"], stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType, styleField);
			//var pageType  = peote.text.Page.PageMacro.buildClass("Page", ["peote","text"], stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType, styleField);
			
			//var fontPath = TPath({ pack:["peote","text"], name:"Font" + Macro.classNameExtension(styleName, styleModule), params:[] });
			//var fontProgramPath = TPath({ pack:["peote","text"], name:"FontProgram" + Macro.classNameExtension(styleName, styleModule), params:[] });
			//var pagePath = TPath({ pack:["peote","text"], name:"Page" + Macro.classNameExtension(styleName, styleModule), params:[] });

			
			//var glyphStyleHasMeta = peote.text.Glyph.GlyphMacro.parseGlyphStyleMetas(styleModule+"."+styleName); // trace("FontProgram: glyphStyleHasMeta", glyphStyleHasMeta);
			//var glyphStyleHasField = peote.text.Glyph.GlyphMacro.parseGlyphStyleFields(styleModule+"."+styleName); // trace("FontProgram: glyphStyleHasField", glyphStyleHasField);
			var glyphStyleHasMeta = Macro.parseGlyphStyleMetas(styleModule+"."+styleName); // trace("FontProgram: glyphStyleHasMeta", glyphStyleHasMeta);
			var glyphStyleHasField = Macro.parseGlyphStyleFields(styleModule+"."+styleName); // trace("FontProgram: glyphStyleHasField", glyphStyleHasField);

			var c = macro

// -------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------
class $className extends peote.ui.interactive.Interactive
	implements peote.ui.interactive.interfaces.ActionTextPage
	implements peote.ui.interactive.interfaces.InputFocus
	implements peote.ui.interactive.interfaces.InputText
#if peote_layout
implements peote.layout.ILayoutElement
#end
{	
	var page:peote.text.Page<$styleType> = null; // $pageType
	var pageLine:peote.text.PageLine<$styleType> = null; //$lineType
	
	public var textWidth(get, never):Float;
	inline function get_textWidth():Float return page.textWidth;
	
	public var textHeight(get, never):Float;
	inline function get_textHeight():Float return page.textHeight;
	
	var fontProgram:peote.text.FontProgram<$styleType>; //$fontProgramType	
	var font:peote.text.Font<$styleType>; //$fontType	
	public var fontStyle:$styleType;
	
	// -------- background style ---------
	var backgroundProgram:peote.ui.style.interfaces.StyleProgram = null;
	var backgroundElement:peote.ui.style.interfaces.StyleElement = null;
	public var backgroundStyle(default, set):Dynamic = null;
	//inline function set_backgroundStyle(style:Dynamic):Dynamic {
	inline function set_backgroundStyle(style:peote.ui.style.interfaces.Style):peote.ui.style.interfaces.Style {
		if (backgroundElement == null) { // not added to Display yet
			backgroundStyle = style;
			if (style != null && page != null) createBackgroundStyle(isVisible && backgroundIsVisible);
		}
		else { // already have styleprogram and element 
			if (style != null) {
				if (style.getUUID() != backgroundStyle.getUUID())
				{	// if is need another styleprogram
					if (isVisible && backgroundIsVisible) backgroundProgram.removeElement(backgroundElement);
					backgroundProgram = null;
					backgroundStyle = style;
					createBackgroundStyle(isVisible && backgroundIsVisible);
				} 
				else { // styleprogram is of same type
					backgroundStyle = style;
					backgroundElement.setStyle(style);
					if (isVisible && backgroundIsVisible) backgroundProgram.update(backgroundElement);
				}
			} 
			else { // remove style
				if (isVisible && backgroundIsVisible) backgroundProgram.removeElement(backgroundElement);
				backgroundStyle = null; backgroundProgram = null; backgroundElement = null;
			}
		}		
		return backgroundStyle;
	}
	public var backgroundIsVisible(default, set):Bool = true;
	inline function set_backgroundIsVisible(b:Bool):Bool {
		if (page != null && backgroundStyle != null) {
			if (b && !backgroundIsVisible) {
				if (backgroundElement == null) createBackgroundStyle(isVisible); // create new selectElement
				else if (isVisible) backgroundProgram.addElement(backgroundElement);
			}
			else if (!b && backgroundIsVisible && backgroundElement != null && isVisible) backgroundProgram.removeElement(backgroundElement);
		}
		return backgroundIsVisible = b;
	}	
	public inline function backgroundShow():Void backgroundIsVisible = true;
	public inline function backgroundHide():Void backgroundIsVisible = false;
	
	// -------- selection style ---------
	var selectionProgram:peote.ui.style.interfaces.StyleProgram = null;
	var selectionElement:peote.ui.style.interfaces.StyleElement = null;
	public var selectionStyle(default, set):Dynamic = null;
	//inline function set_selectionStyle(style:Dynamic):Dynamic {
	inline function set_selectionStyle(style:peote.ui.style.interfaces.Style):peote.ui.style.interfaces.Style {
//TODO:
/*		if (selectionElement == null) { // not added to Display yet
			selectionStyle = style;
			if (style != null && page != null) createSelectionMasked(isVisible && selectionIsVisible);
		}
		else { // already have styleprogram and element 
			if (style != null) {
				if (style.getUUID() != selectionStyle.getUUID()) { // if is need another styleprogram
					if (isVisible && selectionIsVisible) selectionProgram.removeElement(selectionElement);
					selectionProgram = null;
					selectionStyle = style;
					createSelectionMasked(isVisible && selectionIsVisible);
				} 
				else { // styleprogram is of same type
					selectionStyle = style;
					selectionElement.setStyle(style);
					if (isVisible && selectionIsVisible) selectionProgram.update(selectionElement);
				}
			} 
			else { // remove style
				if (isVisible && selectionIsVisible) selectionProgram.removeElement(selectionElement);
				selectionStyle = null; selectionProgram = null; selectionElement = null;
			}
		}		
*/		return selectionStyle;
	}	
	public var selectionIsVisible(default, set):Bool = false;
	inline function set_selectionIsVisible(b:Bool):Bool {
//TODO:
/*		if (page != null && selectionStyle != null) {
			if (b && !selectionIsVisible) {
				if (selectionElement == null) createSelectionMasked(isVisible); // create new selectElement
				else if (isVisible) selectionProgram.addElement(selectionElement);
			}
			else if (!b && selectionIsVisible && selectionElement != null && isVisible) selectionProgram.removeElement(selectionElement);
		}
*/		return selectionIsVisible = b;
	}	
	public inline function selectionShow():Void selectionIsVisible = true;
	public inline function selectionHide():Void selectionIsVisible = false;
	var selectFrom:Int = 0;
	var selectTo:Int = 0;	
	public function select(from:Int, to:Int):Void {
//TODO:
/*		if (from < 0) from = 0;
		if (to < 0) to = 0;
		if (from <= to) { selectFrom = from; selectTo = to;	} else { selectFrom = to; selectTo = from; }
		if (selectFrom == selectTo) selectionHide();
		else {
			if (page != null && selectionStyle != null) {
				if (selectTo > line.length) selectTo = line.length;
				setCreateSelectionMasked( (isVisible && selectionIsVisible), (selectionElement == null) );
			}
			selectionShow();
		}
*/	}
	public inline function hasSelection():Bool return (selectFrom != selectTo);
	public inline function removeSelection() { selectFrom = selectTo; selectionHide(); }
	
	// -------- cursor style ---------
	var cursorProgram:peote.ui.style.interfaces.StyleProgram = null;
	var cursorElement:peote.ui.style.interfaces.StyleElement = null;
	public var cursorStyle(default, set):Dynamic = null;
	//inline function set_cursorStyle(style:Dynamic):Dynamic {
	inline function set_cursorStyle(style:peote.ui.style.interfaces.Style):peote.ui.style.interfaces.Style {
		if (cursorElement == null) { // not added to Display yet
			cursorStyle = style;
			if (style != null && page != null) createCursorMasked(isVisible && cursorIsVisible);
		}
		else { // already have styleprogram and element 
			if (style != null) {
				if (style.getUUID() != cursorStyle.getUUID()) { // if is need another styleprogram
					if (isVisible && cursorIsVisible) cursorProgram.removeElement(cursorElement);
					cursorProgram = null;
					cursorStyle = style;
					createCursorMasked(isVisible && cursorIsVisible);
				} 
				else { // styleprogram is of same type
					cursorStyle = style;
					cursorElement.setStyle(style);
					if (isVisible && cursorIsVisible) cursorProgram.update(cursorElement);
				}
			} 
			else { // remove style
				if (isVisible && cursorIsVisible) cursorProgram.removeElement(cursorElement);
				cursorStyle = null; cursorProgram = null; cursorElement = null;
			}
		}		
		return cursorStyle;
	}		
	public var cursorIsVisible(default, set):Bool = false;
	inline function set_cursorIsVisible(b:Bool):Bool {
		if (page != null && cursorStyle != null) {
			if (b && !cursorIsVisible) {
				if (cursorElement == null) createCursorMasked(isVisible); // create new selectElement
				else if (isVisible) cursorProgram.addElement(cursorElement);
			}
			else if (!b && cursorIsVisible && cursorElement != null && isVisible) cursorProgram.removeElement(cursorElement);
		}
		return cursorIsVisible = b;
	}	
	public inline function cursorShow():Void cursorIsVisible = true;
	public inline function cursorHide():Void cursorIsVisible = false;
	public var cursor(default,set):Int = 0;
	inline function set_cursor(pos:Int):Int {
		if (pos != cursor) {
			if (pos < 0) cursor = 0;
			else if (page != null && pos > pageLine.length) cursor = pageLine.length;
			else cursor = pos;
			
			if (page != null && cursorStyle != null) {	
				setCreateCursorMasked( (isVisible && cursorIsVisible), (cursorElement == null) );
			}
		}
		return cursor;
	}
	
	var cursorWant = -1; // remember cursor if there is smaller lines by going up/down
	public var cursorLine(default,set):Int = 0;
	inline function set_cursorLine(pos:Int):Int {		
		if (pos != cursorLine) {
			if (pos < 0) cursorLine = 0;
			else if (page != null && pos >= page.length) cursorLine = page.length - 1;
			else cursorLine = pos;
			
			if (page != null) {
				pageLine = page.getPageLine(cursorLine);
				if (cursor > pageLine.length) {
					if (cursorWant == -1) cursorWant = cursor;
					cursor = pageLine.length;
				} 
				else if (cursorWant > 0) cursor = cursorWant;
				
				if (cursorStyle != null) setCreateCursorMasked( (isVisible && cursorIsVisible), (cursorElement == null) );
			}
		}
		return cursorLine;
	}
	
	// helpers (only for pages)
/*	public var cursorX(get,set):Int;
	inline function get_cursorX():Int return cursor;
	inline function set_cursorX(pos:Int):Int return set_cursor(pos);
	
	public var cursorY(get,set):Int;
	inline function get_cursorY():Int return cursorLine;
	inline function set_cursorY(pos:Int):Int return set_cursorLine(pos);
*/	
	
	// ---------- text ---------------	
	@:isVar public var text(get, set):String = null;
	inline function get_text():String {
		if (page == null) return text;
		else return fontProgram.pageGetChars(page);
	}
	inline function set_text(t:String):String {
		if (page == null || t == null) return text = t;
		else {
			setText(t);
			return t;
		}
	}
	
	// ----------------- aligning -----------
	var autoSize:Int = 3; // first bit is autoheight, second bit is autowidth
	public var autoWidth(get, set):Bool;
	inline function get_autoWidth():Bool return (autoSize & 2 > 0);
	inline function set_autoWidth(b:Bool):Bool {
		if (b) autoSize |= 2 else autoSize = autoSize & 1;
		return b;
	}
	public var autoHeight(get, set):Bool;
	inline function get_autoHeight():Bool return (autoSize & 1 > 0);
	inline function set_autoHeight(b:Bool):Bool {
		if (b) autoSize |= 1 else autoSize = autoSize & 2;
		return b;
	}
	
	public var hAlign:peote.ui.util.HAlign = peote.ui.util.HAlign.LEFT;
	public var vAlign:peote.ui.util.VAlign = peote.ui.util.VAlign.TOP;
	
	public var xOffset:Float = 0;
	public var yOffset:Float = 0;

	public var leftSpace:Int = 0;
	public var rightSpace:Int = 0;
	public var topSpace:Int = 0;
	public var bottomSpace:Int = 0;	
	
	#if (!peoteui_no_textmasking && !peoteui_no_masking)
	var maskElement:peote.text.MaskElement;
	#end
	
	public function new(xPosition:Int, yPosition:Int, ?textSize:peote.ui.util.TextSize, zIndex:Int = 0, text:String,
	                    //font:$fontType, fontStyle:$styleType) 
	                    font:peote.text.Font<$styleType>, ?fontStyle:$styleType, ?textStyle:peote.ui.style.TextStyle) //textStyle=null
	{
		//trace("NEW UITextPage");		
		var width:Int = 0;
		var height:Int = 0;
		if (textSize != null) {
			if (textSize.height != null) { height = textSize.height; autoHeight = false; }
			if (textSize.width  != null) { width  = textSize.width;  autoWidth  = false; }
			if (textSize.hAlign != null) hAlign = textSize.hAlign;
			if (textSize.vAlign != null) vAlign = textSize.vAlign;
			if (textSize.xOffset != null) xOffset = textSize.xOffset;
			if (textSize.yOffset != null) yOffset = textSize.yOffset;
			if (textSize.leftSpace != null)  leftSpace  = textSize.leftSpace;
			if (textSize.rightSpace != null) rightSpace = textSize.rightSpace;
			if (textSize.topSpace != null) topSpace = textSize.topSpace;
			if (textSize.bottomSpace != null) bottomSpace = textSize.bottomSpace;
		}
		
		super(xPosition, yPosition, width, height, zIndex);
		
		this.text = text;
		this.font = font;
		
		if (fontStyle == null) fontStyle = font.createFontStyle();
		this.fontStyle = fontStyle;
		
		// TODO !!!
		${switch (glyphStyleHasField.local_zIndex) {
			case true: macro fontStyle.zIndex = zIndex;
			default: macro {}
		}}
		
		if (textStyle != null) {
			if (textStyle.backgroundStyle != null) backgroundStyle = textStyle.backgroundStyle;
			if (textStyle.selectionStyle != null) selectionStyle = textStyle.selectionStyle;
			cursorStyle = textStyle.cursorStyle;
		}
	}
	
	inline function getAlignedXOffset(_xOffset:Float):Float
	{
		return (autoWidth) ? _xOffset : switch (hAlign) {
			case peote.ui.util.HAlign.CENTER: (width - leftSpace - rightSpace - page.textWidth) / 2 + _xOffset;
			case peote.ui.util.HAlign.RIGHT: width - leftSpace - rightSpace - page.textWidth + _xOffset;
			default: _xOffset;
		}
	}
	
	inline function getAlignedYOffset(_yOffset:Float):Float
	{
		return (autoHeight) ? _yOffset : switch (vAlign) {
			case peote.ui.util.VAlign.CENTER: (height - topSpace - bottomSpace - page.textHeight) / 2 + _yOffset;
			case peote.ui.util.VAlign.BOTTOM: height - topSpace - bottomSpace - page.textHeight + _yOffset;
			default: _yOffset;
		}
	}
	
/*	inline function createSelectionMasked(addUpdate:Bool) setCreateSelectionMasked(addUpdate, true);
	inline function setCreateSelectionMasked(addUpdate:Bool, create:Bool) 
	{
		var _x = x + leftSpace;
		var _y = y + topSpace;
		var _width  = width  - leftSpace - rightSpace;
		var _height = height - topSpace - bottomSpace;
		#if (!peoteui_no_textmasking && !peoteui_no_masking)
		if (masked) {
			if (maskX > leftSpace) _x = x + maskX;
			if (maskY > topSpace ) _y = y + maskY;
			if (x + maskX + maskWidth  < _x + _width ) _width  = maskX + maskWidth  + x - _x;
			if (y + maskY + maskHeight < _y + _height) _height = maskY + maskHeight + y - _y;
		}
		#end
		_setCreateSelection(_x, _y, _width, _height, getAlignedYOffset(yOffset) + topSpace, addUpdate, create);
	}
	inline function createSelection(x:Int, y:Int, w:Int, h:Int, y_offset:Float, addUpdate:Bool) _setCreateSelection(x, y, w, h, y_offset, addUpdate, true);
	inline function setSelection(x:Int, y:Int, w:Int, h:Int, y_offset:Float, addUpdate:Bool) _setCreateSelection(x, y, w, h, y_offset, addUpdate, false);
	inline function _setCreateSelection(_x:Int, _y:Int, _width:Int, _height:Int, y_offset:Float, addUpdate:Bool, create:Bool)
	{		
		var selectX = Math.round(getPositionAtChar(selectFrom));
		var selectWidth = Math.round(getPositionAtChar(selectTo) - selectX);
		var selectY = Math.round(y + y_offset);
		var selectHeight = Math.round(line.height);
		var mx = 0; var my = 0; var mw = selectWidth; var mh = selectHeight;
		
		#if (!peoteui_no_textmasking && !peoteui_no_masking)
		if (selectX < _x) { mw -= (_x - selectX); mx = _x - selectX; if (mw > _width) mw = _width; }
		else if (selectX + selectWidth > _x + _width) mw = _x + _width - selectX;
		if (mw < 0) mw = 0;
		if (selectY < _y) { mh -= (_y - selectY); my = _y - selectY; if (mh > _height) mh = _height; }
		else if (selectY + selectHeight > _y + _height) mh = _y + _height - selectY;
		if (mh < 0) mh = 0;
		#end
		if (create)	{
			createSelectionStyle(selectX, selectY, selectWidth, selectHeight, mx, my, mw, mh, z); // TODO zIndex
			if (addUpdate) selectionProgram.addElement(selectionElement);
		}
		else {
			selectionElement.setMasked(this, selectX, selectY, selectWidth, selectHeight, mx, my, mw, mh, z); // TODO zIndex
			if (addUpdate) selectionProgram.update(selectionElement);
		}
	}
*/	
	inline function createCursorMasked(addUpdate:Bool) setCreateCursorMasked(addUpdate, true);
	inline function setCreateCursorMasked(addUpdate:Bool, create:Bool) 
	{
		var _x = x + leftSpace;
		var _y = y + topSpace;
		var _width  = width  - leftSpace - rightSpace;
		var _height = height - topSpace - bottomSpace;
		#if (!peoteui_no_textmasking && !peoteui_no_masking)
		if (masked) {
			if (maskX > leftSpace) _x = x + maskX;
			if (maskY > topSpace ) _y = y + maskY;
			if (x + maskX + maskWidth  < _x + _width ) _width  = maskX + maskWidth  + x - _x;
			if (y + maskY + maskHeight < _y + _height) _height = maskY + maskHeight + y - _y;
		}
		#end
		_setCreateCursor(_x, _y, _width, _height, getAlignedYOffset(yOffset) + topSpace, addUpdate, create);
	}
	inline function createCursor(x:Int, y:Int, w:Int, h:Int, y_offset:Float, addUpdate:Bool) _setCreateCursor(x, y, w, h, y_offset, addUpdate, true);
	inline function setCursor(x:Int, y:Int, w:Int, h:Int, y_offset:Float, addUpdate:Bool) _setCreateCursor(x, y, w, h, y_offset, addUpdate, false);
	inline function _setCreateCursor(_x:Int, _y:Int, _width:Int, _height:Int, y_offset:Float, addUpdate:Bool, create:Bool)
	{
		_width += 3; // TODO: fix for cursor at line-end

		var cx = Math.round(getPositionAtChar(cursor));
		var cw = 2; // TODO: make customizable
		var cy = Math.round(getPositionAtLine(cursorLine));
		var ch = Math.round(pageLine.height);
		var mx = 0; var my = 0; var mw = cw; var mh = ch;
		
		#if (!peoteui_no_textmasking && !peoteui_no_masking)
		if (cx < _x) { mw -= (_x - cx); mx = _x - cx; if (mw > _width) mw = _width; }
		else if (cx + cw > _x + _width) mw = _x + _width - cx;
		if (mw < 0) mw = 0;
		if (cy < _y) { mh -= (_y - cy); my = _y - cy; if (mh > _height) mh = _height; }
		else if (cy + ch > _y + _height) mh = _y + _height - cy;
		if (mh < 0) mh = 0;
		#end
		if (create)	{
			createCursorStyle(cx, cy, cw, ch, mx, my, mw, mh, z); // TODO zIndex
			if (addUpdate) cursorProgram.addElement(cursorElement);
		}
		else {
			cursorElement.setMasked(this, cx, cy, cw, ch, mx, my, mw, mh, z); // TODO zIndex
			if (addUpdate) cursorProgram.update(cursorElement);
		}
	}
	
	override inline function updateVisibleStyle()
	{
		if (page != null)
		{
			fontProgram.pageSetStyle(page, fontStyle);		
			if (isVisible) fontProgram.pageUpdate(page);
			
			if (backgroundElement != null) {
				backgroundElement.setStyle(backgroundStyle);
				if (isVisible && backgroundIsVisible) backgroundProgram.update(backgroundElement);
			}
//TODO:		
/*			if (selectionElement != null) {
				selectionElement.setStyle(selectionStyle);		
				if (isVisible && selectionIsVisible) selectionProgram.update(selectionElement);
			}
*/			if (cursorElement != null) {
				cursorElement.setStyle(cursorStyle);		
				if (isVisible && cursorIsVisible) cursorProgram.update(cursorElement);
			}
		}
	}
		
	override inline function updateVisibleLayout():Void
	{
		if (page != null) updatePageLayout(false);
	}
		
	override inline function updateVisible():Void // updates style and layout
	{
		if (page != null) updatePageLayout(true);
	}
		
	inline function updatePageLayout(updateStyle:Bool, updateBgMaskSelCursor:Bool = true,
		pageUpdatePosition:Bool = true, pageUpdateSize:Bool = true, pageUpdateXOffset:Bool = true, pageUpdateYOffset:Bool = true):Void
	{
		if (updateStyle) fontProgram.pageSetStyle(page, fontStyle, isVisible);
		
		if (autoSize > 0) { // auto aligning width and height to textsize
			if (autoWidth)  width  = Std.int(page.textWidth)  + leftSpace + rightSpace;
			if (autoHeight) height = Std.int(page.textHeight) + topSpace  + bottomSpace;
			updatePickable(); // fit interactive pickables to new width and height
		}
			
		var _x = x + leftSpace;
		var _y = y + topSpace;
		var _width  = width  - leftSpace - rightSpace;
		var _height = height - topSpace - bottomSpace;		
		var y_offset:Float = getAlignedYOffset(yOffset);
		
		//fontProgram.pageSetPositionSize(page, _x, _y, _width, _height, getAlignedXOffset(xOffset), y_offset, isVisible);
		if (pageUpdatePosition && pageUpdateSize)
			fontProgram.pageSetPositionSize(page, _x, _y, _width, _height, (pageUpdateXOffset) ? getAlignedXOffset(xOffset) : null, (pageUpdateYOffset) ? y_offset : null, isVisible);
		else if (pageUpdatePosition)
			fontProgram.pageSetPosition(page, _x, _y, (pageUpdateXOffset) ? getAlignedXOffset(xOffset) : null, (pageUpdateYOffset) ? y_offset : null, isVisible);
		else if (pageUpdateSize) 
			fontProgram.pageSetSize(page, _width, _height, (pageUpdateXOffset) ? getAlignedXOffset(xOffset) : null, (pageUpdateYOffset) ? y_offset : null, isVisible);
		else
			fontProgram.pageSetOffset(page, (pageUpdateXOffset) ? getAlignedXOffset(xOffset) : null, (pageUpdateYOffset) ? y_offset : null, isVisible);
		
		if (isVisible) {
			// TODO: optimize setting z-index in depend of styletyp and better allways adding fontprograms at end of uiDisplay (onAddVisibleToDisplay)
			${switch (glyphStyleHasField.local_zIndex) {
				case true: macro {
					if (fontStyle.zIndex != z) {
						fontStyle.zIndex = z;
//TODO:					fontProgram.pageSetStyle(page, fontStyle);
					}
				}
				default: macro {}
			}}		
			fontProgram.pageUpdate(page);
		}
				
		if (updateBgMaskSelCursor) 
		{
			#if (!peoteui_no_textmasking && !peoteui_no_masking)
			if (masked) {
				if (maskX > leftSpace) _x = x + maskX;
				if (maskY > topSpace ) _y = y + maskY;
				if (x + maskX + maskWidth  < _x + _width ) _width  = maskX + maskWidth  + x - _x;
				if (y + maskY + maskHeight < _y + _height) _height = maskY + maskHeight + y - _y;
			}
			fontProgram.setMask(maskElement, _x, _y, _width, _height, isVisible);
			#end
			
			if (backgroundElement != null) {
				if (updateStyle) backgroundElement.setStyle(backgroundStyle);
				backgroundElement.setLayout(this);
				if (isVisible && backgroundIsVisible) backgroundProgram.update(backgroundElement);
			}
//TODO:		
			//if (selectionElement != null) {
				//if (updateStyle) selectionElement.setStyle(selectionStyle);
				//setSelection(_x, _y, _width, _height, y_offset + topSpace, (isVisible && selectionIsVisible));
			//}
			if (cursorElement != null) {
				if (updateStyle) cursorElement.setStyle(cursorStyle);
				setCursor(_x, _y, _width, _height, y_offset + topSpace, (isVisible && cursorIsVisible));
			}
		}
	}
	
	override inline function onAddVisibleToDisplay()
	{
		trace("onAddVisibleToDisplay()", autoWidth, autoHeight);		
		if (page != null) {
			#if (!peoteui_no_textmasking && !peoteui_no_masking)
			fontProgram.addMask(maskElement);
			#end			
			if (backgroundIsVisible && backgroundElement != null) backgroundProgram.addElement(backgroundElement);			
//TODO:		if (selectionIsVisible && selectionElement != null) selectionProgram.addElement(selectionElement);			
			if (cursorIsVisible && cursorElement != null) cursorProgram.addElement(cursorElement);
			fontProgram.pageAdd(page);
		} 
		else {
			createFontStyle();			
			// TODO fontStyle.zIndex;
/*			${switch (glyphStyleHasField.local_zIndex) {
				case true: macro {
					if (fontStyle.zIndex != z) {
						fontStyle.zIndex = z;
						fontProgram.pageSetStyle(page, fontStyle);
					}
				}
				default: macro {}
			}}		
*/			
			page = fontProgram.createPage(text, x, y, (autoWidth) ? null : width, (autoHeight) ? null : height, xOffset, yOffset, fontStyle);
			
			if (cursorLine >= page.length) cursorLine = page.length - 1;
			pageLine = page.getPageLine(cursorLine);
			if (cursor > pageLine.length) cursor = pageLine.length;
			
			text = null; // let GC clear the string (can be get back by fontProgram)
			if (autoSize > 0) { // auto aligning width and height to textsize
				if (autoWidth)  width  = Std.int(page.textWidth)  + leftSpace + rightSpace;
				if (autoHeight) height = Std.int(page.textHeight) + topSpace + bottomSpace;
				if ( hasMoveEvent  != 0 ) pickableMove.update(this);
				if ( hasClickEvent != 0 ) pickableClick.update(this);
			}
			
			var _x = x + leftSpace;
			var _y = y + topSpace;
			var _width  = width  - leftSpace - rightSpace;
			var _height = height - topSpace - bottomSpace;
			
			var y_offset:Float = getAlignedYOffset(yOffset);
			
			fontProgram.pageSetPositionSize(page, _x, _y, _width, _height, getAlignedXOffset(xOffset), y_offset, isVisible);
			fontProgram.pageUpdate(page);
			
			#if (!peoteui_no_textmasking && !peoteui_no_masking)
			if (masked) {
				if (maskX > leftSpace) _x = x + maskX;
				if (maskY > topSpace ) _y = y + maskY;
				if (x + maskX + maskWidth  < _x + _width ) _width  = maskX + maskWidth  + x - _x;
				if (y + maskY + maskHeight < _y + _height) _height = maskY + maskHeight + y - _y;
			}
			maskElement = fontProgram.createMask(_x, _y, _width, _height);
			#end	
			
			if (backgroundStyle != null) createBackgroundStyle(backgroundIsVisible);
//TODO:		if (selectionStyle != null) createSelection(_x, _y, _width, _height, y_offset + topSpace, selectionIsVisible);
			if (cursorStyle != null) createCursor(_x, _y, _width, _height, y_offset + topSpace, cursorIsVisible);
		}		
	}
	
	override inline function onRemoveVisibleFromDisplay()
	{
		//trace("onRemoveVisibleFromDisplay()");
		fontProgram.pageRemove(page);
		#if (!peoteui_no_textmasking && !peoteui_no_masking)
		fontProgram.removeMask(maskElement);
		#end		
		if (backgroundIsVisible && backgroundElement != null) backgroundProgram.removeElement(backgroundElement);
//TODO:	if (selectionIsVisible && selectionElement != null) selectionProgram.removeElement(selectionElement);
		if (cursorIsVisible && cursorElement != null) cursorProgram.removeElement(cursorElement);
	}

	
	inline function createFontStyle()
	{
		var fontStylePos = uiDisplay.usedStyleID.indexOf( fontStyle.getUUID() );
		if (fontStylePos < 0) {
			if (uiDisplay.autoAddStyles) uiDisplay.autoAddStyleProgram( cast fontProgram = font.createFontProgram(fontStyle, #if (peoteui_no_textmasking || peoteui_no_masking) false #else true #end, 1024, 1024, true), fontStyle.getUUID(), true );
			else throw('Error by creating new UITextPage. The style "'+Type.getClassName(Type.getClass(fontStyle))+'" id='+fontStyle.id+' is not inside the availableStyle list of UIDisplay.');
		} else {
			fontProgram = cast uiDisplay.usedStyleProgram[fontStylePos];
			if (fontProgram == null) uiDisplay.addProgramAtStylePos(cast fontProgram = font.createFontProgram(fontStyle, #if (peoteui_no_textmasking || peoteui_no_masking) false #else true #end, 1024, 1024, true), fontStylePos);
		}
	}
	
	inline function createBackgroundStyle(addUpdate:Bool)
	{
		var stylePos = uiDisplay.usedStyleID.indexOf( backgroundStyle.getUUID() );
		if (stylePos < 0) {
			if (uiDisplay.autoAddStyles) uiDisplay.autoAddStyleProgram(cast backgroundProgram = backgroundStyle.createStyleProgram(), backgroundStyle.getUUID() );
			else throw('Error by creating background for new UITextPage. The style "'+Type.getClassName(Type.getClass(backgroundStyle))+'" id='+backgroundStyle.id+' is not inside the availableStyle list of UIDisplay.');
		} else {
			backgroundProgram = cast uiDisplay.usedStyleProgram[stylePos];
			if (backgroundProgram == null) uiDisplay.addProgramAtStylePos(cast backgroundProgram = backgroundStyle.createStyleProgram(), stylePos);				
		}
		backgroundElement = backgroundProgram.createElement(this, backgroundStyle);
		if (addUpdate) backgroundProgram.addElement(backgroundElement);
	}
	
	inline function createSelectionStyle(x:Int, y:Int, w:Int, h:Int, mx:Int, my:Int, mw:Int, mh:Int, z:Int)
	{	//trace("createSelectionStyle");
		var stylePos = uiDisplay.usedStyleID.indexOf( selectionStyle.getUUID() );
		if (stylePos < 0) {
			if (uiDisplay.autoAddStyles) uiDisplay.autoAddStyleProgram(cast selectionProgram = selectionStyle.createStyleProgram(), selectionStyle.getUUID());
			else throw('Error by creating selection for new UITextPage. The style "'+Type.getClassName(Type.getClass(selectionStyle))+'" id='+selectionStyle.id+' is not inside the availableStyle list of UIDisplay.');
		} else {
			selectionProgram = cast uiDisplay.usedStyleProgram[stylePos];
			if (selectionProgram == null) uiDisplay.addProgramAtStylePos(cast selectionProgram = selectionStyle.createStyleProgram(), stylePos);				
		}
		selectionElement = selectionProgram.createElementAt(this, x, y, w, h, mx, my, mw, mh, z, selectionStyle);
	}
		
	inline function createCursorStyle(x:Int, y:Int, w:Int, h:Int, mx:Int, my:Int, mw:Int, mh:Int, z:Int)
	{	//trace("createCursorStyle");
		var stylePos = uiDisplay.usedStyleID.indexOf( cursorStyle.getUUID() );
		if (stylePos < 0) {
			if (uiDisplay.autoAddStyles) uiDisplay.autoAddStyleProgram(cast cursorProgram = cursorStyle.createStyleProgram(), cursorStyle.getUUID() );
			else throw('Error by creating cursor for new UITextPage. The style "'+Type.getClassName(Type.getClass(cursorStyle))+'" id='+cursorStyle.id+' is not inside the availableStyle list of UIDisplay.');
		} else {
			cursorProgram = cast uiDisplay.usedStyleProgram[stylePos];
			if (cursorProgram == null) uiDisplay.addProgramAtStylePos(cast cursorProgram = cursorStyle.createStyleProgram(), stylePos);				
		}
		cursorElement = cursorProgram.createElementAt(this, x, y, w, h, mx, my, mw, mh, z, cursorStyle);
	}

	
	// -------------------------------------------------------
	// ------------------- Input Focus -----------------------
	// -------------------------------------------------------

	public inline function setInputFocus(e:peote.ui.event.PointerEvent=null, setCursor:Bool = false):Void {
		peote.ui.interactive.input2action.InputTextPage.focusElement = this;
		if (uiDisplay != null) uiDisplay.setInputFocus(this, e);
		if (setCursor) setCursorToPointer(e);
		cursorShow();
	}
	
	public inline function removeInputFocus() {
		if (uiDisplay != null) uiDisplay.removeInputFocus(this);
		cursorHide();
	}
	
	// -------------------------------------------------------
	// -----------Keyboard Input and Input2Action ------------
	// -------------------------------------------------------
	
	public var input2Action:input2action.Input2Action = null;

	// for the interface InputFocus 
	@:access(input2action.Input2Action)
	public inline function keyDown(keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void
	{
		//trace("key DOWN");
		//switch (keyCode) {
			//default:
		//}		
		if (input2Action != null) input2Action.keyDown(keyCode, modifier);
		else peote.ui.interactive.input2action.InputTextPage.input2Action.keyDown(keyCode, modifier);
	}
	
	@:access(input2action.Input2Action)
	public inline function keyUp(keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void
	{
		//trace("key UP");
		//switch (keyCode) {
			//default:
		//}
		if (input2Action != null) input2Action.keyUp(keyCode, modifier);
		else peote.ui.interactive.input2action.InputTextPage.input2Action.keyUp(keyCode, modifier);
	}
	
	
	// -------------------------------------------------------
	// --------------- Cursor and Selection ------------------
	// -------------------------------------------------------
	
	public function setCursorToPointer(e:peote.ui.event.PointerEvent):Void {
		if (uiDisplay != null) {
			cursorLine = getLineAtPosition(e.y);
			cursor = getCharAtPosition(e.x);
			cursorWant = -1;
		}
	}
	
	// ----------- Selection Events -----------
	
	public function startSelection(e:peote.ui.event.PointerEvent):Void {
		if (uiDisplay != null) uiDisplay.startSelection(this, e);
	}
	
	public function stopSelection(e:peote.ui.event.PointerEvent = null):Void {
		if (uiDisplay != null) uiDisplay.stopSelection(this, e);
	}
	
	// select-handler what is called by PeoteUIDisplay
	
	var selectStartFrom:Int = 0;
	var xOffsetAtSelectStart:Float = 0;
		
	function onSelectStart(e:peote.ui.event.PointerEvent):Void {
		trace("selectStart", xOffset);
/*		removeSelection();
		selectStartFrom = cursor = getCharAtPosition(e.x);
		xOffsetAtSelectStart = xOffset;
		selectionHide();
*/	}
	
	function onSelectStop(e:peote.ui.event.PointerEvent = null):Void {
		trace("selectStop", (e != null) ? e.x : "", xOffset);
	}
	
	function onSelect(e:peote.ui.event.PointerEvent):Void {
/*		if (localX(e.x) < leftSpace) {
			if (localX(e.x) < getAlignedXOffset(leftSpace) + xOffsetAtSelectStart) {
				xOffset = Math.max(- getAlignedXOffset(0), xOffsetAtSelectStart);
			}
			else xOffset = leftSpace - localX(e.x) + xOffsetAtSelectStart;
			updateLineLayout(false); // OPTIMIZING: not for the background!
		}
		else if (localX(e.x) > width - rightSpace) {
			if ( localX(e.x) > getAlignedXOffset(page.textWidth + leftSpace  + xOffsetAtSelectStart ) ) {
				xOffset = Math.min(-getAlignedXOffset(Math.floor(page.textWidth) - width + leftSpace + rightSpace), xOffsetAtSelectStart);
			} 
			else xOffset = width - localX(e.x) - rightSpace  + xOffsetAtSelectStart;
			updateLineLayout(false); // OPTIMIZING: not for the background!
		}
		else if (xOffset != xOffsetAtSelectStart) {
			xOffset = xOffsetAtSelectStart;
			updateLineLayout(false); // OPTIMIZING: not for the background!
		}
		cursor = getCharAtPosition(e.x);
		select( selectStartFrom, cursor );
		// TODO: detect the char left right while xOffset changes at the border
		//       OR allways change xScroll to make cursor fully visible!
*/	}

	
	// -----------------------------------------------------
	// ------------------- TextInput -----------------------
	// -----------------------------------------------------

	// ----------------------- change the text  -----------------------	
	public function setText(text:String, fontStyle:Null<$styleType> = null, forceAutoWidth:Null<Bool> = null, forceAutoHeight:Null<Bool> = null, autoUpdate = false)
	{
		if (fontStyle != null) this.fontStyle = fontStyle;
		
		if (forceAutoWidth != null)  autoWidth  = forceAutoWidth;
		if (forceAutoHeight != null) autoHeight = forceAutoHeight;
		
		if (page != null) {
			fontProgram.pageSet(page, text, x, y, (autoWidth) ? null : width, (autoHeight) ? null : height, xOffset, yOffset, this.fontStyle, null, isVisible);			
			if (cursorLine >= page.length) cursorLine = page.length - 1;
			pageLine = page.getPageLine(cursorLine);
			if (cursor > pageLine.length) cursor = pageLine.length;
// TODO:
			//if (selectTo > line.length) selectTo = line.length;
			
			if (autoUpdate) updateTextOnly();
		} 
		else this.text = text;
	}
	
	public inline function textInput(chars:String):Void {
		if (page == null) return;
			
		//var oldCursor = cursor;
		
		if (hasSelection()) {
// TODO: selection !
			//fontProgram.pageDeleteChars(line, selectFrom, selectTo, isVisible);
			//oldCursor = selectFrom;
			//oldLine = selectLineFrom;
			//removeSelection();
		}
			
// TODO:
		if (chars.length == 1 && chars != "\n") {
			insertChars(chars, cursorLine, cursor, fontStyle);
			cursor++;
		}
		else {
			var restCharLength = pageLine.length - cursor;
			var oldPageLength = page.length;
			
			insertChars(chars, cursorLine, cursor, fontStyle);
			
			//trace("restCharLength",restCharLength);
			if (page.length > oldPageLength) {
				cursorLine += page.length - oldPageLength;
				cursor = pageLine.length - restCharLength;
			} 
			else cursor += chars.length;
			
		}
		
		updateTextOnly();
	}

	inline function updateTextOnly()
	{
		if (autoWidth && autoHeight) updatePageLayout(false, true, false, true, false, false); // change bg, mask, selection and cursor and only line-size
		else {
			if (hAlign == peote.ui.util.HAlign.LEFT && vAlign == peote.ui.util.VAlign.TOP && isVisible) fontProgram.pageUpdate(page);
			else updatePageLayout(false, false, false, false, !autoWidth, !autoHeight); // change only line-offset
		}
	}
	
	// --------------------------------
	// ------------ ACTIONS -----------
	// --------------------------------
		
	public inline function deleteChar()
	{
		if (page == null) return;
		if (hasSelection()) {
// TODO
			//fontProgram.pageDeleteChars(page, select_from, select_to, isVisible);
			//updateTextOnly();
		}
		else if (cursorLine < page.length || cursor < pageLine.length) {
			fontProgram.pageDeleteChar(page, pageLine, cursorLine, cursor, isVisible);
			if (cursor == pageLine.length && pageLine.length == 0) pageLine = page.getPageLine(cursorLine); // after deleting an empty pageline
			updateTextOnly();
		}
	}
	
	public inline function backspace()
	{
		if (page == null) return;
		if (hasSelection()) {
			//fontProgram.pageDeleteChars(page, select_from, select_to, isVisible);
			//updateTextOnly();
		}
		else {
			if (cursor == 0) {
				if (cursorLine > 0) {
					cursorLine--;
					cursor = pageLine.length;
					cursorWant = -1;
					fontProgram.pageRemoveLinefeed(page, pageLine, cursorLine, isVisible);
					if (pageLine.length == 0) pageLine = page.getPageLine(cursorLine); // after deleting an empty pageline
					updateTextOnly();
				}
			}
			else {
				cursor--;
				cursorWant = -1;
				fontProgram.pageDeleteChar(page, pageLine, cursorLine, cursor, isVisible);
				if (cursor == pageLine.length && pageLine.length == 0) pageLine = page.getPageLine(cursorLine); // after deleting an empty pageline
				updateTextOnly();
			}
		}
	}
	
	public inline function tabulator()
	{
		textInput("\t");
	}
	
	public inline function enter()
	{
		if (hasSelection()) {
			//deleteChars(select_from, select_to); 
		}
		else {
			fontProgram.pageAddLinefeedAt(page, pageLine, cursorLine, cursor, isVisible);
			cursorLine++;
			cursor = 0;
			cursorWant = -1;
		}
		updateTextOnly();
	}
	
	public function copyToClipboard() {
		trace("copyToClipboard");
		// TODO: Selection
	}
	
	public function pasteFromClipboard() {
		#if !html5
			if (lime.system.Clipboard.text != null) textInput(lime.system.Clipboard.text);
		#end		
	}

	public inline function cursorLeft()
	{
		if (hasSelection()) { cursor = selectFrom; removeSelection(); }
		else if (cursor == 0) {
			if (cursorLine > 0) {
				cursorLine--;
				cursor = pageLine.length;
			}
		}
		else cursor--;
		cursorWant = -1;
	}

	public inline function cursorRight()
	{
		if (hasSelection()) { cursor = selectTo; removeSelection(); }
		else if (cursor == pageLine.length) {
			if (cursorLine < page.length-1) {
				cursorLine++;
				cursor = 0;
			}
		}
		else cursor++;
		cursorWant = -1;
	}

	public inline function cursorUp()
	{
		if (hasSelection()) removeSelection();
		cursorLine--;
	}

	public inline function cursorDown()
	{
		if (hasSelection()) removeSelection();
		cursorLine++;
	}
	
	
	
	// ----------------------- delegated methods from FontProgram -----------------------

	public inline function setStyle(glyphStyle:$styleType, fromLine:Int = 0, fromPosition:Int = 0, ?toLine:Null<Int>, ?toPosition:Null<Int>) {
		fontStyle = glyphStyle;
		fontProgram.pageSetStyle(page, fontStyle, fromLine, fromPosition, toLine, toPosition, isVisible);
	}
	
/*	public inline function setChar(charcode:Int, position:Int = 0, glyphStyle:$styleType = null) {
		fontProgram.pageSetChar(page, pageLine, charcode, position, glyphStyle, isVisible);
	}
	
	public inline function setChars(chars:String, position:Int = 0, glyphStyle:$styleType = null) {
		fontProgram.pageSetChars(page, chars, position, glyphStyle, isVisible);		
	}
	
*/	
	inline function pageLineInsertChar(chars:String, position:Int = 0, glyphStyle:$styleType = null) {		
		//fontProgram.pageInsertChar(page, pageLine, chars, lineNumber, position, glyphStyle, isVisible);
	}
	
	public inline function insertChars(chars:String, lineNumber:Int = 0, position:Int = 0, glyphStyle:$styleType = null) {		
		fontProgram.pageInsertChars(page, chars, lineNumber, position, glyphStyle, isVisible);
	}
	
/*	public inline function appendChars(chars:String, glyphStyle:$styleType = null) {		
		fontProgram.lineAppendChars(line, chars, glyphStyle, isVisible); 
	}
*/
	public inline function deleteCharAt(lineNumber:Int = 0, position:Int = 0) {
		fontProgram.pageDeleteChar(page, lineNumber, position, isVisible);
	}

/*	public inline function deleteChars(from:Int = 0, to:Null<Int> = null) {
		fontProgram.lineDeleteChars(line, from, to, isVisible);
	}
	
	public inline function cutChars(from:Int = 0, to:Null<Int> = null):String {
		return fontProgram.lineCutChars(line, from, to, isVisible);
	}
*/	
	public inline function getPositionAtChar(position:Int):Float {
		return fontProgram.pageGetPositionAtChar(page, pageLine, position);
	}
	
	public inline function getPositionAtLine(lineNumber:Int):Float {
		return fontProgram.pageGetPositionAtLine(page, lineNumber);
	}
	
	public inline function getCharAtPosition(xPosition:Float):Int {
		return fontProgram.pageGetCharAtPosition(page, pageLine, xPosition);
	}
	
	public inline function getLineAtPosition(yPosition:Float):Int {
		return fontProgram.pageGetLineAtPosition(page, yPosition);
	}
	

	
	// ----------- events ------------------
	
	public var onPointerOver(never, set):UITextPage<$styleType>->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerOver(f:UITextPage<$styleType>->peote.ui.event.PointerEvent->Void):UITextPage<$styleType>->peote.ui.event.PointerEvent->Void
		return setOnPointerOver(this, f);
	
	public var onPointerOut(never, set):UITextPage<$styleType>->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerOut(f:UITextPage<$styleType>->peote.ui.event.PointerEvent->Void):UITextPage<$styleType>->peote.ui.event.PointerEvent->Void 
		return setOnPointerOut(this, f);
	
	public var onPointerMove(never, set):UITextPage<$styleType>->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerMove(f:UITextPage<$styleType>->peote.ui.event.PointerEvent->Void):UITextPage<$styleType>->peote.ui.event.PointerEvent->Void
		return setOnPointerMove(this, f);
	
	public var onPointerDown(never, set):UITextPage<$styleType>->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerDown(f:UITextPage<$styleType>->peote.ui.event.PointerEvent->Void):UITextPage<$styleType>->peote.ui.event.PointerEvent->Void
		return setOnPointerDown(this, f);
	
	public var onPointerUp(never, set):UITextPage<$styleType>->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerUp(f:UITextPage<$styleType>->peote.ui.event.PointerEvent->Void):UITextPage<$styleType>->peote.ui.event.PointerEvent->Void
		return setOnPointerUp(this, f);
	
	public var onPointerClick(never, set):UITextPage<$styleType>->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerClick(f:UITextPage<$styleType>->peote.ui.event.PointerEvent->Void):UITextPage<$styleType>->peote.ui.event.PointerEvent->Void
		return setOnPointerClick(this, f);
		
	public var onMouseWheel(never, set):UITextPage<$styleType>->peote.ui.event.WheelEvent->Void;
	inline function set_onMouseWheel(f:UITextPage<$styleType>->peote.ui.event.WheelEvent->Void):UITextPage<$styleType>->peote.ui.event.WheelEvent->Void 
		return setOnMouseWheel(this, f);
				
	public var onDrag(never, set):UITextPage<$styleType>->Float->Float->Void;
	inline function set_onDrag(f:UITextPage<$styleType>->Float->Float->Void):UITextPage<$styleType>->Float->Float->Void
		return setOnDrag(this, f);
	
	public var onFocus(never, set):UITextPage<$styleType>->Void;
	inline function set_onFocus(f:UITextPage<$styleType>->Void):UITextPage<$styleType>->Void
		return setOnFocus(this, f);
	
}

// -------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------
			
			Context.defineModule(classPackage.concat([className]).join('.'),[c]);
		}
		return TPath({ pack:classPackage, name:className, params:[] });
	}
}
#end
