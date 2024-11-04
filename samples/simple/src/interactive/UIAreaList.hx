package interactive;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Color;

import peote.text.Font;

import peote.ui.PeoteUIDisplay;
import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;

import peote.ui.interactive.UIArea;
import peote.ui.interactive.Interactive;
import peote.ui.interactive.interfaces.ParentElement;
import peote.ui.config.AreaConfig;
import peote.ui.style.*;


class UIAreaList extends UIArea implements ParentElement
{

	public function new(xPosition:Int, yPosition:Int, width:Int, height:Int, zIndex:Int = 0, ?config:AreaConfig)
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
			moveChildsByOffset.bind(childs.length-1)(deltaHeight);
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
			if (childs[i].isVisible) childs[i].updateLayout();
		}
	}
	
}
