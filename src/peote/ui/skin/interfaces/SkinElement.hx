package peote.ui.skin.interfaces;

import peote.ui.interactive.UIElement;

interface SkinElement 
{
	public function update(uiElement:UIElement, defaultStyle:Dynamic):Void;
	public function remove():Bool;
}