package peote.ui.widget;

import peote.layout.ContainerType;
import peote.layout.LayoutOptions;
import peote.ui.event.PointerEvent;

import peote.ui.widget.Widget;

typedef TextLineOptions = {
	> LayoutOptions,
	?onPointerOver:TextLine->PointerEvent->Void,
}


//@:access(peote.layout.LayoutContainer.childs)
@:forward
abstract TextLine(Widget) from Widget to Widget
{
	public inline function new(font, fontStyleTiled, text:String, textLineOptions:TextLineOptions)
	{
		this = new Widget(ContainerType.BOX,
			font.createLayoutTextLine(0, 0, 112, 25, 0, text, fontStyleTiled),
			textLineOptions
		);
		
		this.onPointerOver = textLineOptions.onPointerOver;
	}
	
	// TODO:
	//public inline function getFontStyle<T>():T return (cast this.layoutElement).fontStyle;
	public inline function getLayoutTextLine<T>():T return cast this.layoutElement;


}
