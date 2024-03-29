package peote.ui.interactive.interfaces;

interface ActionTextLine
{
	public function deleteChar():Void;
	public function backspace():Void;
	
	public function delLeft(toLineStart:Bool = false):Void;
	public function delRight(toLineEnd:Bool = false):Void;
	
	public function tabulator():Void;
	
	public function copyToClipboard():Void;
	public function cutToClipboard():Void;
	public function pasteFromClipboard():Void;
	
	public function selectAll():Void;

	public function undo():Void;
	public function redo():Void;
	
	public function cursorLeft(addSelection:Bool = false):Void;
	public function cursorRight(addSelection:Bool = false):Void;
	public function cursorLeftWord(addSelection:Bool = false):Void;
	public function cursorRightWord(addSelection:Bool = false):Void;
	
	public function cursorStart(addSelection:Bool = false):Void;
	public function cursorEnd(addSelection:Bool = false):Void;
}