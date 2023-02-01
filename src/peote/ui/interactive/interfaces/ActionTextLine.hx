package peote.ui.interactive.interfaces;

interface ActionTextLine
{
	public function deleteChar():Void;
	public function backspace():Void;
	public function tabulator():Void;
	
	public function copyToClipboard():Void;
	public function cutToClipboard():Void;
	public function pasteFromClipboard():Void;

	public function cursorLeft():Void;
	public function cursorRight():Void;
}