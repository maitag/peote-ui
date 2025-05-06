package interactive;

import peote.ui.interactive.UIArea;
import peote.ui.interactive.Interactive;
import peote.ui.interactive.interfaces.ParentElement;

//import peote.ui.config.AreaConfig;


// TODO: let add sliders and resizers to normal UIArea 
class UIAreaScroll extends UIArea implements ParentElement
{

	public function new(xPosition:Int, yPosition:Int, width:Int, height:Int, zIndex:Int = 0, ?config:AreaListConfig)
	{		
		super(xPosition, yPosition, width, height, zIndex, config);		
		
	}

	override function onAddUIElementToDisplay()
	{
		super.onAddUIElementToDisplay();

	}

	override public function add(child:Interactive)
	{
	}
	
	override public function remove(child:Interactive)
	{

	}
	
	
}
