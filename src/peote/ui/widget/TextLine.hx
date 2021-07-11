package peote.ui.widget;

import peote.layout.ContainerType;
import peote.layout.LayoutOptions;

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
	public inline function new(font, fontStyleTiled, text:String, textLineOptions:TextLineOptions)
	{
		this = new Widget(ContainerType.BOX,
			font.createLayoutTextLine(0, 0, 0, 0, 0, true, text, fontStyleTiled),
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
	//public inline function getFontStyle<T>():T return (cast this.layoutElement).fontStyle;
	public inline function getLayoutTextLine<T>():T return cast this.layoutElement;


}
