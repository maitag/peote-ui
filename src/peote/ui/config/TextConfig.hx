package peote.ui.config;

import peote.ui.style.interfaces.Style;
//import peote.view.Color;

@:structInit
class TextConfigImpl
{
	public var backgroundStyle:Style = null;
	
	public var selectionStyle:Style = null;
	//public var selectionFontColor:Color = Color.GREEN;
	
	public var cursorStyle:Style = null;
	//public var cursorFontColor:Color = Color.GREEN;

/*	public function new() 
	{
		
	}
*/	
}

@:structInit
@:forward
abstract TextConfig(TextConfigImpl) from TextConfigImpl to TextConfigImpl
{
	//inline function new(t:_TextLineStyle) {
		//this = t;
	//}
	
	@:from
	static public inline function fromStyle(s:Style):TextConfig {
		return {backgroundStyle:s};
	}

	@:to
	public inline function toStyle():Style {
		return this.backgroundStyle;
	}	
}