package peote.ui.interactive;

#if !macro
@:genericBuild(peote.ui.interactive.TextLine.TextLineMacro.build("TextLine"))
class TextLine<T> {}
#else

import haxe.macro.Expr;
import haxe.macro.Context;
import peote.text.util.Macro;

class TextLineMacro
{
	static public function build(name:String):ComplexType return Macro.build(name, buildClass);
	static public function buildClass(className:String, classPackage:Array<String>, stylePack:Array<String>, styleModule:String, styleName:String, styleSuperModule:String, styleSuperName:String, styleType:ComplexType, styleField:Array<String>):ComplexType
	{
		className += Macro.classNameExtension(styleName, styleModule);
		
		if ( Macro.isNotGenerated(className) )
		{
			Macro.debug(className, classPackage, stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType, styleField);
			
			//var fontType = peote.text.Font.FontMacro.buildClass("Font", ["peote","text"], stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType, styleField);
			peote.ui.interactive.UITextLine.UITextLineMacro.buildClass("UITextLine", classPackage, stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType, styleField);
			var uiTextLineType:TypePath ={ pack:classPackage, name:"UITextLine" + Macro.classNameExtension(styleName, styleModule), params:[] };

			var c = macro

// -------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------

class $className extends $uiTextLineType
{
	public var onPointerOver(default, set):TextLine<$styleType>->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerOver(f:TextLine<$styleType>->peote.ui.event.PointerEvent->Void):TextLine<$styleType>->peote.ui.event.PointerEvent->Void
		return setOnPointerOver(this, f);
	
	public var onPointerOut(default, set):TextLine<$styleType>->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerOut(f:TextLine<$styleType>->peote.ui.event.PointerEvent->Void):TextLine<$styleType>->peote.ui.event.PointerEvent->Void 
		return setOnPointerOut(this, f);
	
	public var onPointerMove(default, set):TextLine<$styleType>->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerMove(f:TextLine<$styleType>->peote.ui.event.PointerEvent->Void):TextLine<$styleType>->peote.ui.event.PointerEvent->Void
		return setOnPointerMove(this, f);
	
	public var onPointerDown(default, set):TextLine<$styleType>->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerDown(f:TextLine<$styleType>->peote.ui.event.PointerEvent->Void):TextLine<$styleType>->peote.ui.event.PointerEvent->Void
		return setOnPointerDown(this, f);
	
	public var onPointerUp(default, set):TextLine<$styleType>->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerUp(f:TextLine<$styleType>->peote.ui.event.PointerEvent->Void):TextLine<$styleType>->peote.ui.event.PointerEvent->Void
		return setOnPointerUp(this, f);
	
	public var onPointerClick(default, set):TextLine<$styleType>->peote.ui.event.PointerEvent->Void;
	inline function set_onPointerClick(f:TextLine<$styleType>->peote.ui.event.PointerEvent->Void):TextLine<$styleType>->peote.ui.event.PointerEvent->Void
		return setOnPointerClick(this, f);
		
	public var onMouseWheel(default, set):TextLine<$styleType>->peote.ui.event.WheelEvent->Void;
	inline function set_onMouseWheel(f:TextLine<$styleType>->peote.ui.event.WheelEvent->Void):TextLine<$styleType>->peote.ui.event.WheelEvent->Void 
		return setOnMouseWheel(this, f);
	
	
	public function new(xPosition:Int, yPosition:Int, width:Int, height:Int, zIndex:Int, masked:Bool = false,
	                    //text:String, font:$fontType, fontStyle:$styleType) 
	                    text:String, font:peote.text.Font<$styleType>, fontStyle:$styleType) 
	{	
		super(xPosition, yPosition, width, height, zIndex, masked, text, font, fontStyle);		
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
