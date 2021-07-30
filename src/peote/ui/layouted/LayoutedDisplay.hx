package peote.ui.layouted;

import peote.layout.LayoutContainer;
import peote.ui.interactive.InteractiveDisplay;

import peote.view.Color;


//@:generic class LayoutDisplay<O,P> extends UIDisplay implements peote.layout.LayoutElement
class LayoutedDisplay extends InteractiveDisplay implements peote.layout.ILayoutElement
{	
	//var options:O;
	//var params:P;
	
	// TODO:
	//var innerDisplays:Array<Display>;
	
	public function new(xPosition:Int=0, yPosition:Int=0, width:Int=100, height:Int=100, zIndex:Int=0, color = 0x00000000) 
	{
		super(xPosition, yPosition, width, height, zIndex, color);
	}	
	
	
	// ---------------- interface to peote-layout ---------------------
	
	public inline function showByLayout() show();
	public inline function hideByLayout() hide();
	
	public function updateByLayout(layoutContainer:LayoutContainer) {
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
			else _update(layoutContainer);
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

	inline function _update(layoutContainer:LayoutContainer) {
		x = Math.round(layoutContainer.x);
		y = Math.round(layoutContainer.y);
		
		if (layoutContainer.isMasked) { // if some of the edges is cut by mask for scroll-area
			x += Math.round(layoutContainer.maskX);
			y += Math.round(layoutContainer.maskY);
			width = Math.round(layoutContainer.maskWidth);
			height = Math.round(layoutContainer.maskHeight);
		}
		else {
			width = Math.round(layoutContainer.width);
			height = Math.round(layoutContainer.height);
		}
	}

}


