package peote.ui.widget;

import peote.layout.ContainerType;
import peote.layout.LayoutOptions;
import peote.view.Color;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;
import peote.ui.widget.Widget;

typedef TextLineOptions = {
	> LayoutOptions,
	?onPointerOver:TextLine->PointerEvent->Void,
	?onPointerOut:TextLine->PointerEvent->Void,
	?onPointerUp:TextLine->PointerEvent->Void,
	?onPointerDown:TextLine->PointerEvent->Void,
	?onPointerClick:TextLine->PointerEvent->Void,
	?onMouseWheel:TextLine->WheelEvent->Void,
}


@:forward
abstract TextLine(Widget) from Widget to Widget
{
	public inline function new(font, fontStyle, text:String, textLineOptions:TextLineOptions)
	{
		this = new Widget(ContainerType.BOX,
			font.createLayoutedTextLine(0, 0, null, 0, text, fontStyle, 0),
			textLineOptions
		);
		
		// TODO: TextLineOptions to set masked oder immer auf volle Breite -> set to line.fullWidth
		// optimal noch ne fontprogram funktion die nur die fullWidth zu den chars ausrechnet
		// und dann die layout-width optionen custom machen (extra "TextSize.()" bei width und height)
		
		this.onPointerOver = textLineOptions.onPointerOver;
		this.onPointerOut = textLineOptions.onPointerOut;
		this.onPointerUp = textLineOptions.onPointerUp;
		this.onPointerDown = textLineOptions.onPointerDown;
		this.onPointerClick = textLineOptions.onPointerClick;
		this.onMouseWheel = textLineOptions.onMouseWheel;
	}
	
	// TODO:
	public inline function getLayoutedTextLine<T>():T return cast this.layoutElement;
	
	public var fontStyle(get, set):Dynamic;
	//inline function get_fontStyle() return (this.layoutElement:Dynamic).fontStyle;
	//inline function set_fontStyle(fontStyle) return (this.layoutElement:Dynamic).fontStyle = fontStyle;
	inline function get_fontStyle<T>():T return (cast this.layoutElement).fontStyle;
	inline function set_fontStyle<T>(fontStyle:T):T return (cast this.layoutElement).fontStyle = fontStyle;
	
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
