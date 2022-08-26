package peote.ui.style.interfaces;

import peote.ui.interactive.InteractiveElement;

interface StyleElement 
{
	private function update(uiElement:InteractiveElement):Void;
	private function updateStyle(uiElement:InteractiveElement):Void;
	private function updateLayout(uiElement:InteractiveElement):Void;
	private function remove():Bool;
}
