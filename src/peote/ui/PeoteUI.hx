package peote.ui;
import peote.layout.LayoutContainer;
import peote.layout.Layout;
import peote.ui.interactive.UIDisplay;


@:forward
abstract PeoteUI(LayoutContainer) from LayoutContainer to LayoutContainer {
	public inline function new(layout:Layout = null, innerLayoutContainer:Array<LayoutContainer> = null) 
	{
		this = new Box(new UIDisplay(0, 0, 0, 0, peote.view.Color.GREY5), layout, innerLayoutContainer);
	}
	
	@:to public inline function display():UIDisplay 
	{
		return cast this.layoutElement;
	}
	
	public inline function onMouseMove(mouseX:Float, mouseY:Float) {
		display().onMouseMove(mouseX, mouseY);
	}
	
}
