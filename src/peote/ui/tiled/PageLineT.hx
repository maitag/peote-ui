package peote.ui.tiled;
@:allow(peote.ui.tiled) class PageLineT {
	public var y(default, null) : Float = 0.0;
	public var textSize(default, null) : Float = 0.0;
	public var lineHeight(default, null) : Float = 0.0;
	public var base(default, null) : Float = 0.0;
	public var height(default, null) : Float = 0.0;
	public var length(get, never) : Int;
	public inline function get_length():Int return glyphes.length;
	var glyphes = new Array<GlyphT>();
	public inline function getGlyph(i:Int):GlyphT return glyphes[i];
	inline function setGlyph(i:Int, glyph:GlyphT) glyphes[i] = glyph;
	inline function pushGlyph(glyph:GlyphT) glyphes.push(glyph);
	inline function insertGlyph(pos:Int, glyph:GlyphT) glyphes.insert(pos, glyph);
	inline function splice(pos:Int, len:Int):Array<GlyphT> return glyphes.splice(pos, len);
	inline function resize(newLength:Int) {
		glyphes.splice(newLength, glyphes.length - newLength);
	}
	inline function append(a:Array<GlyphT>) {
		glyphes = glyphes.concat(a);
	}
	public var visibleFrom(default, null) : Int = 0;
	public var visibleTo(default, null) : Int = 0;
	public var updateFrom(default, null) : Int = 0x1000000;
	public var updateTo(default, null) : Int = 0;
	function new() { }
}