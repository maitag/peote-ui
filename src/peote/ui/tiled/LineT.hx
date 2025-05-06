package peote.ui.tiled;
@:allow(peote.ui.tiled) class LineT {
	public var x(default, null) : Float = 0.0;
	public var offset(default, null) : Float = 0.0;
	public var size(default, null) : Float = 0xffff;
	var pageLine = new PageLineT();
	public var y(get, never) : Float;
	public inline function get_y():Float return pageLine.y;
	public var textSize(get, never) : Float;
	public inline function get_textSize():Float return pageLine.textSize;
	public var lineHeight(get, never) : Float;
	public inline function get_lineHeight():Float return pageLine.lineHeight;
	public var height(get, never) : Float;
	public inline function get_height():Float return pageLine.height;
	public var base(get, never) : Float;
	public inline function get_base():Float return pageLine.base;
	public var length(get, never) : Int;
	public inline function get_length():Int return pageLine.length;
	public inline function getGlyph(i:Int):GlyphT return pageLine.getGlyph(i);
	public var visibleFrom(get, never) : Int;
	public inline function get_visibleFrom():Int return pageLine.visibleFrom;
	public var visibleTo(get, never) : Int;
	public inline function get_visibleTo():Int return pageLine.visibleTo;
	public var updateFrom(get, never) : Int;
	public inline function get_updateFrom():Int return pageLine.updateFrom;
	public var updateTo(get, never) : Int;
	public inline function get_updateTo():Int return pageLine.updateTo;
	public function new() { }
}