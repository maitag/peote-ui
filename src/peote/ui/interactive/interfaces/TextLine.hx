package peote.ui.interactive.interfaces;


interface TextLine 
{
	public var cursor(default, set):Int;
	
	public function cursorShow():Void;
	public function cursorHide():Void;
	
	private function edit_textInput(chars:String):Void;
	private function cursorLeft(isShift:Bool, isCtrl:Bool):Void;
}