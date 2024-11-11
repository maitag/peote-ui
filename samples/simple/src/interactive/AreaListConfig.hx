package interactive;

import peote.ui.style.interfaces.Style;
import peote.ui.config.AreaConfig;
import peote.ui.config.ElementConfig;
import peote.ui.config.ResizeType;
import peote.ui.config.Space;
import peote.ui.config.Align;

@:structInit
private class AreaListConfigImpl
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

	// this is a new one for "UIAreaList"
	public var hAlign:Align = Align.CENTER;
	
/*	public function new() 
	{
		
	}
*/	
}


@:structInit
@:forward
abstract AreaListConfig(AreaListConfigImpl) from AreaListConfigImpl to AreaListConfigImpl
{
	//inline function new(c:AreaListConfigImpl) {
		//this = c;
	//}
	

	// GLITCH if activate this here:

	/*
	@:from
	static public inline function fromAreaConfig(c: AreaConfig):AreaListConfig {
		return {
			backgroundStyle: c.backgroundStyle,
			backgroundSpace: c.backgroundSpace,
			maskSpace: c.maskSpace,
			resizeType: c.resizeType,
			resizerSize: c.resizerSize,
			resizerEdgeSize: c.resizerEdgeSize,
			minWidth: c.minWidth,
			maxWidth: c.maxWidth,
			minHeight: c.minHeight,
			maxHeight: c.maxHeight
	   };
	}
	*/

	@:to
	public inline function toAreaConfig():AreaConfig {
		return {
			backgroundStyle: this.backgroundStyle,
			backgroundSpace: this.backgroundSpace,
			maskSpace: this.maskSpace,
			resizeType: this.resizeType,
			resizerSize: this.resizerSize,
			resizerEdgeSize: this.resizerEdgeSize,
			minWidth: this.minWidth,
			maxWidth: this.maxWidth,
			minHeight: this.minHeight,
			maxHeight: this.maxHeight
		};
	}

	
	@:from
	static public inline function fromStyle(s:Style):AreaListConfig {
		return { backgroundStyle:s };
	}

	@:to
	public inline function toElementConfig():ElementConfig {
		return { backgroundStyle:this.backgroundStyle, backgroundSpace:this.backgroundSpace };
	}

}