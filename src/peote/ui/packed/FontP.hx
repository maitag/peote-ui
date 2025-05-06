package peote.ui.packed;
@:access(peote.text.FontConfig)
class FontP {
	var path : String;
	var jsonFilename : String;
	public var config : peote.text.FontConfig;
	var rangeMapping : peote.text.Gl3FontData;
	public var textureCache : peote.view.Texture;
	var maxTextureSize : Int;
	var ranges : Array<peote.text.Range>;
	var rangeSize = 0x1000;
	public var kerning = false;
	var rParsePathConfig = new EReg("^(.*?)([^/]+)$", "");
	var rParseEnding = new EReg("\\.[a-z]+$", "i");
	var rComments = new EReg("//.*?$", "gm");
	var rHexToDec = new EReg("(\"\\s*)?(0x[0-9a-f]+)(\\s*\")?", "gi");
	public function new(configJsonPath:String, ranges:Array<peote.text.Range> = null, kerning:Bool = true, maxTextureSize:Int = 16384) {
		if (rParsePathConfig.match(configJsonPath)) {
			path = rParsePathConfig.matched(1);
			jsonFilename = rParsePathConfig.matched(2);
		} else throw ("Can\'t load font, error in path to jsonfile: " + '\"' + configJsonPath + '\"');
		this.ranges = ranges;
		this.kerning = kerning;
		this.maxTextureSize = maxTextureSize;
	}
	@:keep
	public function createFontProgram(fontStyle:peote.ui.style.FontStylePacked, isMasked:Bool = false, bufferMinSize:Int = 1024, bufferGrowSize:Int = 1024, bufferAutoShrink:Bool = true):FontProgramP {
		return new FontProgramP(this, fontStyle, isMasked, bufferMinSize, bufferGrowSize, bufferAutoShrink);
	}
	@:keep
	public function createFontStyle():peote.ui.style.FontStylePacked return new peote.ui.style.FontStylePacked();
	public function createGlyph():GlyphP return new GlyphP();
	public function createLine():LineP return new LineP();
	@:keep
	public function createUITextLine(xPosition:Int, yPosition:Int, width:Int, height:Int, zIndex:Int = 0, text:String, ?fontStyle:peote.ui.style.FontStylePacked, ?config:peote.ui.config.TextConfig):peote.ui.interactive.UITextLineP {
		return new peote.ui.interactive.UITextLineP(xPosition, yPosition, width, height, zIndex, text, this, fontStyle, config);
	}
	@:keep
	public function createUITextPage(xPosition:Int, yPosition:Int, width:Int, height:Int, zIndex:Int = 0, text:String, ?fontStyle:peote.ui.style.FontStylePacked, ?config:peote.ui.config.TextConfig):peote.ui.interactive.UITextPageP {
		return new peote.ui.interactive.UITextPageP(xPosition, yPosition, width, height, zIndex, text, this, fontStyle, config);
	}
	public inline function getRange(charcode:Int):peote.text.Gl3FontData {
		return rangeMapping;
	}
	public function load(onLoad:FontP -> Void, ?onProgressOverall:(Int, Int) -> Void, debug:Bool = false) {
		utils.Loader.text(path + jsonFilename, debug, function(jsonString:String) {
			jsonString = rComments.replace(jsonString, "");
			jsonString = rHexToDec.map(jsonString, function(r) return Std.string(Std.parseInt(r.matched(2))));
			var parser = new json2object.JsonParser<peote.text.FontConfig>();
			config = parser.fromJson(jsonString, path + jsonFilename);
			for (e in parser.errors) {
				var pos = switch (e) {
					case IncorrectType(_, _, pos) | IncorrectEnumValue(_, _, pos) | InvalidEnumConstructor(_, _, pos) | UninitializedVariable(_, pos) | UnknownVariable(_, pos) | ParserError(_, pos) | CustomFunctionException(_, pos):{
						pos;
					};
				};
				trace(pos.lines[0].number);
				if (pos != null) haxe.Log.trace(json2object.ErrorUtils.convertError(e), { fileName : pos.file, lineNumber : pos.lines[0].number, className : "", methodName : "" });
			};
			rangeSize = config.rangeSplitSize;
			if (config.line != null) { };
			{
				if (!config.packed) {
					var error = 'Error, for ' + "FontStylePacked" + ' \"@packed\" in \"' + path + jsonFilename + '\" set \"packed\":true';
					haxe.Log.trace(error, { fileName : path + jsonFilename, lineNumber : 0, className : "", methodName : "" });
					throw (error);
				};
			};
			if (kerning && config.kerning != null) kerning = config.kerning;
			{
				if (ranges == null && config.ranges.length > 1) {
					var error = 'Error, set ' + "FontStylePacked" + ' to @multiSlot and/or @multiTexture or define a single range while Font creation or inside \"' + path + jsonFilename + '\"';
					haxe.Log.trace(error, { fileName : path + jsonFilename, lineNumber : 0, className : "", methodName : "" });
					throw (error);
				};
			};
			var found_ranges = new Array<{ var image : String; var data : String; var slot : { var width : Int; var height : Int; }; var tiles : { var x : Int; var y : Int; }; var line : { var height : Float; var base : Float; }; var range : peote.text.Range; }>();
			for (item in config.ranges) {
				var min = item.range.min;
				var max = item.range.max;
				if (ranges != null) {
					for (r in ranges) {
						if ((r.min >= min && r.min <= max) || (r.max >= min && r.max <= max)) {
							found_ranges.push(item);
							break;
						};
					};
				} else found_ranges.push(item);
				if (found_ranges.length == 1) break;
			};
			if (found_ranges.length == 0) {
				var error = 'Error, can not found any ranges inside font-config \"' + path + jsonFilename + '\" that fit ' + ranges;
				haxe.Log.trace(error, { fileName : path + jsonFilename, lineNumber : 0, className : "", methodName : "" });
				throw (error);
			} else config.ranges = found_ranges;
			init(onLoad, onProgressOverall, debug);
		});
	}
	private function init(onLoad:FontP -> Void, onProgressOverall:(Int, Int) -> Void, debug:Bool) {
		{ };
		{
			var w:Int = 0;
			var h:Int = 0;
			for (item in config.ranges) {
				if (item.slot.width > w) w = item.slot.width;
				if (item.slot.height > h) h = item.slot.height;
			};
			textureCache = new peote.view.Texture(w, h, config.ranges.length, { format : peote.view.TextureFormat.RGBA, maxTextureSize : maxTextureSize, smoothShrink : true, smoothExpand : true });
		};
		loadFontData(onLoad, onProgressOverall, debug);
	}
	private function loadFontData(onLoad:FontP -> Void, onProgressOverall:(Int, Int) -> Void, debug:Bool):Void {
		var gl3FontData = new Array<peote.text.Gl3FontData>();
		utils.Loader.bytesArray(config.ranges.map(function(v) {
			if (v.data != null) return path + v.data else return path + rParseEnding.replace(v.image, ".dat");
		}), debug, function(index:Int, bytes:lime.utils.Bytes) {
			gl3FontData[index] = new peote.text.Gl3FontData(bytes, config.ranges[index].range.min, config.ranges[index].range.max, kerning);
		}, function(bytes:Array<lime.utils.Bytes>) {
			loadImages(gl3FontData, onLoad, onProgressOverall, debug);
		});
	}
	public function embed() { }
	@:access(peote.text.Range)
	private function loadImages(?gl3FontData:Array<peote.text.Gl3FontData>, onLoad:FontP -> Void, onProgressOverall:(Int, Int) -> Void, debug:Bool):Void {
		utils.Loader.imageArray(config.ranges.map(function(v) return path + v.image), debug, function(index:Int, loaded:Int, size:Int) {
			if (onProgressOverall != null) onProgressOverall(loaded, size);
		}, function(index:Int, image:lime.graphics.Image) {
			{
				var gl3font = gl3FontData[index];
				for (charcode in gl3font.rangeMin ... gl3font.rangeMax + 1) {
					var m = gl3font.getMetric(charcode);
					if (m != null) {
						m.u *= image.width;
						m.v *= image.height;
						m.w *= image.width;
						m.h *= image.height;
						gl3font.setMetric(charcode, m);
					};
				};
				var range = config.ranges[index].range;
				{
					textureCache.setData(image);
					rangeMapping = gl3font;
				};
				range.min = gl3font.firstCharCode;
			};
		}, function(images:Array<lime.graphics.Image>) {
			onLoad(this);
		});
	}
}