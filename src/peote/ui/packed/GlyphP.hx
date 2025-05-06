package peote.ui.packed;
@:allow(peote.ui.packed) class GlyphP implements peote.view.Element {
	public var char(default, null) : Int = -1;
	public function new() { }
	inline function setStyle(glyphStyle:peote.ui.style.FontStylePacked) {
		{
			width = glyphStyle.width;
			height = glyphStyle.height;
			color = glyphStyle.color;
			tilt = glyphStyle.tilt;
			letterSpace = glyphStyle.letterSpace;
		};
	}
	@posX
	public var x : Float = 0.0;
	@posY
	public var y : Float = 0.0;
	@color
	public var color : peote.view.Color = 0xffffffff;
	@custom
	public var tilt : Float = 0.0;
	public var letterSpace : Float = 0.0;
	public var width(default, set) : Float;
	private function set_width(value:Float):Float {
		if (width > 0.0) w = w / width * value else w = 0;
		return width = value;
	}
	public var height(default, set) : Float;
	private function set_height(value:Float):Float {
		if (height > 0.0) h = h / height * value else h = 0;
		return height = value;
	}
	@sizeX
	private var w : Float = 0.0;
	@sizeY
	private var h : Float = 0.0;
	@texX
	private var tx : Float = 0.0;
	@texY
	private var ty : Float = 0.0;
	@texW
	private var tw : Float = 0.0;
	@texH
	private var th : Float = 0.0;
}