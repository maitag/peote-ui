package peote.ui.interactive.interfaces;

import lime.ui.KeyCode;
import lime.ui.KeyModifier;

@:allow(peote.ui.PeoteUIDisplay)
interface InputFocus
{
	public function setInputFocus(e:peote.ui.event.PointerEvent = null, setCursor:Bool = false):Void;
	public function removeInputFocus():Void;
	
	public function textInput(chars:String):Void;
	public function keyDown(keyCode:KeyCode, modifier:KeyModifier):Void;
	public function keyUp (keyCode:KeyCode, modifier:KeyModifier):Void;
}