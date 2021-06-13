package peote.ui.interactive;

#if !macro
@:genericBuild(peote.ui.interactive.UITextLine.UITextLineMacro.build())
class UITextLine<T> {}
#else

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.TypeTools;

class UITextLineMacro
{
	public static var cache = new Map<String, Bool>();
	
	static public function build()
	{	
		switch (Context.getLocalType()) {
			case TInst(_, [t]):
				switch (t) {
					case TInst(n, []):
						var style = n.get();
						var styleSuperName:String = null;
						var styleSuperModule:String = null;
						var s = style;
						while (s.superClass != null) {
							s = s.superClass.t.get(); trace("->" + s.name);
							styleSuperName = s.name;
							styleSuperModule = s.module;
						}
						return buildClass(
							"UITextLine",Context.getLocalClass().get().pack, style.pack, style.module, style.name, styleSuperModule, styleSuperName, TypeTools.toComplexType(t)
						);	
					default: Context.error("Type for FontStyle expected", Context.currentPos());
				}
			default: Context.error("Type for FontStyle expected", Context.currentPos());
		}
		return null;
	}
	
	static public function buildClass(className:String, classPackage:Array<String>, stylePack:Array<String>, styleModule:String, styleName:String, styleSuperModule:String, styleSuperName:String, styleType:ComplexType):ComplexType
	{		
		var styleMod = styleModule.split(".").join("_");
		
		className += "__" + styleMod;
		if (styleModule.split(".").pop() != styleName) className += ((styleMod != "") ? "_" : "") + styleName;
		
		if (!cache.exists(className))
		{
			cache[className] = true;
			
			var styleField:Array<String>;
			//if (styleSuperName == null) styleField = styleModule.split(".").concat([styleName]);
			//else styleField = styleSuperModule.split(".").concat([styleSuperName]);
			styleField = styleModule.split(".").concat([styleName]);
			
			//var glyphType = peote.text.Glyph.GlyphMacro.buildClass("Glyph", stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType);
			var fontType = peote.text.Font.FontMacro.buildClass("Font", ["peote","text"], stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType);
			var fontProgramType = peote.text.FontProgram.FontProgramMacro.buildClass("FontProgram", ["peote","text"], stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType);
			var lineType  = peote.text.Line.LineMacro.buildClass("Line", ["peote","text"], stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType);
			
			#if peoteui_debug_macro
			trace('generating Class: '+classPackage.concat([className]).join('.'));	
			
			trace("ClassName:"+className);           // FontProgram__peote_text_GlypStyle
			trace("classPackage:" + classPackage);   // [peote,text]	
			
			trace("StylePackage:" + stylePack);  // [peote.text]
			trace("StyleModule:" + styleModule); // peote.text.GlyphStyle
			trace("StyleName:" + styleName);     // GlyphStyle			
			trace("StyleType:" + styleType);     // TPath(...)
			trace("StyleField:" + styleField);   // [peote,text,GlyphStyle,GlyphStyle]
			#end
			
/*			var glyphStyleHasMeta = peote.text.Glyph.GlyphMacro.parseGlyphStyleMetas(styleModule+"."+styleName); // trace("FontProgram: glyphStyleHasMeta", glyphStyleHasMeta);
			var glyphStyleHasField = peote.text.Glyph.GlyphMacro.parseGlyphStyleFields(styleModule+"."+styleName); // trace("FontProgram: glyphStyleHasField", glyphStyleHasField);
			
			var charDataType:ComplexType;
			if (glyphStyleHasMeta.packed) {
				if (glyphStyleHasMeta.multiTexture && glyphStyleHasMeta.multiSlot) charDataType = macro: {unit:Int, slot:Int, fontData:peote.text.Gl3FontData, metric:peote.text.Gl3FontData.Metric};
				else if (glyphStyleHasMeta.multiTexture) charDataType = macro: {unit:Int, fontData:peote.text.Gl3FontData, metric:peote.text.Gl3FontData.Metric};
				else if (glyphStyleHasMeta.multiSlot) charDataType = macro: {slot:Int, fontData:peote.text.Gl3FontData, metric:peote.text.Gl3FontData.Metric};
				else charDataType = macro: {fontData:peote.text.Gl3FontData, metric:peote.text.Gl3FontData.Metric};
			}
			else  {
				if (glyphStyleHasMeta.multiTexture && glyphStyleHasMeta.multiSlot) charDataType = macro: {unit:Int, slot:Int, min:Int, max:Int, height:Float, base:Float};
				else if (glyphStyleHasMeta.multiTexture) charDataType = macro: {unit:Int, min:Int, max:Int, height:Float, base:Float};
				else if (glyphStyleHasMeta.multiSlot) charDataType = macro: {slot:Int, min:Int, max:Int, height:Float, base:Float};
				else charDataType = macro: {min:Int, max:Int, height:Float, base:Float};
			}
*/
			// -------------------------------------------------------------------------------------------
			var c = macro		



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

				
} // end class

			// -------------------------------------------------------------------------------------------
			// -------------------------------------------------------------------------------------------
			
			Context.defineModule(classPackage.concat([className]).join('.'),[c]);
		}
		return TPath({ pack:classPackage, name:className, params:[] });
	}
}
#end
