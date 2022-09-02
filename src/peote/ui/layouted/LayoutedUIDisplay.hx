package peote.ui.layouted;

import peote.layout.LayoutContainer;

import peote.view.Color;

import peote.ui.UIDisplay;
import peote.ui.style.interfaces.StyleID;

class LayoutedUIDisplay extends UIDisplay implements peote.layout.ILayoutElement
{	
	//var options:O;
	//var params:P;
	
	// TODO:
	//var innerDisplays:Array<Display>;
	
	public function new(x:Int, y:Int, width:Int, height:Int, color:Color=0x00000000, maxTouchpoints:Int = 3, availableStyles:Array<StyleID> = null, autoAddStyles:Null<Bool> = null) 
	{
		super(x, y, width, height, color, maxTouchpoints, availableStyles, autoAddStyles);
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


