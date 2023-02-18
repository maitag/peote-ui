package peote.ui.interactive.interfaces;

interface ActionTextPage
{
	public function deleteChar():Void;
	public function backspace():Void;
	public function tabulator():Void;
	
	public function copyToClipboard():Void;
	public function cutToClipboard():Void;
	public function pasteFromClipboard():Void;
	
	public function cursorLeft(addSelection:Bool = false):Void;
	public function cursorRight(addSelection:Bool = false):Void;
	public function cursorLeftWord(addSelection:Bool = false):Void;
	public function cursorRightWord(addSelection:Bool = false):Void;
	
	public function cursorUp(addSelection:Bool = false):Void;
	public function cursorDown(addSelection:Bool = false):Void;
	
	public function enter():Void;
}