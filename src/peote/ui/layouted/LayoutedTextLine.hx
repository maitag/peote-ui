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

class $className extends $interactiveTextLineType implements peote.ui.interactive.interfaces.TextLine implements peote.layout.ILayoutElement
{
	
	public function new(xPosition:Int, yPosition:Int, ?textSize:peote.ui.util.TextSize, zIndex:Int = 0, text:String, 
	                    //font:$fontType, fontStyle:$styleType)
	                    font:peote.text.Font<$styleType>, ?fontStyle:$styleType, ?textLineStyle:peote.ui.style.TextLineStyle) 
	{
		//trace("NEW LayoutedTextLine");
		super(xPosition, yPosition, textSize, zIndex, text, font, fontStyle, textLineStyle);
	}
		
	
	// ----------- Interface: LayoutElement --------------------

	public inline function showByLayout():Void show();
	public inline function hideByLayout():Void hide();

	public inline function updateByLayout(layoutContainer:peote.layout.LayoutContainer) {
		// TODO: layoutContainer.updateMask() from here to make it only on-need
		
		if (isVisible)
		{ 
			if (layoutContainer.isHidden) // if it is full outside of the Mask (so invisible)
			{
				#if peotelayout_debug
				//trace("removed", layoutContainer.layout.name);
				#end
				hide();
			}
			else {
				_update(layoutContainer);
			}
		}
		else if (!layoutContainer.isHidden) // not full outside of the Mask anymore
		{
			#if peotelayout_debug
			//trace("showed", layoutContainer.layout.name);
			#end
			_update(layoutContainer);
			show();
		}		
	}
	
	public inline function _update(layoutContainer:peote.layout.LayoutContainer) {
		x = Math.round(layoutContainer.x);
		y = Math.round(layoutContainer.y);
		z = Math.round(layoutContainer.depth);
		width = Math.round(layoutContainer.width);
		height = Math.round(layoutContainer.height);
		
		#if (!peoteui_no_textmasking && !peoteui_no_masking)
		if (layoutContainer.isMasked) { // if some of the edges is cut by mask for scroll-area
			maskX = Math.round(layoutContainer.maskX);
			maskY = Math.round(layoutContainer.maskY);
			maskWidth  = Math.round(layoutContainer.maskWidth);
			maskHeight = Math.round(layoutContainer.maskHeight);
		}
		masked = layoutContainer.isMasked;
		#end
		
		updateLayout();
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
