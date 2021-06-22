package peote.ui.widget;

import peote.layout.ContainerType;
import peote.layout.LayoutOptions;
import peote.ui.event.PointerEvent;


import peote.ui.skin.interfaces.Skin;
import peote.ui.widget.Widget;
import peote.ui.interactive.LayoutElement;

typedef DivOptions = {
	> LayoutOptions,
	//?layout:Layout,
	
	?onPointerOver:Div->PointerEvent->Void,

	
	
	?skin:Skin,
	?style:Dynamic,

}


//@:access(peote.layout.LayoutContainer.childs)
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
