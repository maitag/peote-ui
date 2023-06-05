package peote.ui.layout;

import peote.layout.ContainerType;
import peote.layout.LayoutOptions;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;
import peote.ui.interactive.UIElement;
import peote.ui.config.ElementConfig;

typedef LayoutBoxEvents = {
	?onPointerOver:LayoutBox->PointerEvent->Void,
	?onPointerOut:LayoutBox->PointerEvent->Void,
	?onPointerUp:LayoutBox->PointerEvent->Void,
	?onPointerDown:LayoutBox->PointerEvent->Void,
	?onPointerClick:LayoutBox->PointerEvent->Void,
	?onMouseWheel:LayoutBox->WheelEvent->Void,
}


@:forward
abstract LayoutBox(LayoutElement) from LayoutElement to LayoutElement
{
	public inline function new(config:ElementConfig = null, layout:LayoutOptions = null, events:LayoutBoxEvents = null, childs:Array<LayoutElement> = null) 
	{
		this = new LayoutElement(ContainerType.BOX, 
			new UIElement(0, 0, 0, 0, 0, config),
			layout,
			childs
		);
		
		if (events != null) {
			this.onPointerOver = events.onPointerOver;
			this.onPointerOut = events.onPointerOut;
			this.onPointerUp = events.onPointerUp;
			this.onPointerDown = events.onPointerDown;
			this.onPointerClick = events.onPointerClick;
			this.onMouseWheel = events.onMouseWheel;
		}
	}
	
	public var layoutElement(get, never):UIElement;
	public inline function get_layoutElement():UIElement return cast this.interactive;	
	@:to public inline function toLayoutElement():UIElement return layoutElement;
	
	public var style(get, set):Dynamic;
	inline function get_style():Dynamic {
		return layoutElement.style;
	}
	inline function set_style(style:Dynamic):Dynamic {
		return layoutElement.style = style;
	}

/*	public function update() {
		(this.layoutElement:Dynamic).update();
	}

	public function updateStyle() {
		(this.layoutElement:Dynamic).updateStyle();
	}

	public function updateLayout() {
		(this.layoutElement:Dynamic).updateLayout();
	}
*/	
}
