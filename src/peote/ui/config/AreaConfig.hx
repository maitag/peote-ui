package peote.ui.config;

import peote.ui.style.interfaces.Style;
//import peote.view.Color;

@:structInit
private class AreaConfigImpl
{
	public var backgroundStyle:Style = null;	
	public var backgroundSpace:Space = null;

	public var maskSpace:Space = null;
	
	public var resizeType:ResizeType = ResizeType.NONE;
	public var resizerSize:Int = 5;
	public var resizerEdgeSize:Int = 7;
	public var minWidth:Int  = 10;
	public var maxWidth:Int  = 2000;
	public var minHeight:Int = 10;
	public var maxHeight:Int = 2000;
	
/*	public function new() 
	{
		
	}
*/	
}


@:structInit
@:forward
abstract AreaConfig(AreaConfigImpl) from AreaConfigImpl to AreaConfigImpl
{
	//inline function new(c:AreaConfigImpl) {
		//this = c;
	//}
	
	@:from
	static public inline function fromStyle(s:Style):AreaConfig {
		return { backgroundStyle:s };
	}

	@:to
	public inline function toElementConfig():ElementConfig {
		return { backgroundStyle:this.backgroundStyle, backgroundSpace:this.backgroundSpace };
	}

}