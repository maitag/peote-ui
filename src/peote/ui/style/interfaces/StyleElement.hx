package peote.ui.style.interfaces;

import peote.ui.interactive.Interactive;
import peote.ui.util.Space;

interface StyleElement 
{
	public var x:Int;
	public var y:Int;
	public var w:Int;
	public var h:Int;
	public var z:Int;
	public function setStyle(style:Dynamic):Void;
	public function setLayout(uiElement:Interactive, space:Space = null):Void;
	public function setMasked(uiElement:Interactive, x:Int, y:Int, w:Int, h:Int, mx:Int, my:Int, mw:Int, mh:Int, z:Int, space:Space = null):Void;
}
