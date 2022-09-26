package peote.ui.interactive.interfaces;

@:allow(peote.ui.PeoteUIDisplay)
interface TextLine
{
	public function setInputFocus(e:peote.ui.event.PointerEvent = null):Void;
	public function removeInputFocus():Void;
	
	public function textInput(chars:String):Void;
	
	public function startSelection(e:peote.ui.event.PointerEvent):Void;
	public function stopSelection(e:peote.ui.event.PointerEvent = null):Void;
	
	private function onSelectStart(e:peote.ui.event.PointerEvent):Void;
	private function onSelect(e:peote.ui.event.PointerEvent):Void;
	private function onSelectStop(e:peote.ui.event.PointerEvent = null):Void;

	
	public var cursor(default, set):Int;	
	public var cursorIsVisible(default, set):Bool;
	public function cursorShow():Void;
	public function cursorHide():Void;
	
	public function select(from:Int, to:Int):Void;
	public var selectionIsVisible(default, set):Bool;
	public function selectionShow():Void;
	public function selectionHide():Void;
	
	private function cursorLeft(isShift:Bool, isCtrl:Bool):Void;
}