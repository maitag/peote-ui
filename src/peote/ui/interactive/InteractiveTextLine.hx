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

class $className extends peote.ui.interactive.Interactive
{	
	public var fontProgram:peote.text.FontProgram<$styleType>; //$fontProgramType	
	public var font:peote.text.Font<$styleType>; //$fontType
	
	public var fontStyle:$styleType;
	
	public var text:String;
	public var line:peote.text.Line<$styleType> = null; //$lineType
		
	public var textMasked:Bool;
	
	public var backgroundColor:peote.view.Color;
	var backgroundElement:peote.text.BackgroundElement;
	
	#if (!peoteui_no_textmasking && !peoteui_no_masking)
	var maskElement:peote.text.MaskElement;
	#end
	
	public function new(xPosition:Int, yPosition:Int, width:Int, height:Int, zIndex:Int, textMasked:Bool = false,
	                    //text:String, font:$fontType, fontStyle:$styleType, backgroundColor:peote.view.Color = 0) 
	                    text:String, font:peote.text.Font<$styleType>, fontStyle:$styleType, backgroundColor:peote.view.Color = 0)
	{
		//trace("NEW InteractiveTextLine");
		super(xPosition, yPosition, width, height, zIndex);

		this.textMasked = textMasked;
		this.backgroundColor = backgroundColor;
		
		#if (!peoteui_no_textmasking && !peoteui_no_masking)
		maskElement = new peote.text.MaskElement(xPosition, yPosition, width, height);
		#end
		
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
		if (isVisible) {
			fontProgram.updateLine(line);
		}		
	}
	
	override inline function updateVisibleLayout():Void
	{
		// TODO:
		if (textMasked && isVisible) {
			fontProgram.lineSetPositionSize(line, x, y, width);
		}
		else {
			fontProgram.lineSetPosition(line, x, y);
			if (backgroundColor != 0) fontProgram.setLineBackground(backgroundElement, line, false);
		}
		
		if (isVisible) {
			
			// TODO: optimize setting z-index in depend of styletyp and better allways adding fontprograms at end od uiDisplay (onAddVisibleToDisplay)
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
			
			if (backgroundColor != 0) fontProgram.setLineBackground(backgroundElement, line);
		}
		
		
		
		if (!textMasked) {
			width = Std.int(line.textSize);
		}
		
		#if (!peoteui_no_textmasking && !peoteui_no_masking)
		if (masked && textMasked) maskElement.update(x + maskX, y + maskY, maskWidth, maskHeight);
		else maskElement.update(x, y, width, height);
		
		if (isVisible) fontProgram.updateMask(maskElement);
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
		//trace("onAddVisibleToDisplay");	
		if (line == null) {
			if (font.notIntoUiDisplay(uiDisplay.number)) {
				fontProgram = font.createFontProgramForUiDisplay(uiDisplay.number, fontStyle, #if (peoteui_no_textmasking) false #else true #end, true);
				uiDisplay.addProgram(fontProgram); // TODO: better also uiDisplay.addFontProgram() to let clear all skins at once from inside UIDisplay
			}
			else {
				fontProgram = font.getFontProgramByUiDisplay(uiDisplay.number);
				if (fontProgram.numberOfGlyphes()==0) uiDisplay.addProgram(fontProgram);//TODO: adding mask & bg
			}
			
			${switch (glyphStyleHasField.local_zIndex) {
				case true: macro fontStyle.zIndex = z;
				default: macro {}
			}}		
			
			//line = fontProgram.createLine(text, x, y, fontStyle);
			line = new peote.text.Line<$styleType>();
			fontProgram.setLine(line, text, x, y, (textMasked) ? width : null, null, fontStyle);
			
			if (backgroundColor != 0) backgroundElement = fontProgram.createLineBackground(line, backgroundColor);
			
			if (!textMasked) {
				width = Std.int(line.textSize); // TODO
				
				// fit interactive pickables to new width and height
				if ( hasMoveEvent  != 0 ) pickableMove.update(this);
				if ( hasClickEvent != 0 ) pickableClick.update(this);				
			}
			#if (!peoteui_no_textmasking && !peoteui_no_masking)
			maskElement = fontProgram.createMask(x, y, width, height);
			#end
		}
		else {
			if (fontProgram.numberOfGlyphes() == 0) uiDisplay.addProgram(fontProgram);//TODO: adding mask & bg
			#if (!peoteui_no_textmasking && !peoteui_no_masking)
			fontProgram.addMask(maskElement);
			#end
			if (backgroundColor != 0) fontProgram.addBackground(backgroundElement);
			fontProgram.addLine(line);
		}
		
	}
	
	override inline function onRemoveVisibleFromDisplay()
	{	//trace("onRemoveVisibleFromDisplay");
		fontProgram.removeLine(line);
		if (backgroundColor != 0) fontProgram.removeBackground(backgroundElement);
		#if (!peoteui_no_textmasking && !peoteui_no_masking)
		fontProgram.removeMask(maskElement);
		#end
		
		if (fontProgram.numberOfGlyphes()==0)
		{
			uiDisplay.removeProgram(font.removeFontProgramFromUiDisplay(uiDisplay.number)); //TODO: removing mask & bg
			// TODO:
			//d.buffer.clear();
			//d.program.clear();
		}
	}

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
