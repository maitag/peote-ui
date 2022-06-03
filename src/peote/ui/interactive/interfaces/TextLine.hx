package peote.ui.interactive.interfaces;


interface TextLine 
{	
	public function textInput(chars:String):Void;
	
	public function startSelection(e:peote.ui.event.PointerEvent):Void;
	public function stopSelection():Void;
	public function select(x:Float):Void;
	
	public var cursor(default, set):Int;
	
	public function cursorShow():Void;
	public function cursorHide():Void;
	
	private function cursorLeft(isShift:Bool, isCtrl:Bool):Void;
}