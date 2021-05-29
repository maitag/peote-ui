package peote.ui.skin.interfaces;

import peote.ui.interactive.UIDisplay;
import peote.ui.interactive.UIElement;


interface Skin
{
	public function addElement(uiDisplay:UIDisplay, uiElement:UIElement):Void;
	public function removeElement(uiDisplay:UIDisplay, uiElement:UIElement):Void;
	public function updateElement(uiDisplay:UIDisplay, uiElement:UIElement):Void;
	public function createDefaultStyle():Dynamic;
}