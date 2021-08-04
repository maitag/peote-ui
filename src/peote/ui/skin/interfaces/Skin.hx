package peote.ui.skin.interfaces;

import peote.ui.UIDisplay;
import peote.ui.interactive.InteractiveElement;


interface Skin
{
	public function addElement(uiDisplay:UIDisplay, uiElement:InteractiveElement):Void;
	public function removeElement(uiDisplay:UIDisplay, uiElement:InteractiveElement):Void;
	public function updateElement(uiDisplay:UIDisplay, uiElement:InteractiveElement, mx:Int, my:Int, mw:Int, mh:Int):Void;
	public function setCompatibleStyle(style:Dynamic):Dynamic;
}