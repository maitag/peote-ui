package peote.ui.skin.interfaces;

import peote.ui.interactive.InteractiveElement;

interface SkinElement 
{
	public function update(uiElement:InteractiveElement, defaultStyle:Dynamic):Void;
	public function remove():Bool;
}