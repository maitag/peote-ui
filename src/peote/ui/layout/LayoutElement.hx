package peote.ui.layout;

import peote.layout.ILayoutElement;
import peote.layout.Layout;
import peote.layout.LayoutContainer;
import peote.layout.ContainerType;
import peote.ui.PeoteUIDisplay;
import peote.ui.interactive.Interactive;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;


@:access(peote.layout.LayoutContainer)
@:forward
abstract LayoutElement(LayoutContainer) from LayoutContainer to LayoutContainer
{
	public inline function new(containerType:ContainerType, interactive:ILayoutElement, layout:Layout = null, childs:Array<LayoutElement> = null) 
	{	
		this = new LayoutContainer(containerType, interactive, layout, childs);
	}
	
	public var childs(get, never):Array<LayoutElement>;
	public inline function get_childs():Array<LayoutElement> return cast this.childs;	
	
	
	public var interactive(get, never):Interactive;
	public inline function get_interactive():Interactive return cast this.layoutElement;	
	
	public inline function setLayoutSize(width:Int, height:Int) this.update(width, height);
	
	public function add(layoutElement:LayoutElement) {
		this.addChild(layoutElement);
	}
	
	inline function onAddToDisplay(display:PeoteUIDisplay) {
		//TODO
		// add childs to display
	}
	
	inline function onRemoveFromDisplay(display:PeoteUIDisplay) {
		//TODO
	}
	
	public function update() {
		interactive.update();
	}

	public function updateStyle() {
		interactive.updateStyle();
	}

	public function updateLayout() {
		interactive.updateLayout();
	}
	
	// ------------ eventhandler ------------
	public var onPointerOver(never, set):LayoutElement->PointerEvent->Void;
	inline function set_onPointerOver(f:LayoutElement->PointerEvent->Void):LayoutElement->PointerEvent->Void return interactive.setOnPointerOver(this, f);

	public var onPointerOut(never, set):LayoutElement->PointerEvent->Void;
	inline function set_onPointerOut(f:LayoutElement->PointerEvent->Void):LayoutElement->PointerEvent->Void return interactive.setOnPointerOut(this, f);
	
	public var onPointerUp(never, set):LayoutElement->PointerEvent->Void;
	inline function set_onPointerUp(f:LayoutElement->PointerEvent->Void):LayoutElement->PointerEvent->Void return interactive.setOnPointerUp(this, f);
	
	public var onPointerDown(never, set):LayoutElement->PointerEvent->Void;
	inline function set_onPointerDown(f:LayoutElement->PointerEvent->Void):LayoutElement->PointerEvent->Void return interactive.setOnPointerDown(this, f);

	public var onPointerClick(never, set):LayoutElement->PointerEvent->Void;
	inline function set_onPointerClick(f:LayoutElement->PointerEvent->Void):LayoutElement->PointerEvent->Void return interactive.setOnPointerClick(this, f);
	
	public var onPointerMove(never, set):LayoutElement->PointerEvent->Void;
	inline function set_onPointerMove(f:LayoutElement->PointerEvent->Void):LayoutElement->PointerEvent->Void return interactive.setOnPointerMove(this, f);
	
	public var onMouseWheel(never, set):LayoutElement->WheelEvent->Void;
	inline function set_onMouseWheel(f:LayoutElement->WheelEvent->Void):LayoutElement->WheelEvent->Void return interactive.setOnMouseWheel(this, f);
	

}
