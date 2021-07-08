package peote.ui.interactive;

import peote.view.Color;
import peote.view.Display;

import peote.ui.interactive.UIDisplay;


//@:generic class LayoutDisplay<O,P> extends UIDisplay implements peote.layout.LayoutElement
class LayoutDisplay extends UIDisplay implements peote.layout.ILayoutElement
{	
	//var options:O;
	//var params:P;
	
	var innerDisplays:Array<Display>;
	
	public function new(x:Int, y:Int, width:Int, height:Int, color:Color=0x00000000, maxTouchpoints:Int = 3) 
	{
		super(x, y, width, height, color, maxTouchpoints);
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
				x += Math.round(layoutContainer.maskX);
				y += Math.round(layoutContainer.maskY);
				width = Math.round(layoutContainer.maskWidth);
				height = Math.round(layoutContainer.maskHeight);
			}
			
			if (layoutWasHidden) {
				showByLayout();
				layoutWasHidden = false;
			}

		}
	}	

/*	var _peoteView:PeoteView;
	var isVisible:Bool = false;

	public function new(peoteView:PeoteView, color:Color=0x00000000) 
	{
		_peoteView = peoteView;
	}
	
	
	// ------------------ update, show and hide ----------------------
	
	public inline function update(layoutContainer:LayoutContainer) {
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
	
	public inline function show() {
		isVisible = true;
		_peoteView.addDisplay(this);
	}
	
	public inline function hide() {
		isVisible = false;
		_peoteView.removeDisplay(this);
	}
	
	
	// ---------------- interface to peote-layout ---------------------
	
	public inline function showByLayout() {
		if (!isVisible) show();
	}
	
	public inline function hideByLayout() {
		if (isVisible) hide();
	}
	
	public function updateByLayout(layoutContainer:peote.layout.LayoutContainer) {
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
			else update(layoutContainer);
			
		}
		else if (!layoutContainer.isHidden) // not full outside of the Mask anymore
		{
			#if peotelayout_debug
			//trace("showed", layoutContainer.layout.name);
			#end
			update(layoutContainer);
			show();
		}
		
	}	
*/
}


