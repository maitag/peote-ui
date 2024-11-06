package interactive;

import peote.ui.interactive.UIArea;
import peote.ui.interactive.Interactive;
import peote.ui.interactive.interfaces.ParentElement;

//import peote.ui.config.AreaConfig;

class UIAreaList extends UIArea implements ParentElement
{

	public function new(xPosition:Int, yPosition:Int, width:Int, height:Int, zIndex:Int = 0, ?config:AreaListConfig)
	{		
		super(xPosition, yPosition, width, height, zIndex, config);		
		
		// ------------------------------------
		// --------- RESIZE HANDLING ----------		
		// ------------------------------------
		
		this.onResizeWidth = (_, width:Int, deltaWidth:Int) -> {
			
		}

		this.onResizeHeight = (_, height:Int, deltaHeight:Int) -> {
			
		}
	}

	override function onAddUIElementToDisplay()
	{
		super.onAddUIElementToDisplay();

	}

	override public function add(child:Interactive)
	{
		child.x = 0;
		child.width = width;

		if (childs.length == 0) {
			child.y = 0;
		}
		else {
			child.y = childs[childs.length-1].bottom - y;
		}

		super.add(child);

		child.resizeHeight = function(height:Int, deltaHeight:Int) {
			child.maskByElement(this);
			child.updateLayout();
			moveChildsByOffset(childs.indexOf(child)+1, deltaHeight);
		};

	}
	
	override public function remove(child:Interactive)
	{
		var index = childs.indexOf(child);

		if (index == childs.length-1) {
			
		}
		else {
			var yOff = child.height;
			moveChildsByOffset(index+1, -yOff);
		}

		super.remove(child);

	}
	
	function moveChildsByOffset(fromIndex:Int, offset:Int) {
		for (i in fromIndex...childs.length) {
			childs[i].y += offset;
			// if (childs[i].isVisible) {
				childs[i].maskByElement(this);
				childs[i].updateLayout();
			// }
		}
		// updateLayout();
	}
	
}
