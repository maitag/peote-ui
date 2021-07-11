package peote.ui.widget;

import peote.layout.ContainerType;
import peote.layout.LayoutOptions;

import peote.ui.skin.interfaces.Skin;
import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;
import peote.ui.interactive.LayoutElement;
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

	
	
	?skin:Skin,
	?style:Dynamic,

}


@:forward
abstract Div(Widget) from Widget to Widget
{
	public inline function new(divOptions:DivOptions = null, widgets:Array<Widget> = null) 
	{
		this = new Widget(ContainerType.BOX, 
			new LayoutElement(0, 0, 0, 0, 0, divOptions.skin, divOptions.style),
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
	
	public var layoutElement(get, never):LayoutElement;
	public inline function get_layoutElement():LayoutElement return cast this.layoutElement;	
	@:to public inline function toLayoutElement():LayoutElement return layoutElement;
	
	public var style(get, set):Dynamic;
	inline function get_style():Dynamic {
		return layoutElement.style;
	}
	inline function set_style(style:Dynamic):Dynamic {
		return layoutElement.style = style;
	}
	
}
