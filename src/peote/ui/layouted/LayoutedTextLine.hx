package peote.ui.layouted;

#if !macro
@:genericBuild(peote.ui.layouted.LayoutedTextLine.LayoutedTextLineMacro.build("LayoutedTextLine"))
class LayoutedTextLine<T> {}
#else

import haxe.macro.Expr;
import haxe.macro.Context;
import peote.text.util.Macro;

class LayoutedTextLineMacro
{
	static public function build(name:String):ComplexType return Macro.build(name, buildClass);
	static public function buildClass(className:String, classPackage:Array<String>, stylePack:Array<String>, styleModule:String, styleName:String, styleSuperModule:String, styleSuperName:String, styleType:ComplexType, styleField:Array<String>):ComplexType
	{
		className += Macro.classNameExtension(styleName, styleModule);
		
		if ( Macro.isNotGenerated(className) )
		{
			Macro.debug(className, classPackage, stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType, styleField);
			
			peote.ui.interactive.InteractiveTextLine.InteractiveTextLineMacro.buildClass("InteractiveTextLine", ["peote","ui","interactive"], stylePack, styleModule, styleName, styleSuperModule, styleSuperName, styleType, styleField);
			var interactiveTextLineType:TypePath ={ pack:["peote","ui","interactive"], name:"InteractiveTextLine" + Macro.classNameExtension(styleName, styleModule), params:[] };
			
			var c = macro

// -------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------

class $className extends $interactiveTextLineType implements peote.layout.ILayoutElement
{
	
	public function new(xPosition:Int, yPosition:Int, width:Int, height:Int, zIndex:Int, masked:Bool = false,
	                    //text:String, font:$fontType, fontStyle:$styleType) 
	                    text:String, font:peote.text.Font<$styleType>, fontStyle:$styleType) 
	{
		//trace("NEW LayoutedTextLine");
		super(xPosition, yPosition, width, height, zIndex, masked, text, font, fontStyle);
	}
		
	
	// ----------- Interface: LayoutElement --------------------

	public inline function showByLayout():Void show();
	public inline function hideByLayout():Void hide();

	
	// TODO
	
	var layoutWasHidden = false;
	public function updateByLayout(layoutContainer:peote.layout.LayoutContainer) 
	{
		if (!layoutWasHidden && layoutContainer.isHidden) { // if it is full outside of the Mask (so invisible)
			hideByLayout();
			layoutWasHidden = true;
		}
		else {
			x = Math.round(layoutContainer.x);
			y = Math.round(layoutContainer.y);
			width = Math.round(layoutContainer.width);
			height = Math.round(layoutContainer.height);
						
			if (layoutContainer.isMasked) { // if some of the edges is cut by mask for scroll-area
				//maskX = Math.round(layoutContainer.maskX);
				//maskY = Math.round(layoutContainer.maskY);
				//maskWidth = maskX + Math.round(layoutContainer.maskWidth);
				//maskHeight = maskY + Math.round(layoutContainer.maskHeight);
			}
			else { // if its fully displayed
				//maskX = 0;
				//maskY = 0;
				//maskWidth = w;
				//maskHeight = h;
			}
			
			if (layoutWasHidden) {
				showByLayout();
				layoutWasHidden = false;
			}
			else {
				update();
			}
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
