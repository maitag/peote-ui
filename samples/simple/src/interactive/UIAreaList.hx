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
	
		setOnResizeWidthIntern(this, function(_,_,_) {
			for (child in childs) {
				child.width = this.width-((maskSpace != null) ? maskSpace.left + maskSpace.right : 0);
				// child.maskByElement(this);
				// child.updateLayout();
			}
		});

		// this._onResizeHeight = (_, height:Int, deltaHeight:Int) -> {}
	}

	var _firstTimeAdded = true;
	var _autosizedChilds = new Array<Interactive>();
	override function onAddUIElementToDisplay()
	{
		if (_firstTimeAdded) { // detect where is text-elements what have autosize and is zero at first run
			for (child in childs) {
				if ( child.height == 0 && Type.getClassName(Type.getClass(child)).indexOf("peote.ui.interactive.UITextPage")>=0) {
					_autosizedChilds.push(child);
				}
			}
		}

		super.onAddUIElementToDisplay();

		if (_firstTimeAdded) {
			_firstTimeAdded = false;
			for (child in _autosizedChilds) {
				updateChildOnResizeHeight(child, 0, child.height);
			}
			_autosizedChilds = null;		
		}

	}

	public function addResizable(child:Interactive) _add(child, true);
	override public function add(child:Interactive) _add(child, false);
	function _add(child:Interactive, addResizeInternEvent:Bool)
	{
		child.x = 0;
		child.width = width - ((maskSpace != null) ? maskSpace.left + maskSpace.right : 0);

		if (childs.length == 0) {
			child.y = 0;
		}
		else {
			child.y = childs[childs.length-1].bottom - y - ((maskSpace != null) ? maskSpace.top : 0);
		}
		
		super.add(child);

		if (addResizeInternEvent) child.setOnResizeHeightIntern(child, updateChildOnResizeHeight); 

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

	public function updateChildOnResizeHeight(child:Interactive, height:Int, deltaHeight:Int)
	{
		// detect where is text-elements what have autosize and is zero before added
		if (_firstTimeAdded && height == deltaHeight && Type.getClassName(Type.getClass(child)).indexOf("peote.ui.interactive.UITextPage")>=0) return;

		// TODO:

		var childIndex:Int = childs.indexOf(child);
		if (childIndex < 0) return;

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
