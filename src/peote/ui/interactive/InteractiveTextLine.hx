package peote.ui.interactive;

#if !macro
@:genericBuild(peote.ui.interactive.InteractiveTextLine.InteractiveTextLineMacro.build("InteractiveTextLine"))
class InteractiveTextLine<T> extends peote.ui.interactive.Interactive {}
#else

import haxe.macro.Expr;
import haxe.macro.Context;
import peote.text.util.Macro;
//import peote.text.util.GlyphStyleHasField;
//import peote.text.util.GlyphStyleHasMeta;

class InteractiveTextLineMacro
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
class $className extends peote.ui.interactive.Interactive implements peote.ui.interactive.interfaces.TextLine
{	
	var fontProgram:peote.text.FontProgram<$styleType>; //$fontProgramType	
	var font:peote.text.Font<$styleType>; //$fontType
	
	public var fontStyle:$styleType;
	
	@:isVar public var text(get, set):String = null;
	inline function get_text():String {
		if (line == null) return text;
		else return fontProgram.lineGetChars(line);
	}
	inline function set_text(t:String):String {
		if (line == null || t == null) return text = t;
		else {
			fontProgram.setLine(line, t, line.x, line.y, null, xOffset, isVisible); // the setter only did not autosizing!
			return t;
		}
	}
	
	
	var line:peote.text.Line<$styleType> = null; //$lineType
	
	var autoSize:Int = 0; // first bit is autoheight, second bit is autowidth
	
	public var hAlign:peote.ui.util.HAlign = peote.ui.util.HAlign.LEFT;
	public var vAlign:peote.ui.util.VAlign = peote.ui.util.VAlign.CENTER;
	
	public var xOffset:Float = 0;
	public var yOffset:Float = 0;
	
	public var backgroundColor:peote.view.Color;
	
	var backgroundElement:peote.text.BackgroundElement = null;	
	var cursorElement:peote.text.BackgroundElement = null;
	var selectElement:peote.text.BackgroundElement = null;
	
	#if (!peoteui_no_textmasking && !peoteui_no_masking)
	var maskElement:peote.text.MaskElement;
	#end
	
	public function new(xPosition:Int, yPosition:Int, ?textSize:peote.ui.util.TextSize, zIndex:Int = 0, text:String,
	                    //font:$fontType, fontStyle:$styleType, backgroundColor:peote.view.Color = 0) 
	                    font:peote.text.Font<$styleType>, fontStyle:$styleType, backgroundColor:peote.view.Color = 0)
	{
		//trace("NEW InteractiveTextLine");		
		var width:Int = 0;
		var height:Int = 0;
		if (textSize != null) {
			if (textSize.height != null) height = textSize.height else autoSize |= 1;
			if (textSize.width  != null) width  = textSize.width  else autoSize |= 2;
			if (textSize.hAlign != null) hAlign = textSize.hAlign;
			if (textSize.vAlign != null) vAlign = textSize.vAlign;
			if (textSize.xOffset != null) xOffset = textSize.xOffset;
			if (textSize.yOffset != null) yOffset = textSize.yOffset;
		} else autoSize = 3;
		
		// TODO: fontStyle also optional!
		
		super(xPosition, yPosition, width, height, zIndex);

		this.backgroundColor = backgroundColor;
		
		this.text = text;
		this.font = font;
		
		${switch (glyphStyleHasField.local_zIndex) {
			case true: macro fontStyle.zIndex = zIndex;
			default: macro {}
		}}		
		
		this.fontStyle = fontStyle;
		
	}
	
	override inline function updateVisibleStyle() {
		fontProgram.lineSetStyle(line, fontStyle);
		if (isVisible) fontProgram.updateLine(line);
	}
	
	inline function getAlignedYOffset():Float {
		return switch (vAlign) {
			case peote.ui.util.VAlign.CENTER: (height - line.height) / 2 + yOffset;
			case peote.ui.util.VAlign.BOTTOM: height - line.height + yOffset;
			default: yOffset;
		}
	}
	
	inline function setCreateSelection(_x:Int, _y:Int, _width:Int, _height:Int, y_offset:Float, create = false)
	{		
		var selectX = Std.int(getPositionAtChar(selectFrom));
		var selectWidth = Std.int(getPositionAtChar(selectTo) - selectX);
		var selectY = Std.int(y + y_offset);
		var selectHeight = Std.int(line.height);
		
		#if (!peoteui_no_textmasking && !peoteui_no_masking)
		// horizontally
		if (selectX < _x) { selectWidth -= _x - selectX; selectX = _x; }
		if (selectX + selectWidth > _x + _width) selectWidth = _x + _width - selectX;
		if (selectWidth < 0) selectWidth = 0;

		// vertically
		if (selectY < _y) { selectHeight -= _y - selectY; selectY = _y; }
		if (selectY + selectHeight > _y + _height) selectHeight = _y + _height - selectY;
		if (selectHeight < 0) selectHeight = 0;
		#end

		// TODO: if(selectElement == null) -> create
		
		if (create)	selectElement = fontProgram.createBackground(selectX, selectY, selectWidth, selectHeight, z, 0x555555FF, selectionIsVisible);
		else {
			if (selectElement == null) fontProgram.createBackground(selectX, selectY, selectWidth, selectHeight, z, 0x555555FF, selectionIsVisible);
			fontProgram.setBackground(selectElement, selectX, selectY, selectWidth, selectHeight, z, 0x555555FF, isVisible && selectionIsVisible);
		}
	}
	
	inline function setCreateCursor(_x:Int, _y:Int, _width:Int, _height:Int, y_offset:Float, create = false)
	{		
		var cursorX = Std.int(getPositionAtChar(cursor));
		var cursorWidth = 2;
		var cursorY = Std.int(y + y_offset);
		var cursorHeight = Std.int(line.height);
		
		#if (!peoteui_no_textmasking && !peoteui_no_masking)
		// horizontally
		if (cursorX < _x) { cursorWidth -= _x - cursorX; cursorX = _x; }
		if (cursorX + cursorWidth > _x + _width) cursorWidth = _x + _width - cursorX;
		if (cursorWidth < 0) cursorWidth = 0;
		
		// vertically
		if (cursorY < _y) { cursorHeight -= _y - cursorY; cursorY = _y; }
		if (cursorY + cursorHeight > _y + _height) cursorHeight = _y + _height - cursorY;
		if (cursorHeight < 0) cursorHeight = 0;
		#end
		
		// TODO: if(cursorElement == null) -> create
		
		if (create) cursorElement = fontProgram.createBackground(cursorX, cursorY, cursorWidth, cursorHeight, z, 0xFF0000FF, cursorIsVisible);
		else {
			if(cursorElement == null) fontProgram.createBackground(cursorX, cursorY, cursorWidth, cursorHeight, z, 0xFF0000FF, cursorIsVisible);
			fontProgram.setBackground(cursorElement, cursorX, cursorY, cursorWidth, cursorHeight, z, 0xFF0000FF, isVisible && cursorIsVisible);
		}
	}
	
	override inline function updateVisibleLayout():Void
	{
		//trace("updateVisibleLayout()");
		
		// vertically alignment for text, cursor and selection
		var y_offset:Float = getAlignedYOffset();
				
		// horizontally text alignment
		if (hAlign == peote.ui.util.HAlign.CENTER)
			fontProgram.lineSetPositionSize(line, x, y + y_offset, width, (width - line.textSize)/2 + xOffset, isVisible); // TODO: bug at non-packed fonts without a width glyphstyle!
		else if (hAlign == peote.ui.util.HAlign.RIGHT)
			fontProgram.lineSetPositionSize(line, x, y + y_offset, width, width - line.textSize + xOffset, isVisible);
		else
			fontProgram.lineSetPositionSize(line, x, y + y_offset, width, xOffset, isVisible);
			
		if (isVisible) {
			// TODO: optimize setting z-index in depend of styletyp and better allways adding fontprograms at end of uiDisplay (onAddVisibleToDisplay)
			${switch (glyphStyleHasField.local_zIndex) {
				case true: macro {
					if (fontStyle.zIndex != z) {
						fontStyle.zIndex = z;
						fontProgram.lineSetStyle(line, fontStyle);
					}
				}
				default: macro {}
			}}		
		
			fontProgram.updateLine(line);
		}
		
		if (backgroundColor != 0) fontProgram.setBackground(backgroundElement, x, y, width, height, z, backgroundColor, isVisible);
		
		#if (!peoteui_no_textmasking && !peoteui_no_masking)
		var _x = x;
		var _y = y;
		var _width = width;
		var _height = height;
		
		if (masked) {
			_x += maskX;
			_y += maskY;
			_width = maskWidth;
			_height = maskHeight;
		}
		fontProgram.setMask(maskElement, _x, _y, _width, _height, isVisible);
		
		setCreateSelection(_x, _y, _width, _height, y_offset);
		setCreateCursor(_x, _y, _width, _height, y_offset);
		#else
		setCreateSelection(x, y, width, height, y_offset);
		setCreateCursor(x, y, width, height, y_offset);
		#end
		
	}
	
	override inline function updateVisible():Void
	{
		fontProgram.lineSetStyle(line, fontStyle);
		updateVisibleLayout();
	}
	
	// -----------------
	
	override inline function onAddVisibleToDisplay()
	{
		//trace("onAddVisibleToDisplay()", autoWidth, autoHeight);	
		if (line == null) {
			if (font.notIntoUiDisplay(uiDisplay.number)) {
				fontProgram = font.createFontProgramForUiDisplay(uiDisplay.number, fontStyle, #if (peoteui_no_textmasking || peoteui_no_masking) false #else true #end, true);
				uiDisplay.addProgram(fontProgram); // TODO: better also uiDisplay.addFontProgram() to let clear all skins at once from inside UIDisplay
				trace("create new fontProgram for uiDisplay");
			}
			else {
				fontProgram = font.getFontProgramByUiDisplay(uiDisplay.number);
				if (fontProgram.numberOfGlyphes() == 0) {
					uiDisplay.addProgram(fontProgram);
					trace("add fontProgram to uiDisplay (was already used inside of uiDisplay)");
				}
			}
			
			${switch (glyphStyleHasField.local_zIndex) {
				case true: macro fontStyle.zIndex = z;
				default: macro {}
			}}		
			

			line = fontProgram.createLine(text, x, y, (autoSize & 2 == 0) ? width : null, xOffset, fontStyle);
			text = null; // let GC clear the string (after this.line is created this.text is allways get by fontProgram)
			
			// vertically text alignment
			var y_offset:Float = yOffset;
			if (autoSize & 1 == 0) {
				//if (vAlign == peote.ui.util.VAlign.CENTER) y_offset = (height - line.height) / 2 + yOffset;
				//else if (vAlign == peote.ui.util.VAlign.BOTTOM) y_offset = height - line.height + yOffset;
				y_offset = getAlignedYOffset();
			}
			
			// horizontally text alignment
			if (autoSize & 2 == 0) {
				if (hAlign == peote.ui.util.HAlign.CENTER) {
					fontProgram.lineSetPosition(line, x, y + y_offset, (width - line.textSize) / 2 + xOffset); // TODO: bug for negative and non-packed fonts!
					fontProgram.updateLine(line);
				}
				else if (hAlign == peote.ui.util.HAlign.RIGHT) {
					fontProgram.lineSetPosition(line, x, y + y_offset, width - line.textSize + xOffset);
					fontProgram.updateLine(line);
				}
				else if (y_offset != 0 || xOffset !=0) {
					fontProgram.lineSetPosition(line, x, y + y_offset, xOffset);
					fontProgram.updateLine(line);
				}
				
			} 
			else if (y_offset != 0 || xOffset != 0) { 
				fontProgram.lineSetPosition(line, x, y + y_offset, xOffset);
				fontProgram.updateLine(line);
			}
			
			if (autoSize > 0) {
				if (autoSize & 1 > 0) height = Std.int(line.height);
				if (autoSize & 2 > 0) width = Std.int(line.textSize);
				
				// fit interactive pickables to new width and height
				if ( hasMoveEvent  != 0 ) pickableMove.update(this);
				if ( hasClickEvent != 0 ) pickableClick.update(this);
			}
			
			// TODO: if set background later it have to be created again!
			if (backgroundColor != 0) backgroundElement = fontProgram.createBackground(x, y, width, height, z, backgroundColor);
			
			#if (!peoteui_no_textmasking && !peoteui_no_masking)
			maskElement = fontProgram.createMask(x, y, width, height);
			#end
			
			setCreateSelection(x, y, width, height, y_offset, true); // true -> create new selection
			setCreateCursor(x, y, width, height, y_offset, true); // true -> create new cursor
			
		}
		else {
			if (fontProgram.numberOfGlyphes() == 0) {
				trace("add fontProgram to uiDisplay");
				uiDisplay.addProgram(fontProgram);
			}
			#if (!peoteui_no_textmasking && !peoteui_no_masking)
			fontProgram.addMask(maskElement);
			#end
			
			// TODO: better checking if (backgroundElement != null) ?

			if (backgroundColor != 0 && backgroundElement != null) fontProgram.addBackground(backgroundElement);
			if (selectionIsVisible && selectElement != null) fontProgram.addBackground(selectElement);
			if (cursorIsVisible && cursorElement != null) fontProgram.addBackground(cursorElement);
			fontProgram.addLine(line);
		}
		
		
	}
	
	override inline function onRemoveVisibleFromDisplay()
	{
		//trace("onRemoveVisibleFromDisplay()");
		fontProgram.removeLine(line);
		
		if (cursorIsVisible && cursorElement != null) fontProgram.removeBackground(cursorElement);
		if (selectionIsVisible && selectElement != null) fontProgram.removeBackground(selectElement);
		if (backgroundColor != 0 && backgroundElement != null) fontProgram.removeBackground(backgroundElement);
		
		#if (!peoteui_no_textmasking && !peoteui_no_masking)
		fontProgram.removeMask(maskElement);
		#end
		
		if (fontProgram.numberOfGlyphes()==0)
		{
			uiDisplay.removeProgram(font.removeFontProgramFromUiDisplay(uiDisplay.number));
			trace("remove fontProgram from uiDisplay");

			// TODO:
			//d.buffer.clear();
			//d.program.clear();
		}
	}

	
	// ----------------------- change the text  -----------------------
	
	public inline function setText(text:String, fontStyle:Null<$styleType> = null, autoWidth = false, autoHeight = false)
	{
		//this.text = text;
		if (fontStyle != null) this.fontStyle = fontStyle;
		
		if (line != null) fontProgram.setLine(line, text, line.x, line.y, (!autoWidth) ? width : null, xOffset, this.fontStyle, null, isVisible);
		
		if (autoHeight) setAutoHeight();
		if (autoWidth) setAutoWidth();
		
		// TODO: update cursor if it is out of text.length (or only set it again!)
		// TODO: remove selection
	}
	
	public inline function setAutoHeight() {
		if (line != null) height = Std.int(line.height);
		else autoSize |= 1;
	}
	
	public inline function setAutoWidth() {
		if (line != null) width = Std.int(line.textSize);
		else autoSize |= 2;
	}
	
	
	// ----------------------- TextInput -----------------------
	
	public inline function setInputFocus(e:peote.ui.event.PointerEvent=null):Void {
		if (uiDisplay != null) uiDisplay.setInputFocus(this, e);
	}
	
	public inline function removeInputFocus() {
		if (uiDisplay != null) uiDisplay.removeInputFocus(this);
	}
	
	public inline function textInput(chars:String):Void {
		//trace("InteractiveTextLine - textInput:", s);
		if (line != null) {
			insertChars(chars, cursor, fontStyle);
			fontProgram.updateLine(line);
		}
		
		// TODO:
		if (autoSize & 2 > 0) {
			width = Std.int(line.textSize);
			updatePickable();
		}
		// TODO: only on halign etc.
		updateVisibleLayout();
	}

	
	// ----------- Cursor  -----------
	
	public var cursor(default,set):Int = 0;
	inline function set_cursor(pos:Int):Int {		
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
		if (line != null) 
		{
			#if (!peoteui_no_textmasking && !peoteui_no_masking)
			var _x = x;
			var _y = y;
			var _width = width;
			var _height = height;			
			if (masked) {
				_x += maskX;
				_y += maskY;
				_width = maskWidth;
				_height = maskHeight;
			}			
			setCreateCursor(_x, _y, _width, _height, getAlignedYOffset());
			#else
			setCreateCursor(x, y, width, height, getAlignedYOffset());
			#end
			
/*	
			var cursorX = Std.int(getPositionAtChar(cursor));
			var cursorWidth = 2;
			#if (!peoteui_no_textmasking && !peoteui_no_masking)
			var _x = x;
			var _width = width;			
			if (masked) {
				_x += maskX;
				_width = maskWidth;
			}			
			// horizontally
			if (cursorX < _x) { cursorWidth -= _x - cursorX; cursorX = _x; }
			if (cursorX + cursorWidth > _x + _width) cursorWidth = _x + _width - cursorX;
			if (cursorWidth < 0) cursorWidth = 0;
			#end			
			fontProgram.setBackground(cursorElement, cursorX, cursorElement.y, cursorWidth, cursorElement.h, z, 0xFF0000FF, isVisible && cursorIsVisible);
*/		
		}
		return cursor;
	}
		
	public var cursorIsVisible(default, set):Bool = false;
	inline function set_cursorIsVisible(b:Bool):Bool {
		if (b && !cursorIsVisible && line != null) fontProgram.addBackground(cursorElement);
		else if (!b && cursorIsVisible && line != null) fontProgram.removeBackground(cursorElement);
		return cursorIsVisible = b;
	}
	
	public inline function cursorShow():Void cursorIsVisible = true;
	public inline function cursorHide():Void cursorIsVisible = false;
		
	inline function cursorLeft(isShift:Bool, isCtrl:Bool)
	{
		trace("cursor left");
	}

	// ----------- Seletion  -----------
	
	var selectFrom:Int = 0;
	var selectTo:Int = 0;
		
	public var selectionIsVisible(default, set):Bool = false;
	inline function set_selectionIsVisible(b:Bool):Bool {
		if (line != null && isVisible) {
			if (b && !selectionIsVisible) fontProgram.addBackground(selectElement);
			else if (!b && selectionIsVisible) fontProgram.removeBackground(selectElement);
		}
		return selectionIsVisible = b;
	}
	
	public inline function selectionShow():Void selectionIsVisible = true;
	public inline function selectionHide():Void selectionIsVisible = false;
	
	public function select(from:Int, to:Int) {
		if (from <= to) {
			selectFrom = from;
			selectTo = to;
		} else {
			selectFrom = to;
			selectTo = from;
		}
		if (line != null) 
		{
		
			#if (!peoteui_no_textmasking && !peoteui_no_masking)
			var _x = x;
			var _y = y;
			var _width = width;
			var _height = height;			
			if (masked) {
				_x += maskX;
				_y += maskY;
				_width = maskWidth;
				_height = maskHeight;
			}			
			setCreateSelection(_x, _y, _width, _height, getAlignedYOffset());
			#else
			setCreateSelection(x, y, width, height, getAlignedYOffset());
			#end
			
/*			var selectX = Std.int(getPositionAtChar(selectFrom));
			var selectWidth = Std.int(getPositionAtChar(selectTo) - selectX);
			#if (!peoteui_no_textmasking && !peoteui_no_masking)
			var _x = x;
			var _width = width;			
			if (masked) {
				_x += maskX;
				_width = maskWidth;
			}			
			// horizontally
			if (selectX < _x) { selectWidth -= _x - selectX; selectX = _x; }
			if (selectX + selectWidth > _x + _width) selectWidth = _x + _width - selectX;
			if (selectWidth < 0) selectWidth = 0;
			#end			
			fontProgram.setBackground(selectElement, selectX, selectElement.y, selectWidth, selectElement.h, z, 0x555555FF, isVisible && selectionIsVisible);
*/		
		}
		selectionShow();
	}
	
	// start/stop pointer-selection
	public function startSelection(e:peote.ui.event.PointerEvent):Void {
		if (uiDisplay != null) uiDisplay.startSelection(this, e);
	}
	
	public function stopSelection(e:peote.ui.event.PointerEvent = null):Void {
		if (uiDisplay != null) uiDisplay.stopSelection(this, e);
	}
	
	// events
	function onSelectStart(e:peote.ui.event.PointerEvent):Void {
		trace("selectStart", e.x);
		cursor = getCharAtPosition(uiDisplay.localX(e.x));
		selectionIsVisible = true;
	}
	
	function onSelect(e:peote.ui.event.PointerEvent):Void {
		trace("select", localX(e.x));
		if (localX(e.x) < 0) trace("scroll left");
		if (localX(e.x) > width) trace("scroll right");
	}

	function onSelectStop(e:peote.ui.event.PointerEvent = null):Void {
		trace("selectStop", (e != null) ? e.x : "");
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

	public inline function deleteChar(position:Int = 0) {
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
	
	public var onPointerOver(never, set):InteractiveTextLine<$styleType>->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerOver(f:InteractiveTextLine<$styleType>->peote.ui.event.PointerEvent->Void):InteractiveTextLine<$styleType>->peote.ui.event.PointerEvent->Void
		return setOnPointerOver(this, f);
	
	public var onPointerOut(never, set):InteractiveTextLine<$styleType>->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerOut(f:InteractiveTextLine<$styleType>->peote.ui.event.PointerEvent->Void):InteractiveTextLine<$styleType>->peote.ui.event.PointerEvent->Void 
		return setOnPointerOut(this, f);
	
	public var onPointerMove(never, set):InteractiveTextLine<$styleType>->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerMove(f:InteractiveTextLine<$styleType>->peote.ui.event.PointerEvent->Void):InteractiveTextLine<$styleType>->peote.ui.event.PointerEvent->Void
		return setOnPointerMove(this, f);
	
	public var onPointerDown(never, set):InteractiveTextLine<$styleType>->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerDown(f:InteractiveTextLine<$styleType>->peote.ui.event.PointerEvent->Void):InteractiveTextLine<$styleType>->peote.ui.event.PointerEvent->Void
		return setOnPointerDown(this, f);
	
	public var onPointerUp(never, set):InteractiveTextLine<$styleType>->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerUp(f:InteractiveTextLine<$styleType>->peote.ui.event.PointerEvent->Void):InteractiveTextLine<$styleType>->peote.ui.event.PointerEvent->Void
		return setOnPointerUp(this, f);
	
	public var onPointerClick(never, set):InteractiveTextLine<$styleType>->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerClick(f:InteractiveTextLine<$styleType>->peote.ui.event.PointerEvent->Void):InteractiveTextLine<$styleType>->peote.ui.event.PointerEvent->Void
		return setOnPointerClick(this, f);
		
	public var onMouseWheel(never, set):InteractiveTextLine<$styleType>->peote.ui.event.WheelEvent->Void;
	inline function set_onMouseWheel(f:InteractiveTextLine<$styleType>->peote.ui.event.WheelEvent->Void):InteractiveTextLine<$styleType>->peote.ui.event.WheelEvent->Void 
		return setOnMouseWheel(this, f);
				
}

// -------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------
			
			Context.defineModule(classPackage.concat([className]).join('.'),[c]);
		}
		return TPath({ pack:classPackage, name:className, params:[] });
	}
}
#end
