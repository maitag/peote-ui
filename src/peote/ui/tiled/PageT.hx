package peote.ui.tiled;
@:allow(peote.ui.tiled) class PageT {
	public var x(default, null) : Float = 0.0;
	public var y(default, null) : Float = 0.0;
	public var xOffset(default, null) : Float = 0.0;
	public var yOffset(default, null) : Float = 0.0;
	public var width(default, null) : Float = 0xffff;
	public var height(default, null) : Float = 0xffff;
	public var textWidth(default, null) : Float = 0.0;
	public var textHeight(default, null) : Float = 0.0;
	var pageLines = new Array<PageLineT>();
	public var length(get, never) : Int;
	public inline function get_length():Int return pageLines.length;
	public inline function getPageLine(i:Int):PageLineT return pageLines[i];
	inline function setLine(i:Int, line:PageLineT) pageLines[i] = line;
	inline function pushLine(line:PageLineT) pageLines.push(line);
	inline function resize(newLength:Int) {
		pageLines.splice(newLength, pageLines.length - newLength);
	}
	inline function spliceLines(pos:Int, len:Int):Array<PageLineT> {
		return pageLines.splice(pos, len);
	}
	inline function append(a:Array<PageLineT>) {
		pageLines = pageLines.concat(a);
	}
	public var visibleLineFrom(default, null) : Int = 0;
	public var visibleLineTo(default, null) : Int = 0;
	public var updateLineFrom(default, null) : Int = 0x1000000;
	public var updateLineTo(default, null) : Int = 0;
	public function new() { }
}