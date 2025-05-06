package peote.ui.tiled;
@:access(peote.text.FontConfig)
class FontProgramT extends peote.view.Program {
	public var font : FontT;
	public var fontStyle : peote.ui.style.FontStyleTiled;
	public var isMasked(default, null) = false;
	var maskProgram : peote.view.Program;
	var maskBuffer : peote.view.Buffer<peote.text.MaskElement>;
	public var skinPrograms : peote.text.skin.SkinProgramArray = null;
	var _buffer : peote.view.Buffer<GlyphT>;
	public function new(font:FontT, fontStyle:peote.ui.style.FontStyleTiled, isMasked:Bool = false, bufferMinSize:Int = 1024, bufferGrowSize:Int = 1024, bufferAutoShrink:Bool = true) {
		_buffer = new peote.view.Buffer<GlyphT>(bufferMinSize, bufferGrowSize, bufferAutoShrink);
		super(_buffer);
		if (isMasked) enableMasking();
		setFont(font);
		setFontStyle(fontStyle);
	}
	override public function addToDisplay(display:peote.view.Display, ?atProgram:peote.view.Program, addBefore:Bool = false) {
		super.addToDisplay(display, atProgram, addBefore);
		if (isMasked) maskProgram.addToDisplay(display, this, true);
		if (skinPrograms != null) {
			for (skinProgram in skinPrograms) {
				if (skinProgram.depthIndex < 0) skinProgram.addToDisplay(display, this, true) else skinProgram.addToDisplay(display);
			};
		};
	}
	override public function removeFromDisplay(display:peote.view.Display):Void {
		super.removeFromDisplay(display);
		if (isMasked) maskProgram.removeFromDisplay(display);
		if (skinPrograms != null) for (skinProgram in skinPrograms) skinProgram.removeFromDisplay(display);
	}
	public inline function enableMasking() {
		isMasked = true;
		maskBuffer = new peote.view.Buffer<peote.text.MaskElement>(16, 16, true);
		maskProgram = new peote.view.Program(maskBuffer);
		maskProgram.mask = peote.view.Mask.DRAW;
		maskProgram.colorEnabled = false;
		mask = peote.view.Mask.USE;
		if (skinPrograms != null) for (skinProgram in skinPrograms) if (skinProgram.useMaskIfAvail) skinProgram.mask = peote.view.Mask.USE;
	}
	public inline function createMask(x:Int, y:Int, w:Int, h:Int, autoAdd = true):peote.text.MaskElement {
		var maskElement = new peote.text.MaskElement(x, y, w, h);
		if (autoAdd) maskBuffer.addElement(maskElement);
		return maskElement;
	}
	public inline function createLineMask(line:LineT, from:Null<Int> = null, to:Null<Int> = null, autoAdd = true):peote.text.MaskElement {
		if (from != null && to != null && from > to) {
			var tmp = to;
			to = from;
			from = tmp;
		};
		if (from == null || from < line.visibleFrom) from = line.visibleFrom;
		if (to == null || to > line.visibleTo - 1) to = line.visibleTo - 1;
		var w:Int = 0;
		var x:Int = 0;
		if (from <= to) {
			x = Std.int(leftGlyphPos(line.getGlyph(from), getCharData(line.getGlyph(from).char)));
			w = Std.int(rightGlyphPos(line.getGlyph(to), getCharData(line.getGlyph(to).char)) - x);
		};
		return createMask(x, Std.int(line.y), w, Std.int(line.height), autoAdd);
	}
	public inline function setLineMask(maskElement:peote.text.MaskElement, line:LineT, from:Null<Int> = null, to:Null<Int> = null, autoUpdate = true):Void {
		if (from != null && to != null && from > to) {
			var tmp = to;
			to = from;
			from = tmp;
		};
		if (from == null || from < line.visibleFrom) from = line.visibleFrom;
		if (to == null || to > line.visibleTo - 1) to = line.visibleTo - 1;
		if (from > to) maskElement.w = 0 else {
			maskElement.x = Std.int(lineGetPositionAtChar(line, from));
			maskElement.y = Std.int(line.y);
			maskElement.w = Std.int(lineGetPositionAtChar(line, to + 1) - maskElement.x);
			maskElement.h = Std.int(line.height);
		};
		if (autoUpdate) updateMask(maskElement);
	}
	public inline function setMask(maskElement:peote.text.MaskElement, x:Int, y:Int, w:Int, h:Int, autoUpdate = true):Void {
		maskElement.update(x, y, w, h);
		if (autoUpdate) updateMask(maskElement);
	}
	public inline function addMask(maskElement:peote.text.MaskElement):Void {
		maskBuffer.addElement(maskElement);
	}
	public inline function updateMask(maskElement:peote.text.MaskElement):Void {
		maskBuffer.updateElement(maskElement);
	}
	public inline function removeMask(maskElement:peote.text.MaskElement):Void {
		maskBuffer.removeElement(maskElement);
	}
	@:access(peote.text.skin)
	public inline function addSkin<T:(peote.text.skin.SkinProgram)>(skinProgram:T, ?depthIndex:Null<Int>, ?useMaskIfAvail:Null<Bool>):T {
		if (useMaskIfAvail != null) skinProgram.useMaskIfAvail = useMaskIfAvail;
		if (isMasked && skinProgram.useMaskIfAvail) skinProgram.mask = peote.view.Mask.USE else skinProgram.mask = peote.view.Mask.OFF;
		if (skinPrograms == null) skinPrograms = new peote.text.skin.SkinProgramArray();
		skinPrograms.insertZSorted(skinProgram, this, depthIndex, useMaskIfAvail);
		return (skinProgram);
	}
	public inline function removeSkin(skinProgram:peote.text.skin.SkinProgram) {
		for (display in displays) skinProgram.removeFromDisplay(display);
		skinPrograms.remove(skinProgram);
	}
	public inline function skinElemToLine(skinProgram:peote.text.skin.SkinProgram, skinElement:peote.text.skin.SkinElement, line:LineT, from:Null<Int> = null, to:Null<Int> = null, autoUpdate = true):peote.text.skin.SkinElement {
		if (from != null && to != null && from > to) {
			var tmp = to;
			to = from;
			from = tmp;
		};
		if (from == null || from < line.visibleFrom) from = (line.visibleFrom > 0) ? line.visibleFrom - 1 : line.visibleFrom;
		if (to == null || to > line.visibleTo - 1) to = (line.visibleTo < line.length) ? line.visibleTo : line.visibleTo - 1;
		if (from > to) skinElement.w = 0 else {
			skinElement.x = Std.int(lineGetPositionAtChar(line, from));
			skinElement.y = Std.int(line.y);
			skinElement.w = Std.int(lineGetPositionAtChar(line, to + 1)) - skinElement.x;
			skinElement.h = Std.int(line.height);
			{ };
		};
		if (autoUpdate) skinProgram.updateElement(skinElement);
		return (skinElement);
	}
	public inline function setFont(font:FontT):Void {
		this.font = font;
		autoUpdateTextures = false;
		setTexture(font.textureCache, "TEX");
	}
	public inline function setFontStyle(fontStyle:peote.ui.style.FontStyleTiled):Void {
		this.fontStyle = fontStyle;
		blendEnabled = true;
		var color:String;
		color = "color";
		var bgColor:String;
		bgColor = Std.string(font.config.bgColor.toGLSL());
		if (font.config.distancefield) {
			var weight = "0.5";
			{ };
			var sharp = peote.view.intern.Util.toFloatString(0.5);
			{
				if (font.config.bgColor == 0) setColorFormula(color + " * smoothstep( " + weight + " - " + sharp + " * fwidth(TEX.r), " + weight + " + " + sharp + " * fwidth(TEX.r), TEX.r)") else {
					discardAtAlpha(null);
					setColorFormula("mix(" + bgColor + "," + color + "," + "smoothstep( " + weight + " - " + sharp + " * fwidth(TEX.r), " + weight + " + " + sharp + " * fwidth(TEX.r), TEX.r))");
				};
			};
		} else {
			{
				if (font.config.bgColor == 0) setColorFormula(color + " * TEX.r") else {
					discardAtAlpha(null);
					setColorFormula("mix(" + bgColor + "," + color + "," + "TEX.r)");
				};
			};
		};
		{ };
		{ };
		var tilt:String = "0.0";
		tilt = "tilt";
		{
			{ };
			{ };
			{ };
			if (tilt != "" && tilt != "0.0") setFormula("x", "x + (1.0-aPosition.y)*width*" + tilt);
		};
		updateTextures();
	}
	inline function makeTabSize(glyph:GlyphT, width:Float):Float {
		if (glyph.char == 9) return width * 3.0 else return width;
	}
	inline function tab2space(charcode:Int):Int {
		if (charcode == 9) return 32 else return charcode;
	}
	inline function getCharData(charcode:Int):{ var min : Int; var max : Int; var height : Float; var base : Float; } {
		return font.getRange(tab2space(charcode));
	}
	inline function rightGlyphPos(glyph:GlyphT, charData:{ var min : Int; var max : Int; var height : Float; var base : Float; }):Float {
		{
			return glyph.x + makeTabSize(glyph, glyph.width);
		};
	}
	inline function leftGlyphPos(glyph:GlyphT, charData:{ var min : Int; var max : Int; var height : Float; var base : Float; }):Float {
		{
			return glyph.x;
		};
	}
	inline function nextGlyphOffset(glyph:GlyphT, charData:{ var min : Int; var max : Int; var height : Float; var base : Float; }):Float {
		{
			return makeTabSize(glyph, glyph.width);
		};
	}
	inline function letterSpace(glyph:GlyphT):Float {
		return glyph.letterSpace;
	}
	inline function kerningSpaceOffset(prev_glyph:GlyphT, glyph:GlyphT, charData:{ var min : Int; var max : Int; var height : Float; var base : Float; }):Float {
		if (prev_glyph != null) {
			{
				return letterSpace(prev_glyph);
			};
		} else return 0.0;
	}
	public function getCharSize(charCode:Int, glyphStyle:peote.ui.style.FontStyleTiled):Float {
		var charData = getCharData(charCode);
		if (charData == null) return 0.0;
		{
			return glyphStyle.width;
		};
	}
	inline function setPosition(glyph:GlyphT, charData:{ var min : Int; var max : Int; var height : Float; var base : Float; }, x:Float, y:Float) {
		setXPosition(glyph, charData, x);
		setYPosition(glyph, charData, y);
	}
	inline function setXPosition(glyph:GlyphT, charData:{ var min : Int; var max : Int; var height : Float; var base : Float; }, x:Float) {
		{
			glyph.x = x;
		};
	}
	inline function setYPosition(glyph:GlyphT, charData:{ var min : Int; var max : Int; var height : Float; var base : Float; }, y:Float) {
		{
			glyph.y = y;
		};
	}
	inline function getXPosition(glyph:GlyphT, charData:{ var min : Int; var max : Int; var height : Float; var base : Float; }):Float {
		return {
			glyph.x;
		};
	}
	inline function getYPosition(glyph:GlyphT, charData:{ var min : Int; var max : Int; var height : Float; var base : Float; }):Float {
		return {
			glyph.y;
		};
	}
	inline function setSize(glyph:GlyphT, charData:{ var min : Int; var max : Int; var height : Float; var base : Float; }) {
		{ };
	}
	public inline function setStyle(glyph:GlyphT, glyphStyle:peote.ui.style.FontStyleTiled) {
		glyph.setStyle((glyphStyle != null) ? glyphStyle : fontStyle);
	}
	inline function setCharcode(glyph:GlyphT, charcode:Int, charData:{ var min : Int; var max : Int; var height : Float; var base : Float; }) {
		glyph.char = charcode;
		{ };
		{ };
		{
			glyph.tile = tab2space(charcode) - charData.min;
		};
	}
	public inline function createGlyph(charcode:Int, x:Float, y:Float, ?glyphStyle:peote.ui.style.FontStyleTiled, useMetric = false):GlyphT return _createGlyph(charcode, x, y, glyphStyle, useMetric, false);
	public inline function createGlyphAtBase(charcode:Int, x:Float, y:Float, ?glyphStyle:peote.ui.style.FontStyleTiled):GlyphT return _createGlyph(charcode, x, y, glyphStyle, true, true);
	inline function _createGlyph(charcode:Int, x:Float, y:Float, glyphStyle:peote.ui.style.FontStyleTiled, useMetric:Bool, atBaseline:Bool):GlyphT {
		var charData = getCharData(charcode);
		if (charData != null) {
			var glyph = new GlyphT();
			setStyle(glyph, glyphStyle);
			setCharcode(glyph, charcode, charData);
			setSize(glyph, charData);
			if (useMetric) {
				if (atBaseline) setPosition(glyph, charData, x, y - _getBaseline(glyph, charData)) else setPosition(glyph, charData, x, y);
			} else {
				glyph.x = x;
				glyph.y = y;
			};
			_buffer.addElement(glyph);
			return glyph;
		} else return null;
	}
	public inline function glyphAdd(glyph:GlyphT):Void _buffer.addElement(glyph);
	public inline function glyphRemove(glyph:GlyphT):Void _buffer.removeElement(glyph);
	public inline function glyphSet(glyph:GlyphT, charcode:Int, x:Float, y:Float, ?glyphStyle:peote.ui.style.FontStyleTiled, useMetric = false):Bool return _setGlyph(glyph, charcode, x, y, glyphStyle, useMetric, false);
	public inline function glyphSetAtBase(glyph:GlyphT, charcode:Int, x:Float, y:Float, ?glyphStyle:peote.ui.style.FontStyleTiled):Bool return _setGlyph(glyph, charcode, x, y, glyphStyle, true, true);
	inline function _setGlyph(glyph:GlyphT, charcode:Int, x:Float, y:Float, glyphStyle:peote.ui.style.FontStyleTiled, useMetric:Bool, atBaseline:Bool):Bool {
		var charData = getCharData(charcode);
		if (charData != null) {
			setStyle(glyph, glyphStyle);
			setCharcode(glyph, charcode, charData);
			setSize(glyph, charData);
			if (useMetric) {
				if (atBaseline) setPosition(glyph, charData, x, y - _getBaseline(glyph, charData)) else setPosition(glyph, charData, x, y);
			} else {
				glyph.x = x;
				glyph.y = y;
			};
			_buffer.addElement(glyph);
			return true;
		} else return false;
	}
	public inline function glyphSetStyle(glyph:GlyphT, glyphStyle:peote.ui.style.FontStyleTiled, useMetric = false) {
		if (useMetric) {
			var charData = getCharData(glyph.char);
			var old_base:Float = _getBaseline(glyph, charData);
			var old_x = getXPosition(glyph, charData);
			var old_y = getYPosition(glyph, charData);
			setStyle(glyph, glyphStyle);
			setPosition(glyph, charData, old_x, old_y + _baseLineOffset(old_base, glyph, charData));
		} else setStyle(glyph, glyphStyle);
	}
	public inline function glyphSetPosition(glyph:GlyphT, x:Float, y:Float, useMetric = false) _glyphSetPosition(glyph, x, y, useMetric, false);
	public inline function glyphSetPositionAtBase(glyph:GlyphT, x:Float, y:Float) _glyphSetPosition(glyph, x, y, true, true);
	inline function _glyphSetPosition(glyph:GlyphT, x:Float, y:Float, useMetric:Bool, atBaseline:Bool) {
		if (useMetric) {
			if (atBaseline) {
				var charData = getCharData(glyph.char);
				setPosition(glyph, charData, x, y - _getBaseline(glyph, charData));
			} else setPosition(glyph, getCharData(glyph.char), x, y);
		} else {
			glyph.x = x;
			glyph.y = y;
		};
	}
	public inline function glyphSetXPosition(glyph:GlyphT, x:Float, useMetric = false) {
		if (useMetric) setXPosition(glyph, getCharData(glyph.char), x) else glyph.x = x;
	}
	public inline function glyphGetXPosition(glyph:GlyphT, useMetric = false):Float {
		if (useMetric) return getXPosition(glyph, getCharData(glyph.char)) else return glyph.x;
	}
	public inline function glyphSetYPosition(glyph:GlyphT, y:Float, useMetric = false) _glyphSetYPosition(glyph, y, useMetric, false);
	public inline function glyphSetYPositionAtBase(glyph:GlyphT, y:Float) _glyphSetYPosition(glyph, y, true, true);
	inline function _glyphSetYPosition(glyph:GlyphT, y:Float, useMetric:Bool, atBaseline:Bool) {
		if (useMetric) {
			if (atBaseline) {
				var charData = getCharData(glyph.char);
				setYPosition(glyph, charData, y - _getBaseline(glyph, charData));
			} else setYPosition(glyph, getCharData(glyph.char), y);
		} else glyph.y = y;
	}
	public inline function glyphGetYPosition(glyph:GlyphT, useMetric = false):Float return _glyphGetYPosition(glyph, useMetric, false);
	public inline function glyphGetYPositionAtBase(glyph:GlyphT):Float return _glyphGetYPosition(glyph, true, true);
	inline function _glyphGetYPosition(glyph:GlyphT, useMetric:Bool, atBaseline:Bool):Float {
		if (useMetric) {
			if (atBaseline) {
				var charData = getCharData(glyph.char);
				return getYPosition(glyph, charData) + _getBaseline(glyph, charData);
			} else return getYPosition(glyph, getCharData(glyph.char));
		} else return glyph.y;
	}
	public inline function glyphGetBaseline(glyph:GlyphT):Float {
		return _getBaseline(glyph, getCharData(glyph.char));
	}
	public inline function glyphSetChar(glyph:GlyphT, charcode:Int, useMetric:Bool = false):Bool {
		var charData = getCharData(charcode);
		if (charData != null) {
			if (useMetric) {
				var old_charData = getCharData(glyph.char);
				var old_base:Float = _getBaseline(glyph, old_charData);
				var old_x = getXPosition(glyph, old_charData);
				var old_y = getYPosition(glyph, old_charData);
				setCharcode(glyph, charcode, charData);
				setSize(glyph, charData);
				setPosition(glyph, charData, old_x, old_y + _baseLineOffset(old_base, glyph, charData));
			} else {
				setCharcode(glyph, charcode, charData);
				setSize(glyph, charData);
			};
			return true;
		} else return false;
	}
	public inline function glyphUpdate(glyph:GlyphT):Void _buffer.updateElement(glyph);
	public inline function updateAllGlyphes():Void _buffer.update();
	public inline function numberOfGlyphes():Int return _buffer.length;
	public inline function createPageLine(chars:String, x:Float = 0.0, y:Float = 0.0, ?size:Null<Float>, ?offset:Null<Float>, ?glyphStyle:Null<peote.ui.style.FontStyleTiled>, ?defaultFontRange:Null<Int>, addRemoveGlyphes:Bool = true, ?onUnrecognizedChar:(Int, Int) -> Void):PageLineT {
		var pageLine = new PageLineT();
		pageLineSet(pageLine, chars, x, y, size, offset, glyphStyle, defaultFontRange, addRemoveGlyphes, onUnrecognizedChar);
		return pageLine;
	}
	public inline function pageLineAdd(pageLine:PageLineT):Void {
		for (i in pageLine.visibleFrom ... pageLine.visibleTo) glyphAdd(pageLine.getGlyph(i));
	}
	public inline function pageLineRemove(pageLine:PageLineT) {
		for (i in pageLine.visibleFrom ... pageLine.visibleTo) glyphRemove(pageLine.getGlyph(i));
	}
	public function pageLineSet(pageLine:PageLineT, chars:String, x:Float, ?y:Null<Float>, size:Float, offset:Float, ?glyphStyle:Null<peote.ui.style.FontStyleTiled>, ?defaultFontRange:Null<Int>, addRemoveGlyphes:Bool = true, ?onUnrecognizedChar:(Int, Int) -> Void) {
		var line_max = x + size;
		if (y != null) pageLine.y = y else y = pageLine.y;
		var x_start = x;
		x += offset;
		var glyph:GlyphT;
		var prev_glyph:GlyphT = null;
		var i = 0;
		var charData:{ var min : Int; var max : Int; var height : Float; var base : Float; } = null;
		var visibleFrom:Int = 0;
		var visibleTo:Int = 0;
		var old_length = pageLine.length;
		peote.text.util.StringUtils.iter(chars, function(charcode) {
			charData = getCharData(charcode);
			if (charData != null) {
				if (i >= old_length) {
					glyph = new GlyphT();
					pageLine.pushGlyph(glyph);
					setStyle(glyph, glyphStyle);
					setCharcode(glyph, charcode, charData);
					setSize(glyph, charData);
					x += kerningSpaceOffset(prev_glyph, glyph, charData);
					setPosition(glyph, charData, x, y);
					if (glyph.x + glyph.width >= x_start) {
						if (glyph.x < line_max) {
							if (addRemoveGlyphes) _buffer.addElement(glyph);
							visibleTo++;
						};
					} else {
						visibleFrom++;
						visibleTo++;
					};
					x += nextGlyphOffset(glyph, charData);
				} else {
					glyph = pageLine.getGlyph(i);
					if (glyphStyle != null) glyph.setStyle(glyphStyle);
					setCharcode(glyph, charcode, charData);
					setSize(glyph, charData);
					x += kerningSpaceOffset(prev_glyph, glyph, charData);
					setPosition(glyph, charData, x, y);
					if (glyph.x + glyph.width >= x_start) {
						if (glyph.x < line_max) {
							if (addRemoveGlyphes && (i < pageLine.visibleFrom || i >= pageLine.visibleTo)) _buffer.addElement(glyph);
							visibleTo++;
						} else if (addRemoveGlyphes && i < pageLine.visibleTo) _buffer.removeElement(glyph);
					} else {
						if (addRemoveGlyphes && i >= pageLine.visibleFrom) _buffer.removeElement(glyph);
						visibleFrom++;
						visibleTo++;
					};
					x += nextGlyphOffset(glyph, charData);
				};
				if (i == 0) {
					if (defaultFontRange == null) _setLineMetric(pageLine, glyph, charData) else {
						_setDefaultMetric(pageLine, defaultFontRange, glyphStyle);
						var y_offset = _baseLineOffset(pageLine.base, glyph, charData);
						glyph.y += y_offset;
						y += y_offset;
					};
				};
				prev_glyph = glyph;
				i++;
			};
		});
		if (i < old_length) {
			pageLineDeleteChars(pageLine, x_start, size, offset, i, null, addRemoveGlyphes);
			for (j in Std.int(Math.max(i, pageLine.visibleFrom)) ... Std.int(Math.min(pageLine.length, pageLine.visibleTo))) {
				if (addRemoveGlyphes) _buffer.removeElement(pageLine.getGlyph(j));
			};
			pageLine.resize(i);
		};
		if (i == 0) _setDefaultMetric(pageLine, (defaultFontRange == null) ? 0 : defaultFontRange, glyphStyle);
		pageLine.updateFrom = 0;
		pageLine.updateTo = i;
		pageLine.visibleFrom = visibleFrom;
		pageLine.visibleTo = visibleTo;
		pageLine.textSize = x - x_start - offset;
	}
	inline function _setDefaultMetric(pageLine:PageLineT, defaultFontRange:Int, glyphStyle:Null<peote.ui.style.FontStyleTiled>) {
		var charCode = font.config.ranges[defaultFontRange].range.min;
		var charData = getCharData(charCode);
		var glyph = new GlyphT();
		setStyle(glyph, glyphStyle);
		setCharcode(glyph, charCode, charData);
		setSize(glyph, charData);
		_setLineMetric(pageLine, glyph, charData);
	}
	inline function _setLineMetric(pageLine:PageLineT, glyph:GlyphT, charData:{ var min : Int; var max : Int; var height : Float; var base : Float; }) {
		if (glyph != null) {
			{
				var h = glyph.height;
				pageLine.height = h;
				pageLine.lineHeight = h * charData.height;
				pageLine.base = h * charData.base;
			};
		};
	}
	inline function _getBaseline(glyph:GlyphT, charData:{ var min : Int; var max : Int; var height : Float; var base : Float; }):Float {
		{
			return charData.base * glyph.height;
		};
	}
	inline function _baseLineOffset(base:Float, glyph:GlyphT, charData:{ var min : Int; var max : Int; var height : Float; var base : Float; }):Float {
		if (glyph != null) {
			{
				return base - charData.base * glyph.height;
			};
		} else return 0;
	}
	public function pageLineSetStyle(pageLine:PageLineT, x:Float, size:Float, offset:Float, glyphStyle:peote.ui.style.FontStyleTiled, from:Int = 0, ?to:Null<Int>, addRemoveGlyphes:Bool = true):Float {
		if (to == null || to > pageLine.length) to = pageLine.length;
		if (to < from) {
			var tmp = to;
			to = from;
			from = tmp;
		} else if (from == to) to++;
		if (from < pageLine.updateFrom) pageLine.updateFrom = from;
		if (to > pageLine.updateTo) pageLine.updateTo = to;
		var prev_glyph:GlyphT = null;
		var line_x = x;
		x += offset;
		var y = pageLine.y;
		if (from > 0) {
			x = rightGlyphPos(pageLine.getGlyph(from - 1), getCharData(pageLine.getGlyph(from - 1).char));
			prev_glyph = pageLine.getGlyph(from - 1);
			x += kerningSpaceOffset(prev_glyph, pageLine.getGlyph(from), getCharData(pageLine.getGlyph(from - 1).char));
		};
		pageLine.getGlyph(from).setStyle(glyphStyle);
		var charData = getCharData(pageLine.getGlyph(from).char);
		var baseLineOffset:Float = _baseLineOffset(pageLine.base, pageLine.getGlyph(from), charData);
		if (baseLineOffset < 0) {
			if (from > 0) {
				pageLine.updateFrom = 0;
				for (i in 0 ... from) pageLine.getGlyph(i).y -= baseLineOffset;
			};
			if (to < pageLine.length) {
				pageLine.updateTo = pageLine.length;
				for (i in to ... pageLine.length) pageLine.getGlyph(i).y -= baseLineOffset;
			};
			_setLineMetric(pageLine, pageLine.getGlyph(from), charData);
		} else if (baseLineOffset > 0) {
			if (from == 0 && to == pageLine.length) {
				_setLineMetric(pageLine, pageLine.getGlyph(from), charData);
			} else y += baseLineOffset;
		};
		setPosition(pageLine.getGlyph(from), charData, x, y);
		x += nextGlyphOffset(pageLine.getGlyph(from), charData);
		prev_glyph = pageLine.getGlyph(from);
		for (i in from + 1 ... to) {
			pageLine.getGlyph(i).setStyle(glyphStyle);
			charData = getCharData(pageLine.getGlyph(i).char);
			x += kerningSpaceOffset(prev_glyph, pageLine.getGlyph(i), charData);
			setPosition(pageLine.getGlyph(i), charData, x, y);
			x += nextGlyphOffset(pageLine.getGlyph(i), charData);
			prev_glyph = pageLine.getGlyph(i);
		};
		if (to < pageLine.length) {
			x += kerningSpaceOffset(prev_glyph, pageLine.getGlyph(to), charData);
			var _offset = x - leftGlyphPos(pageLine.getGlyph(to), getCharData(pageLine.getGlyph(to).char));
			if (_offset != 0.0) {
				pageLine.updateTo = pageLine.length;
				_setLinePositionOffset(pageLine, line_x, size, _offset, from, to, pageLine.length, addRemoveGlyphes);
			} else _setLinePositionOffset(pageLine, line_x, size, _offset, from, to, to, addRemoveGlyphes);
			return _offset;
		} else {
			var _offset = x - line_x - offset - pageLine.textSize;
			_setLinePositionOffset(pageLine, line_x, size, _offset, from, to, to, addRemoveGlyphes);
			return _offset;
		};
	}
	public function pageLineSetPosition(pageLine:PageLineT, x:Float, size:Float, offset:Float, xNew:Float, yNew:Float, ?offsetNew:Null<Float>, addRemoveGlyphes:Bool = true) {
		pageLine.updateFrom = 0;
		pageLine.updateTo = pageLine.length;
		if (offsetNew != null) _setLinePositionOffsetFull(pageLine, xNew, size, offsetNew - offset + xNew - x, yNew - pageLine.y, addRemoveGlyphes) else for (i in 0 ... pageLine.length) {
			pageLine.getGlyph(i).x += xNew - x;
			pageLine.getGlyph(i).y += yNew - pageLine.y;
		};
		pageLine.y = yNew;
	}
	public function pageLineSetXPosition(pageLine:PageLineT, x:Float, size:Float, offset:Float, xNew:Float, ?offsetNew:Null<Float>, addRemoveGlyphes:Bool = true) {
		pageLine.updateFrom = 0;
		pageLine.updateTo = pageLine.length;
		if (offsetNew != null) _setLinePositionOffsetFull(pageLine, xNew, size, offsetNew - offset + xNew - x, 0, addRemoveGlyphes) else for (i in 0 ... pageLine.updateTo) pageLine.getGlyph(i).x += xNew - x;
	}
	public function pageLineSetYPosition(pageLine:PageLineT, x:Float, size:Float, offset:Float, yNew:Float, ?offsetNew:Null<Float>, addRemoveGlyphes:Bool = true) {
		pageLine.updateFrom = 0;
		pageLine.updateTo = pageLine.length;
		if (offsetNew != null) _setLinePositionOffsetFull(pageLine, x, size, offsetNew - offset, yNew - pageLine.y, addRemoveGlyphes) else for (i in 0 ... pageLine.updateTo) pageLine.getGlyph(i).y += yNew - pageLine.y;
		pageLine.y = yNew;
	}
	public function pageLineSetPositionSize(pageLine:PageLineT, x:Float, size:Float, offset:Float, xNew:Float, yNew:Float, ?offsetNew:Null<Float>, addRemoveGlyphes:Bool = true) {
		pageLine.updateFrom = 0;
		pageLine.updateTo = pageLine.length;
		if (offsetNew != null) _setLinePositionOffsetFull(pageLine, xNew, size, offsetNew - offset + xNew - x, yNew - pageLine.y, addRemoveGlyphes) else _setLinePositionOffsetFull(pageLine, xNew, size, xNew - x, yNew - pageLine.y, addRemoveGlyphes);
		pageLine.y = yNew;
	}
	public function pageLineSetSize(pageLine:PageLineT, x:Float, size:Float, offset:Float, ?offsetNew:Null<Float>, addRemoveGlyphes:Bool = true) {
		pageLine.updateFrom = 0;
		pageLine.updateTo = pageLine.length;
		if (offsetNew != null) _setLinePositionOffsetFull(pageLine, x, size, offsetNew - offset, null, addRemoveGlyphes) else _setLinePositionOffsetFull(pageLine, x, size, null, null, addRemoveGlyphes);
	}
	public function pageLineSetOffset(pageLine:PageLineT, x:Float, size:Float, offset:Float, offsetNew:Float, addRemoveGlyphes:Bool = true) {
		pageLine.updateFrom = 0;
		pageLine.updateTo = pageLine.length;
		_setLinePositionOffsetFull(pageLine, x, size, offsetNew - offset, null, addRemoveGlyphes);
	}
	inline function _setLinePositionOffsetFull(pageLine:PageLineT, x:Float, size:Float, deltaX:Null<Float>, deltaY:Null<Float>, addRemoveGlyphes:Bool) {
		var line_max = x + size;
		var visibleFrom = pageLine.visibleFrom;
		var visibleTo = pageLine.visibleTo;
		for (i in 0 ... pageLine.length) {
			if (deltaX != null) pageLine.getGlyph(i).x += deltaX;
			if (deltaY != null) pageLine.getGlyph(i).y += deltaY;
			if (pageLine.getGlyph(i).x + pageLine.getGlyph(i).width >= x) {
				if (pageLine.getGlyph(i).x < line_max) {
					if (i < pageLine.visibleFrom || i >= pageLine.visibleTo) {
						if (addRemoveGlyphes) _buffer.addElement(pageLine.getGlyph(i));
						if (visibleFrom > i) visibleFrom = i;
						if (visibleTo < i + 1) visibleTo = i + 1;
					};
				} else {
					if (addRemoveGlyphes && i >= pageLine.visibleFrom && i < pageLine.visibleTo) _buffer.removeElement(pageLine.getGlyph(i));
					if (visibleTo > i) visibleTo = i;
				};
			} else {
				if (addRemoveGlyphes && i >= pageLine.visibleFrom && i < pageLine.visibleTo) _buffer.removeElement(pageLine.getGlyph(i));
				visibleFrom = i + 1;
			};
		};
		pageLine.visibleFrom = visibleFrom;
		pageLine.visibleTo = visibleTo;
	}
	inline function _setLinePositionOffset(pageLine:PageLineT, x:Float, size:Float, deltaX:Float, from:Int, withDelta:Int, to:Int, addRemoveGlyphes:Bool) {
		var line_max = x + size;
		var visibleFrom = pageLine.visibleFrom;
		var visibleTo = pageLine.visibleTo;
		for (i in from ... to) {
			if (i >= withDelta) pageLine.getGlyph(i).x += deltaX;
			if (pageLine.getGlyph(i).x + pageLine.getGlyph(i).width >= x) {
				if (pageLine.getGlyph(i).x < line_max) {
					if (i < pageLine.visibleFrom || i >= pageLine.visibleTo) {
						if (addRemoveGlyphes) _buffer.addElement(pageLine.getGlyph(i));
						if (visibleFrom > i) visibleFrom = i;
						if (visibleTo < i + 1) visibleTo = i + 1;
					};
				} else {
					if (addRemoveGlyphes && i >= pageLine.visibleFrom && i < pageLine.visibleTo) _buffer.removeElement(pageLine.getGlyph(i));
					if (visibleTo > i) visibleTo = i;
				};
			} else {
				if (addRemoveGlyphes && i >= pageLine.visibleFrom && i < pageLine.visibleTo) _buffer.removeElement(pageLine.getGlyph(i));
				visibleFrom = i + 1;
			};
		};
		pageLine.visibleFrom = visibleFrom;
		pageLine.visibleTo = visibleTo;
		pageLine.textSize += deltaX;
	}
	public function pageLineSetChar(pageLine:PageLineT, x:Float, size:Float, offset:Float, charcode:Int, position:Int = 0, ?glyphStyle:peote.ui.style.FontStyleTiled, addRemoveGlyphes:Bool = true, ?onUnrecognizedChar:(Int, Int) -> Void):Float {
		if (position >= pageLine.length) position = pageLine.length - 1 else if (position < 0) position = 0;
		var charData = getCharData(charcode);
		if (charData != null) {
			if (position < pageLine.updateFrom) pageLine.updateFrom = position;
			if (position + 1 > pageLine.updateTo) pageLine.updateTo = position + 1;
			var prev_glyph:GlyphT = null;
			var line_x = x;
			x += offset;
			var y = pageLine.y;
			if (position > 0) {
				x = rightGlyphPos(pageLine.getGlyph(position - 1), getCharData(pageLine.getGlyph(position - 1).char));
				prev_glyph = pageLine.getGlyph(position - 1);
			};
			if (glyphStyle != null) {
				pageLine.getGlyph(position).setStyle(glyphStyle);
				y += _baseLineOffset(pageLine.base, pageLine.getGlyph(position), charData);
			};
			setCharcode(pageLine.getGlyph(position), charcode, charData);
			setSize(pageLine.getGlyph(position), charData);
			x += kerningSpaceOffset(prev_glyph, pageLine.getGlyph(position), charData);
			setPosition(pageLine.getGlyph(position), charData, x, y);
			x += nextGlyphOffset(pageLine.getGlyph(position), charData);
			if (position + 1 < pageLine.length) {
				x += kerningSpaceOffset(pageLine.getGlyph(position), pageLine.getGlyph(position + 1), charData);
				var _offset = x - leftGlyphPos(pageLine.getGlyph(position + 1), getCharData(pageLine.getGlyph(position + 1).char));
				if (_offset != 0.0) {
					pageLine.updateTo = pageLine.length;
					_setLinePositionOffset(pageLine, line_x, size, _offset, position, position + 1, pageLine.length, addRemoveGlyphes);
				} else _setLinePositionOffset(pageLine, line_x, size, _offset, position, position + 1, position + 1, addRemoveGlyphes);
				return _offset;
			} else {
				var _offset = x - line_x - offset - pageLine.textSize;
				_setLinePositionOffset(pageLine, line_x, size, _offset, position, position + 1, position + 1, addRemoveGlyphes);
				return _offset;
			};
		} else {
			if (onUnrecognizedChar != null) onUnrecognizedChar(charcode, position);
			return 0;
		};
	}
	public function pageLineSetChars(pageLine:PageLineT, x:Float, size:Float, offset:Float, chars:String, position:Int = 0, ?glyphStyle:peote.ui.style.FontStyleTiled, addRemoveGlyphes:Bool = true, ?onUnrecognizedChar:(Int, Int) -> Void):Float {
		var restChars:String = null;
		if (position >= pageLine.length) {
			position = pageLine.length;
			return pageLineAppendChars(pageLine, x, size, offset, chars, glyphStyle, addRemoveGlyphes, onUnrecognizedChar);
		} else if (position < 0) position = 0;
		if (position + chars.length > pageLine.length) {
			restChars = chars.substr(chars.length - (position + chars.length - pageLine.length));
			chars = chars.substring(0, chars.length - (position + chars.length - pageLine.length));
		};
		var prev_glyph:GlyphT = null;
		var line_x = x;
		x += offset;
		var y = pageLine.y;
		if (position > 0) {
			x = rightGlyphPos(pageLine.getGlyph(position - 1), getCharData(pageLine.getGlyph(position - 1).char));
			prev_glyph = pageLine.getGlyph(position - 1);
		};
		var i = position;
		var charData:{ var min : Int; var max : Int; var height : Float; var base : Float; } = null;
		peote.text.util.StringUtils.iter(chars, function(charcode) {
			if (i < pageLine.length) {
				charData = getCharData(charcode);
				if (charData != null) {
					if (glyphStyle != null) {
						pageLine.getGlyph(i).setStyle(glyphStyle);
						if (i == position) {
							y += _baseLineOffset(pageLine.base, pageLine.getGlyph(i), charData);
						};
					};
					setCharcode(pageLine.getGlyph(i), charcode, charData);
					setSize(pageLine.getGlyph(i), charData);
					x += kerningSpaceOffset(prev_glyph, pageLine.getGlyph(i), charData);
					setPosition(pageLine.getGlyph(i), charData, x, y);
					x += nextGlyphOffset(pageLine.getGlyph(i), charData);
					prev_glyph = pageLine.getGlyph(i);
					i++;
				} else if (onUnrecognizedChar != null) onUnrecognizedChar(charcode, i);
			} else {
				var _offset = pageLineInsertChar(pageLine, line_x, size, offset, charcode, i, glyphStyle, addRemoveGlyphes, onUnrecognizedChar);
				if (_offset > 0) {
					x += _offset;
					i++;
				};
			};
		});
		if (position < pageLine.updateFrom) pageLine.updateFrom = position;
		if (position + i > pageLine.updateTo) pageLine.updateTo = Std.int(Math.min(position + i, pageLine.length));
		if (i < pageLine.length) {
			x += kerningSpaceOffset(pageLine.getGlyph(i - 1), pageLine.getGlyph(i), charData);
			var _offset = x - leftGlyphPos(pageLine.getGlyph(i), getCharData(pageLine.getGlyph(i).char));
			if (_offset != 0.0) {
				pageLine.updateTo = pageLine.length;
				_setLinePositionOffset(pageLine, line_x, size, _offset, position, i, pageLine.length, addRemoveGlyphes);
			} else _setLinePositionOffset(pageLine, line_x, size, _offset, position, i, i, addRemoveGlyphes);
			if (restChars != null) return _offset + pageLineAppendChars(pageLine, line_x, size, offset, restChars, glyphStyle, addRemoveGlyphes, onUnrecognizedChar) else return _offset;
		} else {
			var _offset = x - line_x - offset - pageLine.textSize;
			_setLinePositionOffset(pageLine, line_x, size, _offset, position, i, i, addRemoveGlyphes);
			if (restChars != null) return _offset + pageLineAppendChars(pageLine, line_x, size, offset, restChars, glyphStyle, addRemoveGlyphes, onUnrecognizedChar) else return _offset;
		};
	}
	public function pageLineInsertChar(pageLine:PageLineT, x:Float, size:Float, offset:Float, charcode:Int, position:Int = 0, ?glyphStyle:peote.ui.style.FontStyleTiled, addRemoveGlyphes:Bool = true, ?onUnrecognizedChar:(Int, Int) -> Void):Float {
		var charData = getCharData(charcode);
		if (charData != null) {
			var prev_glyph:GlyphT = null;
			var line_x = x;
			x += offset;
			var y = pageLine.y;
			if (position > 0) {
				if (position >= pageLine.length) position = pageLine.length;
				x = rightGlyphPos(pageLine.getGlyph(position - 1), getCharData(pageLine.getGlyph(position - 1).char));
				prev_glyph = pageLine.getGlyph(position - 1);
			} else if (position < 0) position = 0;
			var x_start = x;
			var glyph = new GlyphT();
			setStyle(glyph, glyphStyle);
			y += _baseLineOffset(pageLine.base, glyph, charData);
			setCharcode(glyph, charcode, charData);
			setSize(glyph, charData);
			x += kerningSpaceOffset(prev_glyph, glyph, charData);
			setPosition(glyph, charData, x, y);
			x += nextGlyphOffset(glyph, charData);
			if (position < pageLine.length) {
				if (position < pageLine.updateFrom) pageLine.updateFrom = position + 1;
				pageLine.updateTo = pageLine.length + 1;
				if (position == 0) x += kerningSpaceOffset(glyph, pageLine.getGlyph(position + 1), charData);
				_setLinePositionOffset(pageLine, line_x, size, x - x_start, position, position, pageLine.length, addRemoveGlyphes);
			} else pageLine.textSize += x - x_start;
			pageLine.insertGlyph(position, glyph);
			if (glyph.x + glyph.width >= line_x) {
				if (glyph.x < line_x + size) {
					if (addRemoveGlyphes) _buffer.addElement(glyph);
					pageLine.visibleTo++;
				};
			} else {
				pageLine.visibleFrom++;
				pageLine.visibleTo++;
			};
			return x - x_start;
		} else {
			if (onUnrecognizedChar != null) {
				if (position >= pageLine.length) position = pageLine.length else if (position < 0) position = 0;
				onUnrecognizedChar(charcode, position);
			};
			return 0;
		};
	}
	public function pageLineInsertChars(pageLine:PageLineT, x:Float, size:Float, offset:Float, chars:String, position:Int = 0, ?glyphStyle:peote.ui.style.FontStyleTiled, addRemoveGlyphes:Bool = true, ?onUnrecognizedChar:(Int, Int) -> Void):Float {
		var prev_glyph:GlyphT = null;
		var line_x = x;
		var y = pageLine.y;
		if (position > 0) {
			x = rightGlyphPos(pageLine.getGlyph(position - 1), getCharData(pageLine.getGlyph(position - 1).char));
			prev_glyph = pageLine.getGlyph(position - 1);
			offset = 0;
		};
		var rest = pageLine.splice(position, pageLine.length - position);
		if (rest.length > 0) {
			var oldFrom = pageLine.visibleFrom - pageLine.length;
			var oldTo = pageLine.visibleTo - pageLine.length;
			if (pageLine.visibleFrom > pageLine.length) pageLine.visibleFrom = pageLine.length;
			if (pageLine.visibleTo > pageLine.length) pageLine.visibleTo = pageLine.length;
			var deltaX = _lineAppend(pageLine, line_x, size, offset, chars, x, y, prev_glyph, glyphStyle, addRemoveGlyphes, onUnrecognizedChar);
			if (position == 0) {
				var kerningSpace = kerningSpaceOffset(pageLine.getGlyph(pageLine.length - 1), rest[0], getCharData(rest[0].char));
				deltaX += kerningSpace;
				pageLine.textSize += kerningSpace;
			};
			if (deltaX != 0.0) {
				if (pageLine.length < pageLine.updateFrom) pageLine.updateFrom = pageLine.length;
				var line_max = line_x + size;
				for (i in 0 ... rest.length) {
					rest[i].x += deltaX;
					if (rest[i].x + rest[i].width >= line_x) {
						if (rest[i].x < line_max) {
							if (addRemoveGlyphes && (i < oldFrom || i >= oldTo)) {
								_buffer.addElement(rest[i]);
							};
							pageLine.visibleTo++;
						} else if (addRemoveGlyphes && i >= oldFrom && i < oldTo) {
							_buffer.removeElement(rest[i]);
						};
					} else {
						if (addRemoveGlyphes && i >= oldFrom && i < oldTo) {
							_buffer.removeElement(rest[i]);
						};
						pageLine.visibleFrom++;
						pageLine.visibleTo++;
					};
				};
				pageLine.append(rest);
				pageLine.updateTo = pageLine.length;
			} else {
				pageLine.visibleFrom = oldFrom + pageLine.length;
				pageLine.visibleTo = oldTo + pageLine.length;
				pageLine.append(rest);
			};
			return deltaX;
		} else return _lineAppend(pageLine, line_x, size, offset, chars, x, y, prev_glyph, glyphStyle, addRemoveGlyphes, onUnrecognizedChar);
	}
	public function pageLineAppendChars(pageLine:PageLineT, x:Float, size:Float, offset:Float, chars:String, ?glyphStyle:peote.ui.style.FontStyleTiled, addRemoveGlyphes:Bool = true, ?onUnrecognizedChar:(Int, Int) -> Void):Float {
		if (pageLine.length > 0) {
			var prev_glyph = pageLine.getGlyph(pageLine.length - 1);
			var fromX = rightGlyphPos(prev_glyph, getCharData(prev_glyph.char));
			return _lineAppend(pageLine, x, size, 0, chars, fromX, pageLine.y, prev_glyph, glyphStyle, addRemoveGlyphes, onUnrecognizedChar);
		} else return _lineAppend(pageLine, x, size, offset, chars, x, pageLine.y, null, glyphStyle, addRemoveGlyphes, onUnrecognizedChar);
	}
	inline function _lineAppend(pageLine:PageLineT, line_x:Float, size:Float, offset:Float, chars:String, x:Float, y:Float, prev_glyph:GlyphT, glyphStyle:peote.ui.style.FontStyleTiled, addRemoveGlyphes:Bool, ?onUnrecognizedChar:(Int, Int) -> Void):Float {
		var first = true;
		var glyph:GlyphT = null;
		var charData:{ var min : Int; var max : Int; var height : Float; var base : Float; } = null;
		x += offset;
		var x_start = x;
		var line_max = line_x + size;
		var i = pageLine.length - 1;
		peote.text.util.StringUtils.iter(chars, function(charcode) {
			charData = getCharData(charcode);
			if (charData != null) {
				glyph = new GlyphT();
				pageLine.pushGlyph(glyph);
				setStyle(glyph, glyphStyle);
				if (first) {
					first = false;
					y += _baseLineOffset(pageLine.base, glyph, charData);
				};
				setCharcode(glyph, charcode, charData);
				setSize(glyph, charData);
				x += kerningSpaceOffset(prev_glyph, glyph, charData);
				setPosition(glyph, charData, x, y);
				if (glyph.x + glyph.width >= line_x) {
					if (glyph.x < line_max) {
						if (addRemoveGlyphes) _buffer.addElement(glyph);
						pageLine.visibleTo++;
					};
				} else {
					pageLine.visibleFrom++;
					pageLine.visibleTo++;
				};
				x += nextGlyphOffset(glyph, charData);
				prev_glyph = glyph;
				i++;
			} else if (onUnrecognizedChar != null) onUnrecognizedChar(charcode, i);
		});
		pageLine.textSize += x - x_start;
		return x - x_start;
	}
	public function pageLineDeleteChar(pageLine:PageLineT, x:Float, size:Float, offset:Float, position:Int = 0, addRemoveGlyphes:Bool = true):Float {
		if (addRemoveGlyphes && position >= pageLine.visibleFrom && position < pageLine.visibleTo) {
			_buffer.removeElement(pageLine.getGlyph(position));
		};
		var _offset = _pageLineDeleteCharsOffset(pageLine, x, size, offset, position, position + 1, addRemoveGlyphes);
		if (position < pageLine.visibleFrom) {
			pageLine.visibleFrom--;
			pageLine.visibleTo--;
		} else if (position < pageLine.visibleTo) {
			pageLine.visibleTo--;
		};
		pageLine.splice(position, 1);
		return _offset;
	}
	public function pageLineDeleteChars(pageLine:PageLineT, x:Float, size:Float, offset:Float, from:Int = 0, ?to:Null<Int>, addRemoveGlyphes:Bool = true):Float {
		if (to == null) to = pageLine.length;
		for (i in ((from < pageLine.visibleFrom) ? pageLine.visibleFrom : from) ... ((to < pageLine.visibleTo) ? to : pageLine.visibleTo)) {
			if (addRemoveGlyphes) _buffer.removeElement(pageLine.getGlyph(i));
		};
		return _pageLineDeleteChars(pageLine, x, size, offset, from, to, addRemoveGlyphes);
	}
	public function pageLineCutChars(pageLine:PageLineT, x:Float, size:Float, offset:Float, from:Int = 0, ?to:Null<Int>, addRemoveGlyphes:Bool = true):String {
		if (to == null) to = pageLine.length;
		var cut = "";
		for (i in from ... to) {
			cut += String.fromCharCode(pageLine.getGlyph(i).char);
			if (i >= pageLine.visibleFrom && i < pageLine.visibleTo && addRemoveGlyphes) _buffer.removeElement(pageLine.getGlyph(i));
		};
		_pageLineDeleteChars(pageLine, x, size, offset, from, to, addRemoveGlyphes);
		return cut;
	}
	public function pageLineGetChars(pageLine:PageLineT, from:Int = 0, ?to:Null<Int>):String {
		if (to == null) to = pageLine.length;
		var chars:String = "";
		for (i in from ... to) chars += String.fromCharCode(pageLine.getGlyph(i).char);
		return chars;
	}
	inline function _pageLineDeleteChars(pageLine:PageLineT, x:Float, size:Float, offset:Float, from:Int, to:Int, addRemoveGlyphes:Bool):Float {
		var _offset = _pageLineDeleteCharsOffset(pageLine, x, size, offset, from, to, addRemoveGlyphes);
		if (from < pageLine.visibleFrom) {
			pageLine.visibleFrom = (to < pageLine.visibleFrom) ? pageLine.visibleFrom - to + from : from;
			pageLine.visibleTo = (to < pageLine.visibleTo) ? pageLine.visibleTo - to + from : from;
		} else if (from < pageLine.visibleTo) {
			pageLine.visibleTo = (to < pageLine.visibleTo) ? pageLine.visibleTo - to + from : from;
		};
		pageLine.splice(from, to - from);
		return _offset;
	}
	inline function _pageLineDeleteCharsOffset(pageLine:PageLineT, x:Float, size:Float, offset:Float, from:Int, to:Int, addRemoveGlyphes:Bool):Float {
		var _offset:Float = 0.0;
		if (to < pageLine.length) {
			var charData = getCharData(pageLine.getGlyph(to).char);
			if (from == 0) {
				_offset = x + offset - leftGlyphPos(pageLine.getGlyph(to), charData);
			} else {
				_offset = rightGlyphPos(pageLine.getGlyph(from - 1), getCharData(pageLine.getGlyph(from - 1).char)) - leftGlyphPos(pageLine.getGlyph(to), charData);
				_offset += kerningSpaceOffset(pageLine.getGlyph(from - 1), pageLine.getGlyph(to), charData);
			};
			if (pageLine.updateFrom > from) pageLine.updateFrom = from;
			pageLine.updateTo = pageLine.length - to + from;
			_setLinePositionOffset(pageLine, x, size, _offset, to, to, pageLine.length, addRemoveGlyphes);
		} else {
			if (pageLine.updateFrom >= pageLine.length - to + from) {
				pageLine.updateFrom = 0x1000000;
				pageLine.updateTo = 0;
			} else if (pageLine.updateTo > pageLine.length - to + from) {
				pageLine.updateTo = pageLine.length - to + from;
			};
			if (from != 0) _offset = rightGlyphPos(pageLine.getGlyph(from - 1), getCharData(pageLine.getGlyph(from - 1).char)) - (x + offset + pageLine.textSize) else _offset = -pageLine.textSize;
			pageLine.textSize += _offset;
		};
		return _offset;
	}
	public function pageLineUpdate(pageLine:PageLineT, ?from:Null<Int>, ?to:Null<Int>) {
		if (from != null) pageLine.updateFrom = from;
		if (to != null) pageLine.updateTo = to;
		if (pageLine.updateTo > 0) {
			if (pageLine.visibleFrom > pageLine.updateFrom) pageLine.updateFrom = pageLine.visibleFrom;
			if (pageLine.visibleTo < pageLine.updateTo) pageLine.updateTo = pageLine.visibleTo;
			for (i in pageLine.updateFrom ... pageLine.updateTo) glyphUpdate(pageLine.getGlyph(i));
			pageLine.updateFrom = 0x1000000;
			pageLine.updateTo = 0;
		};
	}
	public function pageLineGetPositionAtChar(pageLine:PageLineT, x:Float, offset:Float, position:Int):Float {
		if (position == 0 || pageLine.length == 0) return x + offset else if (position < pageLine.length) {
			var right_glyph = pageLine.getGlyph(position);
			var chardata = getCharData(right_glyph.char);
			return (rightGlyphPos(pageLine.getGlyph(position - 1), chardata) + leftGlyphPos(right_glyph, chardata)) / 2;
		} else {
			var last_glyph = pageLine.getGlyph(pageLine.length - 1);
			return rightGlyphPos(last_glyph, getCharData(last_glyph.char));
		};
	}
	public function pageLineGetCharAtPosition(pageLine:PageLineT, x:Float, size:Float, offset:Float, xPosition:Float, intoVisibleRange:Bool = true):Int {
		if (xPosition <= x + ((intoVisibleRange) ? 0 : offset)) return (intoVisibleRange) ? pageLine.visibleFrom : 0 else if (xPosition >= x + ((intoVisibleRange) ? size : offset + pageLine.textSize)) return (intoVisibleRange) ? pageLine.visibleTo : pageLine.length else {
			{
				if (pageLine.length == 0 || xPosition <= pageLine.getGlyph(0).x) return 0 else {
					var from:Int = (intoVisibleRange) ? pageLine.visibleFrom : 0;
					var to:Int = (intoVisibleRange) ? pageLine.visibleTo : pageLine.length;
					if (from >= to) return pageLine.length;
					while (from + 1 < to) if (xPosition > pageLine.getGlyph(from + ((to - from) >> 1)).x) from = from + ((to - from) >> 1) else to = from + ((to - from) >> 1);
					var left_glyph = pageLine.getGlyph(from);
					var chardata = getCharData(left_glyph.char);
					if (xPosition < (leftGlyphPos(left_glyph, chardata) + rightGlyphPos(left_glyph, chardata)) / 2) return from else return to;
				};
			};
		};
	}
	inline function pageLineIsWordCharAt(pageLine:PageLineT, position:Int):Bool {
		return ~/\w/.match(String.fromCharCode(pageLine.getGlyph(position).char));
	}
	inline function pageLineIsWhitespaceCharAt(pageLine:PageLineT, position:Int):Bool {
		return ~/\s/.match(String.fromCharCode(pageLine.getGlyph(position).char));
	}
	public inline function pageLineWordLeft(pageLine:PageLineT, position:Int):Int {
		if (position <= 0) return 0;
		if (pageLineIsWhitespaceCharAt(pageLine, position - 1)) while (position > 0 && pageLineIsWhitespaceCharAt(pageLine, position - 1)) position--;
		if (position <= 0) return 0;
		if (pageLineIsWordCharAt(pageLine, position - 1)) while (position > 0 && pageLineIsWordCharAt(pageLine, position - 1)) position-- else while (position > 0 && (!pageLineIsWordCharAt(pageLine, position - 1) && !pageLineIsWhitespaceCharAt(pageLine, position - 1))) position--;
		return position;
	}
	public inline function pageLineWordRight(pageLine:PageLineT, position:Int):Int {
		if (position >= pageLine.length) return pageLine.length;
		if (pageLineIsWhitespaceCharAt(pageLine, position)) while (position < pageLine.length && pageLineIsWhitespaceCharAt(pageLine, position)) position++ else {
			if (pageLineIsWordCharAt(pageLine, position)) while (position < pageLine.length && pageLineIsWordCharAt(pageLine, position)) position++ else while (position < pageLine.length && (!pageLineIsWordCharAt(pageLine, position) && !pageLineIsWhitespaceCharAt(pageLine, position))) position++;
			while (position < pageLine.length && pageLineIsWhitespaceCharAt(pageLine, position)) position++;
		};
		return position;
	}
	/**
		
				Creates a new Line and returns it. The new created Line is displayed automatically.
				@param chars String that contains the chars (newlines have no effect)
				@param x horizontal position of the upper left pixel of the line, is 0 by default
				@param y vertical position of the upper left pixel of the line, is 0 by default
				@param size (optional) limits the line-size in pixel, so only glyphes inside this range will be displayed
				@param offset (optional) how much pixels the line is shifted inside it's visible range
				@param glyphStyle (optional) GlyphStyle of the line, by default it is using the default FontStyle of the FontProgram 
				@param defaultFontRange (optional) unicode range of the Font where to fetch the line-metric from (by default it's using the metric from the range of the first letter)
				@param onUnrecognizedChar (optional) the function that is called whenever the font does not contain a char
			
	**/
	public inline function createLine(chars:String, x:Float, y:Float, ?size:Null<Float>, ?offset:Null<Float>, ?glyphStyle:Null<peote.ui.style.FontStyleTiled>, ?defaultFontRange:Null<Int>, addRemoveGlyphes:Bool = true, ?onUnrecognizedChar:(Int, Int) -> Void):LineT {
		var line = new LineT();
		lineSet(line, chars, x, y, size, offset, glyphStyle, defaultFontRange, addRemoveGlyphes, onUnrecognizedChar);
		return line;
	}
	/**
		
				Add the line to FontProgram to display it.
				@param line the Line instance
			
	**/
	public inline function lineAdd(line:LineT):Void pageLineAdd(line.pageLine);
	/**
		
				Removes the line from FontProgram to not display it anymore.
				@param line the Line instance
			
	**/
	public inline function lineRemove(line:LineT):Void pageLineRemove(line.pageLine);
	/**
		
				Changing all chars of an existing Line. (can be faster than creating a new line)
				Returns false if the font don't contain one of the chars.
				@param line the Line instance
				@param chars String that contains the chars (newlines have no effect)
				@param x horizontal position of the upper left pixel of the line, is 0 by default
				@param y vertical position of the upper left pixel of the line, is 0 by default
				@param size (optional) limits the line-size in pixel, so only glyphes inside this range will be displayed
				@param offset (optional) how much pixels the line is shifted inside it's visible range
				@param glyphStyle (optional) GlyphStyle of the line, by default it is using the default FontStyle of the FontProgram 
				@param defaultFontRange (optional) unicode range of the Font where to fetch the line-metric from (by default it's using the metric from the range of the first letter)
				@param addRemoveGlyphes (optional) set this to false if the line is not added to prevent also adding/removing of glyphes
				@param onUnrecognizedChar (optional) the function that is called whenever the font does not contain a char
			
	**/
	public inline function lineSet(line:LineT, chars:String, ?x:Null<Float>, ?y:Null<Float>, ?size:Null<Float>, ?offset:Null<Float>, ?glyphStyle:Null<peote.ui.style.FontStyleTiled>, ?defaultFontRange:Null<Int>, addRemoveGlyphes:Bool = true, ?onUnrecognizedChar:(Int, Int) -> Void) {
		if (x != null) line.x = x;
		if (size != null) line.size = size;
		if (offset != null) line.offset = offset;
		pageLineSet(line.pageLine, chars, x, y, line.size, line.offset, glyphStyle, defaultFontRange, addRemoveGlyphes, onUnrecognizedChar);
	}
	/**
		
				Changing the style of glyphes in an existing Line. Needs lineUpdate() after to get effect.
				Returns the offset about how the textSize was changed.
				@param line Line instance
				@param glyphStyle new GlyphStyle
				@param from position of the first char into range, is 0 by default (start of line)
				@param to position after the last char into range, is line.length by default (end of line)
				@param addRemoveGlyphes (optional) set this to false if the line is not added to prevent also adding/removing of glyphes
			
	**/
	public inline function lineSetStyle(line:LineT, glyphStyle:peote.ui.style.FontStyleTiled, from:Int = 0, ?to:Null<Int>, addRemoveGlyphes:Bool = true):Float {
		return pageLineSetStyle(line.pageLine, line.x, line.size, line.offset, glyphStyle, from, to, addRemoveGlyphes);
	}
	/**
		
				Set the position of a Line. Needs lineUpdate() after to get effect.
				@param line Line instance
				@param x horizontal position of the upper left pixel of the line
				@param y vertical position of the upper left pixel of the line
				@param offset (optional) how much pixels the line is shifted inside it's visible range
				@param addRemoveGlyphes (optional) set this to false if the line is not added to prevent also adding/removing of glyphes
			
	**/
	public inline function lineSetPosition(line:LineT, x:Float, y:Float, ?offset:Null<Float>, addRemoveGlyphes:Bool = true) {
		pageLineSetPosition(line.pageLine, line.x, line.size, line.offset, x, y, offset, addRemoveGlyphes);
		line.x = x;
		if (offset != null) line.offset = offset;
	}
	/**
		
				Set the x position of a Line. Needs lineUpdate() after to get effect.
				@param line Line instance
				@param x horizontal position of the upper left pixel of the line
				@param offset (optional) how much pixels the line is shifted inside it's visible range
				@param addRemoveGlyphes (optional) set this to false if the line is not added to prevent also adding/removing of glyphes
			
	**/
	public inline function lineSetXPosition(line:LineT, x:Float, ?offset:Null<Float>, addRemoveGlyphes:Bool = true) {
		pageLineSetXPosition(line.pageLine, line.x, line.size, line.offset, x, offset, addRemoveGlyphes);
		line.x = x;
		if (offset != null) line.offset = offset;
	}
	/**
		
				Set the y position of a Line. Needs lineUpdate() after to get effect.
				@param line Line instance
				@param y vertical position of the upper left pixel of the line
				@param offset (optional) how much pixels the line is shifted inside it's visible range
				@param addRemoveGlyphes (optional) set this to false if the line is not added to prevent also adding/removing of glyphes
			
	**/
	public inline function lineSetYPosition(line:LineT, y:Float, ?offset:Null<Float>, addRemoveGlyphes:Bool = true) {
		pageLineSetYPosition(line.pageLine, line.x, line.size, line.offset, y, offset, addRemoveGlyphes);
		if (offset != null) line.offset = offset;
	}
	/**
		
				Set the position and size of a Line. Needs lineUpdate() after to get effect.
				@param line Line instance
				@param x horizontal position of the upper left pixel of the line
				@param y vertical position of the upper left pixel of the line
				@param size limits the line-size in pixel, so only glyphes inside this range will be displayed
				@param offset (optional) how much pixels the line is shifted inside it's visible range
				@param addRemoveGlyphes (optional) set this to false if the line is not added to prevent also adding/removing of glyphes
			
	**/
	public inline function lineSetPositionSize(line:LineT, x:Float, y:Float, size:Float, ?offset:Null<Float>, addRemoveGlyphes:Bool = true) {
		pageLineSetPositionSize(line.pageLine, line.x, size, line.offset, x, y, offset, addRemoveGlyphes);
		line.x = x;
		line.size = size;
		if (offset != null) line.offset = offset;
	}
	/**
		
				Set the size of a Line. Needs lineUpdate() after to get effect.
				@param line Line instance
				@param size limits the line-size in pixel, so only glyphes inside this range will be displayed
				@param offset (optional) how much pixels the line is shifted inside it's visible range
				@param addRemoveGlyphes (optional) set this to false if the line is not added to prevent also adding/removing of glyphes
			
	**/
	public inline function lineSetSize(line:LineT, size:Float, ?offset:Null<Float>, addRemoveGlyphes:Bool = true) {
		pageLineSetSize(line.pageLine, line.x, size, line.offset, offset, addRemoveGlyphes);
		line.size = size;
		if (offset != null) line.offset = offset;
	}
	/**
		
				Set the offset of how much the Line is shifted. Needs lineUpdate() after to get effect.
				@param line Line instance where to change the style
				@param offset how much pixels the line is shifted inside it's visible range
				@param addRemoveGlyphes (optional) set this to false if the line is not added to prevent also adding/removing of glyphes
			
	**/
	public inline function lineSetOffset(line:LineT, offset:Float, addRemoveGlyphes:Bool = true) {
		pageLineSetOffset(line.pageLine, line.x, line.size, line.offset, offset, addRemoveGlyphes);
		line.offset = offset;
	}
	/**
		
				Changing a char inside of a Line. Needs lineUpdate() after to get effect. Returns the offset about how the textSize was changed.
				@param line the Line instance
				@param charcode the unicode number of the char (newline have no effect)
				@param position where to change the char, is 0 by default (first char into line)
				@param glyphStyle (optional) GlyphStyle of the new chars, by default it is using the default FontStyle of the FontProgram 
				@param addRemoveGlyphes (optional) set this to false if the line is not added to prevent also adding/removing of glyphes
				@param onUnrecognizedChar (optional) the function that is called whenever the font does not contain a char
			
	**/
	public inline function lineSetChar(line:LineT, charcode:Int, position:Int = 0, ?glyphStyle:peote.ui.style.FontStyleTiled, addRemoveGlyphes:Bool = true, ?onUnrecognizedChar:(Int, Int) -> Void):Float {
		return pageLineSetChar(line.pageLine, line.x, line.size, line.offset, charcode, position, glyphStyle, addRemoveGlyphes, onUnrecognizedChar);
	}
	/**
		
				Changing the chars inside of a Line. Needs lineUpdate() after to get effect. Returns the offset about how the textSize was changed.
				@param line the Line instance
				@param chars String that contains the letters (newlines have no effect)
				@param position where to change, is 0 by default (first char into line)
				@param glyphStyle (optional) GlyphStyle of the new chars, by default it is using the default FontStyle of the FontProgram 
				@param addRemoveGlyphes (optional) set this to false if the line is not added to prevent also adding/removing of glyphes
				@param onUnrecognizedChar (optional) the function that is called whenever the font does not contain a char
			
	**/
	public inline function lineSetChars(line:LineT, chars:String, position:Int = 0, ?glyphStyle:peote.ui.style.FontStyleTiled, addRemoveGlyphes:Bool = true, ?onUnrecognizedChar:(Int, Int) -> Void):Float {
		return pageLineSetChars(line.pageLine, line.x, line.size, line.offset, chars, position, glyphStyle, addRemoveGlyphes, onUnrecognizedChar);
	}
	/**
		
				Insert a new char into a Line. If it's not inserted at end of line it needs lineUpdate() after to get effect.
				Returns the offset about how the textSize was changed.
				@param line the Line instance
				@param charcode the unicode number of the new char (newline have no effect)
				@param position where to insert, is 0 by default (before first char into line)
				@param glyphStyle (optional) GlyphStyle of the new chars, by default it is using the default FontStyle of the FontProgram 
				@param addRemoveGlyphes (optional) set this to false if the line is not added to prevent also adding/removing of glyphes
				@param onUnrecognizedChar (optional) the function that is called whenever the font does not contain a char
			
	**/
	public inline function lineInsertChar(line:LineT, charcode:Int, position:Int = 0, ?glyphStyle:peote.ui.style.FontStyleTiled, addRemoveGlyphes:Bool = true, ?onUnrecognizedChar:(Int, Int) -> Void):Float {
		return pageLineInsertChar(line.pageLine, line.x, line.size, line.offset, charcode, position, glyphStyle, addRemoveGlyphes, onUnrecognizedChar);
	}
	/**
		
				Insert new chars into a Line. If it's not inserted at end of line it needs lineUpdate() after to get effect.
				Returns the offset about how the textSize was changed.
				@param line the Line instance
				@param chars String that contains the new letters (newlines have no effect)
				@param position where to insert, is 0 by default (before first char into line)
				@param glyphStyle (optional) GlyphStyle of the new chars, by default it is using the default FontStyle of the FontProgram 
				@param addRemoveGlyphes (optional) set this to false if the line is not added to prevent also adding/removing of glyphes
				@param onUnrecognizedChar (optional) the function that is called whenever the font does not contain a char
			
	**/
	public inline function lineInsertChars(line:LineT, chars:String, position:Int = 0, ?glyphStyle:peote.ui.style.FontStyleTiled, addRemoveGlyphes:Bool = true, ?onUnrecognizedChar:(Int, Int) -> Void):Float {
		return pageLineInsertChars(line.pageLine, line.x, line.size, line.offset, chars, position, glyphStyle, addRemoveGlyphes, onUnrecognizedChar);
	}
	/**
		
				Append new chars at end of a Line. Returns the offset about how the textSize was changed.
				@param line the Line instance
				@param chars String that contains the new chars (newlines have no effect)
				@param glyphStyle (optional) GlyphStyle of the new chars, by default it is using the default FontStyle of the FontProgram 
				@param addRemoveGlyphes (optional) set this to false if the line is not added to prevent also adding/removing of glyphes
				@param onUnrecognizedChar (optional) the function that is called whenever the font does not contain a char
			
	**/
	public inline function lineAppendChars(line:LineT, chars:String, ?glyphStyle:peote.ui.style.FontStyleTiled, addRemoveGlyphes:Bool = true, ?onUnrecognizedChar:(Int, Int) -> Void):Float {
		return pageLineAppendChars(line.pageLine, line.x, line.size, line.offset, chars, glyphStyle, addRemoveGlyphes, onUnrecognizedChar);
	}
	/**
		
				Delete a char from a Line and returns the offset of how much the line was shrinked.
				If it's not the last char into line it needs lineUpdate() after to get effect.
				@param line the Line instance
				@param position where to delete, is 0 by default (first char into line)
				@param addRemoveGlyphes (optional) set this to false if the line is not added to prevent also adding/removing of glyphes
			
	**/
	public inline function lineDeleteChar(line:LineT, position:Int = 0, addRemoveGlyphes:Bool = true):Float {
		return pageLineDeleteChar(line.pageLine, line.x, line.size, line.offset, position, addRemoveGlyphes);
	}
	/**
		
				Delete chars from a Line and returns the offset of how much the line was shrinked.
				If it's not the last chars into line it needs lineUpdate() after to get effect.
				@param from position of the first char into range, is 0 by default (start of line)
				@param to position after the last char into range, is line.length by default (end of line)
				@param addRemoveGlyphes (optional) set this to false if the line is not added to prevent also adding/removing of glyphes
			
	**/
	public inline function lineDeleteChars(line:LineT, from:Int = 0, ?to:Null<Int>, addRemoveGlyphes:Bool = true):Float {
		return pageLineDeleteChars(line.pageLine, line.x, line.size, line.offset, from, to, addRemoveGlyphes);
	}
	/**
		
				Delete chars from a Line and returns it as a String. If it's not the last chars it needs lineUpdate() after to get effect.
				@param line the Line instance
				@param from position of the first char into range, is 0 by default (start of line)
				@param to position after the last char into range, is line.length by default (end of line)
				@param addRemoveGlyphes (optional) set this to false if the line is not added to prevent also adding/removing of glyphes
			
	**/
	public inline function lineCutChars(line:LineT, from:Int = 0, ?to:Null<Int>, addRemoveGlyphes:Bool = true):String {
		return pageLineCutChars(line.pageLine, line.x, line.size, line.offset, from, to, addRemoveGlyphes);
	}
	/**
		
				Returns the chars from a Line as a String.
				@param line the Line instance
				@param from position of the first char into range, is 0 by default (start of line)
				@param to position after the last char into range, is line.length by default (end of line)
			
	**/
	public inline function lineGetChars(line:LineT, from:Int = 0, ?to:Null<Int>):String {
		return pageLineGetChars(line.pageLine, from, to);
	}
	/**
		
				Updates a Line to apply the changes by one or more of the following functions:
				lineSetStyle(), lineSetPosition(), lineSetXPosition(), lineSetYPosition(), lineSetPositionSize(), lineSetSize(), lineSetOffset(),
				lineSetChar(), lineSetChars(), lineInsertChar(), lineInsertChars(), lineDeleteChar(), lineDeleteChars(), lineCutChars().
				Only chars that are into the visible area will be updated if the line is shifted by offset or limited by size.
				@param line the Line instance
				@param from position of the first char into range, by default this is set by the functions that was changing the line
				@param to position after the last char into range, by default this is set by the functions that was changing the line
			
	**/
	public inline function lineUpdate(line:LineT, ?from:Null<Int>, ?to:Null<Int>):Void pageLineUpdate(line.pageLine, from, to);
	/**
		
				Returns the x pixel-value of the middle position between a char and its previous char into a line.
				This function can be used to calculate a cursor-position.
				@param line the Line instance
				@param position index of the char into the line (0 returns the position before the first char)
			
	**/
	public inline function lineGetPositionAtChar(line:LineT, position:Int):Float {
		return pageLineGetPositionAtChar(line.pageLine, line.x, line.offset, position);
	}
	/**
		
				Returns the index of the char where to place the cursor at a given x pixel-position.
				This function can be used to pick a char by mouse-position.
				@param line the Line instance
				@param xPosition x pixel-value at where to pick the nearest char
			
	**/
	public inline function lineGetCharAtPosition(line:LineT, xPosition:Float, intoVisibleRange:Bool = true):Int {
		return pageLineGetCharAtPosition(line.pageLine, line.x, line.size, line.offset, xPosition, intoVisibleRange);
	}
	public inline function lineWordLeft(line:LineT, position:Int):Int return pageLineWordLeft(line.pageLine, position);
	public inline function lineWordRight(line:LineT, position:Int):Int return pageLineWordRight(line.pageLine, position);
	public inline function createPage(chars:String, x:Float, y:Float, ?width:Null<Float>, ?height:Null<Float>, ?xOffset:Null<Float>, ?yOffset:Null<Float>, glyphStyle:Null<peote.ui.style.FontStyleTiled> = null, ?defaultFontRange:Null<Int>, addRemoveGlyphes:Bool = true, ?onUnrecognizedChar:(Int, Int, Int) -> Void):PageT {
		var page = new PageT();
		pageSet(page, chars, x, y, width, height, xOffset, yOffset, glyphStyle, defaultFontRange, addRemoveGlyphes, onUnrecognizedChar);
		return page;
	}
	public inline function pageAdd(page:PageT) {
		for (i in page.visibleLineFrom ... page.visibleLineTo) pageLineAdd(page.getPageLine(i));
	}
	public inline function pageRemove(page:PageT) {
		for (i in page.visibleLineFrom ... page.visibleLineTo) pageLineRemove(page.getPageLine(i));
	}
	public inline function pageLineIsVisible(page:PageT, lineNumber:Int):Bool {
		return (page.visibleLineFrom <= lineNumber && lineNumber < page.visibleLineTo);
	}
	static var regLinesplit = new EReg("^(.*?)(\n|\r\n|\r)", "");
	public function pageSet(page:PageT, chars:String, ?x:Null<Float>, ?y:Null<Float>, ?width:Null<Float>, ?height:Null<Float>, ?xOffset:Null<Float>, ?yOffset:Null<Float>, ?glyphStyle:peote.ui.style.FontStyleTiled, ?defaultFontRange:Null<Int>, addRemoveGlyphes:Bool = true, ?onUnrecognizedChar:(Int, Int, Int) -> Void) {
		if (x != null) page.x = x;
		if (y != null) page.y = y else y = page.y;
		if (width != null) page.width = width;
		if (height != null) page.height = height;
		if (xOffset != null) page.xOffset = xOffset;
		if (yOffset != null) page.yOffset = yOffset;
		chars += "\n";
		var visibleLineFrom:Int = 0;
		var visibleLineTo:Int = 0;
		var i:Int = 0;
		var textWidth:Float = 0.0;
		y += page.yOffset;
		while (i < page.length && regLinesplit.match(chars)) {
			var pageLine = page.getPageLine(i);
			if (i > visibleLineFrom) {
				pageLineSet(pageLine, regLinesplit.matched(1), page.x, y, page.width, page.xOffset, glyphStyle, defaultFontRange, addRemoveGlyphes && pageLineIsVisible(page, i), (onUnrecognizedChar == null) ? null : onUnrecognizedChar.bind(i));
				if (y <= page.y + page.height) {
					if (addRemoveGlyphes && (!pageLineIsVisible(page, i))) pageLineAdd(pageLine);
					visibleLineTo++;
				} else {
					if (addRemoveGlyphes && pageLineIsVisible(page, i)) pageLineRemove(pageLine);
				};
			} else {
				pageLineSet(pageLine, regLinesplit.matched(1), page.x, y, page.width, page.xOffset, glyphStyle, defaultFontRange, addRemoveGlyphes && pageLineIsVisible(page, i), (onUnrecognizedChar == null) ? null : onUnrecognizedChar.bind(i));
				if (y + pageLine.lineHeight < page.y) {
					if (addRemoveGlyphes && pageLineIsVisible(page, i)) pageLineRemove(pageLine);
					visibleLineFrom++;
					visibleLineTo++;
				} else {
					if (addRemoveGlyphes && (!pageLineIsVisible(page, i))) pageLineAdd(pageLine);
					visibleLineTo++;
				};
			};
			i++;
			y += pageLine.lineHeight;
			if (pageLine.textSize > textWidth) textWidth = pageLine.textSize;
			chars = regLinesplit.matchedRight();
		};
		page.textWidth = textWidth;
		page.updateLineFrom = 0;
		page.updateLineTo = i;
		if (i < page.length) {
			while (addRemoveGlyphes && pageLineIsVisible(page, i)) {
				trace("removeLine", i);
				pageLineRemove(page.getPageLine(i));
				i++;
			};
			page.resize(page.updateLineTo);
			page.visibleLineFrom = visibleLineFrom;
			page.visibleLineTo = visibleLineTo;
		} else {
			y += _pageAppendChars(page, chars, i, y, visibleLineFrom, visibleLineTo, glyphStyle, defaultFontRange, addRemoveGlyphes, onUnrecognizedChar);
		};
		page.textHeight = y - page.yOffset - page.y;
	}
	inline function _pageAppendChars(page:PageT, chars:String, i:Int, y:Float, visibleLineFrom:Int, visibleLineTo:Int, ?glyphStyle:peote.ui.style.FontStyleTiled, defaultFontRange:Null<Int>, addRemoveGlyphes:Bool, onUnrecognizedChar:(Int, Int, Int) -> Void):Float {
		var textWidth = page.textWidth;
		var onUnrecognizedLineChar = (onUnrecognizedChar == null) ? null : onUnrecognizedChar.bind(i);
		var y_start = y;
		while (regLinesplit.match(chars)) {
			var pageLine = new PageLineT();
			if (i > visibleLineFrom) {
				if (y <= page.y + page.height) {
					pageLineSet(pageLine, regLinesplit.matched(1), page.x, y, page.width, page.xOffset, glyphStyle, defaultFontRange, addRemoveGlyphes, onUnrecognizedLineChar);
					visibleLineTo++;
				} else pageLineSet(pageLine, regLinesplit.matched(1), page.x, y, page.width, page.xOffset, glyphStyle, defaultFontRange, false, onUnrecognizedLineChar);
			} else {
				pageLineSet(pageLine, regLinesplit.matched(1), page.x, y, page.width, page.xOffset, glyphStyle, defaultFontRange, false, onUnrecognizedLineChar);
				if (y + pageLine.lineHeight < page.y) {
					visibleLineFrom++;
					visibleLineTo++;
				} else {
					if (addRemoveGlyphes) pageLineAdd(pageLine);
					visibleLineTo++;
				};
			};
			i++;
			y += pageLine.lineHeight;
			page.pushLine(pageLine);
			if (pageLine.textSize > textWidth) textWidth = pageLine.textSize;
			chars = regLinesplit.matchedRight();
		};
		page.visibleLineFrom = visibleLineFrom;
		page.visibleLineTo = visibleLineTo;
		page.textWidth = textWidth;
		return y - y_start;
	}
	public function pageAppendChars(page:PageT, chars:String, ?glyphStyle:peote.ui.style.FontStyleTiled, ?defaultFontRange:Null<Int>, addRemoveGlyphes:Bool = true, ?onUnrecognizedChar:(Int, Int, Int) -> Void):Float {
		chars += "\n";
		var offset:Float = 0;
		if (page.length > 0) {
			if (regLinesplit.match(chars)) {
				var i:Int = page.length - 1;
				var pageLine = page.getPageLine(i);
				pageLineAppendChars(pageLine, page.x, page.width, page.xOffset, regLinesplit.matched(1), glyphStyle, addRemoveGlyphes && pageLineIsVisible(page, i), (onUnrecognizedChar == null) ? null : onUnrecognizedChar.bind(i));
				pageTextWidthAfterExpand(page, pageLine.textSize);
				offset = _pageAppendChars(page, regLinesplit.matchedRight(), ++i, pageLine.y + pageLine.lineHeight, page.visibleLineFrom, page.visibleLineTo, glyphStyle, defaultFontRange, addRemoveGlyphes, onUnrecognizedChar);
			};
		} else offset = _pageAppendChars(page, chars, 0, page.y, 0, 0, glyphStyle, defaultFontRange, addRemoveGlyphes, onUnrecognizedChar);
		page.textHeight += offset;
		return offset;
	}
	public function pageSetStyle(page:PageT, glyphStyle:peote.ui.style.FontStyleTiled, fromLine:Int = 0, fromPosition:Int = 0, ?toLine:Null<Int>, ?toPosition:Null<Int>, addRemoveGlyphes:Bool = true):Float {
		if (toLine == null || toLine > page.length) toLine = page.length;
		if (toLine < fromLine) {
			var tmp = toLine;
			toLine = fromLine;
			fromLine = tmp;
		} else if (fromLine == toLine) toLine++;
		if (fromLine < page.updateLineFrom) page.updateLineFrom = fromLine;
		if (toLine > page.updateLineTo) page.updateLineTo = toLine;
		if (fromLine < 0) fromLine = 0;
		var pageLine:PageLineT;
		var offset:Float = 0.0;
		var y:Float = 0.0;
		var oldLineHeight:Float = 0.0;
		var oldLineSize:Float = 0.0;
		var newLineSize:Float = 0.0;
		var visibleLineFrom = page.visibleLineFrom;
		var visibleLineTo = page.visibleLineTo;
		for (i in fromLine ... toLine) {
			pageLine = page.getPageLine(i);
			if (pageLine.textSize > oldLineSize) oldLineSize = pageLine.textSize;
			oldLineHeight = pageLine.lineHeight;
			if (i == fromLine) {
				pageLineSetStyle(pageLine, page.x, page.width, page.xOffset, glyphStyle, fromPosition, addRemoveGlyphes && pageLineIsVisible(page, i));
				y = pageLine.y;
			} else {
				if (i == toLine - 1) pageLineSetStyle(pageLine, page.x, page.width, page.xOffset, glyphStyle, 0, toPosition, addRemoveGlyphes && pageLineIsVisible(page, i)) else pageLineSetStyle(pageLine, page.x, page.width, page.xOffset, glyphStyle, addRemoveGlyphes && pageLineIsVisible(page, i));
				y += pageLine.lineHeight;
			};
			if (pageLine.textSize > newLineSize) newLineSize = pageLine.textSize;
			if (pageLine.lineHeight != oldLineHeight) {
				pageLineSetYPosition(pageLine, page.x, page.width, page.xOffset, y, null, addRemoveGlyphes && pageLineIsVisible(page, i));
				offset += pageLine.lineHeight - oldLineHeight;
				if (pageLine.y + pageLine.lineHeight >= page.y) {
					if (pageLine.y < page.y + page.height) {
						if (i < visibleLineFrom || i >= visibleLineTo) {
							if (addRemoveGlyphes && !pageLineIsVisible(page, i)) pageLineAdd(pageLine);
							if (visibleLineFrom > i) visibleLineFrom = i;
							if (visibleLineTo < i + 1) visibleLineTo = i + 1;
						};
					} else {
						if (addRemoveGlyphes && pageLineIsVisible(page, i)) pageLineRemove(pageLine);
						if (visibleLineTo > i) visibleLineTo = i;
					};
				} else {
					if (addRemoveGlyphes && pageLineIsVisible(page, i)) pageLineRemove(pageLine);
					visibleLineFrom = i + 1;
				};
			};
		};
		pageTextWidthAfterChangeMultiple(page, fromLine, toLine, oldLineSize, newLineSize);
		if (offset != 0) {
			page.updateLineTo = page.length;
			for (i in toLine ... page.length) {
				pageLine = page.getPageLine(i);
				pageLineSetYPosition(pageLine, page.x, page.width, page.xOffset, pageLine.y + offset, null, addRemoveGlyphes && pageLineIsVisible(page, i));
				if (pageLine.y + pageLine.lineHeight >= page.y) {
					if (pageLine.y < page.y + page.height) {
						if (i < visibleLineFrom || i >= visibleLineTo) {
							if (addRemoveGlyphes && !pageLineIsVisible(page, i)) pageLineAdd(pageLine);
							if (visibleLineFrom > i) visibleLineFrom = i;
							if (visibleLineTo < i + 1) visibleLineTo = i + 1;
						};
					} else {
						if (addRemoveGlyphes && pageLineIsVisible(page, i)) pageLineRemove(pageLine);
						if (visibleLineTo > i) visibleLineTo = i;
					};
				} else {
					if (addRemoveGlyphes && pageLineIsVisible(page, i)) pageLineRemove(pageLine);
					visibleLineFrom = i + 1;
				};
			};
		};
		page.visibleLineFrom = visibleLineFrom;
		page.visibleLineTo = visibleLineTo;
		page.textHeight += offset;
		return offset;
	}
	public function pageInsertChars(page:PageT, chars:String, lineNumber:Int = 0, position:Int = 0, ?glyphStyle:peote.ui.style.FontStyleTiled, ?defaultFontRange:Null<Int>, addRemoveGlyphes:Bool = true, ?onUnrecognizedChar:(Int, Int, Int) -> Void):Float {
		chars += "\n";
		var offset:Float = 0.0;
		if (page.length > 0 && lineNumber < page.length) {
			if (regLinesplit.match(chars)) {
				var pageLine = page.getPageLine(lineNumber);
				if (regLinesplit.matchedRight().length == 0) {
					if (lineNumber < page.updateLineFrom) page.updateLineFrom = lineNumber;
					if (lineNumber >= page.updateLineTo) page.updateLineTo = lineNumber + 1;
					pageLineInsertChars(pageLine, page.x, page.width, page.xOffset, regLinesplit.matched(1), position, glyphStyle, addRemoveGlyphes && (page.visibleLineFrom <= lineNumber && lineNumber < page.visibleLineTo), (onUnrecognizedChar == null) ? null : onUnrecognizedChar.bind(lineNumber));
					pageTextWidthAfterExpand(page, pageLine.textSize);
				} else {
					var restChars = pageLine.splice(position, pageLine.length - position);
					var oldFrom:Int = 0;
					var oldTo:Int = 0;
					var restCharsTextSize:Float = 0.0;
					var firstLineOldTextSize:Float = pageLine.textSize;
					if (restChars.length > 0) {
						if (position == 0) {
							pageLine.textSize = 0.0;
							restCharsTextSize = firstLineOldTextSize;
						} else {
							pageLine.textSize = rightGlyphPos(pageLine.getGlyph(position - 1), getCharData(pageLine.getGlyph(position - 1).char)) - page.x - page.xOffset;
							restCharsTextSize = firstLineOldTextSize - pageLine.textSize;
						};
						oldFrom = pageLine.visibleFrom - pageLine.length;
						oldTo = pageLine.visibleTo - pageLine.length;
						if (pageLine.visibleFrom > pageLine.length) pageLine.visibleFrom = pageLine.length;
						if (pageLine.visibleTo > pageLine.length) pageLine.visibleTo = pageLine.length;
					};
					var oldLineFrom = page.visibleLineFrom;
					var oldLineTo = page.visibleLineTo;
					pageLineAppendChars(pageLine, page.x, page.width, page.xOffset, regLinesplit.matched(1), glyphStyle, addRemoveGlyphes && (page.visibleLineFrom <= lineNumber && lineNumber < page.visibleLineTo), (onUnrecognizedChar == null) ? null : onUnrecognizedChar.bind(lineNumber));
					var firstLineNewTextSize:Float = pageLine.textSize;
					var restLines:Array<PageLineT> = page.spliceLines(lineNumber + 1, page.length - (lineNumber + 1));
					var restLineFrom = page.length;
					var restLineWasVisible:Bool = (page.visibleLineFrom <= lineNumber && lineNumber < page.visibleLineTo);
					offset = _pageAppendChars(page, regLinesplit.matchedRight(), page.length, pageLine.y + pageLine.lineHeight, (page.visibleLineFrom > page.length) ? page.length : page.visibleLineFrom, (page.visibleLineTo > page.length) ? page.length : page.visibleLineTo, glyphStyle, defaultFontRange, addRemoveGlyphes, onUnrecognizedChar);
					if (restChars.length > 0) {
						var pageLine = page.getPageLine(page.length - 1);
						if (pageLine.length < pageLine.updateFrom) pageLine.updateFrom = pageLine.length;
						var line_max = page.x + page.width;
						var deltaX = pageLine.textSize - leftGlyphPos(restChars[0], getCharData(restChars[0].char)) + page.x + page.xOffset;
						if (pageLine.length > 0) {
							deltaX += kerningSpaceOffset(pageLine.getGlyph(pageLine.length - 1), restChars[0], getCharData(restChars[0].char));
						};
						var deltaY = pageLine.y + pageLine.base - glyphGetYPositionAtBase(restChars[0]);
						var restLineIsVisible:Bool = (page.visibleLineFrom <= page.length - 1 && page.length - 1 < page.visibleLineTo);
						for (i in 0 ... restChars.length) {
							restChars[i].x += deltaX;
							restChars[i].y += deltaY;
							if (restLineWasVisible) {
								if (restChars[i].x + restChars[i].width >= page.x) {
									if (restChars[i].x < line_max) {
										if (restLineIsVisible && addRemoveGlyphes && (i < oldFrom || i >= oldTo)) _buffer.addElement(restChars[i]);
										pageLine.visibleTo++;
									} else if (restLineIsVisible && addRemoveGlyphes && i >= oldFrom && i < oldTo) _buffer.removeElement(restChars[i]);
								} else {
									if (restLineIsVisible && addRemoveGlyphes && i >= oldFrom && i < oldTo) _buffer.removeElement(restChars[i]);
									pageLine.visibleFrom++;
									pageLine.visibleTo++;
								};
								if (!restLineIsVisible && addRemoveGlyphes && i >= oldFrom && i < oldTo) _buffer.removeElement(restChars[i]);
							} else {
								if (restChars[i].x + restChars[i].width >= page.x) {
									if (restChars[i].x < line_max) {
										if (addRemoveGlyphes && restLineIsVisible) _buffer.addElement(restChars[i]);
										pageLine.visibleTo++;
									};
								} else {
									pageLine.visibleFrom++;
									pageLine.visibleTo++;
								};
							};
						};
						pageLine.append(restChars);
						pageLine.updateTo = pageLine.length;
						if (page.length - 1 < page.updateLineFrom) page.updateLineFrom = page.length - 1;
						pageLine.textSize += restCharsTextSize;
						pageTextWidthAfterExpand(page, pageLine.textSize);
					};
					if (restLines.length > 0) {
						if (page.length < page.updateLineFrom) page.updateLineFrom = page.length;
						page.append(restLines);
						var visibleLineFrom = page.visibleLineFrom;
						var visibleLineTo = page.visibleLineTo;
						var fromLine = page.length - restLines.length;
						for (i in fromLine ... page.length) {
							var pageLine = page.getPageLine(i);
							pageLineSetYPosition(pageLine, page.x, page.width, page.xOffset, offset + pageLine.y, null, addRemoveGlyphes && (oldLineFrom <= restLineFrom && restLineFrom < oldLineTo));
							if (pageLine.y + pageLine.lineHeight >= page.y) {
								if (pageLine.y < page.y + page.height) {
									if (i < page.visibleLineFrom || i >= page.visibleLineTo) {
										if (addRemoveGlyphes && !(restLineFrom >= oldLineFrom && restLineFrom < oldLineTo)) pageLineAdd(pageLine);
										if (visibleLineFrom > i) visibleLineFrom = i;
										if (visibleLineTo < i + 1) visibleLineTo = i + 1;
									};
								} else {
									if (addRemoveGlyphes && restLineFrom >= oldLineFrom && restLineFrom < oldLineTo) pageLineRemove(pageLine);
									if (visibleLineTo > i) visibleLineTo = i;
								};
							} else {
								if (addRemoveGlyphes && restLineFrom >= oldLineFrom && restLineFrom < oldLineTo) pageLineRemove(pageLine);
								visibleLineFrom = i + 1;
							};
							restLineFrom++;
						};
						page.visibleLineFrom = visibleLineFrom;
						page.visibleLineTo = visibleLineTo;
					};
					pageTextWidthAfterChange(page, firstLineOldTextSize, firstLineNewTextSize);
					if (page.length > page.updateLineTo) page.updateLineTo = page.length;
				};
			};
		} else {
			offset = _pageAppendChars(page, chars, page.length, page.y + page.textHeight, page.visibleLineFrom, page.visibleLineTo, glyphStyle, defaultFontRange, addRemoveGlyphes, onUnrecognizedChar);
			page.updateLineFrom = 0;
			page.updateLineTo = page.length;
		};
		page.textHeight += offset;
		return offset;
	}
	public inline function pageTextWidthAfterExpand(page:PageT, newSize:Float) {
		if (newSize > page.textWidth) page.textWidth = newSize;
	}
	public inline function pageTextWidthAfterChange(page:PageT, oldSize:Float, newSize:Float) {
		if (newSize > page.textWidth) page.textWidth = newSize else if (oldSize >= page.textWidth && newSize < page.textWidth) {
			for (pageLine in page.pageLines) if (pageLine.textSize > newSize) newSize = pageLine.textSize;
			page.textWidth = newSize;
		};
	}
	public inline function pageTextWidthAfterChangeMultiple(page:PageT, fromLine:Int, toLine:Int, oldSize:Float, newSize:Float) {
		if (newSize > page.textWidth) page.textWidth = newSize else if (oldSize >= page.textWidth && newSize < page.textWidth) {
			var pageLine:PageLineT;
			for (i in 0 ... fromLine) {
				pageLine = page.getPageLine(i);
				if (pageLine.textSize > newSize) newSize = pageLine.textSize;
			};
			for (i in toLine ... page.length) {
				pageLine = page.getPageLine(i);
				if (pageLine.textSize > newSize) newSize = pageLine.textSize;
			};
			page.textWidth = newSize;
		};
	}
	public function pageGetChars(page:PageT, fromLine:Int = 0, ?toLine:Null<Int>, fromChar:Int = 0, ?toChar:Null<Int>):String {
		if (toLine == null) toLine = page.length;
		var chars:String = "";
		if (fromLine == toLine - 1) {
			chars = pageLineGetChars(page.getPageLine(fromLine), fromChar, toChar);
		} else {
			chars += pageLineGetChars(page.getPageLine(fromLine), fromChar) + "\n";
			for (i in fromLine + 1 ... toLine - 1) {
				var pageLine = page.getPageLine(i);
				chars += pageLineGetChars(pageLine) + "\n";
			};
			chars += pageLineGetChars(page.getPageLine(toLine - 1), 0, toChar);
		};
		return chars;
	}
	public inline function pageCutChars(page:PageT, fromLine:Int = 0, ?toLine:Null<Int>, fromChar:Int = 0, ?toChar:Null<Int>, addRemoveGlyphes:Bool = true):String {
		var chars:String = pageGetChars(page, fromLine, toLine, fromChar, toChar);
		pageDeleteChars(page, fromLine, toLine, fromChar, toChar, addRemoveGlyphes);
		return chars;
	}
	public function pageAddLinefeedAt(page:PageT, ?pageLine:PageLineT, lineNumber:Int, position:Int = 0, ?glyphStyle:peote.ui.style.FontStyleTiled, ?defaultFontRange:Null<Int>, addRemoveGlyphes:Bool = true) {
		if (pageLine == null) pageLine = page.getPageLine(lineNumber);
		if (position == 0) pageNewLinefeed(page, lineNumber, false, glyphStyle, defaultFontRange) else if (position == pageLine.length) pageNewLinefeed(page, lineNumber, glyphStyle, defaultFontRange) else {
			pageInsertChars(page, "\n", lineNumber, position, glyphStyle, defaultFontRange, addRemoveGlyphes);
		};
	}
	public inline function pageNewLinefeed(page:PageT, ?pageLine:PageLineT, lineNumber:Int, afterLine:Bool = true, ?glyphStyle:peote.ui.style.FontStyleTiled, ?defaultFontRange:Null<Int>, addRemoveGlyphes:Bool = true) {
		if (pageLine == null) pageLine = page.getPageLine(lineNumber);
		if (afterLine) pageInsertChars(page, "\n", lineNumber, pageLine.length, glyphStyle, defaultFontRange, addRemoveGlyphes) else pageInsertChars(page, "\n", lineNumber, 0, glyphStyle, defaultFontRange, addRemoveGlyphes);
	}
	public function pageRemoveLinefeed(page:PageT, ?pageLine:PageLineT, lineNumber:Int, addRemoveGlyphes:Bool = true) {
		if (lineNumber >= page.length - 1) return;
		if (pageLine == null) pageLine = page.getPageLine(lineNumber);
		var nextLine = page.getPageLine(lineNumber + 1);
		if (pageLine.length == 0) {
			_pageDeleteLine(page, pageLine, pageLine.y, lineNumber, addRemoveGlyphes);
		} else if (nextLine.length == 0) {
			_pageDeleteLine(page, pageLine, nextLine.y, lineNumber + 1, addRemoveGlyphes);
		} else {
			var glyph = pageLine.getGlyph(pageLine.length - 1);
			var nextGlyph = nextLine.getGlyph(0);
			var nextCharData = getCharData(nextGlyph.char);
			var xOff = rightGlyphPos(glyph, getCharData(glyph.char)) - page.x - page.xOffset;
			var kerningOff = kerningSpaceOffset(glyph, nextGlyph, nextCharData);
			var nextLineY = nextLine.y;
			if (addRemoveGlyphes) {
				if (pageLineIsVisible(page, lineNumber) && !pageLineIsVisible(page, lineNumber + 1)) pageLineAdd(nextLine) else if (!pageLineIsVisible(page, lineNumber) && pageLineIsVisible(page, lineNumber + 1)) pageLineRemove(nextLine);
			};
			pageLineSetPosition(nextLine, page.x, page.width, page.xOffset, page.x, pageLine.y + _baseLineOffset(pageLine.base, nextGlyph, nextCharData), page.xOffset + xOff + kerningOff, addRemoveGlyphes && pageLineIsVisible(page, lineNumber));
			if (nextLine.visibleFrom < nextLine.visibleTo) {
				if (nextLine.visibleFrom > 0) pageLine.visibleFrom = pageLine.length + nextLine.visibleFrom;
				pageLine.visibleTo = pageLine.length + nextLine.visibleTo;
			};
			pageLine.textSize += nextLine.textSize + kerningOff;
			pageTextWidthAfterExpand(page, pageLine.textSize);
			if (pageLine.length < pageLine.updateFrom) pageLine.updateFrom = pageLine.length;
			for (glyph in nextLine.glyphes) pageLine.pushGlyph(glyph);
			pageLine.updateTo = pageLine.length;
			if (lineNumber < page.updateLineFrom) page.updateLineFrom = lineNumber;
			_pageDeleteLine(page, nextLine, nextLineY, lineNumber + 1, addRemoveGlyphes);
		};
	}
	public function pageDeleteChar(page:PageT, ?pageLine:PageLineT, lineNumber:Int, position:Int, addRemoveGlyphes:Bool = true) {
		if (pageLine == null) pageLine = page.getPageLine(lineNumber);
		if (position < pageLine.length) {
			var oldTextSize = pageLine.textSize;
			pageLineDeleteChar(pageLine, page.x, page.width, page.xOffset, position, addRemoveGlyphes && pageLineIsVisible(page, lineNumber));
			if (lineNumber < page.updateLineFrom) page.updateLineFrom = lineNumber;
			if (lineNumber >= page.updateLineTo) page.updateLineTo = lineNumber + 1;
			pageTextWidthAfterChange(page, oldTextSize, pageLine.textSize);
		} else pageRemoveLinefeed(page, pageLine, lineNumber, addRemoveGlyphes);
	}
	public function pageDeleteChars(page:PageT, fromLine:Int, toLine:Int, fromChar:Int, toChar:Int, addRemoveGlyphes:Bool = true) {
		if (fromLine == toLine - 1) {
			var pageLine = page.getPageLine(fromLine);
			var oldTextSize = pageLine.textSize;
			pageLineDeleteChars(pageLine, page.x, page.width, page.xOffset, fromChar, toChar, addRemoveGlyphes && pageLineIsVisible(page, fromLine));
			if (fromLine < page.updateLineFrom) page.updateLineFrom = fromLine;
			if (toLine > page.updateLineTo) page.updateLineTo = toLine;
			pageTextWidthAfterChange(page, oldTextSize, pageLine.textSize);
		} else if (fromChar == 0 && toChar == 0) {
			pageDeleteLines(page, fromLine, toLine - 1, addRemoveGlyphes);
		} else if (fromChar == 0) {
			var nextLineY = page.getPageLine(fromLine).y;
			var nextLine = page.getPageLine(toLine - 1);
			var oldTextSize = nextLine.textSize;
			pageLineDeleteChars(nextLine, page.x, page.width, page.xOffset, 0, toChar, addRemoveGlyphes && pageLineIsVisible(page, toLine - 1));
			var newTextSize = nextLine.textSize;
			if (fromLine < page.updateLineFrom) page.updateLineFrom = fromLine;
			for (i in fromLine ... toLine - 1) {
				var _pageLine = page.getPageLine(i);
				if (_pageLine.textSize > oldTextSize) oldTextSize = _pageLine.textSize;
				if (addRemoveGlyphes && pageLineIsVisible(page, i)) pageLineRemove(_pageLine);
			};
			pageTextWidthAfterChangeMultiple(page, fromLine, toLine, oldTextSize, newTextSize);
			_pageDeleteLines(page, nextLineY, fromLine, toLine - 1, addRemoveGlyphes);
		} else {
			var pageLine = page.getPageLine(fromLine);
			var oldTextSize = pageLine.textSize;
			var nextLineY = page.getPageLine(fromLine + 1).y;
			pageLineDeleteChars(pageLine, page.x, page.width, page.xOffset, fromChar, addRemoveGlyphes && pageLineIsVisible(page, fromLine));
			var nextLine = page.getPageLine(toLine - 1);
			if (fromLine < page.updateLineFrom) page.updateLineFrom = fromLine;
			if (toChar >= nextLine.length) {
				var newTextSize = pageLine.textSize;
				for (i in fromLine + 1 ... toLine) {
					var _pageLine = page.getPageLine(i);
					if (_pageLine.textSize > oldTextSize) oldTextSize = _pageLine.textSize;
					if (addRemoveGlyphes && pageLineIsVisible(page, i)) pageLineRemove(_pageLine);
				};
				pageTextWidthAfterChangeMultiple(page, fromLine, toLine, oldTextSize, newTextSize);
				_pageDeleteLines(page, nextLineY, fromLine + 1, toLine, addRemoveGlyphes);
			} else {
				if (nextLine.textSize > oldTextSize) oldTextSize = nextLine.textSize;
				pageLineDeleteChars(nextLine, page.x, page.width, page.xOffset, 0, toChar, addRemoveGlyphes && pageLineIsVisible(page, toLine - 1));
				var glyph = pageLine.getGlyph(pageLine.length - 1);
				var nextGlyph = nextLine.getGlyph(0);
				var nextCharData = getCharData(nextGlyph.char);
				var xOff = rightGlyphPos(glyph, getCharData(glyph.char)) - page.x - page.xOffset;
				var kerningOff = kerningSpaceOffset(glyph, nextGlyph, nextCharData);
				if (addRemoveGlyphes) {
					if (pageLineIsVisible(page, fromLine) && !pageLineIsVisible(page, toLine - 1)) pageLineAdd(nextLine) else if (!pageLineIsVisible(page, fromLine) && pageLineIsVisible(page, toLine - 1)) pageLineRemove(nextLine);
				};
				pageLineSetPosition(nextLine, page.x, page.width, page.xOffset, page.x, pageLine.y + _baseLineOffset(pageLine.base, nextGlyph, nextCharData), page.xOffset + xOff + kerningOff, addRemoveGlyphes && pageLineIsVisible(page, fromLine));
				if (nextLine.visibleFrom < nextLine.visibleTo) {
					if (nextLine.visibleFrom > 0) pageLine.visibleFrom = pageLine.length + nextLine.visibleFrom;
					pageLine.visibleTo = pageLine.length + nextLine.visibleTo;
				};
				pageLine.textSize += nextLine.textSize + kerningOff;
				var newTextSize = pageLine.textSize;
				if (pageLine.length < pageLine.updateFrom) pageLine.updateFrom = pageLine.length;
				for (glyph in nextLine.glyphes) pageLine.pushGlyph(glyph);
				pageLine.updateTo = pageLine.length;
				for (i in fromLine + 1 ... toLine - 1) {
					var _pageLine = page.getPageLine(i);
					if (_pageLine.textSize > oldTextSize) oldTextSize = _pageLine.textSize;
					if (addRemoveGlyphes && pageLineIsVisible(page, i)) pageLineRemove(_pageLine);
				};
				pageTextWidthAfterChangeMultiple(page, fromLine, toLine, oldTextSize, newTextSize);
				_pageDeleteLines(page, nextLineY, fromLine + 1, toLine, addRemoveGlyphes);
			};
		};
	}
	public function pageDeleteLine(page:PageT, lineNumber:Int, addRemoveGlyphes:Bool = true) {
		var pageLine = page.getPageLine(lineNumber);
		_pageDeleteLine(page, pageLine, pageLine.y, lineNumber, addRemoveGlyphes);
	}
	public function pageDeleteLines(page:PageT, fromLine:Int, toLine:Int, addRemoveGlyphes:Bool = true) {
		var oldTextSize:Float = 0.0;
		for (i in fromLine ... toLine) {
			var pageLine = page.getPageLine(i);
			if (pageLine.textSize > oldTextSize) oldTextSize = pageLine.textSize;
			if (addRemoveGlyphes && pageLineIsVisible(page, i)) pageLineRemove(pageLine);
		};
		pageTextWidthAfterChangeMultiple(page, fromLine, toLine, oldTextSize, 0.0);
		_pageDeleteLines(page, page.getPageLine(fromLine).y, fromLine, toLine, addRemoveGlyphes);
	}
	inline function _pageDeleteLine(page:PageT, pageLine:PageLineT, pageLineY:Float, lineNumber:Int, addRemoveGlyphes:Bool = true) {
		page.spliceLines(lineNumber, 1);
		pageTextWidthAfterChange(page, pageLine.textSize, 0.0);
		if (page.visibleLineFrom > lineNumber) page.visibleLineFrom--;
		if (page.visibleLineTo > lineNumber) page.visibleLineTo--;
		_pageMoveLinesUp(page, lineNumber, pageLineY, addRemoveGlyphes);
		if (lineNumber < page.updateLineFrom) page.updateLineFrom = lineNumber;
		page.updateLineTo = page.length;
	}
	inline function _pageDeleteLines(page:PageT, pageLineY:Float, fromLine:Int, toLine:Int, addRemoveGlyphes:Bool = true) {
		var n = toLine - fromLine;
		page.spliceLines(fromLine, n);
		if (page.visibleLineFrom > fromLine) {
			if (page.visibleLineFrom < toLine) page.visibleLineFrom = fromLine else page.visibleLineFrom -= n;
		};
		if (page.visibleLineTo > fromLine) {
			if (page.visibleLineTo < toLine) page.visibleLineTo = fromLine else page.visibleLineTo -= n;
		};
		_pageMoveLinesUp(page, fromLine, pageLineY, addRemoveGlyphes);
		if (fromLine < page.updateLineFrom) page.updateLineFrom = fromLine;
		page.updateLineTo = page.length;
	}
	inline function _pageMoveLinesUp(page:PageT, fromLine:Int, pageLineY:Float, addRemoveGlyphes:Bool = true) {
		if (fromLine < page.length) {
			var yOffset = pageLineY - page.getPageLine(fromLine).y;
			var visibleLineFrom = page.visibleLineFrom;
			var visibleLineTo = page.visibleLineTo;
			for (i in fromLine ... page.length) {
				var pageLine = page.getPageLine(i);
				pageLineSetYPosition(pageLine, page.x, page.width, page.xOffset, pageLine.y + yOffset, null, addRemoveGlyphes && pageLineIsVisible(page, i));
				if (pageLine.y + pageLine.lineHeight >= page.y) {
					if (pageLine.y < page.y + page.height) {
						if (i < page.visibleLineFrom || i >= page.visibleLineTo) {
							if (addRemoveGlyphes) pageLineAdd(pageLine);
							if (visibleLineFrom > i) visibleLineFrom = i;
							if (visibleLineTo < i + 1) visibleLineTo = i + 1;
						};
					} else {
						if (addRemoveGlyphes && pageLineIsVisible(page, i)) pageLineRemove(pageLine);
						if (visibleLineTo > i) visibleLineTo = i;
					};
				} else {
					if (addRemoveGlyphes && pageLineIsVisible(page, i)) pageLineRemove(pageLine);
					visibleLineFrom = i + 1;
				};
			};
			page.visibleLineFrom = visibleLineFrom;
			page.visibleLineTo = visibleLineTo;
			page.textHeight += yOffset;
		} else {
			page.textHeight = pageLineY - page.y - page.yOffset;
		};
	}
	public function pageWrapLine(page:PageT, lineNumber:Int, wordwrap:Bool = false, updatePageTextWidth:Bool = true, ?glyphStyle:peote.ui.style.FontStyleTiled, ?defaultFontRange:Null<Int>, addRemoveGlyphes:Bool = true):Int {
		if (lineNumber >= page.length) return 0;
		trace("pageWrapLine ", lineNumber);
		var pageLine = page.getPageLine(lineNumber);
		var position:Int;
		var glyph:GlyphT;
		var repeat = true;
		var oldSize:Float = pageLine.textSize;
		var newSize:Float = 0.0;
		var i:Int = 0;
		while (repeat && pageLine.textSize > page.width) {
			position = pageLine.visibleTo - 1;
			glyph = pageLine.getGlyph(position);
			if (wordwrap) {
				while (position > 0 && glyph.char != 32 && glyph.char != 9) {
					position--;
					glyph = pageLine.getGlyph(position);
				};
				if (position == 0) {
					position = pageLine.visibleTo - 1;
					glyph = pageLine.getGlyph(position);
				};
			};
			if (glyph.char == 32 || glyph.char == 9 || rightGlyphPos(glyph, getCharData(glyph.char)) <= page.x + page.width) {
				position++;
				glyph = pageLine.getGlyph(position);
				while (position < pageLine.length && (glyph.char == 32 || glyph.char == 9)) {
					position++;
					glyph = pageLine.getGlyph(position);
				};
			};
			if (position > 0 && position < pageLine.length) {
				pageInsertChars(page, "\n", lineNumber, position, glyphStyle, defaultFontRange, addRemoveGlyphes);
				if (pageLine.textSize > newSize) newSize = pageLine.textSize;
				pageLine = page.getPageLine(++lineNumber);
				i++;
			} else repeat = false;
		};
		if (updatePageTextWidth && newSize > 0.0) pageTextWidthAfterChange(page, oldSize, newSize);
		return i;
	}
	public function pageSetPosition(page:PageT, x:Float, y:Float, ?xOffset:Null<Float>, ?yOffset:Null<Float>, addRemoveGlyphes:Bool = true) {
		page.updateLineFrom = 0;
		page.updateLineTo = page.length;
		if (yOffset != null) _setPagePosSizeOffset(page, _SET_POS, x, y, xOffset, yOffset, addRemoveGlyphes) else for (i in 0 ... page.length) {
			var pageLine = page.getPageLine(i);
			pageLineSetPosition(pageLine, page.x, page.width, page.xOffset, x, pageLine.y + y - page.y, xOffset, addRemoveGlyphes && pageLineIsVisible(page, i));
		};
		page.x = x;
		page.y = y;
		if (xOffset != null) page.xOffset = xOffset;
		if (yOffset != null) page.yOffset = yOffset;
	}
	public function pageSetXPosition(page:PageT, x:Float, ?xOffset:Null<Float>, ?yOffset:Null<Float>, addRemoveGlyphes:Bool = true) {
		page.updateLineFrom = 0;
		page.updateLineTo = page.length;
		if (yOffset != null) _setPagePosSizeOffset(page, _SET_POS, x, page.y, xOffset, yOffset, addRemoveGlyphes) else for (i in 0 ... page.length) {
			var pageLine = page.getPageLine(i);
			pageLineSetXPosition(pageLine, page.x, page.width, page.xOffset, x, xOffset, addRemoveGlyphes && pageLineIsVisible(page, i));
		};
		page.x = x;
		if (xOffset != null) page.xOffset = xOffset;
		if (yOffset != null) page.yOffset = yOffset;
	}
	public function pageSetYPosition(page:PageT, y:Float, ?xOffset:Null<Float>, ?yOffset:Null<Float>, addRemoveGlyphes:Bool = true) {
		page.updateLineFrom = 0;
		page.updateLineTo = page.length;
		if (yOffset != null) _setPagePosSizeOffset(page, _SET_POS, null, y, xOffset, yOffset, addRemoveGlyphes) else for (i in 0 ... page.length) {
			var pageLine = page.getPageLine(i);
			pageLineSetYPosition(pageLine, page.x, page.width, page.xOffset, pageLine.y + y - page.y, xOffset, addRemoveGlyphes && pageLineIsVisible(page, i));
		};
		page.y = y;
		if (xOffset != null) page.xOffset = xOffset;
		if (yOffset != null) page.yOffset = yOffset;
	}
	public function pageSetPositionSize(page:PageT, x:Float, y:Float, width:Float, height:Float, ?xOffset:Null<Float>, ?yOffset:Null<Float>, addRemoveGlyphes:Bool = true) {
		page.updateLineFrom = 0;
		page.updateLineTo = page.length;
		page.height = height;
		if (page.width != width) {
			page.width = width;
			_setPagePosSizeOffset(page, _SET_POS_SIZE, x, y, xOffset, (yOffset != null) ? yOffset : 0, addRemoveGlyphes);
		} else _setPagePosSizeOffset(page, _SET_POS, x, y, xOffset, (yOffset != null) ? yOffset : 0, addRemoveGlyphes);
		page.x = x;
		page.y = y;
		if (xOffset != null) page.xOffset = xOffset;
		if (yOffset != null) page.yOffset = yOffset;
	}
	public function pageSetSize(page:PageT, width:Float, height:Float, ?xOffset:Null<Float>, ?yOffset:Null<Float>, addRemoveGlyphes:Bool = true) {
		page.updateLineFrom = 0;
		page.updateLineTo = page.length;
		page.height = height;
		if (page.width != width) {
			page.width = width;
			if (yOffset != null) _setPagePosSizeOffset(page, _SET_POS_SIZE, page.x, page.y, xOffset, yOffset, addRemoveGlyphes) else _setPagePosSizeOffset(page, _SET_SIZE, null, page.y, xOffset, 0, addRemoveGlyphes);
		} else _setPagePosSizeOffset(page, _SET_POS, null, page.y, xOffset, (yOffset != null) ? yOffset : 0, addRemoveGlyphes);
		if (xOffset != null) page.xOffset = xOffset;
		if (yOffset != null) page.yOffset = yOffset;
	}
	public function pageSetOffset(page:PageT, ?xOffset:Null<Float>, ?yOffset:Null<Float>, addRemoveGlyphes:Bool = true) {
		page.updateLineFrom = 0;
		page.updateLineTo = page.length;
		if (yOffset != null) _setPagePosSizeOffset(page, _SET_POS, null, page.y, xOffset, yOffset, addRemoveGlyphes) else if (xOffset != null) {
			for (i in 0 ... page.length) {
				var pageLine = page.getPageLine(i);
				pageLineSetOffset(pageLine, page.x, page.width, page.xOffset, xOffset, addRemoveGlyphes && pageLineIsVisible(page, i));
			};
		};
		if (xOffset != null) page.xOffset = xOffset;
		if (yOffset != null) page.yOffset = yOffset;
	}
	public function pageSetXOffset(page:PageT, xOffset:Float, addRemoveGlyphes:Bool = true) {
		page.updateLineFrom = 0;
		page.updateLineTo = page.length;
		for (i in 0 ... page.length) {
			var pageLine = page.getPageLine(i);
			pageLineSetOffset(pageLine, page.x, page.width, page.xOffset, xOffset, addRemoveGlyphes && pageLineIsVisible(page, i));
		};
		page.xOffset = xOffset;
	}
	public function pageSetYOffset(page:PageT, yOffset:Float, addRemoveGlyphes:Bool = true) {
		page.updateLineFrom = 0;
		page.updateLineTo = page.length;
		_setPagePosSizeOffset(page, _SET_POS, null, page.y, null, yOffset, addRemoveGlyphes);
		page.yOffset = yOffset;
	}
	static inline var _SET_POS = 0;
	static inline var _SET_POS_SIZE = 1;
	static inline var _SET_SIZE = 2;
	inline function _setPagePosSizeOffset(page:PageT, howToSet:Int, x:Null<Float>, y:Float, ?xOffset:Null<Float>, yOffset:Float, addRemoveGlyphes:Bool) {
		var visibleLineFrom = page.visibleLineFrom;
		var visibleLineTo = page.visibleLineTo;
		yOffset += y - page.y - page.yOffset;
		for (i in 0 ... page.length) {
			var pageLine = page.getPageLine(i);
			if (howToSet == _SET_POS_SIZE) pageLineSetPositionSize(pageLine, page.x, page.width, page.xOffset, x, yOffset + pageLine.y, xOffset, addRemoveGlyphes && pageLineIsVisible(page, i)) else if (howToSet == _SET_SIZE) pageLineSetSize(pageLine, page.x, page.width, page.xOffset, xOffset, addRemoveGlyphes && pageLineIsVisible(page, i)) else if (howToSet == _SET_POS) {
				if (x != null) pageLineSetPosition(pageLine, page.x, page.width, page.xOffset, x, yOffset + pageLine.y, xOffset, addRemoveGlyphes && pageLineIsVisible(page, i)) else pageLineSetYPosition(pageLine, page.x, page.width, page.xOffset, yOffset + pageLine.y, xOffset, addRemoveGlyphes && pageLineIsVisible(page, i));
			};
			if (pageLine.y + pageLine.lineHeight >= y) {
				if (pageLine.y < y + page.height) {
					if (i < page.visibleLineFrom || i >= page.visibleLineTo) {
						if (addRemoveGlyphes) pageLineAdd(pageLine);
						if (visibleLineFrom > i) visibleLineFrom = i;
						if (visibleLineTo < i + 1) visibleLineTo = i + 1;
					};
				} else {
					if (addRemoveGlyphes && pageLineIsVisible(page, i)) pageLineRemove(pageLine);
					if (visibleLineTo > i) visibleLineTo = i;
				};
			} else {
				if (addRemoveGlyphes && pageLineIsVisible(page, i)) pageLineRemove(pageLine);
				visibleLineFrom = i + 1;
			};
		};
		page.visibleLineFrom = visibleLineFrom;
		page.visibleLineTo = visibleLineTo;
	}
	public function pageUpdate(page:PageT, fromLine:Null<Int> = null, toLine:Null<Int> = null) {
		if (fromLine != null) page.updateLineFrom = fromLine;
		if (toLine != null) page.updateLineTo = toLine;
		if (page.updateLineTo > 0) {
			if (page.visibleLineFrom > page.updateLineFrom) page.updateLineFrom = page.visibleLineFrom;
			if (page.visibleLineTo < page.updateLineTo) page.updateLineTo = page.visibleLineTo;
			for (i in page.updateLineFrom ... page.updateLineTo) pageLineUpdate(page.getPageLine(i));
			page.updateLineFrom = 0x1000000;
			page.updateLineTo = 0;
		};
	}
	public inline function pageGetPositionAtChar(page:PageT, pageLine:PageLineT, position:Int):Float {
		return pageLineGetPositionAtChar(pageLine, page.x, page.xOffset, position);
	}
	public inline function pageGetCharAtPosition(page:PageT, pageLine:PageLineT, xPosition:Float, intoVisibleRange:Bool = true):Int {
		return pageLineGetCharAtPosition(pageLine, page.x, page.width, page.xOffset, xPosition, intoVisibleRange);
	}
	public inline function pageGetPositionAtLine(page:PageT, lineNumber:Int):Float {
		return page.getPageLine(lineNumber).y;
	}
	public function pageGetLineAtPosition(page:PageT, yPosition:Float, intoVisibleRange:Bool = true):Int {
		if (yPosition <= page.y + ((intoVisibleRange) ? 0 : page.yOffset)) return (intoVisibleRange) ? page.visibleLineFrom : 0 else if (yPosition >= page.y + ((intoVisibleRange) ? page.height : page.yOffset + page.textHeight)) return (intoVisibleRange) ? page.visibleLineTo : page.length else {
			{
				if (page.length == 0 || yPosition <= page.getPageLine(0).y) return 0 else {
					var from:Int = (intoVisibleRange) ? page.visibleLineFrom : 0;
					var to:Int = (intoVisibleRange) ? page.visibleLineTo : page.length;
					while (from + 1 < to) if (yPosition > page.getPageLine(from + ((to - from) >> 1)).y) from = from + ((to - from) >> 1) else to = from + ((to - from) >> 1);
					return from;
				};
			};
		};
	}
}