package peote.ui.interactive;

#if !macro
@:genericBuild(peote.ui.interactive.UITextPage.UITextPageMacro.build("UITextPage"))
class UITextPage<T> extends peote.ui.interactive.Interactive {}
#else

import haxe.macro.Expr;
import haxe.macro.Context;
import peote.text.util.Macro;

class UITextPageMacro
{
	static public function build(name:String):ComplexType return Macro.build(name, buildClass);
	static public function buildClass(className:String, classPackage:Array<String>, stylePack:Array<String>, styleModule:String, styleName:String, styleSuperModule:String, styleSuperName:String, styleType:ComplexType, styleField:Array<String>):ComplexType
	{
		className += Macro.classNameExtension(styleName, styleModule);
		var fullyQualifiedName:String = classPackage.concat([className]).join('.');

		if ( !Macro.typeAlreadyGenerated(fullyQualifiedName) )
		{	
			Macro.debug(className, classPackage, stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType, styleField);
			
			//var glyphType = peote.text.Glyph.GlyphMacro.buildClass("Glyph", ["peote","text"], stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType);
			var uiTextPageType:ComplexType =  TPath({ pack:classPackage, name:"UITextPage" + Macro.classNameExtension(styleName, styleModule), params:[] });

			var pageType = //peote.text.Page.PageMacro.buildClass("Page", ["peote","text"], stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType, styleField);
				TPath({ pack:["peote","text"], name:"Page", params:[TPType(styleType)] });
			var pageLineType = //peote.text.PageLine.PageLineMacro.buildClass("PageLine", ["peote","text"], stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType, styleField);
				TPath({ pack:["peote","text"], name:"PageLine", params:[TPType(styleType)] });
			var fontType = //peote.text.Font.FontMacro.buildClass("Font", ["peote","text"], stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType, styleField);
				TPath({ pack:["peote","text"], name:"Font", params:[TPType(styleType)] });
			var fontProgramType = //peote.text.FontProgram.FontProgramMacro.buildClass("FontProgram", ["peote","text"], stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType, styleField);
				TPath({ pack:["peote","text"], name:"FontProgram", params:[TPType(styleType)] });
		
			
			//var fontType = peote.text.Font.FontMacro.buildClass("Font", ["peote","text"], stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType, styleField);
			//var fontProgramType = peote.text.FontProgram.FontProgramMacro.buildClass("FontProgram", ["peote","text"], stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType, styleField);
			//var pageType  = peote.text.Page.PageMacro.buildClass("Page", ["peote","text"], stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType, styleField);
			
			//var fontPath = TPath({ pack:["peote","text"], name:"Font" + Macro.classNameExtension(styleName, styleModule), params:[] });
			//var fontProgramPath = TPath({ pack:["peote","text"], name:"FontProgram" + Macro.classNameExtension(styleName, styleModule), params:[] });
			//var pagePath = TPath({ pack:["peote","text"], name:"Page" + Macro.classNameExtension(styleName, styleModule), params:[] });
		
			Context.defineModule(fullyQualifiedName, [ getTypeDefinition(className, styleModule, styleName, styleType, uiTextPageType, pageType, pageLineType, fontType, fontProgramType) ]);
		}
		return TPath({ pack:classPackage, name:className, params:[] });
	}
		
	static public function getTypeDefinition(className:String, styleModule:String, styleName:String, styleType:ComplexType, uiTextPageType:ComplexType, pageType:ComplexType, pageLineType:ComplexType, fontType:ComplexType, fontProgramType:ComplexType):TypeDefinition
	{
		// var glyphStyleHasMeta = Macro.parseGlyphStyleMetas(styleModule+"."+styleName); // trace("FontProgram: glyphStyleHasMeta", glyphStyleHasMeta);
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
	public var page(default, null):$pageType = null;
	var pageLine:$pageLineType = null; // temporary pageline 

	public var length(get, never):Int;
	inline function get_length():Int return page.length; // number of lines

	public inline function getLineLength(lineNumber:Int):Int return page.getPageLine(lineNumber).length; // number of chars into line
	
	var undoBuffer:peote.ui.util.UndoBufferPage = null;
	public var hasUndo(get, never):Bool;
	inline function get_hasUndo():Bool return (undoBuffer != null);
	
	public var textWidth(get, never):Float;
	inline function get_textWidth():Float return (page != null) ? page.textWidth : width;
	
	public var textHeight(get, never):Float;
	inline function get_textHeight():Float return (page != null) ? page.textHeight : height;
	
	public var fontProgram(default, null):$fontProgramType;	
	public var font(default, null):$fontType;	
	public var fontStyle:$styleType;
	
	public var backgroundSpace:peote.ui.config.Space = null;
	
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
					if (isVisible && backgroundIsVisible) backgroundProgram.updateElement(backgroundElement);
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
	var selectionElementArray:Array<peote.ui.style.interfaces.StyleElement> = null;
	var selectionElementMax:Int = 0;
	public var selectionStyle(default, set):Dynamic = null;
	//inline function set_selectionStyle(style:Dynamic):Dynamic {
	inline function set_selectionStyle(style:peote.ui.style.interfaces.Style):peote.ui.style.interfaces.Style {
		if (selectionElementArray == null) { // not added to Display yet
			selectionStyle = style;
			if (style != null && page != null) createSelectionMasked(isVisible && selectionIsVisible);
		}
		else { // already have styleprogram and element 
			if (style != null) {
				if (style.getUUID() != selectionStyle.getUUID()) { // if is need another styleprogram
					if (isVisible && selectionIsVisible) selectionElementsRemove();
					selectionProgram = null;
					selectionStyle = style;
					createSelectionMasked(isVisible && selectionIsVisible);
				} 
				else { // styleprogram is of same type
					selectionStyle = style;
					selectionElementsSetStyle(style, isVisible && selectionIsVisible);
				}
			} 
			else { // remove style
				if (isVisible && selectionIsVisible) selectionElementsRemove();
				selectionStyle = null; selectionProgram = null; selectionElementArray = null;
			}
		}		
		return selectionStyle;
	}	
	public var selectionIsVisible(default, set):Bool = false;
	inline function set_selectionIsVisible(b:Bool):Bool {
		if (page != null && selectionStyle != null) {
			if (b && !selectionIsVisible) {
				if (selectionElementArray == null) createSelectionMasked(isVisible); // create new selectElements
				else if (isVisible) selectionElementsAdd();
			}
			else if (!b && selectionIsVisible && selectionElementArray != null && isVisible) selectionElementsRemove();
		}
		return selectionIsVisible = b;
	}	
	public inline function selectionShow():Void selectionIsVisible = true;
	public inline function selectionHide():Void selectionIsVisible = false;
	var selectFrom:Int = 0;
	var selectTo:Int = 0;	
	var selectLineFrom:Int = 0;
	var selectLineTo:Int = 0;
	
	public function select(fromChar:Int, toChar:Int, fromLine:Int, toLine:Int):Void { // toLine inclusive
		if (fromChar < 0) fromChar = 0;
		if (toChar < 0) toChar = 0;
		if (fromLine < 0) fromLine = 0;
		if (toLine < 0) toLine = 0;
		
		if (fromLine > toLine) { selectLineFrom = toLine; selectLineTo = fromLine; }
		else { selectLineFrom = fromLine; selectLineTo = toLine; }
		
		if (fromLine > toLine || (fromLine == toLine && fromChar > toChar)) { selectFrom = toChar; selectTo = fromChar; }
		else { selectFrom = fromChar; selectTo = toChar; }
		
		selectLineTo++;
		
		if (selectLineFrom == selectLineTo-1 && selectFrom == selectTo) selectionHide();
		else {
			if (page != null && selectionStyle != null) {
				if (selectLineFrom >= page.length) selectionHide();
				else {
					if (selectLineTo > page.length) selectLineTo = page.length;					
					if (selectTo > page.getPageLine(selectLineTo - 1).length) selectTo = page.getPageLine(selectLineTo - 1).length;
					setCreateSelectionMasked( (isVisible && selectionIsVisible), (selectionElementArray == null) );
				}
			}
			selectionShow();
		}
		//trace("select from/to:", selectLineFrom, selectLineTo, selectFrom, selectTo);
	}
	public inline function hasSelection():Bool return ( (selectLineFrom < selectLineTo-1 || selectFrom != selectTo) );
	public inline function removeSelection() { selectLineFrom = selectLineTo = selectFrom = selectTo = 0; selectionHide(); }
	
	// -------- cursor style ---------
	var cursorProgram:peote.ui.style.interfaces.StyleProgram = null;
	var cursorElement:peote.ui.style.interfaces.StyleElement = null;
	public var cursorStyle(default, set):Dynamic = null;
	//inline function set_cursorStyle(style:Dynamic):Dynamic {
	inline function set_cursorStyle(style:peote.ui.style.interfaces.Style):peote.ui.style.interfaces.Style {
		if (cursorElement == null) { // not added to Display yet
			cursorStyle = style;
			if (style != null && page != null) _createCursorMasked(isVisible && cursorIsVisible);
		}
		else { // already have styleprogram and element 
			if (style != null) {
				if (style.getUUID() != cursorStyle.getUUID()) { // if is need another styleprogram
					if (isVisible && cursorIsVisible) cursorProgram.removeElement(cursorElement);
					cursorProgram = null;
					cursorStyle = style;
					_createCursorMasked(isVisible && cursorIsVisible);
				} 
				else { // styleprogram is of same type
					cursorStyle = style;
					cursorElement.setStyle(style);
					if (isVisible && cursorIsVisible) cursorProgram.updateElement(cursorElement);
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
				if (cursorElement == null) _createCursorMasked(isVisible); // create new selectElement
				else if (isVisible) cursorProgram.addElement(cursorElement);
			}
			else if (!b && cursorIsVisible && cursorElement != null && isVisible) cursorProgram.removeElement(cursorElement);
		}
		return cursorIsVisible = b;
	}	
	public inline function cursorShow():Void cursorIsVisible = true;
	public inline function cursorHide():Void cursorIsVisible = false;
	
	var cursorWant = -1; // remember cursor if there is smaller lines by going up/down
	
	public var cursor(default, null):Int = 0;
	public inline function setCursor(cursor:Int, update:Bool = true, changeOffset:Bool = true) 
	{
		//trace("setCursor", cursor);
		if (cursor < 0) this.cursor = 0 else this.cursor = cursor;		
		if (page != null) {
			if (cursor > pageLine.length) this.cursor = pageLine.length;
			_updateCursorOrOffset(update, changeOffset);
		}
	}
	
	public var cursorLine(default, null):Int = 0;
	public inline function setCursorLine(cursorLine:Int, update:Bool = true, changeOffset:Bool = true) // TODO: , ?oldCursorLine:Int
	{
		//trace("setCursorLine", cursorLine);
		if (cursorLine < 0) this.cursorLine = 0 else this.cursorLine = cursorLine;		
		if (page != null) {
			if (cursorLine >= page.length) this.cursorLine = page.length - 1;
			pageLine = page.getPageLine(this.cursorLine);
			if (cursor > pageLine.length) this.cursor = pageLine.length;
			_updateCursorOrOffset(update, changeOffset); // TODO: ,oldCursorLine:Int
		}		
	}
	
	public inline function setCursorAndLine(cursor:Int, cursorLine:Int, update:Bool = true, changeOffset:Bool = true) // TODO: , ?oldCursorLine:Int
	{
		//trace("setCursorAndLine", cursor, cursorLine);
		if (cursor < 0) this.cursor = 0 else this.cursor = cursor;	
		if (cursorLine < 0) this.cursorLine = 0 else this.cursorLine = cursorLine;

		if (page != null) {
			if (cursorLine >= page.length) this.cursorLine = page.length - 1;
			pageLine = page.getPageLine(this.cursorLine);
			if (cursor > pageLine.length) this.cursor = pageLine.length;			
			_updateCursorOrOffset(update, changeOffset); // TODO: ,oldCursorLine:Int
		}
	}	

	inline function _updateCursorOrOffset(update:Bool, changeOffset:Bool) // TODO: , ?oldCursorLine:Int
	{
		if (changeOffset) {
			var xOffsetChanged = xOffsetToCursor();
			var yOffsetChanged = yOffsetToCursor(); // TODO: , oldCursorLine:Int
			if (update) {
				if (xOffsetChanged || yOffsetChanged) {
					updatePageLayout( false, // updateStyle
					false, false, true, // updateBgMask, updateSelection, updateCursor
					false, false, xOffsetChanged, yOffsetChanged); // pageUpdatePosition, pageUpdateSize, pageUpdateXOffset, pageUpdateYOffset
				}
				else if (cursorStyle != null) _setCreateCursorMasked( (isVisible && cursorIsVisible), (cursorElement == null) );
			}
		}
		else if (update && cursorStyle != null) {
			_setCreateCursorMasked( (isVisible && cursorIsVisible), (cursorElement == null) );
		}		
	}
	
	public inline function offsetToCursor(update:Bool = true)
	{
		var xOffsetChanged = xOffsetToCursor();
		var yOffsetChanged = yOffsetToCursor();
		if (update && page != null && (xOffsetChanged || yOffsetChanged)) {
			updatePageLayout( false, false, false, true, //  updateStyle, updateBgMask, updateSelection, updateCursor
				false, false, xOffsetChanged, yOffsetChanged // pageUpdatePosition, pageUpdateSize, pageUpdateXOffset, pageUpdateYOffset
			);
		}
	}
	
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
	var autoSize:Int = 0; // first bit is autoheight, second bit is autowidth
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
	
	public var hAlign = peote.ui.config.HAlign.LEFT;
	public var vAlign = peote.ui.config.VAlign.TOP;
	
	public var xOffset:Float = 0.0;
	public var yOffset:Float = 0.0;
	
	public var leftSpace:Int = 0;
	public var rightSpace:Int = 0;
	public var topSpace:Int = 0;
	public var bottomSpace:Int = 0;	
	
	#if (!peoteui_no_textmasking && !peoteui_no_masking)
	var maskElement:peote.text.MaskElement;
	#end
	
	public function new(xPosition:Int, yPosition:Int, width:Int, height:Int, zIndex:Int = 0, text:String,
	                    font:$fontType, ?fontStyle:$styleType,
						?config:peote.ui.config.TextConfig)
	{
		//trace("NEW UITextPage");		
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
		
		if (config != null)
		{
			backgroundStyle = config.backgroundStyle;
			backgroundSpace = config.backgroundSpace;
			
			selectionStyle = config.selectionStyle;
			cursorStyle = config.cursorStyle;
			
			if (config.autoWidth != null) autoWidth = config.autoWidth else if (width == 0) autoWidth = true;
			if (config.autoHeight != null) autoHeight = config.autoHeight else if (height == 0) autoHeight = true;
			if (config.hAlign != null) hAlign = config.hAlign;
			if (config.vAlign != null) vAlign = config.vAlign;
			xOffset = config.xOffset;
			yOffset = config.yOffset;
			
			if (config.textSpace != null) {
				leftSpace = config.textSpace.left;
				rightSpace = config.textSpace.right;
				topSpace = config.textSpace.top;
				bottomSpace = config.textSpace.bottom;
			}
			
			if (config.undoBufferSize > 0) undoBuffer = new peote.ui.util.UndoBufferPage(config.undoBufferSize);
		}
		else {
			if (width == 0) autoWidth = true;
			if (height == 0) autoHeight = true;
		}
		
	}
	
	inline function getAlignedXOffset(_xOffset:Float):Float
	{
		return (autoWidth) ? _xOffset : switch (hAlign) {
			case peote.ui.config.HAlign.CENTER: (width - leftSpace - rightSpace - page.textWidth) / 2 + _xOffset;
			case peote.ui.config.HAlign.RIGHT: width - leftSpace - rightSpace - page.textWidth + _xOffset;
			default: _xOffset;
		}
	}
	
	inline function getAlignedYOffset(_yOffset:Float):Float
	{
		return (autoHeight) ? _yOffset : switch (vAlign) {
			case peote.ui.config.VAlign.CENTER: (height - topSpace - bottomSpace - page.textHeight) / 2 + _yOffset;
			case peote.ui.config.VAlign.BOTTOM: height - topSpace - bottomSpace - page.textHeight + _yOffset;
			default: _yOffset;
		}
	}
	
	inline function xOffsetToCursor():Bool
	{
		if (autoWidth) return false;
		else {
			var cx = Math.round(getPositionAtChar(cursor));
			var cw = 2; // TODO: make customizable		
			if (cx + cw > x + width - rightSpace) { //trace("xOffsetToCursor right");
				setXOffset(getAlignedXOffset(xOffset) - cx - cw + x + width - rightSpace, false, true);
				hAlign = peote.ui.config.HAlign.LEFT;
				return true;
			}
			else if (cx < x + leftSpace) { //trace("xOffsetToCursor left");
				setXOffset(getAlignedXOffset(xOffset) - cx + x + leftSpace, false, true);
				hAlign = peote.ui.config.HAlign.LEFT;
				return true; 
			}
			else return false;
		}
	}
	
	inline function yOffsetToCursor():Bool  // TODO: , ?oldCursorLine:Int (rename this into fixYOffsetForCursor)
	{
		if (autoHeight) return false;
		else {
			//var cy = Math.round(getPositionAtLine(cursorLine));
			var cy = Math.round(pageLine.y);
			var ch = Math.round(pageLine.height);
			
			//TODO: if (oldCursorLine != null) { 
			//trace(oldCursorLine.y - pageLine.y);
			
			if (cy + ch > y + height - bottomSpace) { //trace("yOffsetToCursor bottom");
				setYOffset(getAlignedYOffset(yOffset) - cy - ch + y + height - bottomSpace, false, true);
				vAlign = peote.ui.config.VAlign.TOP;
				return true; 
			}
			else if (cy < y + topSpace) { //trace("yOffsetToCursor top");
				setYOffset(getAlignedYOffset(yOffset) - cy + y + topSpace, false, true);
				vAlign = peote.ui.config.VAlign.TOP;
				return true;
			}
			else return false;
		}
	}
	
	inline function createSelectionMasked(addUpdate:Bool) setCreateSelectionMasked(addUpdate, true);
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
		_setCreateSelection(_x, _y, _width, _height, getAlignedYOffset(yOffset) + topSpace, addUpdate, create, false);
	}
	inline function createSelection(x:Int, y:Int, w:Int, h:Int, y_offset:Float, addUpdate:Bool) _setCreateSelection(x, y, w, h, y_offset, addUpdate, true, false);
	inline function setSelection(x:Int, y:Int, w:Int, h:Int, y_offset:Float, addUpdate:Bool, updateStyle:Bool) _setCreateSelection(x, y, w, h, y_offset, addUpdate, false, updateStyle);
	inline function _setCreateSelection(_x:Int, _y:Int, _width:Int, _height:Int, y_offset:Float, addUpdate:Bool, create:Bool, updateStyle:Bool)
	{		
		var selectX:Int, selectWidth:Int, selectY:Int, selectHeight:Int, mx:Int, my:Int, mw:Int, mh:Int;
	
		var from:Int = (page.visibleLineFrom > selectLineFrom) ? page.visibleLineFrom : selectLineFrom;
		var to:Int = (page.visibleLineTo < selectLineTo) ? page.visibleLineTo : selectLineTo;
		
		var _selectFrom = selectFrom;
		var _selectTo = selectTo;

// TODO		
		if (from >= page.length) {
			from = page.length - 1; // only dirty FIX here
			// trace("bug into _setCreateSelection", from, "out of max page-line"); // TODO: bug here after deleting line and out of selection
		}
		
		//if ( selectFrom == page.getPageLine(from).length ) {
			//_selectFrom = 0; from++;
		//}
		if ( _selectTo == 0 && to > from + 1) {
// TODO		
			if (to - 1 >= page.length) {
				to = page.length; // only dirty FIX here
				// trace("bug into _setCreateSelection", to, "out of max page-line"); // TODO: bug here after deleting line and out of selection
			}
						
			to--; 
			_selectTo = page.getPageLine(to-1).length;
		}
		
		
		var _pageLine:$pageLineType;
		var selectionElement:peote.ui.style.interfaces.StyleElement;
		
		if (create)	{
			createSelectionStyle();
			selectionElementArray = new Array<peote.ui.style.interfaces.StyleElement>();
		}
		else if (addUpdate) { // remove the ones what is outside now
			//trace("remove old ones", from, to, to - from, selectionElementMax);
			var fromOld:Int = to - from;
			if (fromOld < 0) fromOld = 0;
			for (i in fromOld...selectionElementMax) selectionProgram.removeElement(selectionElementArray[i]);
		}
		
		var selectionElementMaxOld = selectionElementMax;
		selectionElementMax = 0;
		
// TODO: optimize (set allways at start and if fontStyle is changing)
		var nlSize = fontProgram.getCharSize(32, fontStyle); // size of space-char top mark newlines
		
		for (i in from...to)
		{			
			_pageLine = page.getPageLine(i);
		
			if (i == selectLineFrom && i == selectLineTo-1) { // one line selection
				selectX = Math.round(fontProgram.pageGetPositionAtChar(page, _pageLine, _selectFrom));
				selectWidth = Math.round(fontProgram.pageGetPositionAtChar(page, _pageLine, _selectTo) - selectX);
			}
			else if (i == selectLineFrom) { // first selection line
				selectX = Math.round(fontProgram.pageGetPositionAtChar(page, _pageLine, _selectFrom));
				selectWidth = Math.round(page.x + page.xOffset + _pageLine.textSize - selectX + nlSize);
			}
			else if (i == selectLineTo-1) { // last selection line
				selectX = Math.round(page.x + page.xOffset);
				selectWidth = Math.round(fontProgram.pageGetPositionAtChar(page, _pageLine, _selectTo) - selectX);
			} 
			else { // fully selected lines
				selectX = Math.round(page.x + page.xOffset);
				selectWidth = Math.round(_pageLine.textSize + nlSize);
			}
			
			selectY = Math.round(_pageLine.y);
			selectHeight = Math.round(_pageLine.height);
			
			mx = 0; my = 0; mw = selectWidth; mh = selectHeight;
			
			#if (!peoteui_no_textmasking && !peoteui_no_masking)
			if (selectX < _x) { mw -= (_x - selectX); mx = _x - selectX; if (mw > _width) mw = _width; }
			else if (selectX + selectWidth > _x + _width) mw = _x + _width - selectX;
			if (mw < 0) mw = 0;
			if (selectY < _y) { mh -= (_y - selectY); my = _y - selectY; if (mh > _height) mh = _height; }
			else if (selectY + selectHeight > _y + _height) mh = _y + _height - selectY;
			if (mh < 0) mh = 0;
			#end
			
			if (create || selectionElementMax >= selectionElementArray.length)	{
				selectionElement = selectionProgram.createElementAt(this, selectX, selectY, selectWidth, selectHeight, mx, my, mw, mh, z, selectionStyle);
				// TODO zIndex				
				if (addUpdate) selectionProgram.addElement(selectionElement);
				selectionElementArray.push(selectionElement);
			}
			else {
				selectionElement = selectionElementArray[selectionElementMax];
				selectionElement.setMasked(this, selectX, selectY, selectWidth, selectHeight, mx, my, mw, mh, z);
				// TODO zIndex				
				if (selectionElementMax >= selectionElementMaxOld) { // old element was outside of visible area
					selectionElement.setStyle(selectionStyle);
					if (addUpdate) selectionProgram.addElement(selectionElement);
				}
				else {
					if (updateStyle) selectionElement.setStyle(selectionStyle);
					if (addUpdate) selectionProgram.updateElement(selectionElement);
				}
			}
		
			selectionElementMax++;
		}		
		//trace("new selectionElementMax", selectionElementMax);		
	}
	
	inline function selectionElementsAdd() {
		for (i in 0...selectionElementMax) selectionProgram.addElement(selectionElementArray[i]);
	}
	inline function selectionElementsRemove() {
		for (i in 0...selectionElementMax) selectionProgram.removeElement(selectionElementArray[i]);
	}
	inline function selectionElementsSetStyle(style:peote.ui.style.interfaces.Style, updateAfter:Bool) {
		var selectionElement:peote.ui.style.interfaces.StyleElement;
		for (i in 0...selectionElementMax) {
			selectionElement = selectionElementArray[i];
			selectionElement.setStyle(style);
			if (updateAfter) selectionProgram.updateElement(selectionElement);
		}
	}

	inline function _createCursorMasked(addUpdate:Bool) _setCreateCursorMasked(addUpdate, true);
	inline function _setCreateCursorMasked(addUpdate:Bool, create:Bool) 
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
	inline function _createCursor(x:Int, y:Int, w:Int, h:Int, y_offset:Float, addUpdate:Bool) _setCreateCursor(x, y, w, h, y_offset, addUpdate, true);
	inline function _setCursor(x:Int, y:Int, w:Int, h:Int, y_offset:Float, addUpdate:Bool) _setCreateCursor(x, y, w, h, y_offset, addUpdate, false);
	inline function _setCreateCursor(_x:Int, _y:Int, _width:Int, _height:Int, y_offset:Float, addUpdate:Bool, create:Bool)
	{
		_width += 3; // TODO: fix for cursor at line-end

		var cx = Math.round(getPositionAtChar(cursor));
		var cw = 2; // TODO: make customizable
		//var cy = Math.round(getPositionAtLine(cursorLine));
		var cy = Math.round(pageLine.y);
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
			if (addUpdate) cursorProgram.updateElement(cursorElement);
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
				if (isVisible && backgroundIsVisible) backgroundProgram.updateElement(backgroundElement);
			}
			if (selectionElementArray != null) {
				selectionElementsSetStyle(selectionStyle, isVisible && selectionIsVisible);
			}
			if (cursorElement != null) {
				cursorElement.setStyle(cursorStyle);		
				if (isVisible && cursorIsVisible) cursorProgram.updateElement(cursorElement);
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
		
	inline function updatePageLayout(updateStyle:Bool,
		updateBgMask:Bool = true, updateSelection:Bool = true, updateCursor:Bool = true,
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
		
		// TODO: if (masked) also here!
		if (pageUpdatePosition && pageUpdateSize)
			fontProgram.pageSetPositionSize(page, _x, _y, _width, _height, (pageUpdateXOffset) ? getAlignedXOffset(xOffset) : null, (pageUpdateYOffset) ? y_offset : null, isVisible);
		else if (pageUpdatePosition)
			fontProgram.pageSetPosition(page, _x, _y, (pageUpdateXOffset) ? getAlignedXOffset(xOffset) : null, (pageUpdateYOffset) ? y_offset : null, isVisible);
		else if (pageUpdateSize)
			fontProgram.pageSetSize(page, _width, _height, (pageUpdateXOffset) ? getAlignedXOffset(xOffset) : null, (pageUpdateYOffset) ? y_offset : null, isVisible);
		else if (pageUpdateXOffset || pageUpdateYOffset) 
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
				
		if (updateBgMask) 
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
				backgroundElement.setLayout(this, backgroundSpace);
				if (isVisible && backgroundIsVisible) backgroundProgram.updateElement(backgroundElement);
			}
		}
		
		if (updateSelection && selectionElementArray != null) {
			setSelection(_x, _y, _width, _height, y_offset + topSpace, (isVisible && selectionIsVisible), updateStyle);
		}
		
		if (updateCursor && cursorElement != null) {
			if (updateStyle) cursorElement.setStyle(cursorStyle);
			_setCursor(_x, _y, _width, _height, y_offset + topSpace, (isVisible && cursorIsVisible));
		}
	}
	
	override inline function onAddVisibleToDisplay()
	{
		//trace("onAddVisibleToDisplay()", autoWidth, autoHeight);		
		if (page != null) {
			#if (!peoteui_no_textmasking && !peoteui_no_masking)
			fontProgram.addMask(maskElement);
			#end			
			if (backgroundIsVisible && backgroundElement != null) backgroundProgram.addElement(backgroundElement);			
			if (selectionIsVisible && selectionElementArray != null) selectionElementsAdd();			
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
			if (selectionStyle != null) createSelection(_x, _y, _width, _height, y_offset + topSpace, selectionIsVisible);
			if (cursorStyle != null) _createCursor(_x, _y, _width, _height, y_offset + topSpace, cursorIsVisible);
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
		if (selectionIsVisible && selectionElementArray != null) selectionElementsRemove();
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
		backgroundElement = backgroundProgram.createElement(this, backgroundStyle, backgroundSpace);
		if (addUpdate) backgroundProgram.addElement(backgroundElement);
	}
	
	inline function createSelectionStyle()
	{	//trace("createSelectionStyle");
		var stylePos = uiDisplay.usedStyleID.indexOf( selectionStyle.getUUID() );
		if (stylePos < 0) {
			if (uiDisplay.autoAddStyles) uiDisplay.autoAddStyleProgram(cast selectionProgram = selectionStyle.createStyleProgram(), selectionStyle.getUUID());
			else throw('Error by creating selection for new UITextPage. The style "'+Type.getClassName(Type.getClass(selectionStyle))+'" id='+selectionStyle.id+' is not inside the availableStyle list of UIDisplay.');
		} else {
			selectionProgram = cast uiDisplay.usedStyleProgram[stylePos];
			if (selectionProgram == null) uiDisplay.addProgramAtStylePos(cast selectionProgram = selectionStyle.createStyleProgram(), stylePos);				
		}
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

	public inline function setInputFocus(e:peote.ui.event.PointerEvent = null, cursorToPointer:Bool = false):Void {
		peote.ui.interactive.input2action.InputTextPage.focusElement = this;
		if (uiDisplay != null) uiDisplay.setInputFocus(this, e);
		if (cursorToPointer) setCursorToPointer(e);
		cursorShow();
	}

	public inline function setInputFocusAt(cursor:Int, cursorLine:Int, setCursorToPosition:Bool = true):Void {
		peote.ui.interactive.input2action.InputTextPage.focusElement = this;
		if (uiDisplay != null) uiDisplay.setInputFocus(this);
		if (setCursorToPosition) setCursorAndLine(cursor, cursorLine);
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
	public inline function keyDown(keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void
	{
		//trace("key DOWN");
		//switch (keyCode) {
			//default:
		//}		
		if (input2Action != null) input2Action.keyDown(keyCode, modifier);
		else peote.ui.interactive.input2action.InputTextPage.input2Action.keyDown(keyCode, modifier);
	}
	
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
	
	public inline function setCursorToPointer(e:peote.ui.event.PointerEvent):Void {
		if (uiDisplay != null) setCursorToPosition(e.x, e.y);
	}
	
	public inline function setCursorToPosition(x:Int, y:Int):Void {
		setCursorLine(getLineAtPosition(y), false, false);
		setCursor(getCharAtPosition(x)); 
		cursorWant = -1;
	}
	
	// ----------- Selection Events -----------
	
	public function startSelection(e:peote.ui.event.PointerEvent):Void {
		if (uiDisplay != null) uiDisplay.startSelection(this, e);
	}
	
	public function stopSelection(e:peote.ui.event.PointerEvent = null):Void {
		if (uiDisplay != null) uiDisplay.stopSelection(this, e);
	}
	
	// select-handler (called by PeoteUIDisplay)
	
	var selectStartFrom:Int = 0;
	var selectStartFromLine:Int = 0;
		
	inline function onSelectStart(e:peote.ui.event.PointerEvent):Void {
		//trace("selectStart", xOffset);
		removeSelection();
		setCursorToPosition(e.x, e.y);
		selectStartFromLine = cursorLine;
		selectStartFrom = cursor;
		selectionHide();
	}
	
	inline function onSelectStop(e:peote.ui.event.PointerEvent = null):Void {
		//trace("selectStop", (e != null) ? e.x : "", xOffset);
		stopSelectOutsideTimer();
		selectNextX = 0;
		selectNextY = 0;
	}
	
	inline function onSelect(e:peote.ui.event.PointerEvent):Void {
		//trace("onSelect");
		if (e.x < leftSpace + x) {
			if (selectNextX != -1) { selectNextX = - 1; startSelectOutsideTimer(); }
		}
		else if (e.x > width - rightSpace + x) {
			if (selectNextX != 1) { selectNextX = 1; startSelectOutsideTimer();	}
		}
		else selectNextX = 0;
				
		if (e.y < topSpace + y) {
			if (selectNextY != -1) { selectNextY = - 1; startSelectOutsideTimer(); }
		}
		else if (e.y > height - bottomSpace + y) {
			if (selectNextY != 1) { selectNextY = 1; startSelectOutsideTimer(); }
		}
		else selectNextY = 0;
		
		if (selectNextX == 0 && selectNextY == 0) {
			stopSelectOutsideTimer();
			setCursorToPosition(e.x, e.y);
			select( selectStartFrom, cursor, selectStartFromLine, cursorLine );
		}
		else if (selectNextX == 0) {
			setCursor(getCharAtPosition(e.x)); 
			cursorWant = -1;
			select( selectStartFrom, cursor, selectStartFromLine, cursorLine );
		}
		else if (selectNextY == 0) {
			setCursorLine(getLineAtPosition(e.y));
			cursorWant = -1;
			select( selectStartFrom, cursor, selectStartFromLine, cursorLine );
		}
	}
	
	var seletionOutsideTimer = new haxe.Timer(50);
	var seletionOutsideTimerIsRun = false;
	var selectNextX:Int = 0;
	var selectNextY:Int = 0;
	function startSelectOutsideTimer() {
		if (! seletionOutsideTimerIsRun) {
			seletionOutsideTimer = new haxe.Timer(50);
			seletionOutsideTimer.run = selectNextOutside;
			seletionOutsideTimerIsRun = true;
		}
	}
	function stopSelectOutsideTimer() {
		seletionOutsideTimer.stop();
		seletionOutsideTimerIsRun = false;
	}
	function selectNextOutside() {
		if ((selectNextX < 0 && cursor == 0) || (selectNextX > 0 && cursor == pageLine.length)) selectNextX = 0;
		if ((selectNextY < 0 && cursorLine == 0) || (selectNextY > 0 && cursorLine == page.length -1)) selectNextY = 0;
		if (selectNextX == 0 && selectNextY == 0) {
			stopSelectOutsideTimer();
		}
		else {
			if (selectNextX < 0 && cursor > pageLine.visibleFrom) cursor = pageLine.visibleFrom;
			if (selectNextX > 0 && cursor < pageLine.visibleTo) cursor = pageLine.visibleTo;
			if (selectNextY < 0 && cursorLine > page.visibleLineFrom) cursorLine = page.visibleLineFrom;
			if (selectNextY > 0 && cursorLine < page.visibleLineTo) cursorLine = page.visibleLineTo;
			
			if (selectNextY != 0 && selectNextX != 0) setCursorAndLine(cursor + selectNextX, cursorLine + selectNextY);
			else if (selectNextX != 0) setCursor(cursor + selectNextX);
			else if (selectNextY != 0) setCursorLine(cursorLine + selectNextY);
			
			cursorWant = -1;
			select( selectStartFrom, cursor, selectStartFromLine, cursorLine );
		}
	}
	
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
			setOldTextSize();
			fontProgram.pageSet(page, text, x, y, (autoWidth) ? null : width, (autoHeight) ? null : height, xOffset, yOffset, this.fontStyle, null, isVisible);			
// TODO:
			//if (selectTo > line.length) selectTo = line.length;
			setCursorAndLine(cursor, cursorLine, autoUpdate);
			if (autoUpdate) updateTextOnly(true);
			cursorWant = -1;
		} 
		else this.text = text;
	}

	// ---------- create regexp to restrict chars --------
	var r_az = ~/[a-z]-[a-z]/g;
	var r_AZ = ~/[A-Z]-[A-Z]/g;
	var r_09 = ~/[0-9]-[0-9]/g;
	var restricRegExp:EReg = null;

	public var restrictedChars(default, set):String = "";
	inline function set_restrictedChars(chars:String):String
	{
		if (chars == restrictedChars) return chars;
		if (chars == "") {
			restricRegExp = null;
			return restrictedChars = chars;
		}

		var ranges:String = "";
		
		if (r_az.match(chars)) {
		  ranges += r_az.matched(0);
		  chars = r_az.replace(chars, "");
		}		
		if (r_AZ.match(chars)) {
		  ranges += r_AZ.matched(0);
		  chars = r_AZ.replace(chars, "");
		}		
		if (r_09.match(chars)) {
		  ranges += r_09.matched(0);
		  chars = r_09.replace(chars, "");
		}
			
		chars = StringTools.replace(chars, "\\", "\\\\");
		chars = StringTools.replace(chars, "-", "\\-");
		chars = StringTools.replace(chars, "[", "\\[");
		chars = StringTools.replace(chars, "]", "\\]");
				
		restricRegExp = new EReg("[^"+ ranges + chars + "\r\n]", "g");
		return restrictedChars = chars;
	}
	
	public inline function textInput(chars:String):Void {
		if (page == null) return;			

		// restrict chars
		if (restricRegExp != null) chars = restricRegExp.replace(chars, "");
		if (chars == "") return;

		setOldTextSize();
		if (hasSelection()) {
			deleteChars(selectLineFrom, selectLineTo, selectFrom, selectTo);
			setCursorAndLine(selectFrom, selectLineFrom, false, false);
			removeSelection();
		}
			
		if (chars.length == 1 && chars != "\n") {
			// TODO OPTIMIZE: insertChar(chars.substr(0,1), pageLine, cursor, fontStyle);
			insertChars(chars, cursorLine, cursor, fontStyle);
			setCursor(cursor+1, false);
		}
		else {
			var restCharLength = pageLine.length - cursor;
			var oldPageLength = page.length;
			
			insertChars(chars, cursorLine, cursor, fontStyle);
			
			if (page.length > oldPageLength) {
				setCursorLine(cursorLine + page.length - oldPageLength, false, false);
				setCursor(pageLine.length - restCharLength, false);
			} 
			else setCursor(cursor + chars.length, false); // TODO: unrecognized chars!		
		}		
		updateTextOnly(true);
	}

	
	var oldTextWidth:Float = 0.0;
	var oldTextHeight:Float = 0.0;
	inline function setOldTextSize() {
		oldTextWidth = page.textWidth;
		oldTextHeight = page.textHeight;		
	}

	inline function updateTextOnly(updateCursor:Bool)
	{
		updatePageLayout(
			// updateStyle, updateBgMask, updateSelection, updateCursor
			false, (autoWidth || autoHeight), false, updateCursor,
			// pageUpdatePosition, pageUpdateSize, pageUpdateXOffset, pageUpdateYOffset
			false, (autoWidth || autoHeight), !autoWidth, !autoHeight
		);
		
		cursorWant = -1;
		
		if (oldTextWidth != page.textWidth) {
			if (_onResizeTextWidth != null) _onResizeTextWidth(this, page.textWidth, page.textWidth - oldTextWidth);
			if (onResizeTextWidth != null) onResizeTextWidth(this, page.textWidth, page.textWidth - oldTextWidth);
		}
		if (oldTextHeight != page.textHeight) {
			if (_onResizeTextHeight != null) _onResizeTextHeight(this, page.textHeight, page.textHeight - oldTextHeight);
			if (onResizeTextHeight != null) onResizeTextHeight(this, page.textHeight, page.textHeight - oldTextHeight);
		}
	}
	
	// --------------------------------
	// ------------ ACTIONS -----------
	// --------------------------------
		
	public inline function deleteChar()
	{
		if (page == null) return;		
		if (hasSelection()) {
			setOldTextSize();
			deleteChars(selectLineFrom, selectLineTo, selectFrom, selectTo);
			setCursorAndLine(selectFrom, selectLineFrom, false);
			removeSelection();
			updateTextOnly(true);
		}
		else if (cursorLine < page.length - 1 || cursor < pageLine.length) {
			setOldTextSize();
			if (cursor == pageLine.length) removeLinefeed() else deleteCharAtCursor();
			//if (cursor == 0 && pageLine.length == 0) pageLine = page.getPageLine(cursorLine); // Fix after deleting an empty pageline
			setCursorAndLine(cursor, cursorLine, false);
			updateTextOnly(true);
		}
	}
	
	public inline function backspace()
	{
		if (page == null) return;
		if (hasSelection()) {
			setOldTextSize();
			deleteChars(selectLineFrom, selectLineTo, selectFrom, selectTo);
			setCursorAndLine(selectFrom, selectLineFrom, false);
			removeSelection();
			updateTextOnly(true);
		}
		else {
			if (cursor == 0) {
				if (cursorLine > 0) {
					setOldTextSize();
					setCursorLine(cursorLine-1, false, false);
					setCursor(pageLine.length, false);
					removeLinefeed();
					if (pageLine.length == 0) pageLine = page.getPageLine(cursorLine); // Fix after deleting an empty pageline
					//setCursorAndLine(cursor, cursorLine, false);
					// check BUG here if out of selection
					//trace("select from/to:",cursorLine, selectLineFrom, selectLineTo);
					//if (cursorLine < selectLineFrom) selectLineFrom--;
					//if (cursorLine < selectLineTo) selectLineTo--;					
					updateTextOnly(true);
				}
			}
			else {
				setOldTextSize();
				deleteCharAtPos(cursor - 1);
				setCursorAndLine(cursor-1, cursorLine, false);
				updateTextOnly(true);
			}
		}
	}
	
	public inline function delLeft(toLineStart:Bool = false)
	{
		if (page == null) return;
		if (cursor == 0) {
			if (!toLineStart && cursorLine > 0) {
				setOldTextSize();
				setCursorLine(cursorLine-1, false, false);
				setCursor(pageLine.length, false);
				removeLinefeed();
				if (pageLine.length == 0) pageLine = page.getPageLine(cursorLine); // Fix after deleting an empty pageline
				//setCursorAndLine(cursor, cursorLine, false);
				if (hasSelection()) {
					if (selectLineFrom == selectLineTo - 1) selectTo = cursor + (selectTo - selectFrom);
					select(cursor, selectTo, selectLineFrom-1, selectLineTo-2);
				}
				updateTextOnly(true);
			}
		}
		else {
			setOldTextSize();
			var from = (toLineStart) ? 0 : fontProgram.pageLineWordLeft(pageLine, cursor);
			deleteChars(cursorLine, cursorLine+1, from, cursor);
			if (hasSelection()) {
				if (cursor == selectTo) removeSelection();
				else {
					if (selectLineFrom == selectLineTo - 1) selectTo -= cursor - from;
					select(from, selectTo, selectLineFrom, selectLineTo-1);
				}
			}
			setCursor(from, false);
			updateTextOnly(true);
		}
	}
	
	public inline function delRight(toLineEnd:Bool = false)
	{
		if (page == null) return;
		if (cursorLine < page.length - 1 || cursor < pageLine.length) {
			if (hasSelection()) removeSelection();
			setOldTextSize();
			if (cursor == pageLine.length) { if (!toLineEnd) removeLinefeed(); }
			else deleteChars(cursorLine, cursorLine+1, cursor, (toLineEnd) ? pageLine.length : fontProgram.pageLineWordRight(pageLine, cursor));
			//if (cursor == 0 && pageLine.length == 0) pageLine = page.getPageLine(cursorLine); // Fix after deleting an empty pageline
			setCursorAndLine(cursor, cursorLine, false);
			updateTextOnly(true);
		}		
	}
	
	public inline function tabulator()
	{
		textInput("\t");
	}
	
	public inline function enter()
	{
		if (page == null) return;
		setOldTextSize();		
		if (hasSelection()) {
			deleteChars(selectLineFrom, selectLineTo, selectFrom, selectTo);
			addLinefeedAtLine(selectLineFrom, selectFrom);
			setCursorAndLine(0, selectLineFrom+1, false);
			removeSelection();
		}
		else {
			addLinefeedAtCursor();
			setCursorAndLine(0, cursorLine+1, false);
		}
		updateTextOnly(true);
	}
	
	public function copyToClipboard() {
		if (page != null && hasSelection()) {
			lime.system.Clipboard.text = fontProgram.pageGetChars(page, selectLineFrom, selectLineTo, selectFrom, selectTo);
		}
	}
	
	public function cutToClipboard() {
		if (page != null && hasSelection()) {			
			setOldTextSize();
			lime.system.Clipboard.text = cutChars(selectLineFrom, selectLineTo, selectFrom, selectTo);
			setCursorAndLine(selectFrom, selectLineFrom, false);
			removeSelection();
			updateTextOnly(true);
		}
		// TODO: without selection delete fully line
	}
	
	public function pasteFromClipboard() {
		#if !html5
			if (lime.system.Clipboard.text != null) textInput(lime.system.Clipboard.text);
		#end		
	}

	public function selectAll() {
		select(0, page.getPageLine(page.length - 1).length, 0, page.length - 1);
		setCursorAndLine(0, 0, false, false);
	}

	inline function _updateCursorSelection(newCursor:Null<Int>, newCursorLine:Null<Int>, addSelection:Bool) { // TODO: keepCursorY:Bool
		var oldCursorLine = cursorLine;
		var oldCursor = cursor;
		
		if (newCursor != null) cursorWant = -1; // TODO: cursorWant als Float um tabulator-problem zu umgehen!
		else if (cursorWant > 0) newCursor = cursorWant;
		
		if (newCursor != null && newCursorLine != null) setCursorAndLine(newCursor, newCursorLine); // TODO: , (keepCursorY) ? oldCursorLine : null
		else if (newCursor != null) setCursor(newCursor);
		else setCursorLine(newCursorLine); // TODO: , (keepCursorY) ? oldCursorLine : null
		
		if (newCursor == null && cursorWant == -1 && cursor != oldCursor) cursorWant = oldCursor;
		
		if (addSelection) {
			if (hasSelection()) {
				if (oldCursorLine == selectLineFrom && oldCursor == selectFrom) select(cursor, selectTo, cursorLine, selectLineTo - 1 );
				else select(selectFrom, cursor, selectLineFrom, cursorLine);
			}
			else {
				if (cursorLine < oldCursorLine) select(cursor, oldCursor, cursorLine, oldCursorLine );
				else select( oldCursor, cursor, oldCursorLine, cursorLine );
			}
		}
	}
	
	public inline function cursorPageStart(addSelection:Bool = false)
	{
		if (!addSelection && hasSelection()) removeSelection();
		_updateCursorSelection(0, 0, addSelection);
	}
	
	public inline function cursorPageEnd(addSelection:Bool = false)
	{
		if (!addSelection && hasSelection()) removeSelection();
		_updateCursorSelection(page.getPageLine(page.length-1).length, page.length-1, addSelection);
	}
	
	public inline function cursorStart(addSelection:Bool = false)
	{
		if (!addSelection && hasSelection()) removeSelection();
		_updateCursorSelection(0, null, addSelection);
	}
	
	public inline function cursorEnd(addSelection:Bool = false)
	{
		if (!addSelection && hasSelection()) removeSelection();
		_updateCursorSelection(pageLine.length, null, addSelection);
	}
	
	public inline function cursorLeft(addSelection:Bool = false)
	{
		if (!addSelection && hasSelection()) { setCursorAndLine(selectFrom, selectLineFrom); removeSelection(); }
		else if (cursor == 0 && cursorLine > 0) _updateCursorSelection(page.getPageLine(cursorLine-1).length, cursorLine-1, addSelection);
		else _updateCursorSelection(cursor - 1, null, addSelection);
	}

	public inline function cursorRight(addSelection:Bool = false)
	{
		if (!addSelection && hasSelection()) { setCursorAndLine(selectTo, selectLineTo - 1); removeSelection(); }
		else if (cursor == pageLine.length && cursorLine < page.length-1) _updateCursorSelection(0, cursorLine + 1, addSelection);
		else _updateCursorSelection(cursor + 1, null, addSelection);
	}

	public inline function cursorLeftWord(addSelection:Bool = false) {
		if (!addSelection && hasSelection()) removeSelection();
		if (cursor == 0 && cursorLine > 0) _updateCursorSelection(page.getPageLine(cursorLine-1).length, cursorLine-1,addSelection);
		else _updateCursorSelection(fontProgram.pageLineWordLeft(pageLine, cursor), null, addSelection);
	}
	
	public inline function cursorRightWord(addSelection:Bool = false) {
		if (!addSelection && hasSelection()) removeSelection();
		if (cursor == pageLine.length && cursorLine < page.length-1) _updateCursorSelection(0, cursorLine + 1, addSelection);
		else _updateCursorSelection(fontProgram.pageLineWordRight(pageLine, cursor), null, addSelection);
	}
	
	public inline function cursorUp(addSelection:Bool = false)
	{
		if (!addSelection && hasSelection()) removeSelection();
		_updateCursorSelection(null, cursorLine - 1, addSelection);
		// TODO: identation-guide-bug ...better into _updateCursorSelection
		//_updateCursorSelection(fontProgram.pageGetCharAtPosition(page, page.getPageLine(cursorLine - 1), cursorElement.x), cursorLine - 1, addSelection);
	}

	public inline function cursorDown(addSelection:Bool = false)
	{
		if (!addSelection && hasSelection()) removeSelection();
		_updateCursorSelection(null, cursorLine + 1, addSelection);
	}
	
	public inline function cursorPageUp(addSelection:Bool = false)
	{
		if (!addSelection && hasSelection()) removeSelection();
		_updateCursorSelection(null, cursorLine - (page.visibleLineTo - page.visibleLineFrom), addSelection); // TODO: , true
	}

	public inline function cursorPageDown(addSelection:Bool = false)
	{
		if (!addSelection && hasSelection()) removeSelection();
		_updateCursorSelection(null, cursorLine + (page.visibleLineTo - page.visibleLineFrom), addSelection); // TODO: , true
	}
	
	public inline function undo()
	{
		if (hasUndo) {
			var step = undoBuffer.undo();
			if ( step != null) {
				if (hasSelection()) removeSelection();
				
				setOldTextSize();
				
				switch (step.action) {
					case INSERT: //trace("undo INSERT");
						fontProgram.pageDeleteChars(page, step.fromLine, step.toLine, step.fromPos, step.toPos, isVisible);
						if (onDeleteText != null) onDeleteText(this, step.fromLine, step.toLine, step.fromPos, step.toPos, step.chars);
						setCursorAndLine(step.fromPos, step.fromLine, false);
					case DELETE: //trace("undo DELETE");
						fontProgram.pageInsertChars(page, step.chars, step.fromLine, step.fromPos, fontStyle, isVisible);
						if (onInsertText != null) onInsertText(this, step.fromLine, step.toLine, step.fromPos, step.toPos, step.chars);
						setCursorAndLine(step.toPos, step.toLine-1, false);
				}
			
				updateTextOnly(true);
			}
		}
		
	}
	
	public inline function redo()
	{
		if (hasUndo) {
			var step = undoBuffer.redo();
			if ( step != null) {
				if (hasSelection()) removeSelection();
				
				setOldTextSize();
				
				switch (step.action) {
					case INSERT: //trace("redo INSERT");
						fontProgram.pageInsertChars(page, step.chars, step.fromLine, step.fromPos, fontStyle, isVisible);
						if (onInsertText != null) onInsertText(this, step.fromLine, step.toLine, step.fromPos, step.toPos, step.chars);
						setCursorAndLine(step.toPos, step.toLine-1, false);
					case DELETE: //trace("redo DELETE");
						fontProgram.pageDeleteChars(page, step.fromLine, step.toLine, step.fromPos, step.toPos, isVisible);
						if (onDeleteText != null) onDeleteText(this, step.fromLine, step.toLine, step.fromPos, step.toPos, step.chars);
						setCursorAndLine(step.fromPos, step.fromLine, false);
				}
				
				updateTextOnly(true);
			}
		}
		
	}
	
	
	
	// ----------------------- delegated methods from FontProgram -----------------------

	// TODO	

	public inline function setStyle(glyphStyle:$styleType, fromLine:Int = 0, fromPosition:Int = 0, ?toLine:Null<Int>, ?toPosition:Null<Int>) {
		fontStyle = glyphStyle;
		fontProgram.pageSetStyle(page, fontStyle, fromLine, fromPosition, toLine, toPosition, isVisible);
	}
	
/*	public inline function setChar(charcode:Int, position:Int = 0, glyphStyle:$styleType = null) {
		//fontProgram.pageSetChar(page, pageLine, charcode, position, glyphStyle, isVisible);
	}
	
	public inline function setChars(chars:String, position:Int = 0, glyphStyle:$styleType = null) {
		//fontProgram.pageSetChars(page, chars, position, glyphStyle, isVisible);
	}
*/	
	public inline function appendChars(chars:String, glyphStyle:$styleType = null) {
		setOldTextSize();
		fontProgram.pageAppendChars(page, chars, glyphStyle, isVisible);
		updateTextOnly(false);
	}	
	
	public inline function addLinefeedAtCursor() {
		_addLinefeed(pageLine, cursorLine, cursor);
	}
	
	public inline function addLinefeedAtPos(position:Int) {
		_addLinefeed(pageLine, cursorLine, position);
	}
	
	public inline function addLinefeedAtLine(lineNumber:Int, position:Int) {
		_addLinefeed(null, lineNumber, position);
	}
	
	public inline function removeLinefeed() {
		_removeLinefeed(pageLine, cursorLine);
	}
	
	public inline function removeLinefeedAtLine(lineNumber:Int) {
		_removeLinefeed(pageLine, lineNumber);
	}
	
	public inline function deleteCharAtCursor() {
		_deleteChar(pageLine, cursorLine, cursor);
	}
	
	public inline function deleteCharAtPos(position:Int) {
		_deleteChar(pageLine, cursorLine, position);
	}
	
	public inline function deleteCharAtLine(lineNumber:Int, position:Int) {
		_deleteChar(null, lineNumber, position);
	}
	
	// ------------ undo-buffer methods --------------
	
/*	public inline function insertChar(char:String, lineNumber:Int = 0, position:Int = 0, glyphStyle:$styleType = null) {	
		// TODO:
		fontProgram.pageInsertChar(page, char, lineNumber, position, glyphStyle, isVisible);
	}
*/
	public inline function insertChars(chars:String, lineNumber, position, glyphStyle:$styleType = null) {
		var toLine = page.length;
		var toPos = pageLine.length - position;
		
		fontProgram.pageInsertChars(page, chars, lineNumber, position, glyphStyle, isVisible);
		
		toLine = lineNumber + page.length - toLine; 
		toPos = ((lineNumber == toLine) ? pageLine.length : page.getPageLine(toLine).length) - toPos;
		if (hasUndo) undoBuffer.insert(lineNumber, toLine+1, position, toPos, chars);
		if (onInsertText != null) onInsertText(this, lineNumber, toLine+1, position, toPos, chars);
	}
	
	public inline function deleteChars(fromLine:Int, toLine:Int, fromPos:Int, toPos:Int) {
		if (hasUndo) undoBuffer.delete(fromLine, toLine, fromPos, toPos, fontProgram.pageGetChars(page, fromLine, toLine, fromPos, toPos) );
		if (onDeleteText != null) onDeleteText(this, fromLine, toLine, fromPos, toPos, fontProgram.pageGetChars(page, fromLine, toLine, fromPos, toPos) );
		fontProgram.pageDeleteChars(page, fromLine, toLine, fromPos, toPos, isVisible);
	}
	
	inline function _deleteChar(_pageLine:$pageLineType, lineNumber:Int, position:Int) {
		//TODO:optimize
		if (hasUndo) undoBuffer.delete(lineNumber, lineNumber+1, position, position+1, fontProgram.pageGetChars(page, lineNumber, lineNumber+1, position, position+1) );
		if (onDeleteText != null) onDeleteText(this, lineNumber, lineNumber+1, position, position+1, fontProgram.pageGetChars(page, lineNumber, lineNumber+1, position, position+1) );
		fontProgram.pageDeleteChar(page, _pageLine, lineNumber, position, isVisible);
	}
	
	public inline function cutChars(fromLine:Int, toLine:Int, fromPos:Int, toPos:Int):String {
		if (hasUndo || onDeleteText != null) {
			var chars = fontProgram.pageCutChars(page, fromLine, toLine, fromPos, toPos, isVisible);
			if (hasUndo) undoBuffer.delete(fromLine, toLine, fromPos, toPos, chars);
			if (onDeleteText != null) onDeleteText(this, fromLine, toLine, fromPos, toPos, chars);
			return chars;
		} else return fontProgram.pageCutChars(page, fromLine, toLine, fromPos, toPos, isVisible);
	}
	
	inline function _addLinefeed(_pageLine:$pageLineType, lineNumber:Int, position:Int) {
		fontProgram.pageAddLinefeedAt(page, _pageLine, lineNumber, position, isVisible); // TODO: glyphstyle/defaultRange
		if (hasUndo) undoBuffer.insert(lineNumber, lineNumber+2, position, 0, "\n");
		if (onInsertText != null) onInsertText(this, lineNumber, lineNumber+2, position, 0, "\n");
	}
	
	inline function _removeLinefeed(_pageLine:$pageLineType, lineNumber:Int) {
		var position = (_pageLine != null) ? _pageLine.length : page.getPageLine(lineNumber).length;
		if (hasUndo) undoBuffer.delete(lineNumber, lineNumber+2, position, 0, "\n");
		if (onDeleteText != null) onDeleteText(this, lineNumber, lineNumber+2, position, 0, "\n");
		fontProgram.pageRemoveLinefeed(page, _pageLine, lineNumber, isVisible);
	}
	
	
/*	public inline function appendChars(chars:String, glyphStyle:$styleType = null) {		
		fontProgram.lineAppendChars(line, chars, glyphStyle, isVisible); 
	}

*/

	// -------- get screen position to char or line or vice versa -------

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
	

	// ------------- set Offsets ----------------
	
	public inline function setOffset(xOffset:Float, yOffset:Float, update:Bool = true, triggerEvent:Bool = false) {
		if (triggerEvent) {
			if (_onChangeXOffset != null) _onChangeXOffset(this, xOffset , xOffset-this.xOffset);
			if (_onChangeYOffset != null) _onChangeYOffset(this, yOffset , yOffset-this.yOffset);
			if (onChangeXOffset != null) onChangeXOffset(this, xOffset , xOffset-this.xOffset);
			if (onChangeYOffset != null) onChangeYOffset(this, yOffset , yOffset-this.yOffset);
		}
		this.xOffset = xOffset;
		this.yOffset = yOffset;
		if (update) updatePageLayout( false, false, true, true, //  updateStyle, updateBgMask, updateSelection, updateCursor
			false, false, true, true); // pageUpdatePosition, pageUpdateSize, pageUpdateXOffset, pageUpdateYOffset
	}
	public inline function setXOffset(xOffset:Float, update:Bool = true, triggerEvent:Bool = false) _setXOffset(xOffset, update, triggerEvent, triggerEvent);
	inline function _setXOffset(xOffset:Float, update:Bool, triggerInternalEvent:Bool, triggerEvent:Bool) {
		if (triggerInternalEvent && _onChangeXOffset != null) _onChangeXOffset(this, xOffset , xOffset-this.xOffset);
		if (triggerEvent && onChangeXOffset != null) onChangeXOffset(this, xOffset , xOffset-this.xOffset);
		this.xOffset = xOffset;
		if (update) updatePageLayout( false, false, true, true, //  updateStyle, updateBgMask, updateSelection, updateCursor
			false, false, true, false); // pageUpdatePosition, pageUpdateSize, pageUpdateXOffset, pageUpdateYOffset
	}
	public inline function setYOffset(yOffset:Float, update:Bool = true, triggerEvent:Bool = false) _setYOffset(yOffset, update, triggerEvent, triggerEvent);
	inline function _setYOffset(yOffset:Float, update:Bool, triggerInternalEvent:Bool, triggerEvent:Bool) {
		if (triggerInternalEvent && _onChangeYOffset != null) _onChangeYOffset(this, yOffset , yOffset-this.yOffset);
		if (triggerEvent && onChangeYOffset != null) onChangeYOffset(this, yOffset , yOffset-this.yOffset);
		this.yOffset = yOffset;
		if (update) updatePageLayout( false, false, true, true, //  updateStyle, updateBgMask, updateSelection, updateCursor
			false, false, false, true); // pageUpdatePosition, pageUpdateSize, pageUpdateXOffset, pageUpdateYOffset
	}
	
	// ------- bind automatic to UISliders ------
	// TODO: check that the internal events not already used, 
	// more parameters: offsetBySlider, sliderByOffset, sliderByResize, sliderByTextResize
	// optional param for Math.round(value)
	
	public function bindHSlider(slider:peote.ui.interactive.UISlider) {
		slider.setRange(0, Math.min(0, width - leftSpace - rightSpace - textWidth), (width  - leftSpace - rightSpace ) / textWidth, false, false );		
		slider._onChange = function(_, value:Float, _) _setXOffset(Math.round(value), true, false, true); // don't trigger internal _onChangeXOffset again!
		_onChangeXOffset = function (_,xOffset:Float,_) slider.setValue(xOffset, true, false); // trigger sliders _onChange and onChange
		_onResizeTextWidth = function(_, _, delta:Float) {
			var s = width - leftSpace - rightSpace;
			if (textWidth < s || textWidth - delta > s) {
				slider.setRange(0, Math.min(0, s - textWidth), s / textWidth, true, false );
			} else {
				slider.setRange(0, Math.min(0, s - textWidth), s / textWidth, false, false );
				slider.setValue(xOffset, true, false);
			}
		}
		setOnResizeWidthSlider(this, function(_,_,_) {
			slider.setRange(0, Math.min(0, width - leftSpace - rightSpace - textWidth), (width - leftSpace - rightSpace ) / textWidth, true, false );
		});
	}
	
	public function bindVSlider(slider:peote.ui.interactive.UISlider) {
		slider.setRange(0, Math.min(0, height - topSpace - bottomSpace - textHeight), (height - topSpace - bottomSpace) / textHeight , false, false);				
		slider._onChange = function(_, value:Float, _) _setYOffset(Math.round(value), true, false, true); // don't trigger internal _onChangeYOffset again!
		_onChangeYOffset = function (_,yOffset:Float,_) slider.setValue(yOffset, true, false); // trigger sliders _onChange and onChange					
		_onResizeTextHeight = function(_, _, delta:Float) {
			var s = height - topSpace - bottomSpace;
			if (textHeight < s || textHeight - delta > s) {
				slider.setRange(0, Math.min(0, s - textHeight), s / textHeight , true, false);
			} else {
				slider.setRange(0, Math.min(0, s - textHeight), s / textHeight , false, false);
				slider.setValue(yOffset, true, false);
			}
		}
		setOnResizeHeightSlider(this, function(_,_,_) {
			slider.setRange(0, Math.min(0, height - topSpace - bottomSpace - textHeight), (height - topSpace - bottomSpace) / textHeight , true, false);
		});
	}
	
	public function unbindHSlider(slider:peote.ui.interactive.UISlider) {
		slider._onChange = null;
		_onChangeXOffset = null;
		setOnResizeWidthSlider(this, null);
		_onResizeTextWidth = null;
	}
	
	public function unbindVSlider(slider:peote.ui.interactive.UISlider) {
		slider._onChange = null;
		_onChangeYOffset = null;
		setOnResizeHeightSlider(this, null);
		_onResizeTextHeight = null;
	}
	
	
	// ------------ Events ---------------

	var _onResizeTextWidth:$uiTextPageType->Float->Float->Void = null;
	var _onResizeTextHeight:$uiTextPageType->Float->Float->Void = null;
	var _onChangeXOffset:$uiTextPageType->Float->Float->Void = null;
	var _onChangeYOffset:$uiTextPageType->Float->Float->Void = null;
	
	// text-size (inner) resize events
	public var onResizeTextWidth:$uiTextPageType->Float->Float->Void = null;
	public var onResizeTextHeight:$uiTextPageType->Float->Float->Void = null;

	// events if text page is changing offset
	public var onChangeXOffset:$uiTextPageType->Float->Float->Void = null;
	public var onChangeYOffset:$uiTextPageType->Float->Float->Void = null;

	// events if text is changed: fromLine, toLine, fromPos, toPos, chars
	public var onInsertText:$uiTextPageType->Int->Int->Int->Int->String->Void = null;
	public var onDeleteText:$uiTextPageType->Int->Int->Int->Int->String->Void = null;
	
	public var onResizeWidth(never, set):$uiTextPageType->Int->Int->Void;
	inline function set_onResizeWidth(f:$uiTextPageType->Int->Int->Void):$uiTextPageType->Int->Int->Void
		return setOnResizeWidth(this, f);
	
	public var onResizeHeight(never, set):$uiTextPageType->Int->Int->Void;
	inline function set_onResizeHeight(f:$uiTextPageType->Int->Int->Void):$uiTextPageType->Int->Int->Void
		return setOnResizeHeight(this, f);
	
	public var onPointerOver(never, set):$uiTextPageType->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerOver(f:$uiTextPageType->peote.ui.event.PointerEvent->Void):$uiTextPageType->peote.ui.event.PointerEvent->Void
		return setOnPointerOver(this, f);
	
	public var onPointerOut(never, set):$uiTextPageType->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerOut(f:$uiTextPageType->peote.ui.event.PointerEvent->Void):$uiTextPageType->peote.ui.event.PointerEvent->Void 
		return setOnPointerOut(this, f);
	
	public var onPointerMove(never, set):$uiTextPageType->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerMove(f:$uiTextPageType->peote.ui.event.PointerEvent->Void):$uiTextPageType->peote.ui.event.PointerEvent->Void
		return setOnPointerMove(this, f);
	
	public var onPointerDown(never, set):$uiTextPageType->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerDown(f:$uiTextPageType->peote.ui.event.PointerEvent->Void):$uiTextPageType->peote.ui.event.PointerEvent->Void
		return setOnPointerDown(this, f);
	
	public var onPointerUp(never, set):$uiTextPageType->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerUp(f:$uiTextPageType->peote.ui.event.PointerEvent->Void):$uiTextPageType->peote.ui.event.PointerEvent->Void
		return setOnPointerUp(this, f);
	
	public var onPointerClick(never, set):$uiTextPageType->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerClick(f:$uiTextPageType->peote.ui.event.PointerEvent->Void):$uiTextPageType->peote.ui.event.PointerEvent->Void
		return setOnPointerClick(this, f);
		
	public var onMouseWheel(never, set):$uiTextPageType->peote.ui.event.WheelEvent->Void;
	inline function set_onMouseWheel(f:$uiTextPageType->peote.ui.event.WheelEvent->Void):$uiTextPageType->peote.ui.event.WheelEvent->Void 
		return setOnMouseWheel(this, f);
				
	public var onDrag(never, set):$uiTextPageType->Float->Float->Void;
	inline function set_onDrag(f:$uiTextPageType->Float->Float->Void):$uiTextPageType->Float->Float->Void
		return setOnDrag(this, f);
	
	public var onFocus(never, set):$uiTextPageType->Void;
	inline function set_onFocus(f:$uiTextPageType->Void):$uiTextPageType->Void
		return setOnFocus(this, f);

}

// -------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------
		
		return c;
	}
}
#end
