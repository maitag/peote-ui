package peote.ui.widget;

import peote.layout.ILayoutElement;
import peote.layout.Layout;
import peote.layout.LayoutContainer;
import peote.layout.ContainerType;
import peote.ui.interactive.InteractiveElement;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;


@:access(peote.layout.LayoutContainer.childs)
@:forward
abstract Widget(LayoutContainer) from LayoutContainer to LayoutContainer
{
	public inline function new(containerType:ContainerType, uiElem:ILayoutElement, layout:Layout = null, widgets:Array<Widget> = null) 
	{	
		this = new LayoutContainer(containerType,
			uiElem,
			layout, widgets);
	}
	
	public var childs(get, never):Array<Widget>;
	public inline function get_childs():Array<Widget> return cast this.childs;	
	
	
	public var interactiveElement(get, never):InteractiveElement;
	public inline function get_interactiveElement():InteractiveElement return cast this.layoutElement;	
	
	
	
	// ------------ eventhandler ------------
	public var onPointerOver(never, set):Widget->PointerEvent->Void;
	inline function set_onPointerOver(f:Widget->PointerEvent->Void):Widget->PointerEvent->Void return interactiveElement.setOnPointerOver(this, f);

	public var onPointerOut(never, set):Widget->PointerEvent->Void;
	inline function set_onPointerOut(f:Widget->PointerEvent->Void):Widget->PointerEvent->Void return interactiveElement.setOnPointerOut(this, f);
	
	public var onPointerUp(never, set):Widget->PointerEvent->Void;
	inline function set_onPointerUp(f:Widget->PointerEvent->Void):Widget->PointerEvent->Void return interactiveElement.setOnPointerUp(this, f);
	
	public var onPointerDown(never, set):Widget->PointerEvent->Void;
	inline function set_onPointerDown(f:Widget->PointerEvent->Void):Widget->PointerEvent->Void return interactiveElement.setOnPointerDown(this, f);

	public var onPointerClick(never, set):Widget->PointerEvent->Void;
	inline function set_onPointerClick(f:Widget->PointerEvent->Void):Widget->PointerEvent->Void return interactiveElement.setOnPointerClick(this, f);
	
	public var onPointerMove(never, set):Widget->PointerEvent->Void;
	inline function set_onPointerMove(f:Widget->PointerEvent->Void):Widget->PointerEvent->Void return interactiveElement.setOnPointerMove(this, f);
	
	public var onMouseWheel(never, set):Widget->WheelEvent->Void;
	inline function set_onMouseWheel(f:Widget->WheelEvent->Void):Widget->WheelEvent->Void return interactiveElement.setOnMouseWheel(this, f);
	

}
