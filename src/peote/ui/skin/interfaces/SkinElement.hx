package peote.ui.skin.interfaces;

import peote.ui.interactive.InteractiveElement;

interface SkinElement 
{
	private function update(uiElement:InteractiveElement, defaultStyle:Dynamic):Void;
	private function updateStyle(uiElement:InteractiveElement, defaultStyle:Dynamic):Void;
	private function updateLayout(uiElement:InteractiveElement, defaultStyle:Dynamic):Void;
	private function remove():Bool;
}