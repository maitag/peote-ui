package peote.ui.config;

import peote.ui.style.interfaces.Style;
//import peote.view.Color;

@:structInit
private class ElementConfigImpl
{
	public var backgroundStyle:Style;
	
	public var backgroundSpace:Space;
	
	public inline function new(backgroundStyle:Style = null, backgroundSpace:Space = null) 
	{
		this.backgroundStyle = backgroundStyle;
		this.backgroundSpace = backgroundSpace;
	}
	
}

@:structInit
@:forward
abstract ElementConfig(ElementConfigImpl) from ElementConfigImpl to ElementConfigImpl
{
	public inline function new(backgroundStyle:Style = null, backgroundSpace:Space = null) {
		this = new ElementConfigImpl(backgroundStyle, backgroundSpace);
	}
	
	
	@:from
	static public inline function fromStyle(s:Style):ElementConfig {
		//return { backgroundStyle:s };
		return new ElementConfigImpl(s);
	}

/*	@:to
	public inline function toStyle():Style {
		return this.backgroundStyle;
	}	
*/

	@:to
	public inline function toSliderConfig():SliderConfig {
		return (this == null) ? null : {backgroundStyle:this.backgroundStyle, backgroundSpace:this.backgroundSpace};
	}	

	@:to
	public inline function toAreaConfig():AreaConfig {
		return (this == null) ? null : {backgroundStyle:this.backgroundStyle, backgroundSpace:this.backgroundSpace};
	}	

	@:to
	public inline function toTextConfig():TextConfig {
		return (this == null) ? null : {backgroundStyle:this.backgroundStyle, backgroundSpace:this.backgroundSpace};
	}	


}