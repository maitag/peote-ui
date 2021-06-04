package peote.ui.skin.interfaces;

import peote.ui.interactive.InteractiveDisplay;
import peote.ui.interactive.InteractiveElement;


interface Skin
{
	public function addElement(uiDisplay:InteractiveDisplay, uiElement:InteractiveElement):Void;
	public function removeElement(uiDisplay:InteractiveDisplay, uiElement:InteractiveElement):Void;
	public function updateElement(uiDisplay:InteractiveDisplay, uiElement:InteractiveElement):Void;
	public function setCompatibleStyle(style:Dynamic):Dynamic;
}