package peote.ui.style.interfaces;

import peote.ui.interactive.Interactive;

interface StyleProgram
{
	public function createElement(uiElement:Interactive, style:Dynamic):StyleElement;
	public function createElementAt(uiElement:Interactive, x:Int, y:Int, w:Int, h:Int, mx:Int, my:Int, mw:Int, mh:Int, z:Int, style:Dynamic):StyleElement;
	public function addElement(styleElement:StyleElement):Void;
	public function removeElement(styleElement:StyleElement):Void;
	public function update(styleElement:StyleElement):Void;
}
