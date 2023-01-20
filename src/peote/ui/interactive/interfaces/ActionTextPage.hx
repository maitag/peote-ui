package peote.ui.interactive.interfaces;

interface ActionTextPage
{
	public function deleteChar():Void;
	public function backspace():Void;
	public function enter():Void;
	
	public function cursorLeft():Void;
	public function cursorRight():Void;
	public function cursorUp():Void;
	public function cursorDown():Void;
}