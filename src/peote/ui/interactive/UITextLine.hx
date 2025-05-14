package peote.ui.interactive;

#if !macro
@:genericBuild(peote.ui.interactive.UITextLine.UITextLineMacro.build("UITextLine"))
class UITextLine<T> extends peote.ui.interactive.Interactive {}
#else

import haxe.macro.Expr;
import haxe.macro.Context;
import peote.text.util.Macro;

class UITextLineMacro
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
			var uiTextLineType:ComplexType =  TPath({ pack:classPackage, name:"UITextLine" + Macro.classNameExtension(styleName, styleModule), params:[] });

			var lineType = //peote.text.Line.LineMacro.buildClass("Line", ["peote","text"], stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType, styleField);
				TPath({ pack:["peote","text"], name:"Line", params:[TPType(styleType)] });
			var fontType = //peote.text.Font.FontMacro.buildClass("Font", ["peote","text"], stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType, styleField);
				TPath({ pack:["peote","text"], name:"Font", params:[TPType(styleType)] });
			var fontProgramType = //peote.text.FontProgram.FontProgramMacro.buildClass("FontProgram", ["peote","text"], stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType, styleField);
				TPath({ pack:["peote","text"], name:"FontProgram", params:[TPType(styleType)] });
			
			//var fontPath = TPath({ pack:["peote","text"], name:"Font" + Macro.classNameExtension(styleName, styleModule), params:[] });
			//var fontProgramPath = TPath({ pack:["peote","text"], name:"FontProgram" + Macro.classNameExtension(styleName, styleModule), params:[] });
			//var linePath = TPath({ pack:["peote","text"], name:"Line" + Macro.classNameExtension(styleName, styleModule), params:[] });
			
			Context.defineModule(fullyQualifiedName, [ getTypeDefinition(className, styleModule, styleName, styleType, uiTextLineType, lineType, fontType, fontProgramType) ]);
		}
		return TPath({ pack:classPackage, name:className, params:[] });
	}
		
	static public function getTypeDefinition(className:String, styleModule:String, styleName:String, styleType:ComplexType, uiTextLineType:ComplexType, lineType:ComplexType, fontType:ComplexType, fontProgramType:ComplexType):TypeDefinition
	{
		// var glyphStyleHasMeta = Macro.parseGlyphStyleMetas(styleModule+"."+styleName); // trace("FontProgram: glyphStyleHasMeta", glyphStyleHasMeta);
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
	var line:$lineType = null;
	
	var undoBuffer:peote.ui.util.UndoBufferLine = null;
	public var hasUndo(get, never):Bool;
	inline function get_hasUndo():Bool return (undoBuffer != null);
	
	public var textWidth(get, never):Float;
	inline function get_textWidth():Float return line.textSize;
	
	var fontProgram:$fontProgramType;
	var font:$fontType;
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
			if (style != null && line != null) _createCursorMasked(isVisible && cursorIsVisible);
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
				if (cursorElement == null) _createCursorMasked(isVisible); // create new selectElement
				else if (isVisible) cursorProgram.addElement(cursorElement);
			}
			else if (!b && cursorIsVisible && cursorElement != null && isVisible) cursorProgram.removeElement(cursorElement);
		}
		return cursorIsVisible = b;
	}	
	public inline function cursorShow():Void cursorIsVisible = true;
	public inline function cursorHide():Void cursorIsVisible = false;
	
	public var cursor(default,null):Int = 0;
	public inline function setCursor(cursor:Int, update:Bool = true, changeOffset:Bool = true)
	{		
		//trace("setCursor", cursor);
		if (cursor < 0) this.cursor = 0 else this.cursor = cursor;		
		if (line != null) {
			if (cursor > line.length) this.cursor = line.length;
			_updateCursorOrOffset(update, changeOffset);
		}		
	}	
	
	inline function _updateCursorOrOffset(update:Bool, changeOffset:Bool)
	{
		if (changeOffset) {
			var xOffsetChanged = xOffsetToCursor();
			if (update) {
				if (xOffsetChanged) {
					updateLineLayout( false, // updateStyle
					false, false, true, // updateBgMask, updateSelection, updateCursor
					false, false, xOffsetChanged); // lineUpdatePosition, lineUpdateSize, lineUpdateOffset
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
		if (update && line != null && xOffsetChanged) {
			updateLineLayout( false, false, false, true, //  updateStyle, updateBgMask, updateSelection, updateCursor
				false, false, xOffsetChanged // lineUpdatePosition, lineUpdateSize, lineUpdateOffset
			);
		}
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
	public var vAlign = peote.ui.config.VAlign.CENTER;
	
	public var xOffset:Float = 0;
	public var yOffset:Float = 0;

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
		//trace("NEW UITextLine");		
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
			
			if (config.undoBufferSize > 0) undoBuffer = new peote.ui.util.UndoBufferLine(config.undoBufferSize);
		}
		else {
			if (width == 0) autoWidth = true;
			if (height == 0) autoHeight = true;
		}
	}
	
	inline function getAlignedXOffset(_xOffset:Float):Float
	{
		return (autoWidth) ? _xOffset : switch (hAlign) {
			case peote.ui.config.HAlign.CENTER: (width - leftSpace - rightSpace - line.textSize) / 2 + _xOffset;
			case peote.ui.config.HAlign.RIGHT: width - leftSpace - rightSpace - line.textSize + _xOffset;
			default: _xOffset;
		}
	}
	
	inline function getAlignedYOffset():Float
	{
		return (autoHeight) ? yOffset : switch (vAlign) {
			case peote.ui.config.VAlign.CENTER: (height - topSpace - bottomSpace - line.height) / 2 + yOffset;
			case peote.ui.config.VAlign.BOTTOM: height - topSpace - bottomSpace - line.height + yOffset;
			default: yOffset;
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
		_setCreateCursor(_x, _y, _width, _height, getAlignedYOffset() + topSpace, addUpdate, create);
	}
	inline function _createCursor(x:Int, y:Int, w:Int, h:Int, y_offset:Float, addUpdate:Bool) _setCreateCursor(x, y, w, h, y_offset, addUpdate, true);
	inline function _setCursor(x:Int, y:Int, w:Int, h:Int, y_offset:Float, addUpdate:Bool) _setCreateCursor(x, y, w, h, y_offset, addUpdate, false);
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
		else if (lineUpdateOffset) 
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
				backgroundElement.setLayout(this, backgroundSpace);
				if (isVisible && backgroundIsVisible) backgroundProgram.update(backgroundElement);
			}
		}
		
		if (updateSelection && selectionElement != null) {
			if (updateStyle) selectionElement.setStyle(selectionStyle);
			setSelection(_x, _y, _width, _height, y_offset + topSpace, (isVisible && selectionIsVisible));
		}
		
		if (updateCursor && cursorElement != null) {
			if (updateStyle) cursorElement.setStyle(cursorStyle);
			_setCursor(_x, _y, _width, _height, y_offset + topSpace, (isVisible && cursorIsVisible));
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
			if (cursorStyle != null) _createCursor(_x, _y, _width, _height, y_offset + topSpace, cursorIsVisible);
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
		backgroundElement = backgroundProgram.createElement(this, backgroundStyle, backgroundSpace);
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
	
	public inline function setInputFocus(e:peote.ui.event.PointerEvent = null, cursorToPointer:Bool = false):Void {
		peote.ui.interactive.input2action.InputTextLine.focusElement = this;
		if (uiDisplay != null) uiDisplay.setInputFocus(this, e);
		if (cursorToPointer) setCursorToPointer(e);
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
	public inline function keyDown(keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {
		if (input2Action != null) input2Action.keyDown(keyCode, modifier);
		else peote.ui.interactive.input2action.InputTextLine.input2Action.keyDown(keyCode, modifier);
	}
	
	public inline function keyUp(keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {
		if (input2Action != null) input2Action.keyUp(keyCode, modifier);
		else peote.ui.interactive.input2action.InputTextLine.input2Action.keyUp(keyCode, modifier);
	}
	

	// -------------------------------------------------------
	// --------------- Cursor and Selection ------------------
	// -------------------------------------------------------
	
	public inline function setCursorToPointer(e:peote.ui.event.PointerEvent):Void {
		if (uiDisplay != null) setCursorToPosition(e.x);
	}
	
	public inline function setCursorToPosition(x:Int):Void {
		setCursor(getCharAtPosition(x)); 
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
		
	inline function onSelectStart(e:peote.ui.event.PointerEvent):Void {
		//trace("selectStart", xOffset);
		removeSelection();
		setCursorToPosition(e.x);
		selectStartFrom = cursor;
		selectionHide();
	}
	
	inline function onSelectStop(e:peote.ui.event.PointerEvent = null):Void {
		//trace("selectStop", (e != null) ? e.x : "", xOffset);
		stopSelectOutsideTimer();
		selectNextX = 0;
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
				
		if (selectNextX == 0) {
			stopSelectOutsideTimer();
			setCursorToPosition(e.x);
			select( selectStartFrom, cursor );
		}
		else if (selectNextX == 0) {
			setCursor(getCharAtPosition(e.x));
			select( selectStartFrom, cursor );
		}
	}

	var seletionOutsideTimer = new haxe.Timer(50);
	var seletionOutsideTimerIsRun = false;
	var selectNextX:Int = 0;
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
		if ((selectNextX < 0 && cursor == 0) || (selectNextX > 0 && cursor == line.length)) stopSelectOutsideTimer();
		else {
			if (selectNextX < 0 && cursor > line.visibleFrom) cursor = line.visibleFrom;
			else if (selectNextX > 0 && cursor < line.visibleTo) cursor = line.visibleTo;
			
			if (selectNextX != 0) setCursor(cursor + selectNextX);
			select( selectStartFrom, cursor );
		}
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
		
		// TODO: check why have to reset xOffset after another update() ?
		
		if (line != null) {
			setOldTextSize();
			fontProgram.lineSet(line, text, x, y, (autoWidth) ? null : width, xOffset, this.fontStyle, null, isVisible);
			
			if (selectTo > line.length) selectTo = line.length;
			setCursor(cursor, autoUpdate);			
			if (autoUpdate) updateTextOnly(true);
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
				
		restricRegExp = new EReg( "[^" + ranges + chars + "]", "g" );
		return restrictedChars = chars;
	}

	public inline function textInput(chars:String):Void {
		if (line == null) return;

		// restrict chars
		if (restricRegExp != null) chars = restricRegExp.replace(chars, "");
		if (chars == "") return;

		setOldTextSize();
		if (hasSelection()) {
			deleteChars(selectFrom, selectTo);
			setCursor(selectFrom, false, false);
			removeSelection();
		}
			
		if (chars.length == 1) {
			insertChar(chars, cursor, fontStyle);
			setCursor(cursor+1, false);
		}
		else {
			insertChars(chars, cursor, fontStyle);
			setCursor(cursor + chars.length, false); // TODO: unrecognized chars!					
		}
		updateTextOnly(true);
	}

	var oldTextWidth:Float = 0.0;
	inline function setOldTextSize() oldTextWidth = line.textSize;
	
	inline function updateTextOnly(updateCursor:Bool)
	{
		// TODO: if FontStyle changed -> also for autoHeight!
		
		updateLineLayout(
			// updateStyle, updateBgMask, updateSelection, updateCursor
			false, autoWidth, false, updateCursor,
			// lineUpdatePosition, lineUpdateSize, lineUpdateOffset
			false, autoWidth, !autoWidth
		);
				
		if (oldTextWidth != line.textSize) {
			if (_onResizeTextWidth != null) _onResizeTextWidth(this, line.textSize, line.textSize - oldTextWidth);
			if (onResizeTextWidth != null) onResizeTextWidth(this, line.textSize, line.textSize - oldTextWidth);
		}		
	}
	
	// --------------------------------
	// ------------ ACTIONS -----------
	// --------------------------------	
	
	public inline function deleteChar()
	{
		if (line == null) return;
		if (hasSelection()) {
			setOldTextSize();
			deleteChars(selectFrom, selectTo);
			setCursor(selectFrom, false);
			removeSelection();
			updateTextOnly(true);
		}
		else if (cursor < line.length) {
			setOldTextSize();
			deleteCharAtCursor();
			setCursor(cursor, false);
			updateTextOnly(true);
		}
	}

	public inline function backspace()
	{
		if (line == null) return;
		if (hasSelection()) {
			setOldTextSize();
			deleteChars(selectFrom, selectTo);
			setCursor(selectFrom, false);
			removeSelection();
			updateTextOnly(true);
		}
		else if (cursor > 0) {
			setOldTextSize();
			deleteCharAtPos(cursor - 1);
			setCursor(cursor-1, false);
			updateTextOnly(true);
		}
	}
	
	public inline function delLeft(toLineStart:Bool = false)
	{
		if (line == null) return;
		if (cursor > 0) {
			setOldTextSize();
			var from = (toLineStart) ? 0 : fontProgram.lineWordLeft(line, cursor);
			deleteChars(from, cursor);
			if (hasSelection()) {
				if (cursor == selectTo) removeSelection();
				else {
					selectTo -= cursor - from;
					select(from, selectTo);
				}
			}
			setCursor(from, false);
			updateTextOnly(true);
		}
	}
	
	public inline function delRight(toLineEnd:Bool = false)
	{
		if (line == null) return;
		if (cursor < line.length) {
			if (hasSelection()) removeSelection();
			setOldTextSize();
			deleteChars(cursor, (toLineEnd) ? line.length : fontProgram.lineWordRight(line, cursor));
			setCursor(cursor, false);
			updateTextOnly(true);
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
			setOldTextSize();
			lime.system.Clipboard.text = cutChars(selectFrom, selectTo);
			setCursor(selectFrom, false);
			removeSelection();
			updateTextOnly(true);
		}
	}
	
	public function pasteFromClipboard() {
		#if !html5
			if (lime.system.Clipboard.text != null) textInput(lime.system.Clipboard.text);
		#end		
	}

	public function selectAll() {
		select(0, line.length - 1);
		setCursor(0, false, false);
	}

	inline function _updateCursorSelection(newCursor:Int, addSelection:Bool) {
		var oldCursor = cursor;
		
		setCursor(newCursor);
				
		if (addSelection) {
			if (hasSelection()) {
				if (oldCursor == selectFrom) select(cursor, selectTo);
				else select(selectFrom, cursor);
			}
			else select( oldCursor, cursor );
		}
	}
	
	public inline function cursorStart(addSelection:Bool = false)
	{
		if (!addSelection && hasSelection()) removeSelection();
		_updateCursorSelection(0, addSelection);
	}
	
	public inline function cursorEnd(addSelection:Bool = false)
	{
		if (!addSelection && hasSelection()) removeSelection();
		_updateCursorSelection(line.length, addSelection);
	}
	
	public inline function cursorLeft(addSelection:Bool = false)
	{
		if (!addSelection && hasSelection()) { setCursor(selectFrom); removeSelection(); }
		else if (cursor > 0 ) _updateCursorSelection(cursor - 1, addSelection);
	}

	public inline function cursorRight(addSelection:Bool = false)
	{
		if (!addSelection && hasSelection()) { setCursor(selectTo); removeSelection(); }
		else if (cursor < line.length) _updateCursorSelection(cursor + 1, addSelection);
	}

	public inline function cursorLeftWord(addSelection:Bool = false) {
		if (!addSelection && hasSelection()) removeSelection();
		if (cursor > 0) _updateCursorSelection(fontProgram.lineWordLeft(line, cursor), addSelection);
	}
	
	public inline function cursorRightWord(addSelection:Bool = false)
	{
		if (!addSelection && hasSelection()) removeSelection();
		if (cursor < line.length) _updateCursorSelection(fontProgram.lineWordRight(line, cursor), addSelection);
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
						fontProgram.lineDeleteChars(line, step.fromPos, step.toPos, isVisible);
						if (onDeleteText != null) onDeleteText(this, step.fromPos, step.toPos, step.chars);
						setCursor(step.fromPos, false);
					case DELETE: //trace("undo DELETE");
						fontProgram.lineInsertChars(line, step.chars, step.fromPos, fontStyle, isVisible);
						if (onInsertText != null) onInsertText(this, step.fromPos, step.toPos, step.chars);
						setCursor(step.toPos, false);
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
						fontProgram.lineInsertChars(line, step.chars, step.fromPos, fontStyle, isVisible);
						if (onInsertText != null) onInsertText(this, step.fromPos, step.toPos, step.chars);
						setCursor(step.toPos, false);
					case DELETE: //trace("redo DELETE");
						fontProgram.lineDeleteChars(line, step.fromPos, step.toPos, isVisible);
						if (onDeleteText != null) onDeleteText(this, step.fromPos, step.toPos, step.chars);
						setCursor(step.fromPos, false);
				}
				
				updateTextOnly(true);
			}
		}
		
	}
		
	// ----------------------- delegated methods from FontProgram -----------------------
	
	// TODO	

	public inline function setStyle(glyphStyle:$styleType, from:Int = 0, to:Null<Int> = null) {
		fontStyle = glyphStyle;
		fontProgram.lineSetStyle(line, fontStyle, from, to, isVisible);
	}
	
/*	public inline function setChar(charcode:Int, position:Int = 0, glyphStyle:$styleType = null) {
		fontProgram.lineSetChar(line, charcode, position, glyphStyle, isVisible);
	}
	
	public inline function setChars(chars:String, position:Int = 0, glyphStyle:$styleType = null) {
		fontProgram.lineSetChars(line, chars, position, glyphStyle, isVisible);		
	}
	
	public inline function appendChars(chars:String, glyphStyle:$styleType = null) {
		fontProgram.lineAppendChars(line, chars, glyphStyle, isVisible); 
	}
*/
	public inline function deleteCharAtCursor() {
		_deleteChar(cursor);
	}
	
	public inline function deleteCharAtPos(position:Int) {
		_deleteChar(position);
	}

	// ------------ undo-buffer methods --------------
	
	public inline function insertChar(char:String, position:Int, glyphStyle:$styleType = null) {
		fontProgram.lineInsertChar(line, char.charCodeAt(0), position, glyphStyle, isVisible);
		if (hasUndo) undoBuffer.insert(position, position + 1, char);
		if (onInsertText != null) onInsertText(this, position, position + 1, char);
	}
	
	public inline function insertChars(chars:String, position:Int, glyphStyle:$styleType = null) {
		fontProgram.lineInsertChars(line, chars, position, glyphStyle, isVisible);
		if (hasUndo) undoBuffer.insert(position, position + chars.length, chars);
		if (onInsertText != null) onInsertText(this, position, position + chars.length, chars);
	}
	
	inline function _deleteChar(position:Int = 0) {
		if (hasUndo) undoBuffer.delete(position, position+1, fontProgram.lineGetChars(line, position, position+1) );
		if (onDeleteText != null) {
			var chars = fontProgram.lineGetChars(line, position, position+1);
			fontProgram.lineDeleteChar(line, position, isVisible);
			onDeleteText(this, position, position+1, chars );
		} 
		else fontProgram.lineDeleteChar(line, position, isVisible);
	}
	
	public inline function deleteChars(from:Int, to:Int) {
		if (hasUndo) undoBuffer.delete(from, to, fontProgram.lineGetChars(line, from, to) );
		if (onDeleteText != null) {
			var chars = fontProgram.lineGetChars(line, from, to);
			fontProgram.lineDeleteChars(line, from, to, isVisible);
			onDeleteText(this, from, to, chars );
		}
		else fontProgram.lineDeleteChars(line, from, to, isVisible);
	}
	
	public inline function cutChars(from:Int, to:Int):String {
		if (hasUndo || onDeleteText != null) {
			var chars = fontProgram.lineCutChars(line, from, to, isVisible);
			if (hasUndo) undoBuffer.delete(from, to, chars);
			if (onDeleteText != null) onDeleteText(this, from, to, chars);
			return chars;
		} else return fontProgram.lineCutChars(line, from, to, isVisible);
	}
	
	// -------- get screen position to char or line or vice versa -------

	public inline function getPositionAtChar(position:Int):Float {
		return fontProgram.lineGetPositionAtChar(line, position);
	}
	
	public inline function getCharAtPosition(xPosition:Float):Int {
		return fontProgram.lineGetCharAtPosition(line, xPosition);
	}
	
	// ------------- set Offsets ----------------
	
	public inline function setXOffset(xOffset:Float, update:Bool = true, triggerEvent:Bool = false) _setXOffset(xOffset, update, triggerEvent, triggerEvent);
	inline function _setXOffset(xOffset:Float, update:Bool, triggerInternalEvent:Bool, triggerEvent:Bool) {
		if (triggerInternalEvent && _onChangeXOffset != null) _onChangeXOffset(this, xOffset , xOffset-this.xOffset);
		if (triggerEvent && onChangeXOffset != null) onChangeXOffset(this, xOffset , xOffset-this.xOffset);
		this.xOffset = xOffset;
		if (update) updateLineLayout( false, false, true, true, //  updateStyle, updateBgMask, updateSelection, updateCursor
			false, false, true); // lineUpdatePosition, lineUpdateSize, lineUpdateOffset
	}
	
	// ------- bind automatic to UISliders ------
	// TODO: check that the internal events not already used, 
	// more parameters: offsetBySlider, sliderByOffset, sliderByResize, sliderByTextResize
	// optional param for Math.round(value)
	
	public function bindHSlider(slider:peote.ui.interactive.UISlider) {
		slider.setRange(0, Math.min(0, width - leftSpace - rightSpace - textWidth), (width  - leftSpace - rightSpace ) / textWidth, false, false );		
		slider._onChange = function(_, value:Float, _) _setXOffset(Math.round(value), true, false, true); // don't trigger internal _onChangeXOffset again!
		_onChangeXOffset = function (_,xOffset:Float,_) slider.setValue(xOffset, true, false); // trigger sliders _onChange and onChange						
		_onResizeTextWidth = function(_,_,delta:Float) {
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
	
	public function unbindHSlider(slider:peote.ui.interactive.UISlider) {
		slider._onChange = null;
		_onChangeXOffset = null;
		// _onResizeWidthForSlider = null;
		setOnResizeWidthSlider(this, null);
		_onResizeTextWidth = null;
	}
	
	
	// ----------- Events ---------------

	var _onResizeTextWidth:$uiTextLineType->Float->Float->Void = null;
	var _onChangeXOffset:$uiTextLineType->Float->Float->Void = null;

	// text-size (inner) resize events
	public var onResizeTextWidth:$uiTextLineType->Float->Float->Void = null;
	
	// events if text page is changing offset
	public var onChangeXOffset:$uiTextLineType->Float->Float->Void = null;

	// events if text is changed: fromPos, toPos, chars
	public var onInsertText:$uiTextLineType->Int->Int->String->Void = null;
	public var onDeleteText:$uiTextLineType->Int->Int->String->Void = null;
	
	public var onResizeWidth(never, set):$uiTextLineType->Int->Int->Void;
	inline function set_onResizeWidth(f:$uiTextLineType->Int->Int->Void):$uiTextLineType->Int->Int->Void
		return setOnResizeWidth(this, f);
	
	public var onResizeHeight(never, set):$uiTextLineType->Int->Int->Void;
	inline function set_onResizeHeight(f:$uiTextLineType->Int->Int->Void):$uiTextLineType->Int->Int->Void
		return setOnResizeHeight(this, f);
	
	public var onPointerOver(never, set):$uiTextLineType->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerOver(f:$uiTextLineType->peote.ui.event.PointerEvent->Void):$uiTextLineType->peote.ui.event.PointerEvent->Void
		return setOnPointerOver(this, f);
	
	public var onPointerOut(never, set):$uiTextLineType->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerOut(f:$uiTextLineType->peote.ui.event.PointerEvent->Void):$uiTextLineType->peote.ui.event.PointerEvent->Void 
		return setOnPointerOut(this, f);
	
	public var onPointerMove(never, set):$uiTextLineType->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerMove(f:$uiTextLineType->peote.ui.event.PointerEvent->Void):$uiTextLineType->peote.ui.event.PointerEvent->Void
		return setOnPointerMove(this, f);
	
	public var onPointerDown(never, set):$uiTextLineType->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerDown(f:$uiTextLineType->peote.ui.event.PointerEvent->Void):$uiTextLineType->peote.ui.event.PointerEvent->Void
		return setOnPointerDown(this, f);
	
	public var onPointerUp(never, set):$uiTextLineType->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerUp(f:$uiTextLineType->peote.ui.event.PointerEvent->Void):$uiTextLineType->peote.ui.event.PointerEvent->Void
		return setOnPointerUp(this, f);
	
	public var onPointerClick(never, set):$uiTextLineType->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerClick(f:$uiTextLineType->peote.ui.event.PointerEvent->Void):$uiTextLineType->peote.ui.event.PointerEvent->Void
		return setOnPointerClick(this, f);
		
	public var onMouseWheel(never, set):$uiTextLineType->peote.ui.event.WheelEvent->Void;
	inline function set_onMouseWheel(f:$uiTextLineType->peote.ui.event.WheelEvent->Void):$uiTextLineType->peote.ui.event.WheelEvent->Void 
		return setOnMouseWheel(this, f);
				
	public var onDrag(never, set):$uiTextLineType->Float->Float->Void;
	inline function set_onDrag(f:$uiTextLineType->Float->Float->Void):$uiTextLineType->Float->Float->Void
		return setOnDrag(this, f);
	
	public var onFocus(never, set):$uiTextLineType->Void;
	inline function set_onFocus(f:$uiTextLineType->Void):$uiTextLineType->Void 
		return setOnFocus(this, f);
		
}

// -------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------
		
		return c;
	}
}
#end
