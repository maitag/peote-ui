package peote.ui.widget;

import peote.layout.LayoutContainer;
import peote.layout.LayoutOptions;
import peote.layout.ContainerType;

import peote.ui.skin.interfaces.Skin;
import peote.ui.event.PointerEvent;

typedef WidgetPointerEventParams = Widget->PointerEvent->Void;

typedef WidgetOptions = {
	> LayoutOptions,
	?skin:Skin,
	?style:Dynamic,
	
	?onPointerOver:WidgetPointerEventParams,
}


//@:access(peote.layout.LayoutContainer.childs)
@:forward
abstract Widget(LayoutContainer) from LayoutContainer to LayoutContainer 
{
	public inline function new(containerType:ContainerType, widgetOptions:WidgetOptions = null, innerLayoutContainer:Array<LayoutContainer> = null) 
	{	
		this = new LayoutContainer(containerType,
			new UIElement(0, 0, 0, 0, widgetOptions.skin, widgetOptions.style),
			widgetOptions, innerLayoutContainer);

		set_onPointerOver(widgetOptions.onPointerOver);
	}
	
	public var uiElement(get, never):UIElement;
	public inline function get_uiElement():UIElement return cast this.layoutElement;
	
	@:to public inline function toUIElement():UIElement return uiElement;
	
	
	public var onPointerOver(never, set):WidgetPointerEventParams;
	inline function set_onPointerOver(f:WidgetPointerEventParams):WidgetPointerEventParams {
		uiElement.rebindPointerOver( f.bind(this), f == null);
		return f;
	}
	
	public var style(get, set):Dynamic;
	inline function get_style():Dynamic {
		return uiElement.style;
	}
	inline function set_style(style:Dynamic):Dynamic {
		return uiElement.style = style;
	}
	
}
