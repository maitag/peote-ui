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
	var line:peote.text.Line<$styleType> = null; //$lineType
	
	var fontProgram:peote.text.FontProgram<$styleType>; //$fontProgramType	
	var font:peote.text.Font<$styleType>; //$fontType	
	public var fontStyle:$styleType;
	
	// -------- background style ---------
	var backgroundStyleProgram:peote.ui.style.interfaces.StyleProgram = null;
	var backgroundStyleElement:peote.ui.style.interfaces.StyleElement = null;

	public var backgroundStyle(default, set):Dynamic = null;
	inline function set_backgroundStyle(style:Dynamic):Dynamic {
		if (backgroundStyleElement == null) { // not added to Display yet
			if (style != null) { // add new style
				backgroundStyle = style;
				if (isVisible) createBackgroundStyle();	// access of uiDisplay only after onAddVidibleToDisplay
			}
		}
		else { // already have styleprogram and element 
			if (style != null) {
				if (style.getID() | (style.id << 16) != backgroundStyle.getID() | (backgroundStyle.id << 16))
				{	// if is need another styleprogram
					if (isVisible) backgroundStyleProgram.removeElement(backgroundStyleElement);
					backgroundStyleProgram = null;
					backgroundStyle = style;
					if (isVisible) createBackgroundStyle() else backgroundStyleElement = null;
				} 
				else { // styleprogram is of same type
					backgroundStyle = style;
					backgroundStyleElement.setStyle(style);
					if (isVisible) backgroundStyleProgram.update(backgroundStyleElement);
				}
			} 
			else { // remove style
				if (isVisible) backgroundStyleProgram.removeElement(backgroundStyleElement);
				backgroundStyle = null;
				backgroundStyleProgram = null;
				backgroundStyleElement = null;
			}
		}		
		return backgroundStyle;
	}
	
	// -------- selection style ---------
	var selectionStyleProgram:peote.ui.style.interfaces.StyleProgram = null;
	var selectionStyleElement:peote.ui.style.interfaces.StyleElement = null;
	public var selectionStyle(default, set):Dynamic = null;
	inline function set_selectionStyle(style:Dynamic):Dynamic {
		if (selectionStyleElement == null) { // not added to Display yet
			if (style != null) { // add new style
				selectionStyle = style;
				if (isVisible && selectionIsVisible) {
					#if (!peoteui_no_textmasking && !peoteui_no_masking)
					if (masked) createSelection(x+maskX, y+maskY, maskWidth, maskHeight, getAlignedYOffset(), true);
					else createSelection(x, y, width, height, getAlignedYOffset(), true);
					#else
					createSelection(x, y, width, height, getAlignedYOffset(), true);
					#end
				}
			}
		}
		else { // already have styleprogram and element 
			if (style != null) {
				if (style.getID() | (style.id << 16) != selectionStyle.getID() | (selectionStyle.id << 16))
				{	// if is need another styleprogram
					if (isVisible && selectionIsVisible) selectionStyleProgram.removeElement(selectionStyleElement);
					selectionStyleProgram = null;
					selectionStyle = style;
					if (isVisible && selectionIsVisible) {
						#if (!peoteui_no_textmasking && !peoteui_no_masking)
						if (masked) createSelection(x+maskX, y+maskY, maskWidth, maskHeight, getAlignedYOffset(), true);
						else createSelection(x, y, width, height, getAlignedYOffset(), true);
						#else
						createSelection(x, y, width, height, getAlignedYOffset(), true);
						#end
					}
					else selectionStyleElement = null;
				} 
				else { // styleprogram is of same type
					selectionStyle = style;
					selectionStyleElement.setStyle(style);
					if (isVisible && selectionIsVisible) selectionStyleProgram.update(selectionStyleElement);
				}
			} 
			else { // remove style
				if (isVisible && selectionIsVisible) selectionStyleProgram.removeElement(selectionStyleElement);
				selectionStyle = null;
				selectionStyleProgram = null;
				selectionStyleElement = null;
			}
		}		
		return selectionStyle;
	}
	
	public var selectionIsVisible(default, set):Bool = false;
	inline function set_selectionIsVisible(b:Bool):Bool {
		if (line != null && selectionStyle != null) {
			if (b && !selectionIsVisible) {
				if (selectionStyleElement == null) { // create new selectElement
					#if (!peoteui_no_textmasking && !peoteui_no_masking)
					if (masked) createSelection(x+maskX, y+maskY, maskWidth, maskHeight, getAlignedYOffset(), isVisible);
					else createSelection(x, y, width, height, getAlignedYOffset(), isVisible);
					#else
					createSelection(x, y, width, height, getAlignedYOffset(), isVisible);
					#end
				}
				else if (isVisible) selectionStyleProgram.addElement(selectionStyleElement);
			}
			else if (!b && selectionIsVisible && selectionStyleElement != null && isVisible) selectionStyleProgram.removeElement(selectionStyleElement);
		}
		return selectionIsVisible = b;
	}	
	public inline function selectionShow():Void selectionIsVisible = true;
	public inline function selectionHide():Void selectionIsVisible = false;
	
	// -------- cursor style ---------
	var cursorStyleProgram:peote.ui.style.interfaces.StyleProgram = null;
	var cursorStyleElement:peote.ui.style.interfaces.StyleElement = null;
	public var cursorStyle:Dynamic = null;
	
	public var cursorIsVisible(default, set):Bool = false;
	inline function set_cursorIsVisible(b:Bool):Bool {
// TODO
/*		if (line != null) {
			if (b && !cursorIsVisible) {
				if (cursorElement == null) {
					// create new cursorElement
					#if (!peoteui_no_textmasking && !peoteui_no_masking)
					if (masked) setCreateCursor(x+maskX, y+maskY, maskWidth, maskHeight, getAlignedYOffset(), true);
					else setCreateCursor(x, y, width, height, getAlignedYOffset(), true);
					#else
					setCreateCursor(x, y, width, height, getAlignedYOffset(), true);
					#end
				}
				if (isVisible) fontProgram.addBackground(cursorElement);
			}
			else if (!b && cursorIsVisible && cursorElement != null && isVisible) fontProgram.removeBackground(cursorElement);
		}
*/
		return cursorIsVisible = b;
	}	
	public inline function cursorShow():Void cursorIsVisible = true;
	public inline function cursorHide():Void cursorIsVisible = false;
	
	
	
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

	#if (!peoteui_no_textmasking && !peoteui_no_masking)
	var maskElement:peote.text.MaskElement;
	#end
	
	public function new(xPosition:Int, yPosition:Int, ?textSize:peote.ui.util.TextSize, zIndex:Int = 0, text:String,
	                    //font:$fontType, fontStyle:$styleType) 
	                    font:peote.text.Font<$styleType>, ?fontStyle:$styleType, ?textLineStyle:peote.ui.style.TextLineStyle) //textStyle=null
	{
		//trace("NEW InteractiveTextLine");		
		var width:Int = 0;
		var height:Int = 0;
		if (textSize != null) {
			if (textSize.height != null) { height = textSize.height; autoHeight = false; }
			if (textSize.width  != null) { width  = textSize.width; autoWidth = false; }
			if (textSize.hAlign != null) hAlign = textSize.hAlign;
			if (textSize.vAlign != null) vAlign = textSize.vAlign;
			if (textSize.xOffset != null) xOffset = textSize.xOffset;
			if (textSize.yOffset != null) yOffset = textSize.yOffset;
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
		
		if (textLineStyle != null) {
			backgroundStyle = textLineStyle.backgroundStyle;
			selectionStyle = textLineStyle.selectionStyle;
		}		
	}
	
	inline function getAlignedYOffset():Float
	{
		return switch (vAlign) {
			case peote.ui.util.VAlign.CENTER: (height - line.height) / 2 + yOffset;
			case peote.ui.util.VAlign.BOTTOM: height - line.height + yOffset;
			default: yOffset;
		}
	}
	
	inline function createSelection(x:Int, y:Int, w:Int, h:Int, y_offset:Float, addUpdate:Bool) _setCreateSelection(x, y, w, h, y_offset, addUpdate, true);
	inline function setSelection(x:Int, y:Int, w:Int, h:Int, y_offset:Float, addUpdate:Bool) _setCreateSelection(x, y, w, h, y_offset, addUpdate, false);
	inline function _setCreateSelection(_x:Int, _y:Int, _width:Int, _height:Int, y_offset:Float, addUpdate:Bool, create:Bool)
	{		
		var selectX = Std.int(getPositionAtChar(selectFrom));
		var selectWidth = Std.int(getPositionAtChar(selectTo) - selectX);
		var selectY = Std.int(y + y_offset);
		var selectHeight = Std.int(line.height);		

		var mx = 0;
		var my = 0;
		var mw = selectWidth;
		var mh = selectHeight;
		
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
			if (addUpdate) selectionStyleProgram.addElement(selectionStyleElement);
		}
		else {
			selectionStyleElement.setMasked(this, selectX, selectY, selectWidth, selectHeight, mx, my, mw, mh, z); // TODO zIndex
			if (addUpdate) selectionStyleProgram.update(selectionStyleElement);
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
		
// TODO
/*		if (create) cursorElement = fontProgram.createBackground(cursorX, cursorY, cursorWidth, cursorHeight, z, 0xFF0000FF, isVisible && cursorIsVisible);
		else fontProgram.setBackground(cursorElement, cursorX, cursorY, cursorWidth, cursorHeight, z, 0xFF0000FF, isVisible && cursorIsVisible);
*/
	}
	
	override inline function updateVisibleStyle() {
		fontProgram.lineSetStyle(line, fontStyle);
		if (isVisible) fontProgram.updateLine(line);
		
		styleUpdateVisibleStyle(backgroundStyle, backgroundStyleElement, backgroundStyleProgram);
	}
	
	inline function styleUpdateVisibleStyle(style:Dynamic, styleElement:peote.ui.style.interfaces.StyleElement, styleProgram:peote.ui.style.interfaces.StyleProgram):Void
	{
		if (style != null) {
			styleElement.setStyle(style);
			if (isVisible) styleProgram.update(styleElement);
		}
	}	
	
	override inline function updateVisibleLayout():Void
	{
		//trace("updateVisibleLayout()");
		if (line != null) updateLineLayout();
		styleUpdateVisibleLayout(backgroundStyle, backgroundStyleElement, backgroundStyleProgram);		
	}
		
	inline function updateLineLayout():Void
	{
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
// TODO:
		if (selectionStyleElement != null) setSelection(_x, _y, _width, _height, y_offset, (isVisible && selectionIsVisible));
		//if (cursorElement != null) setCreateCursor(_x, _y, _width, _height, y_offset);
		#else
		if (selectionStyleElement != null) setSelection(x, y, width, height, y_offset, (isVisible && selectionIsVisible));
		//if (cursorElement != null) setCreateCursor(x, y, width, height, y_offset);

		#end		
	}
	
	inline function styleUpdateVisibleLayout(style:Dynamic, styleElement:peote.ui.style.interfaces.StyleElement, styleProgram:peote.ui.style.interfaces.StyleProgram):Void
	{
		if (style != null) {
			styleElement.setLayout(this);
			if (isVisible) styleProgram.update(styleElement);
		}
	}
	
	
	override inline function updateVisible():Void
	{
		if (line == null) {
			fontProgram.lineSetStyle(line, fontStyle, isVisible);
			updateLineLayout();
		}	
		styleUpdateVisible(backgroundStyle, backgroundStyleElement, backgroundStyleProgram);
	}
	
	inline function styleUpdateVisible(style:Dynamic, styleElement:peote.ui.style.interfaces.StyleElement, styleProgram:peote.ui.style.interfaces.StyleProgram):Void
	{
		if (style != null) {
			styleElement.setStyle(style);
			styleElement.setLayout(this);
			if (isVisible) styleProgram.update(styleElement);
		}
	}	
	
	override inline function onAddVisibleToDisplay()
	{
		//trace("onAddVisibleToDisplay()", autoWidth, autoHeight);
		
		if (line != null) {
			#if (!peoteui_no_textmasking && !peoteui_no_masking)
			fontProgram.addMask(maskElement);
			#end
			
			if (selectionIsVisible && selectionStyleElement != null) selectionStyleProgram.addElement(selectionStyleElement);
			if (backgroundStyleElement != null) backgroundStyleProgram.addElement(backgroundStyleElement);
// TODO
/*			
			if (cursorIsVisible && cursorStyleElement != null) fontProgram.addBackground(cursorElement);
*/
			fontProgram.addLine(line);			
		} 
		else
		{
			var fontStylePos = uiDisplay.usedStyleID.indexOf( fontStyle.getID() | (fontStyle.id << 16) );
			if (fontStylePos < 0) {
				if (uiDisplay.autoAddStyles) uiDisplay.autoAddStyleProgram( cast fontProgram = font.createFontProgram(fontStyle, #if (peoteui_no_textmasking || peoteui_no_masking) false #else true #end), fontStyle.getID() | (fontStyle.id << 16) , true );
				else throw('Error by creating new InteractiveTextLine. The style "'+Type.getClassName(Type.getClass(fontStyle))+'" id='+fontStyle.id+' is not inside the availableStyle list of UIDisplay.');
			} else {
				fontProgram = cast uiDisplay.usedStyleProgram[fontStylePos];
				if (fontProgram == null) uiDisplay.addProgramAtStylePos(cast fontProgram = font.createFontProgram(fontStyle, #if (peoteui_no_textmasking || peoteui_no_masking) false #else true #end), fontStylePos);
			}
			
			// TODO fontStyle.zIndex;
			line = fontProgram.createLine(text, x, y, (autoWidth) ? null : width, xOffset, fontStyle);
			
			text = null; // let GC clear the string (after this.line is created this.text is allways get by fontProgram)
			
			// vertically text alignment
			var y_offset:Float = (autoHeight) ? yOffset : getAlignedYOffset();

			// horizontally text alignment
			if (!autoWidth) {
				if (hAlign == peote.ui.util.HAlign.CENTER) {
					fontProgram.lineSetPosition(line, x, y + y_offset, (width - line.textSize) / 2 + xOffset, isVisible); // TODO: bug for negative and non-packed fonts!
					if (isVisible) fontProgram.updateLine(line);
				}
				else if (hAlign == peote.ui.util.HAlign.RIGHT) {
					fontProgram.lineSetPosition(line, x, y + y_offset, width - line.textSize + xOffset, isVisible);
					if (isVisible) fontProgram.updateLine(line);
				}
				else if (y_offset != 0 || xOffset !=0) {
					fontProgram.lineSetPosition(line, x, y + y_offset, xOffset, isVisible);
					if (isVisible) fontProgram.updateLine(line);
				}
				
			} 
			else if (y_offset != 0 || xOffset != 0) { 
				fontProgram.lineSetPosition(line, x, y + y_offset, xOffset, isVisible);
				if (isVisible) fontProgram.updateLine(line);
			}
			
			if (autoSize > 0) {
				// auto aligning width and height to textsize
				if (autoHeight) height = Std.int(line.height);
				if (autoWidth) width = Std.int(line.textSize);
				// fit interactive pickables to new width and height
				if ( hasMoveEvent  != 0 ) pickableMove.update(this);
				if ( hasClickEvent != 0 ) pickableClick.update(this);
			}
			
			#if (!peoteui_no_textmasking && !peoteui_no_masking)
			maskElement = fontProgram.createMask(x, y, width, height);
			#end	
			
			if (backgroundStyle != null) createBackgroundStyle();
			if (selectionStyle != null) createSelection(x, y, width, height, y_offset, selectionIsVisible);
			
			// TODO
			//setCreateCursor(x, y, width, height, y_offset, true); // true -> create new cursor			
		}
		
		//if (backgroundStyleElement != null) backgroundStyleProgram.addElement(backgroundStyleElement);
		//else if (backgroundStyle != null) createBackgroundStyle();		
	}
	
	inline function createBackgroundStyle()
	{
		var stylePos = uiDisplay.usedStyleID.indexOf( backgroundStyle.getID() | (backgroundStyle.id << 16) );
		if (stylePos < 0) {
			if (uiDisplay.autoAddStyles) uiDisplay.autoAddStyleProgram(cast backgroundStyleProgram = backgroundStyle.createStyleProgram(), backgroundStyle.getID() | (backgroundStyle.id << 16) );
			else throw('Error by creating background for new InteractiveTextLine. The style "'+Type.getClassName(Type.getClass(backgroundStyle))+'" id='+backgroundStyle.id+' is not inside the availableStyle list of UIDisplay.');
		} else {
			backgroundStyleProgram = cast uiDisplay.usedStyleProgram[stylePos];
			if (backgroundStyleProgram == null) uiDisplay.addProgramAtStylePos(cast backgroundStyleProgram = backgroundStyle.createStyleProgram(), stylePos);				
		}
		backgroundStyleProgram.addElement(backgroundStyleElement = backgroundStyleProgram.createElement(this, backgroundStyle));
	}
	
	inline function createSelectionStyle(x:Int, y:Int, w:Int, h:Int, mx:Int, my:Int, mw:Int, mh:Int, z:Int)
	{
		var stylePos = uiDisplay.usedStyleID.indexOf( selectionStyle.getID() | (selectionStyle.id << 16) );
		if (stylePos < 0) {
			if (uiDisplay.autoAddStyles) uiDisplay.autoAddStyleProgram(cast selectionStyleProgram = selectionStyle.createStyleProgram(), selectionStyle.getID() | (selectionStyle.id << 16) );
			else throw('Error by creating selection for new InteractiveTextLine. The style "'+Type.getClassName(Type.getClass(selectionStyle))+'" id='+selectionStyle.id+' is not inside the availableStyle list of UIDisplay.');
		} else {
			selectionStyleProgram = cast uiDisplay.usedStyleProgram[stylePos];
			if (selectionStyleProgram == null) uiDisplay.addProgramAtStylePos(cast selectionStyleProgram = selectionStyle.createStyleProgram(), stylePos);				
		}
		selectionStyleElement = selectionStyleProgram.createElementAt(this, x, y, w, h, mx, my, mw, mh, z, selectionStyle);
	}
	
	override inline function onRemoveVisibleFromDisplay()
	{
		//trace("onRemoveVisibleFromDisplay()");
		
		//if (isVisible && line != null) {
		//trace("remove line from fontProgram");
		fontProgram.removeLine(line);
		#if (!peoteui_no_textmasking && !peoteui_no_masking)
		fontProgram.removeMask(maskElement);
		#end
		
		// remove background, selection and cursor styles
		if (backgroundStyleElement != null) backgroundStyleProgram.removeElement(backgroundStyleElement);
		if (selectionIsVisible && selectionStyleElement != null) selectionStyleProgram.removeElement(selectionStyleElement);
		// TODO: cursor
	}

	
	
	// ----------------------- change the text  -----------------------
	
	public inline function setText(text:String, fontStyle:Null<$styleType> = null, forceAutoWidth:Null<Bool> = null, forceAutoHeight:Null<Bool> = null, autoUpdate = false)
	{
		if (fontStyle != null) this.fontStyle = fontStyle;
		
		if (forceAutoWidth != null) autoWidth = forceAutoWidth;
		if (forceAutoHeight != null) autoHeight = forceAutoHeight;
		
		if (line != null) {
			fontProgram.setLine(line, text, x, y, (autoWidth) ? null : width, xOffset, this.fontStyle, null, isVisible);
			if (cursor > line.length) cursor = line.length;
			if (selectTo > line.length) selectTo = line.length;
			if (autoSize > 0) {
				// auto aligning width and height to new textsize
				if (autoHeight) height = Std.int(line.height);
				if (autoWidth) width = Std.int(line.textSize);
				if (autoUpdate) updatePickable();
			}
			if (autoUpdate) updateVisibleLayout();
		} 
		else this.text = text;		
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
// TODO
/*
			if (masked) setCreateCursor(x+maskX, y+maskY, maskWidth, maskHeight, getAlignedYOffset(), (cursorElement == null) ? true : false);
			else setCreateCursor(x, y, width, height, getAlignedYOffset(), (cursorElement == null) ? true : false);
*/
			#else
			//setCreateCursor(x, y, width, height, getAlignedYOffset(), (cursorElement == null) ? true : false);
			#end
		}
		return cursor;
	}
		
		
	inline function cursorLeft(isShift:Bool, isCtrl:Bool)
	{
		trace("cursor left");
	}

	// ----------- Seletion  -----------
	
	var selectFrom:Int = 0;
	var selectTo:Int = 0;
	
	public function select(from:Int, to:Int):Void {
		if (from < 0) from = 0;
		if (to < 0) to = 0;
		if (from <= to) {
			selectFrom = from;
			selectTo = to;
		} else {
			selectFrom = to;
			selectTo = from;
		}
		if (line != null && selectionStyle != null)
		{
			if (selectTo > line.length) selectTo = line.length;
			#if (!peoteui_no_textmasking && !peoteui_no_masking)
			if (masked) _setCreateSelection(x+maskX, y+maskY, maskWidth, maskHeight, getAlignedYOffset(), (isVisible && selectionIsVisible), (selectionStyleElement == null));
			else _setCreateSelection(x, y, width, height, getAlignedYOffset(), (isVisible && selectionIsVisible), (selectionStyleElement == null));
			#else
			_setCreateSelection(x, y, width, height, getAlignedYOffset(), (isVisible && selectionIsVisible), (selectionStyleElement == null));
			#end
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
