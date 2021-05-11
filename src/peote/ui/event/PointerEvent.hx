package peote.ui.event;

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
