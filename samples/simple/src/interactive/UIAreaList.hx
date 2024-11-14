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
		
		// TODO: extra _handler for the Slider 
	
		this._onResizeWidth = (_, width:Int, deltaWidth:Int) -> {
			for (child in childs) {
				child.width = width-((maskSpace != null) ? maskSpace.left + maskSpace.right : 0);
				// child.maskByElement(this);
				// child.updateLayout();
			}
		}

		// this._onResizeHeight = (_, height:Int, deltaHeight:Int) -> {}
	}

	override function onAddUIElementToDisplay()
	{
		super.onAddUIElementToDisplay();

		// TODO: try to set all positions here so the textfields have its size
		/*
		for (child in childs) {
			child.resizeHeight = function(height:Int, deltaHeight:Int) {
				child.maskByElement(this, maskSpace);
				child.updateLayout();
				moveChildsByOffset(childs.indexOf(child)+1, deltaHeight);
				innerBottom += deltaHeight;
				if (_onResizeInnerHeight != null) _onResizeInnerHeight(this, innerHeight, deltaHeight);
				if (onResizeInnerHeight != null) onResizeInnerHeight(this, innerHeight, deltaHeight);	
			};
		}
		*/
	}

	override public function add(child:Interactive)
	{
		child.x = 0;
		child.width = width - ((maskSpace != null) ? maskSpace.left + maskSpace.right : 0);

		if (childs.length == 0) {
			child.y = 0;
		}
		else {
			child.y = childs[childs.length-1].bottom - y - ((maskSpace != null) ? maskSpace.top : 0);
		}
		trace(child.height);
		super.add(child);

		/*
		child.resizeHeight = function(height:Int, deltaHeight:Int) {
			child.maskByElement(this, maskSpace);
			child.updateLayout();
			moveChildsByOffset(childs.indexOf(child)+1, deltaHeight);
			innerBottom += deltaHeight;
			if (_onResizeInnerHeight != null) _onResizeInnerHeight(this, innerHeight, deltaHeight);
			if (onResizeInnerHeight != null) onResizeInnerHeight(this, innerHeight, deltaHeight);	
		};
		*/

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

	public function updateChildOnResizeHeight(child:Interactive, deltaHeight:Int)
	{
		// TODO:

		var childIndex:Int = childs.indexOf(child);
		if (childIndex < 0) return;

		trace( Type.getClassName(Type.getClass(child)) );
		
		child.maskByElement(this, maskSpace);
		// if ( Type.getClassName(Type.getClass(child)).indexOf("peote.ui.interactive.UITextPage")<0 )
		child.updateLayout();
		
		// Problem if it is a textfield and the inner is not added to Display
		moveChildsByOffset(childIndex+1, deltaHeight);

		innerBottom += deltaHeight;
		if (_onResizeInnerHeight != null) _onResizeInnerHeight(this, innerHeight, deltaHeight); // TODO: extra event for this!
		if (onResizeInnerHeight != null) onResizeInnerHeight(this, innerHeight, deltaHeight);
	}
	
	function moveChildsByOffset(fromIndex:Int, offset:Int) {
		for (i in fromIndex...childs.length) {
			childs[i].y += offset;
			// if (childs[i].isVisible) {
				childs[i].maskByElement(this, maskSpace);
				childs[i].updateLayout();
			// }
		}
		//updateLayout();
	}
	



}
