package peote.ui.widget;

import peote.layout.ContainerType;


import peote.ui.widget.Widget;
import peote.ui.widget.Widget.WidgetOptions;


typedef DivOptions = {
	> WidgetOptions,
}


@:access(peote.layout.LayoutContainer.childs)
@:forward
abstract Div(Widget) from Widget to Widget 
{
	public inline function new(divOptions:WidgetOptions = null, widgets:Array<Widget> = null) 
	{
		this = new Widget(ContainerType.BOX, divOptions, widgets);
	}
	
}
