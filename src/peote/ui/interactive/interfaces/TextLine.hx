package peote.ui.interactive.interfaces;


interface TextLine 
{	
	public function textInput(chars:String):Void;
	
	public function startSelection(e:peote.ui.event.PointerEvent):Void;
	public function stopSelection(e:peote.ui.event.PointerEvent = null):Void;
	
	private function selectStart(e:peote.ui.event.PointerEvent):Void;
	private function select(e:peote.ui.event.PointerEvent):Void;
	private function selectStop(e:peote.ui.event.PointerEvent = null):Void;
	
	public var cursor(default, set):Int;
	
	public function cursorShow():Void;
	public function cursorHide():Void;
	
	private function cursorLeft(isShift:Bool, isCtrl:Bool):Void;
}