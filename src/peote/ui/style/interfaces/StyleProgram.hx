package peote.ui.style.interfaces;

import peote.ui.UIDisplay;
import peote.ui.interactive.InteractiveElement;

interface StyleProgram
{
	private function addElement(uiDisplay:UIDisplay, uiElement:InteractiveElement):Void;
	private function removeElement(uiDisplay:UIDisplay, uiElement:InteractiveElement):Bool;
	private function updateElement(uiDisplay:UIDisplay, uiElement:InteractiveElement):Void;
	private function updateElementStyle(uiDisplay:UIDisplay, uiElement:InteractiveElement):Void;
	private function updateElementLayout(uiDisplay:UIDisplay, uiElement:InteractiveElement):Void;
}
