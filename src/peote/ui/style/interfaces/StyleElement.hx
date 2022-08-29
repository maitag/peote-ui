package peote.ui.style.interfaces;

import peote.ui.interactive.InteractiveElement;

@:allow(peote.ui)
interface StyleElement 
{
	private function setStyle(style:Dynamic):Void;
	private function setLayout(uiElement:InteractiveElement):Void;
}
