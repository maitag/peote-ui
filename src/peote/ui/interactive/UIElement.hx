package peote.ui.interactive;

import peote.ui.interactive.InteractiveElement;

import peote.ui.skin.interfaces.Skin;
import peote.ui.skin.interfaces.SkinElement;


@:allow(peote.ui)
class UIElement extends InteractiveElement
{	
	public var skin:Skin = null;
	public var style(default, set):Dynamic = null;
	inline function set_style(s:Dynamic):Dynamic {
		trace("set style");
		if (skin == null) {
			if (s != null) throw ("Error, for styling the widget needs a skin");
			style = s;
		} 
		else style = skin.setCompatibleStyle(s); // TODO: in debug mode trace a warning here if a compatible skin is recreated!
		
		return style;
	}		
	
	//var skinElementIndex:Int;
	var skinElement:SkinElement;
	
	public function new(xPosition:Int=0, yPosition:Int=0, width:Int=100, height:Int=100, zIndex:Int=0, skin:Skin=null, style:Dynamic=null) 
	{
		super(xPosition, yPosition, width, height, zIndex);
		
		this.skin = skin;
		set_style(style);
	}
	
	
	override inline function updateVisible():Void
	{
		if (skin != null) skin.updateElement(uiDisplay, this);
	}
	
	// -----------------
	
	override inline function onAddVisibleToDisplay()
	{
		if (skin != null) skin.addElement(uiDisplay, this);
	}
	
	override inline function onRemoveVisibleFromDisplay()
	{		
		if (skin != null) skin.removeElement(uiDisplay, this);
	}

			
}