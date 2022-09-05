package peote.ui.style.interfaces;

import peote.ui.interactive.Interactive;

@:allow(peote.ui)
interface StyleProgram
{
	private function createElement(uiElement:Interactive, style:Dynamic):StyleElement;
	private function addElement(styleElement:StyleElement):Void;
	private function removeElement(styleElement:StyleElement):Void;
	private function update(styleElement:StyleElement):Void;
}
