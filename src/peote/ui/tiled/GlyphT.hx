package peote.ui.tiled;
@:allow(peote.ui.tiled) class GlyphT implements peote.view.Element {
	public var char(default, null) : Int = -1;
	public function new() { }
	inline function setStyle(glyphStyle:peote.ui.style.FontStyleTiled) {
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
	@sizeX
	@varying
	public var width : Float = 0.0;
	@sizeY
	public var height : Float = 0.0;
	@texTile
	private var tile : Int = 0;
}