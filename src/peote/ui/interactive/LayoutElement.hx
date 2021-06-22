package peote.ui.interactive;

import peote.ui.interactive.UIElement;
import peote.ui.skin.interfaces.Skin;

//@:generic class LayoutElement<O,P> extends UIElement implements peote.layout.LayoutElement
class LayoutElement extends UIElement implements peote.layout.ILayoutElement
{
	//var options:O;
	//var params:P;
	
	public function new(xPosition:Int=0, yPosition:Int=0, width:Int=100, height:Int=100, zIndex:Int=0, skin:Skin=null, style:Dynamic=null) 
	{
		super(xPosition, yPosition, width, height, zIndex, skin, style);
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
				//maskX = Math.round(layoutContainer.maskX);
				//maskY = Math.round(layoutContainer.maskY);
				//maskWidth = maskX + Math.round(layoutContainer.maskWidth);
				//maskHeight = maskY + Math.round(layoutContainer.maskHeight);
			}
			else { // if its fully displayed
				//maskX = 0;
				//maskY = 0;
				//maskWidth = w;
				//maskHeight = h;
			}
			
			if (layoutWasHidden) {
				showByLayout();
				layoutWasHidden = false;
			}
			else update();
		}
	}	
		
}