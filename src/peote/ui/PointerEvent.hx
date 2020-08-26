package peote.ui;

import lime.ui.Touch;
import lime.ui.MouseButton;

typedef PointerEvent =
{
	x:Int,
	y:Int,
	type:PointerType,
	?touch:Touch,
	?mouseButton:MouseButton
}

@:enum abstract PointerType(Int) from Int to Int
{
	var MOUSE = 0;
	var TOUCH = 1;
	var PEN   = 2;
}
