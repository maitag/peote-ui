package peote.ui.widget;

import peote.layout.ILayoutElement;
import peote.layout.Layout;
import peote.layout.LayoutContainer;
import peote.layout.ContainerType;
import peote.ui.interactive.InteractiveElement;

import peote.ui.event.PointerEvent;


//@:access(peote.layout.LayoutContainer.childs)
@:forward
abstract Widget(LayoutContainer) from LayoutContainer to LayoutContainer
{
	public inline function new(containerType:ContainerType, uiElem:ILayoutElement, layout:Layout = null, widgets:Array<Widget> = null) 
	{	
		this = new LayoutContainer(containerType,
			uiElem,
			layout, widgets);
	}
	
	public var interactiveElement(get, never):InteractiveElement;
	public inline function get_interactiveElement():InteractiveElement return cast this.layoutElement;	
	
	public var onPointerOver(never, set):Widget->PointerEvent->Void;
	inline function set_onPointerOver(f:Widget->PointerEvent->Void):Widget->PointerEvent->Void {
		interactiveElement.rebindPointerOver( f.bind(this), f == null);
		return f;
	}
	
	public var onPointerOut(never, set):Widget->PointerEvent->Void;
	inline function set_onPointerOut(f:Widget->PointerEvent->Void):Widget->PointerEvent->Void {
		interactiveElement.rebindPointerOut( f.bind(this), f == null);
		return f;
	}
	
}
