package peote.ui.skin.interfaces;

import peote.ui.interactive.InteractiveElement;

interface SkinElement 
{
	public function update(uiElement:InteractiveElement, defaultStyle:Dynamic, mx:Int, my:Int, mw:Int, mh:Int):Void;
	public function remove():Bool;
}