package peote.ui.event;

#if (haxe_ver >= 4.0) enum #else @:enum#end
abstract PointerType(Int) from Int to Int
{
	var MOUSE = 0;
	var TOUCH = 1;
	var PEN   = 2;
}
