package peote.ui.interactive;

#if !macro
@:genericBuild(peote.ui.interactive.UITextLine.UITextLineMacro.build("UITextLine"))
class UITextLine<T> {}
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
			
			//var glyphType = peote.text.Glyph.GlyphMacro.buildClass("Glyph", stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType);
			var fontType = peote.text.Font.FontMacro.buildClass("Font", ["peote","text"], stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType, styleField);
			var fontProgramType = peote.text.FontProgram.FontProgramMacro.buildClass("FontProgram", ["peote","text"], stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType, styleField);
			var lineType  = peote.text.Line.LineMacro.buildClass("Line", ["peote","text"], stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType, styleField);
			
			//var glyphStyleHasMeta = peote.text.Glyph.GlyphMacro.parseGlyphStyleMetas(styleModule+"."+styleName); // trace("FontProgram: glyphStyleHasMeta", glyphStyleHasMeta);
			//var glyphStyleHasField = peote.text.Glyph.GlyphMacro.parseGlyphStyleFields(styleModule+"."+styleName); // trace("FontProgram: glyphStyleHasField", glyphStyleHasField);

			var c = macro

// -------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------

class $className extends peote.ui.interactive.InteractiveElement
{	
	public var onPointerOver(default, set):UITextLine<$styleType>->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerOver(f:UITextLine<$styleType>->peote.ui.event.PointerEvent->Void):UITextLine<$styleType>->peote.ui.event.PointerEvent->Void {
		rebindPointerOver( f.bind(this), f == null);
		return onPointerOver = f;
	}
	public var onPointerOut(default, set):UITextLine<$styleType>->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerOut(f:UITextLine<$styleType>->peote.ui.event.PointerEvent->Void):UITextLine<$styleType>->peote.ui.event.PointerEvent->Void {
		rebindPointerOut( f.bind(this), f == null);
		return onPointerOut = f;
	}

	// --------------------------------------------------------------------------
	
	static var displays:Int = 0;
	
	#if (peoteui_maxDisplays == "1")
		static var displayFontProgram:$fontProgramType;
	#else
		static var displayFontProgram = new haxe.ds.Vector<$fontProgramType>(peote.ui.interactive.UIDisplay.MAX_DISPLAYS);
	#end
	
	public static inline function notIntoDisplay(uiDisplay:peote.ui.interactive.UIDisplay):Bool {
		return ((displays & (1 << uiDisplay.number))==0);
	}
	
	//var fontProgram:peote.text.FontProgram<$styleType>;
	var fontProgram:$fontProgramType;
	public var font:$fontType;
	public var fontStyle:$styleType;
	
	public var text:String;
	public var line:$lineType;
	
	public function new(xPosition:Int = 0, yPosition:Int = 0, width:Int = 100, height:Int = 100, zIndex:Int = 0,
	                    text:String, font:$fontType, fontStyle:$styleType) 
	{
		super(xPosition, yPosition, width, height, zIndex);
		
		this.text = text;
		this.font = font;
		this.fontStyle = fontStyle;
		
		line = new peote.text.Line<$styleType>();
		line.x = x;
		line.y = y;
		line.maxX = x + width;
		line.maxY = y + height;
		line.xOffset = 0;
	}
	
	public function updateStyle(from:Int = 0, to:Null<Int> = null) {
		fontProgram.lineSetStyle(line, fontStyle, from, to);
	}
	
	
	override inline function updateVisible():Void
	{
		fontProgram.lineSetPosition(line, x, y);
		fontProgram.updateLine(line);
	}
	
	// -----------------
	
	override inline function onAddVisibleToDisplay()
	{		
		if (notIntoDisplay(uiDisplay))
		{
			displays |= 1 << uiDisplay.number;
			fontProgram = font.createFontProgram(fontStyle);
			#if (peoteui_maxDisplays == "1")
				displayFontProgram = fontProgram;
			#else
				displayFontProgram.set(uiDisplay.number, fontProgram);
			#end
			uiDisplay.addProgram(fontProgram); // TODO: better also uiDisplay.addFontProgram() to let clear all skins at once from inside UIDisplay
		}
		else
			#if (peoteui_maxDisplays == "1")
				fontProgram = displayFontProgram;
			#else
				fontProgram = displayFontProgram.get(uiDisplay.number));
			#end
		
		fontProgram.setLine(line, text, line.x, line.y, fontStyle);
	}
	
	override inline function onRemoveVisibleFromDisplay()
	{
		fontProgram.removeLine(line);
		
		if (fontProgram.numberOfGlyphes()==0) 
		{
			// for the last element into buffer remove from displays bitmask
			displays &= ~(1 << uiDisplay.number);
			
			#if (peoteui_maxDisplays == "1")
				uiDisplay.removeProgram(displayFontProgram);
			#else
				uiDisplay.removeProgram(displayFontProgram.get(uiDisplay.number));
			#end			
						
			// TODO:
			//d.buffer.clear();
			//d.program.clear();
		}
	}

				
}

// -------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------
			
			Context.defineModule(classPackage.concat([className]).join('.'),[c]);
		}
		return TPath({ pack:classPackage, name:className, params:[] });
	}
}
#end
