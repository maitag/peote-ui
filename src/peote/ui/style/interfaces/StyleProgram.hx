package peote.ui.style.interfaces;

import peote.ui.interactive.InteractiveElement;

@:allow(peote.ui)
interface StyleProgram
{
	private function createElement(uiElement:InteractiveElement):StyleElement;
	private function addElement(styleElement:StyleElement):Void;
	private function removeElement(styleElement:StyleElement):Void;
	private function update(styleElement:StyleElement):Void;
}
