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
			
			//var fontType = TPath({ pack:["peote","text"], name:"Font" + Macro.classNameExtension(styleName, styleModule), params:[] });
			//var fontProgramType = TPath({ pack:["peote","text"], name:"FontProgram" + Macro.classNameExtension(styleName, styleModule), params:[] });
			//var lineType = TPath({ pack:["peote","text"], name:"Line" + Macro.classNameExtension(styleName, styleModule), params:[] });

			
			//var glyphStyleHasMeta = peote.text.Glyph.GlyphMacro.parseGlyphStyleMetas(styleModule+"."+styleName); // trace("FontProgram: glyphStyleHasMeta", glyphStyleHasMeta);
			//var glyphStyleHasField = peote.text.Glyph.GlyphMacro.parseGlyphStyleFields(styleModule+"."+styleName); // trace("FontProgram: glyphStyleHasField", glyphStyleHasField);

			var c = macro

// -------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------

class $className extends peote.ui.interactive.Interactive
{	
	static var displays:Int = 0;
	
	#if (peoteui_maxDisplays == "1")
		//static var displayFontProgram:$fontProgramType;
		static var displayFontProgram:peote.text.FontProgram<$styleType>;
	#else
		//static var displayFontProgram = new haxe.ds.Vector<$fontProgramType>(peote.ui.UIDisplay.MAX_DISPLAYS);
		static var displayFontProgram = new haxe.ds.Vector<peote.text.FontProgram<$styleType>;>(peote.ui.UIDisplay.MAX_DISPLAYS);
	#end
	
	public static inline function notIntoDisplay(uiDisplay:peote.ui.UIDisplay):Bool {
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
		
	public var textMasked:Bool;
	
	#if (!peoteui_no_textmasking)
	var maskElement:peote.text.MaskElement;
	#end
	
	public function new(xPosition:Int, yPosition:Int, width:Int, height:Int, zIndex:Int, textMasked:Bool = false,
	                    //text:String, font:$fontType, fontStyle:$styleType) 
	                    text:String, font:peote.text.Font<$styleType>, fontStyle:$styleType) 
	{
		//trace("NEW InteractiveTextLine");
		super(xPosition, yPosition, width, height, zIndex);

		this.textMasked = textMasked;
		
		#if (!peoteui_no_textmasking)
		maskElement = new peote.text.MaskElement(xPosition, yPosition, width, height);
		#end
		
		this.text = text;
		this.font = font;
		this.fontStyle = fontStyle;
		
	}
	
	public function updateStyle(from:Int = 0, to:Null<Int> = null) {
		fontProgram.lineSetStyle(line, fontStyle, from, to);
	}
	
	
	override inline function updateVisible():Void
	{
		//trace("updateVisible");
		if (textMasked ) {
			line.maxX = x + width;
			//line.maxY = y + height;
			if (isVisible ) fontProgram.lineSetXOffset(line, 0); // need if mask changed
		}
		
		fontProgram.lineSetPosition(line, x, y);
		
		if (isVisible ) {
			fontProgram.lineSetStyle(line, fontStyle); // TODO: BUG inside peote-text -> if maxX/maxY changed to much in size (RESIZE-EVENT ONLY)?
			fontProgram.updateLine(line);
		}
		
		if (!textMasked) {
			width = Std.int(line.fullWidth);
			// TODO:
			//height= Std.int(line.fullHeight);
		}
		
		#if (!peoteui_no_textmasking)
		if (masked && textMasked) maskElement.update(x + maskX, y + maskY, maskWidth, maskHeight);
		else maskElement.update(x, y, width, height);
		if (isVisible) fontProgram.updateMask(maskElement);
		#end
		
	}
	
	// -----------------
	
	override inline function onAddVisibleToDisplay()
	{	//trace("onAddVisibleToDisplay");	
		if (notIntoDisplay(uiDisplay))
		{
			displays |= 1 << uiDisplay.number;
			fontProgram = font.createFontProgram(fontStyle, true);
			#if (peoteui_maxDisplays == "1")
				displayFontProgram = fontProgram;
			#else
				displayFontProgram.set(uiDisplay.number, fontProgram);
			#end
			uiDisplay.addProgram(fontProgram); // TODO: better also uiDisplay.addFontProgram() to let clear all skins at once from inside UIDisplay
		}
		else {
			#if (peoteui_maxDisplays == "1")
				fontProgram = displayFontProgram;
			#else
				fontProgram = displayFontProgram.get(uiDisplay.number));
			#end
		}
		if (line == null) {
			//line = fontProgram.createLine(text, x, y, fontStyle);
			line = new peote.text.Line<$styleType>();
			if (textMasked) {
				line.maxX = x + width;
				//line.maxY = y + height;
			}
			
			fontProgram.setLine(line, text, x, y, fontStyle);
			
			if (!textMasked) {
				width = Std.int(line.fullWidth);
				// TODO:
				//height= Std.int(line.fullHeight);
				
				// fit interactive pickables to new width and height
				if ( hasMoveEvent  != 0 ) pickableMove.update(this);
				if ( hasClickEvent != 0 ) pickableClick.update(this);				
			}
			#if (!peoteui_no_textmasking)
			maskElement = fontProgram.createMask(x, y, width, height);
			#end
		}
		else {
			fontProgram.addLine(line);
			#if (!peoteui_no_textmasking)
			fontProgram.addMask(maskElement);
			#end
		}
		
	}
	
	override inline function onRemoveVisibleFromDisplay()
	{	//trace("onRemoveVisibleFromDisplay");
		fontProgram.removeLine(line);
		#if (!peoteui_no_textmasking)
		fontProgram.removeMask(maskElement);
		#end
		
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
