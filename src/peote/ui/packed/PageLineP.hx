package peote.ui.packed;
@:allow(peote.ui.packed) class PageLineP {
	public var y(default, null) : Float = 0.0;
	public var textSize(default, null) : Float = 0.0;
	public var lineHeight(default, null) : Float = 0.0;
	public var base(default, null) : Float = 0.0;
	public var height(default, null) : Float = 0.0;
	public var length(get, never) : Int;
	public inline function get_length():Int return glyphes.length;
	var glyphes = new Array<GlyphP>();
	public inline function getGlyph(i:Int):GlyphP return glyphes[i];
	inline function setGlyph(i:Int, glyph:GlyphP) glyphes[i] = glyph;
	inline function pushGlyph(glyph:GlyphP) glyphes.push(glyph);
	inline function insertGlyph(pos:Int, glyph:GlyphP) glyphes.insert(pos, glyph);
	inline function splice(pos:Int, len:Int):Array<GlyphP> return glyphes.splice(pos, len);
	inline function resize(newLength:Int) {
		glyphes.splice(newLength, glyphes.length - newLength);
	}
	inline function append(a:Array<GlyphP>) {
		glyphes = glyphes.concat(a);
	}
	public var visibleFrom(default, null) : Int = 0;
	public var visibleTo(default, null) : Int = 0;
	public var updateFrom(default, null) : Int = 0x1000000;
	public var updateTo(default, null) : Int = 0;
	function new() { }
}