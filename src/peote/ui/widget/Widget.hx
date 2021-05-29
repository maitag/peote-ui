package peote.ui.widget;
import peote.layout.ContainerType;
import peote.layout.LayoutContainer;
import peote.ui.interactive.Button;
import peote.ui.interactive.UIElement;
import peote.ui.skin.RoundedSkin;
import peote.ui.skin.SimpleStyle;
import peote.view.Color;

typedef WidgetOptions = {
	> LayoutOptions,
	?color:Color,
	?skin:RoundedSkin,
	?style:SimpleStyle,
}

private typedef WidgetEventParams = Widget->PointerEvent->Void;

class Widget extends LayoutContainer implements IWidget
{

	var uiElement(get, set):UIElement;
	public inline function get_uiElement():UIElement {
		return cast this.layoutElement;
	}
	public inline function set_uiElement(uiElement):UIElement {
		return this.layoutElement = uiElement;
	}
	
	public function new(widgets:Array<IWidget>) 
	{
		var skin:RoundedSkin = null;
		var style:SimpleStyle = null;
		var uiElement = new UIElement(0, 0, 0, 0, 0, skin, style);
		super(ContainerType.Box, uiElement, widgets);
	}
	
	public function add(widget:IWidget) 
	{
		
	}
	
	public var onPointerOver(default, set):WidgetEventParams;
	inline function set_onPointerOver(f:WidgetEventParams):WidgetEventParams {
		uiElement.rebindPointerOver( f.bind(this), f == null);
		return onPointerOver = f;
	}
	
}