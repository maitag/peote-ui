package peote.ui.interactive;

import peote.ui.interactive.InteractiveElement;

import peote.ui.skin.interfaces.Skin;
import peote.ui.skin.interfaces.SkinElement;
import peote.ui.text.FontSkin;


@:allow(peote.ui)
class UIElement<T> extends InteractiveElement
{	
	public var fontSkin:FontSkin<T> = null;
	public var fontStyle(default, set):Dynamic = null;
	inline function set_fontStyle(s:T):T {
		trace("set fontStyle");
		if (s != null) fontStyle = s;
		else fontStyle = fontSkin.setCompatibleStyle(s); // TODO: in debug mode trace a warning here if a compatible skin is recreated!
		
		return fontStyle;
	}		
	
	//var skinElementIndex:Int;
	var skinElement:SkinElement;
	
	public function new(xPosition:Int=0, yPosition:Int=0, width:Int=100, height:Int=100, zIndex:Int=0, fontSkin:FontSkin<T>, fontStyle:T) 
	{
		super(xPosition, yPosition, width, height, zIndex);
		
		this.fontSkin = fontSkin;
		set_style(fontStyle);
	}
	
	
	override inline function updateVisible():Void
	{
		fontSkin.updateElement(uiDisplay, this);
	}
	
	// -----------------
	
	override inline function onAddVisibleToDisplay()
	{
		fontSkin.addElement(uiDisplay, this);
	}
	
	override inline function onRemoveVisibleFromDisplay()
	{		
		fontSkin.removeElement(uiDisplay, this);
	}

			
}