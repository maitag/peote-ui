package peote.ui.interactive;

#if !macro
@:genericBuild(peote.ui.interactive.UITextLine.UITextLineMacro.build("UITextLine"))
class UITextLine<T> extends peote.ui.interactive.Interactive {}
#else

import haxe.macro.Expr;
import haxe.macro.Context;
import peote.text.util.Macro;
//import peote.text.util.GlyphStyleHasField;
//import peote.text.util.GlyphStyleHasMeta;

class UITextLineMacro
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
			//var lineType  = peote.text.Line.LineMacro.buildClass("Line", ["peote","text"], stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType, styleField);
			
			//var fontPath = TPath({ pack:["peote","text"], name:"Font" + Macro.classNameExtension(styleName, styleModule), params:[] });
			//var fontProgramPath = TPath({ pack:["peote","text"], name:"FontProgram" + Macro.classNameExtension(styleName, styleModule), params:[] });
			//var linePath = TPath({ pack:["peote","text"], name:"Line" + Macro.classNameExtension(styleName, styleModule), params:[] });

			
			//var glyphStyleHasMeta = peote.text.Glyph.GlyphMacro.parseGlyphStyleMetas(styleModule+"."+styleName); // trace("FontProgram: glyphStyleHasMeta", glyphStyleHasMeta);
			//var glyphStyleHasField = peote.text.Glyph.GlyphMacro.parseGlyphStyleFields(styleModule+"."+styleName); // trace("FontProgram: glyphStyleHasField", glyphStyleHasField);
			var glyphStyleHasMeta = Macro.parseGlyphStyleMetas(styleModule+"."+styleName); // trace("FontProgram: glyphStyleHasMeta", glyphStyleHasMeta);
			var glyphStyleHasField = Macro.parseGlyphStyleFields(styleModule+"."+styleName); // trace("FontProgram: glyphStyleHasField", glyphStyleHasField);

			var c = macro

// -------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------
class $className extends peote.ui.interactive.Interactive
	implements peote.ui.interactive.interfaces.ActionTextLine
	implements peote.ui.interactive.interfaces.InputFocus
	implements peote.ui.interactive.interfaces.InputText
#if peote_layout
implements peote.layout.ILayoutElement
#end
{	
	var line:peote.text.Line<$styleType> = null; //$lineType
	
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
			if (style != null && line != null) createBackgroundStyle(isVisible && backgroundIsVisible);
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
		if (line != null && backgroundStyle != null) {
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
		if (selectionElement == null) { // not added to Display yet
			selectionStyle = style;
			if (style != null && line != null) createSelectionMasked(isVisible && selectionIsVisible);
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
		return selectionStyle;
	}	
	public var selectionIsVisible(default, set):Bool = false;
	inline function set_selectionIsVisible(b:Bool):Bool {
		if (line != null && selectionStyle != null) {
			if (b && !selectionIsVisible) {
				if (selectionElement == null) createSelectionMasked(isVisible); // create new selectElement
				else if (isVisible) selectionProgram.addElement(selectionElement);
			}
			else if (!b && selectionIsVisible && selectionElement != null && isVisible) selectionProgram.removeElement(selectionElement);
		}
		return selectionIsVisible = b;
	}	
	public inline function selectionShow():Void selectionIsVisible = true;
	public inline function selectionHide():Void selectionIsVisible = false;
	var selectFrom:Int = 0;
	var selectTo:Int = 0;	
	public function select(from:Int, to:Int):Void {
		if (from < 0) from = 0;
		if (to < 0) to = 0;
		if (from <= to) { selectFrom = from; selectTo = to;	} else { selectFrom = to; selectTo = from; }
		if (selectFrom == selectTo) selectionHide();
		else {
			if (line != null && selectionStyle != null) {
				if (selectTo > line.length) selectTo = line.length;
				setCreateSelectionMasked( (isVisible && selectionIsVisible), (selectionElement == null) );
			}
			selectionShow();
		}
	}
	public inline function hasSelection():Bool return (selectFrom != selectTo);
	public inline function removeSelection() { selectFrom = selectTo = 0; selectionHide(); }
	
	// -------- cursor style ---------
	var cursorProgram:peote.ui.style.interfaces.StyleProgram = null;
	var cursorElement:peote.ui.style.interfaces.StyleElement = null;
	public var cursorStyle(default, set):Dynamic = null;
	//inline function set_cursorStyle(style:Dynamic):Dynamic {
	inline function set_cursorStyle(style:peote.ui.style.interfaces.Style):peote.ui.style.interfaces.Style {
		if (cursorElement == null) { // not added to Display yet
			cursorStyle = style;
			if (style != null && line != null) createCursorMasked(isVisible && cursorIsVisible);
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
		if (line != null && cursorStyle != null) {
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
			else {
				if (line != null) {
					if (pos > line.length) cursor = line.length;
					else cursor = pos;
				}
				else {
					if (pos > text.length) cursor = text.length;
					else cursor = pos;
				}
			}		
			if (line != null && cursorStyle != null) {	
				setCreateCursorMasked( (isVisible && cursorIsVisible), (cursorElement == null) );
			}
		}
		return cursor;
	}	
	
	
	// ---------- text ---------------	
	@:isVar public var text(get, set):String = null;
	inline function get_text():String {
		if (line == null) return text;
		else return fontProgram.lineGetChars(line);
	}
	inline function set_text(t:String):String {
		if (line == null || t == null) return text = t;
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
	public var vAlign:peote.ui.util.VAlign = peote.ui.util.VAlign.CENTER;
	
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
		//trace("NEW UITextLine");		
		var width:Int = 0;
		var height:Int = 0;
		if (textSize != null) {
			if (textSize.height != null) { height = textSize.height; autoHeight = false; }
			if (textSize.width  != null) { width  = textSize.width; autoWidth = false; }
			if (textSize.hAlign != null) hAlign = textSize.hAlign;
			if (textSize.vAlign != null) vAlign = textSize.vAlign;
			if (textSize.xOffset != null) xOffset = textSize.xOffset;
			if (textSize.yOffset != null) yOffset = textSize.yOffset;
			if (textSize.leftSpace != null) leftSpace = textSize.leftSpace;
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
			case peote.ui.util.HAlign.CENTER: (width - leftSpace - rightSpace - line.textSize) / 2 + _xOffset;
			case peote.ui.util.HAlign.RIGHT: width - leftSpace - rightSpace - line.textSize + _xOffset;
			//case peote.ui.util.HAlign.CENTER: (width - leftSpace - rightSpace - Math.floor(line.textSize))/2 + _xOffset;
			//case peote.ui.util.HAlign.RIGHT: width - leftSpace - rightSpace - Math.floor(line.textSize) + _xOffset;
			default: _xOffset;
		}
	}
	
	inline function getAlignedYOffset():Float
	{
		return (autoHeight) ? yOffset : switch (vAlign) {
			case peote.ui.util.VAlign.CENTER: (height - topSpace - bottomSpace - line.height) / 2 + yOffset;
			case peote.ui.util.VAlign.BOTTOM: height - topSpace - bottomSpace - line.height + yOffset;
			default: yOffset;
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
		_setCreateSelection(_x, _y, _width, _height, getAlignedYOffset() + topSpace, addUpdate, create);
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
		_setCreateCursor(_x, _y, _width, _height, getAlignedYOffset() + topSpace, addUpdate, create);
	}
	inline function createCursor(x:Int, y:Int, w:Int, h:Int, y_offset:Float, addUpdate:Bool) _setCreateCursor(x, y, w, h, y_offset, addUpdate, true);
	inline function setCursor(x:Int, y:Int, w:Int, h:Int, y_offset:Float, addUpdate:Bool) _setCreateCursor(x, y, w, h, y_offset, addUpdate, false);
	inline function _setCreateCursor(_x:Int, _y:Int, _width:Int, _height:Int, y_offset:Float, addUpdate:Bool, create:Bool)
	{
		_width += 3; // TODO: fix for cursor at line-end
		
		var cx = Math.round(getPositionAtChar(cursor));
		var cw = 2; // TODO: make customizable
		var cy = Math.round(y + y_offset);
		var ch = Math.round(line.height);		
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
		if (line != null)
		{		
			fontProgram.lineSetStyle(line, fontStyle);		
			if (isVisible) fontProgram.lineUpdate(line);
			
			if (backgroundElement != null) {
				backgroundElement.setStyle(backgroundStyle);
				if (isVisible && backgroundIsVisible) backgroundProgram.update(backgroundElement);
			}
			if (selectionElement != null) {
				selectionElement.setStyle(selectionStyle);		
				if (isVisible && selectionIsVisible) selectionProgram.update(selectionElement);
			}
			if (cursorElement != null) {
				cursorElement.setStyle(cursorStyle);		
				if (isVisible && cursorIsVisible) cursorProgram.update(cursorElement);
			}
		}
	}
		
	override inline function updateVisibleLayout():Void
	{
		if (line != null) updateLineLayout(false);
	}
		
	override inline function updateVisible():Void // updates style and layout
	{
		if (line != null) updateLineLayout(true);
	}
		
	inline function updateLineLayout(updateStyle:Bool,
		updateBgMask:Bool = true, updateSelection:Bool = true, updateCursor:Bool = true,
		lineUpdatePosition:Bool = true, lineUpdateSize:Bool = true, lineUpdateOffset:Bool = true):Void
	{
		if (updateStyle) fontProgram.lineSetStyle(line, fontStyle, isVisible);
		
		if (autoSize > 0) { // auto aligning width and height to textsize
			//if (autoWidth) width = Std.int(line.textSize) + leftSpace + rightSpace;
			if (autoWidth) width = Std.int(line.textSize) + leftSpace + rightSpace;
			if (autoHeight) height = Std.int(line.height) + topSpace + bottomSpace;
			updatePickable(); // fit interactive pickables to new width and height
		}
			
		var _x = x + leftSpace;
		var _y = y + topSpace;
		var _width  = width  - leftSpace - rightSpace;
		var _height = height - topSpace - bottomSpace;		
		var y_offset:Float = getAlignedYOffset();
		
		// TODO: if (masked) also here!
		//fontProgram.lineSetPositionSize(line, _x, _y + y_offset, _width, getAlignedXOffset(xOffset), isVisible);
		if (lineUpdatePosition && lineUpdateSize)
			fontProgram.lineSetPositionSize(line, _x, _y + y_offset, _width, (lineUpdateOffset) ? getAlignedXOffset(xOffset) : null, isVisible);
		else if (lineUpdatePosition)
			fontProgram.lineSetPosition(line, _x, _y + y_offset, (lineUpdateOffset) ? getAlignedXOffset(xOffset) : null, isVisible);
		else if (lineUpdateSize) 
			fontProgram.lineSetSize(line, _width, (lineUpdateOffset) ? getAlignedXOffset(xOffset) : null, isVisible);
		else
			fontProgram.lineSetOffset(line, getAlignedXOffset(xOffset), isVisible);
		
		if (isVisible) {
			// TODO: optimize setting z-index in depend of styletyp and better allways adding fontprograms at end of uiDisplay (onAddVisibleToDisplay)
			${switch (glyphStyleHasField.local_zIndex) {
				case true: macro {
					if (fontStyle.zIndex != z) {
						fontStyle.zIndex = z;
//TODO:					fontProgram.lineSetStyle(line, fontStyle);
					}
				}
				default: macro {}
			}}		
			fontProgram.lineUpdate(line);
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
				backgroundElement.setLayout(this);
				if (isVisible && backgroundIsVisible) backgroundProgram.update(backgroundElement);
			}
		}
		
		if (updateSelection && selectionElement != null) {
			if (updateStyle) selectionElement.setStyle(selectionStyle);
			setSelection(_x, _y, _width, _height, y_offset + topSpace, (isVisible && selectionIsVisible));
		}
		
		if (updateCursor && cursorElement != null) {
			if (updateStyle) cursorElement.setStyle(cursorStyle);
			setCursor(_x, _y, _width, _height, y_offset + topSpace, (isVisible && cursorIsVisible));
		}
	}
		
	override inline function onAddVisibleToDisplay()
	{
		//trace("onAddVisibleToDisplay()", autoWidth, autoHeight);		
		if (line != null) {
			#if (!peoteui_no_textmasking && !peoteui_no_masking)
			fontProgram.addMask(maskElement);
			#end			
			if (backgroundIsVisible && backgroundElement != null) backgroundProgram.addElement(backgroundElement);			
			if (selectionIsVisible && selectionElement != null) selectionProgram.addElement(selectionElement);			
			if (cursorIsVisible && cursorElement != null) cursorProgram.addElement(cursorElement);
			fontProgram.lineAdd(line);
		} 
		else {
			createFontStyle();			
			// TODO fontStyle.zIndex;
/*			${switch (glyphStyleHasField.local_zIndex) {
				case true: macro {
					if (fontStyle.zIndex != z) {
						fontStyle.zIndex = z;
						fontProgram.lineSetStyle(line, fontStyle);
					}
				}
				default: macro {}
			}}		
*/			
			line = fontProgram.createLine(text, x, y, (autoWidth) ? null : width, xOffset, fontStyle);
			text = null; // let GC clear the string (can be get back by fontProgram)
			if (autoSize > 0) { // auto aligning width and height to textsize
				if (autoWidth) width = Std.int(line.textSize) + leftSpace + rightSpace;
				if (autoHeight) height = Std.int(line.height) + topSpace + bottomSpace;
				if ( hasMoveEvent  != 0 ) pickableMove.update(this);
				if ( hasClickEvent != 0 ) pickableClick.update(this);
			}
			
			var _x = x + leftSpace;
			var _y = y + topSpace;
			var _width  = width  - leftSpace - rightSpace;
			var _height = height - topSpace - bottomSpace;
			
			var y_offset:Float = getAlignedYOffset();
			
			fontProgram.lineSetPositionSize(line, _x, _y + y_offset, _width, getAlignedXOffset(xOffset), isVisible);
			fontProgram.lineUpdate(line);
			
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
			if (cursorStyle != null) createCursor(_x, _y, _width, _height, y_offset + topSpace, cursorIsVisible);
		}		
	}
	
	override inline function onRemoveVisibleFromDisplay()
	{
		//trace("onRemoveVisibleFromDisplay()");
		fontProgram.lineRemove(line);
		#if (!peoteui_no_textmasking && !peoteui_no_masking)
		fontProgram.removeMask(maskElement);
		#end		
		if (backgroundIsVisible && backgroundElement != null) backgroundProgram.removeElement(backgroundElement);
		if (selectionIsVisible && selectionElement != null) selectionProgram.removeElement(selectionElement);
		if (cursorIsVisible && cursorElement != null) cursorProgram.removeElement(cursorElement);
	}

	
	inline function createFontStyle()
	{
		var fontStylePos = uiDisplay.usedStyleID.indexOf( fontStyle.getUUID() );
		if (fontStylePos < 0) {
			if (uiDisplay.autoAddStyles) uiDisplay.autoAddStyleProgram( cast fontProgram = font.createFontProgram(fontStyle, #if (peoteui_no_textmasking || peoteui_no_masking) false #else true #end, 1024, 1024, true), fontStyle.getUUID(), true );
			else throw('Error by creating new UITextLine. The style "'+Type.getClassName(Type.getClass(fontStyle))+'" id='+fontStyle.id+' is not inside the availableStyle list of UIDisplay.');
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
			else throw('Error by creating background for new UITextLine. The style "'+Type.getClassName(Type.getClass(backgroundStyle))+'" id='+backgroundStyle.id+' is not inside the availableStyle list of UIDisplay.');
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
			else throw('Error by creating selection for new UITextLine. The style "'+Type.getClassName(Type.getClass(selectionStyle))+'" id='+selectionStyle.id+' is not inside the availableStyle list of UIDisplay.');
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
			else throw('Error by creating cursor for new UITextLine. The style "'+Type.getClassName(Type.getClass(cursorStyle))+'" id='+cursorStyle.id+' is not inside the availableStyle list of UIDisplay.');
		} else {
			cursorProgram = cast uiDisplay.usedStyleProgram[stylePos];
			if (cursorProgram == null) uiDisplay.addProgramAtStylePos(cast cursorProgram = cursorStyle.createStyleProgram(), stylePos);				
		}
		cursorElement = cursorProgram.createElementAt(this, x, y, w, h, mx, my, mw, mh, z, cursorStyle);
	}
	
	
	// -------------------------------------------------------
	// ------------------- Input Focus -----------------------
	// -------------------------------------------------------
	
	public inline function setInputFocus(e:peote.ui.event.PointerEvent = null, setCursor:Bool = false):Void {
		peote.ui.interactive.input2action.InputTextLine.focusElement = this;
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
		else peote.ui.interactive.input2action.InputTextLine.input2Action.keyDown(keyCode, modifier);
	}
	
	@:access(input2action.Input2Action)
	public inline function keyUp(keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void
	{
		//trace("key UP");
		//switch (keyCode) {
			//default:
		//}
		if (input2Action != null) input2Action.keyUp(keyCode, modifier);
		else peote.ui.interactive.input2action.InputTextLine.input2Action.keyUp(keyCode, modifier);
	}
	

	// -------------------------------------------------------
	// --------------- Cursor and Selection ------------------
	// -------------------------------------------------------
	
	public function setCursorToPointer(e:peote.ui.event.PointerEvent):Void {
		if (uiDisplay != null) cursor = getCharAtPosition(e.x);
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
		//trace("selectStart", xOffset);
		removeSelection();
		selectStartFrom = cursor = getCharAtPosition(e.x);
		xOffsetAtSelectStart = xOffset;
		selectionHide();
	}
	
	function onSelectStop(e:peote.ui.event.PointerEvent = null):Void {
		//trace("selectStop", (e != null) ? e.x : "", xOffset);
	}
	
	function onSelect(e:peote.ui.event.PointerEvent):Void {
		if (localX(e.x) < leftSpace) {
			if (localX(e.x) < getAlignedXOffset(leftSpace) + xOffsetAtSelectStart) {
				xOffset = Math.max(- getAlignedXOffset(0), xOffsetAtSelectStart);
			}
			else xOffset = leftSpace - localX(e.x) + xOffsetAtSelectStart;
			updateLineLayout(false); // OPTIMIZING: not for the background!
		}
		else if (localX(e.x) > width - rightSpace) {
			if ( localX(e.x) > getAlignedXOffset(line.textSize + leftSpace  + xOffsetAtSelectStart ) ) {
				xOffset = Math.min(-getAlignedXOffset(Math.floor(line.textSize) - width + leftSpace + rightSpace), xOffsetAtSelectStart);
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
	}

		
	// -----------------------------------------------------
	// ------------------- TextInput -----------------------
	// -----------------------------------------------------
	
	// ----------------------- change the text  -----------------------	
	public function setText(text:String, fontStyle:Null<$styleType> = null, forceAutoWidth:Null<Bool> = null, forceAutoHeight:Null<Bool> = null, autoUpdate = false)
	{
		if (fontStyle != null) this.fontStyle = fontStyle;
		
		if (forceAutoWidth != null) autoWidth = forceAutoWidth;
		if (forceAutoHeight != null) autoHeight = forceAutoHeight;
		
		if (line != null) {
			fontProgram.lineSet(line, text, x, y, (autoWidth) ? null : width, xOffset, this.fontStyle, null, isVisible);
			if (cursor > line.length) cursor = line.length;
			if (selectTo > line.length) selectTo = line.length;
			
			if (autoUpdate) updateTextOnly();
		} 
		else this.text = text;
	}
	
	public inline function textInput(chars:String):Void {
		if (line == null) return;
		var oldCursor = cursor;			
		if (hasSelection()) {
			fontProgram.lineDeleteChars(line, selectFrom, selectTo, isVisible);
			oldCursor = selectFrom;
			removeSelection();
		}
		var oldLength = line.length;
		insertChars(chars, oldCursor, fontStyle); // TODO: extra "inputFontStyle" for textInput
		updateTextOnly();
		cursor = oldCursor + (line.length - oldLength);
	}

	inline function updateTextOnly()
	{
		// TODO: if FontStyle changed -> also for autoHeight!
		
		// updateStyle, updateBgMask, updateSelection, updateCursor, lineUpdatePosition, lineUpdateSize, lineUpdateOffset
		if (autoWidth) updateLineLayout(false, // updateStyle
			true, false, false, // updateBgMask, updateSelection, updateCursor
			false, true, false); // lineUpdatePosition, lineUpdateSize, lineUpdateOffset
		else {
			if ( !autoWidth && hAlign == peote.ui.util.HAlign.LEFT && isVisible) fontProgram.lineUpdate(line);
			else updateLineLayout(false,  // updateStyle
				// updateBgMask, updateSelection, updateCursor
				autoWidth, false, (hAlign != peote.ui.util.HAlign.LEFT),
				// lineUpdatePosition, lineUpdateSize, lineUpdateOffset
				false, autoWidth, !autoWidth);
		}					
	}
	
	// --------------------------------
	// ------------ ACTIONS -----------
	// --------------------------------	
	
	public inline function deleteChar()
	{
		if (line == null) return;
		if (hasSelection()) {
			fontProgram.lineDeleteChars(line, selectFrom, selectTo, isVisible);
			cursor = selectFrom;
			removeSelection();
			updateTextOnly();
		}
		else if (cursor < line.length) {
			fontProgram.lineDeleteChar(line, cursor, isVisible);
			updateTextOnly();
		}
	}

	public inline function backspace()
	{
		if (line == null) return;
		if (hasSelection()) {
			fontProgram.lineDeleteChars(line, selectFrom, selectTo, isVisible);
			cursor = selectFrom;
			removeSelection();
			updateTextOnly();
		}
		else if (cursor > 0) {
			cursor--;
			fontProgram.lineDeleteChar(line, cursor, isVisible);
			updateTextOnly();
		}
	}
	
	public inline function tabulator()
	{
		textInput("\t");
	}
	
	public function copyToClipboard() {
		if (line != null && hasSelection()) {
			lime.system.Clipboard.text = fontProgram.lineGetChars(line, selectFrom, selectTo);
		}
	}
	
	public function cutToClipboard() {
		if (line != null && hasSelection()) {
			lime.system.Clipboard.text = fontProgram.lineCutChars(line, selectFrom, selectTo, isVisible);
			cursor = selectFrom;
			removeSelection();
			updateTextOnly();
		}
	}
	
	public function pasteFromClipboard() {
		#if !html5
			if (lime.system.Clipboard.text != null) textInput(lime.system.Clipboard.text);
		#end		
	}

	public inline function cursorLeft()
	{
		if (hasSelection()) { cursor = selectFrom; removeSelection(); }
		else cursor--;
	}

	public inline function cursorRight()
	{
		if (hasSelection()) { cursor = selectTo; removeSelection(); }
		else cursor++;
	}

	public inline function cursorLeftWord() {
		if (hasSelection()) removeSelection();
		cursor = fontProgram.lineWordLeft(line, cursor);
	}
	
	public inline function cursorRightWord()
	{
		if (hasSelection()) removeSelection();
		cursor = fontProgram.lineWordRight(line, cursor);
	}

	
	// ----------------------- delegated methods from FontProgram -----------------------

	public inline function setStyle(glyphStyle:$styleType, from:Int = 0, to:Null<Int> = null) {
		fontProgram.lineSetStyle(line, glyphStyle, from, to, isVisible);
	}
	
	public inline function setChar(charcode:Int, position:Int = 0, glyphStyle:$styleType = null) {
		fontProgram.lineSetChar(line, charcode, position, glyphStyle, isVisible);
	}
	
	public inline function setChars(chars:String, position:Int = 0, glyphStyle:$styleType = null) {
		fontProgram.lineSetChars(line, chars, position, glyphStyle, isVisible);		
	}
	
	public inline function insertChar(charcode:Int, position:Int = 0, glyphStyle:$styleType = null) {
		fontProgram.lineInsertChar(line, charcode, position, glyphStyle, isVisible);
	}
	
	public inline function insertChars(chars:String, position:Int = 0, glyphStyle:$styleType = null) {
		fontProgram.lineInsertChars(line, chars, position, glyphStyle, isVisible);
	}
	
	public inline function appendChars(chars:String, glyphStyle:$styleType = null) {
		fontProgram.lineAppendChars(line, chars, glyphStyle, isVisible); 
	}

	public inline function deleteCharAt(position:Int = 0) {
		fontProgram.lineDeleteChar(line, position, isVisible);
	}

	public inline function deleteChars(from:Int = 0, to:Null<Int> = null) {
		fontProgram.lineDeleteChars(line, from, to, isVisible);
	}
	
	public inline function cutChars(from:Int = 0, to:Null<Int> = null):String {
		return fontProgram.lineCutChars(line, from, to, isVisible);
	}
	
	public inline function getPositionAtChar(position:Int):Float {
		return fontProgram.lineGetPositionAtChar(line, position);
	}
	
	public inline function getCharAtPosition(xPosition:Float):Int {
		return fontProgram.lineGetCharAtPosition(line, xPosition);
	}
	
	// ----------- events ------------------
	
	public var onPointerOver(never, set):UITextLine<$styleType>->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerOver(f:UITextLine<$styleType>->peote.ui.event.PointerEvent->Void):UITextLine<$styleType>->peote.ui.event.PointerEvent->Void
		return setOnPointerOver(this, f);
	
	public var onPointerOut(never, set):UITextLine<$styleType>->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerOut(f:UITextLine<$styleType>->peote.ui.event.PointerEvent->Void):UITextLine<$styleType>->peote.ui.event.PointerEvent->Void 
		return setOnPointerOut(this, f);
	
	public var onPointerMove(never, set):UITextLine<$styleType>->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerMove(f:UITextLine<$styleType>->peote.ui.event.PointerEvent->Void):UITextLine<$styleType>->peote.ui.event.PointerEvent->Void
		return setOnPointerMove(this, f);
	
	public var onPointerDown(never, set):UITextLine<$styleType>->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerDown(f:UITextLine<$styleType>->peote.ui.event.PointerEvent->Void):UITextLine<$styleType>->peote.ui.event.PointerEvent->Void
		return setOnPointerDown(this, f);
	
	public var onPointerUp(never, set):UITextLine<$styleType>->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerUp(f:UITextLine<$styleType>->peote.ui.event.PointerEvent->Void):UITextLine<$styleType>->peote.ui.event.PointerEvent->Void
		return setOnPointerUp(this, f);
	
	public var onPointerClick(never, set):UITextLine<$styleType>->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerClick(f:UITextLine<$styleType>->peote.ui.event.PointerEvent->Void):UITextLine<$styleType>->peote.ui.event.PointerEvent->Void
		return setOnPointerClick(this, f);
		
	public var onMouseWheel(never, set):UITextLine<$styleType>->peote.ui.event.WheelEvent->Void;
	inline function set_onMouseWheel(f:UITextLine<$styleType>->peote.ui.event.WheelEvent->Void):UITextLine<$styleType>->peote.ui.event.WheelEvent->Void 
		return setOnMouseWheel(this, f);
				
	public var onDrag(never, set):UITextLine<$styleType>->Float->Float->Void;
	inline function set_onDrag(f:UITextLine<$styleType>->Float->Float->Void):UITextLine<$styleType>->Float->Float->Void
		return setOnDrag(this, f);
	
	public var onFocus(never, set):UITextLine<$styleType>->Void;
	inline function set_onFocus(f:UITextLine < $styleType >->Void):UITextLine < $styleType >->Void 
		return setOnFocus(this, f);
		
	public var onResizeWidth(never, set):UITextLine<$styleType>->Int->Int->Void;
	inline function set_onResizeWidth(f:UITextLine<$styleType>->Int->Int->Void):UITextLine<$styleType>->Int->Int->Void
		return setOnResizeWidth(this, f);
		
	public var onResizeHeight(never, set):UITextLine<$styleType>->Int->Int->Void;
	inline function set_onResizeHeight(f:UITextLine<$styleType>->Int->Int->Void):UITextLine<$styleType>->Int->Int->Void
		return setOnResizeHeight(this, f);
	
}

// -------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------
			
			Context.defineModule(classPackage.concat([className]).join('.'),[c]);
		}
		return TPath({ pack:classPackage, name:className, params:[] });
	}
}
#end
