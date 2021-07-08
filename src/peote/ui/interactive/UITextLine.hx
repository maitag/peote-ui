package peote.ui.interactive;

#if !macro
@:genericBuild(peote.ui.interactive.UITextLine.UITextLineMacro.build("UITextLine"))
class UITextLine<T> extends peote.ui.interactive.InteractiveElement{}
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
			
			//var fontType = TPath({ pack:["peote","text"], name:"Font" + Macro.classNameExtension(styleName, styleModule), params:[] });
			//var fontProgramType = TPath({ pack:["peote","text"], name:"FontProgram" + Macro.classNameExtension(styleName, styleModule), params:[] });
			//var lineType = TPath({ pack:["peote","text"], name:"Line" + Macro.classNameExtension(styleName, styleModule), params:[] });

			
			//var glyphStyleHasMeta = peote.text.Glyph.GlyphMacro.parseGlyphStyleMetas(styleModule+"."+styleName); // trace("FontProgram: glyphStyleHasMeta", glyphStyleHasMeta);
			//var glyphStyleHasField = peote.text.Glyph.GlyphMacro.parseGlyphStyleFields(styleModule+"."+styleName); // trace("FontProgram: glyphStyleHasField", glyphStyleHasField);

			var c = macro

// -------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------

class $className extends peote.ui.interactive.InteractiveElement
{	
	static var displays:Int = 0;
	
	#if (peoteui_maxDisplays == "1")
		//static var displayFontProgram:$fontProgramType;
		static var displayFontProgram:peote.text.FontProgram<$styleType>;
	#else
		//static var displayFontProgram = new haxe.ds.Vector<$fontProgramType>(peote.ui.interactive.UIDisplay.MAX_DISPLAYS);
		static var displayFontProgram = new haxe.ds.Vector<peote.text.FontProgram<$styleType>;>(peote.ui.interactive.UIDisplay.MAX_DISPLAYS);
	#end
	
	public static inline function notIntoDisplay(uiDisplay:peote.ui.interactive.UIDisplay):Bool {
		return ((displays & (1 << uiDisplay.number))==0);
	}
	
	//var fontProgram:$fontProgramType;
	var fontProgram:peote.text.FontProgram<$styleType>;
	
	//public var font:$fontType;
	public var font:peote.text.Font<$styleType>;
	
	public var fontStyle:$styleType;
	
	public var text:String;
	public var line:peote.text.Line<$styleType> = null;
	//public var line:$lineType;
	
	public var masked:Bool;
	
	public function new(xPosition:Int, yPosition:Int, width:Int, height:Int, zIndex:Int, masked:Bool = false,
	                    //text:String, font:$fontType, fontStyle:$styleType) 
	                    text:String, font:peote.text.Font<$styleType>, fontStyle:$styleType) 
	{
		//trace("NEW UITextLine");
		super(xPosition, yPosition, width, height, zIndex);

		this.masked = masked;
		
		this.text = text;
		this.font = font;
		this.fontStyle = fontStyle;
		
	}
	
	public function updateStyle(from:Int = 0, to:Null<Int> = null) {
		//trace("updateStyle",x,y);
		fontProgram.lineSetStyle(line, fontStyle, from, to);
	}
	
	
	override inline function updateVisible():Void
	{
		
		if (masked) {
			line.maxX = x + width;
			line.maxY = y + height;
			fontProgram.lineSetXOffset(line, 0); // need if mask changed
		}
		
		fontProgram.lineSetPosition(line, x, y);
		fontProgram.updateLine(line);
		
		if (!masked) {
			width = Std.int(line.fullWidth);
			// TODO:
			//height= Std.int(line.fullHeight);
		}
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
		
		if (line == null) {
			//line = fontProgram.createLine(text, x, y, fontStyle);
			line = new peote.text.Line<$styleType>();
			if (masked) {
				line.maxX = x + width;
				line.maxY = y + height;
			}
			
			fontProgram.setLine(line, text, x, y, fontStyle);
			
			if (!masked) {
				width = Std.int(line.fullWidth);
				// TODO:
				//height= Std.int(line.fullHeight);
				
				// fit interactive pickables to new width and height
				if ( hasMoveEvent  != 0 ) pickableMove.update(this);
				if ( hasClickEvent != 0 ) pickableClick.update(this);				
			}
		}
		else fontProgram.addLine(line);
		
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
