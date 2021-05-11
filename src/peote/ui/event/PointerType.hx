package peote.ui.event;

@:enum abstract PointerType(Int) from Int to Int
{
	var MOUSE = 0;
	var TOUCH = 1;
	var PEN   = 2;
}
