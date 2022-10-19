package peote.ui.style.interfaces;

interface StyleID 
{
	public function getUUID():Int;
	public function isFontStyle():Bool;
	
	public var id(default, null):Int; // custom id	
}
