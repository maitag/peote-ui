package peote.ui.widget;

import peote.layout.ContainerType;
import peote.layout.LayoutOptions;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;
import peote.ui.interactive.InteractiveElement;
import peote.ui.widget.Widget;

typedef DivOptions = {
	> LayoutOptions,
	//?layout:Layout,
	
	?onPointerOver:Div->PointerEvent->Void,
	?onPointerOut:Div->PointerEvent->Void,
	?onPointerUp:Div->PointerEvent->Void,
	?onPointerDown:Div->PointerEvent->Void,
	?onPointerClick:Div->PointerEvent->Void,
	?onMouseWheel:Div->WheelEvent->Void,

	
	
	?style:Dynamic,

}


@:forward
abstract Div(Widget) from Widget to Widget
{
	public inline function new(divOptions:DivOptions = null, widgets:Array<Widget> = null) 
	{
		this = new Widget(ContainerType.BOX, 
			new InteractiveElement(0, 0, 0, 0, 0, divOptions.style),
			divOptions,
			widgets
		);
		
		this.onPointerOver = divOptions.onPointerOver;
		this.onPointerOut = divOptions.onPointerOut;
		this.onPointerUp = divOptions.onPointerUp;
		this.onPointerDown = divOptions.onPointerDown;
		this.onPointerClick = divOptions.onPointerClick;
		this.onMouseWheel = divOptions.onMouseWheel;
	}
	
	public var layoutElement(get, never):InteractiveElement;
	public inline function get_layoutElement():InteractiveElement return cast this.layoutElement;	
	@:to public inline function toLayoutElement():InteractiveElement return layoutElement;
	
	public var style(get, set):Dynamic;
	inline function get_style():Dynamic {
		return layoutElement.style;
	}
	inline function set_style(style:Dynamic):Dynamic {
		return layoutElement.style = style;
	}

	public function update() {
		(this.layoutElement:Dynamic).update();
	}

	public function updateStyle() {
		(this.layoutElement:Dynamic).updateStyle();
	}

	public function updateLayout() {
		(this.layoutElement:Dynamic).updateLayout();
	}
	
}
