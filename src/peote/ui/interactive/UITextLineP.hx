package peote.ui.interactive;
class UITextLineP extends peote.ui.interactive.Interactive implements peote.ui.interactive.interfaces.ActionTextLine implements peote.ui.interactive.interfaces.InputFocus implements peote.ui.interactive.interfaces.InputText {
	var line : peote.ui.packed.LineP = null;
	var undoBuffer : peote.ui.util.UndoBufferLine = null;
	public var hasUndo(get, never) : Bool;
	inline function get_hasUndo():Bool return (undoBuffer != null);
	public var textWidth(get, never) : Float;
	inline function get_textWidth():Float return line.textSize;
	var fontProgram : peote.ui.packed.FontProgramP;
	var font : peote.ui.packed.FontP;
	public var fontStyle : peote.ui.style.FontStylePacked;
	public var backgroundSpace : peote.ui.config.Space = null;
	var backgroundProgram : peote.ui.style.interfaces.StyleProgram = null;
	var backgroundElement : peote.ui.style.interfaces.StyleElement = null;
	public var backgroundStyle(default, set) : Dynamic = null;
	inline function set_backgroundStyle(style:peote.ui.style.interfaces.Style):peote.ui.style.interfaces.Style {
		if (backgroundElement == null) {
			backgroundStyle = style;
			if (style != null && line != null) createBackgroundStyle(isVisible && backgroundIsVisible);
		} else {
			if (style != null) {
				if (style.getUUID() != backgroundStyle.getUUID()) {
					if (isVisible && backgroundIsVisible) backgroundProgram.removeElement(backgroundElement);
					backgroundProgram = null;
					backgroundStyle = style;
					createBackgroundStyle(isVisible && backgroundIsVisible);
				} else {
					backgroundStyle = style;
					backgroundElement.setStyle(style);
					if (isVisible && backgroundIsVisible) backgroundProgram.update(backgroundElement);
				};
			} else {
				if (isVisible && backgroundIsVisible) backgroundProgram.removeElement(backgroundElement);
				backgroundStyle = null;
				backgroundProgram = null;
				backgroundElement = null;
			};
		};
		return backgroundStyle;
	}
	public var backgroundIsVisible(default, set) : Bool = true;
	inline function set_backgroundIsVisible(b:Bool):Bool {
		if (line != null && backgroundStyle != null) {
			if (b && !backgroundIsVisible) {
				if (backgroundElement == null) createBackgroundStyle(isVisible) else if (isVisible) backgroundProgram.addElement(backgroundElement);
			} else if (!b && backgroundIsVisible && backgroundElement != null && isVisible) backgroundProgram.removeElement(backgroundElement);
		};
		return backgroundIsVisible = b;
	}
	public inline function backgroundShow():Void backgroundIsVisible = true;
	public inline function backgroundHide():Void backgroundIsVisible = false;
	var selectionProgram : peote.ui.style.interfaces.StyleProgram = null;
	var selectionElement : peote.ui.style.interfaces.StyleElement = null;
	public var selectionStyle(default, set) : Dynamic = null;
	inline function set_selectionStyle(style:peote.ui.style.interfaces.Style):peote.ui.style.interfaces.Style {
		if (selectionElement == null) {
			selectionStyle = style;
			if (style != null && line != null) createSelectionMasked(isVisible && selectionIsVisible);
		} else {
			if (style != null) {
				if (style.getUUID() != selectionStyle.getUUID()) {
					if (isVisible && selectionIsVisible) selectionProgram.removeElement(selectionElement);
					selectionProgram = null;
					selectionStyle = style;
					createSelectionMasked(isVisible && selectionIsVisible);
				} else {
					selectionStyle = style;
					selectionElement.setStyle(style);
					if (isVisible && selectionIsVisible) selectionProgram.update(selectionElement);
				};
			} else {
				if (isVisible && selectionIsVisible) selectionProgram.removeElement(selectionElement);
				selectionStyle = null;
				selectionProgram = null;
				selectionElement = null;
			};
		};
		return selectionStyle;
	}
	public var selectionIsVisible(default, set) : Bool = false;
	inline function set_selectionIsVisible(b:Bool):Bool {
		if (line != null && selectionStyle != null) {
			if (b && !selectionIsVisible) {
				if (selectionElement == null) createSelectionMasked(isVisible) else if (isVisible) selectionProgram.addElement(selectionElement);
			} else if (!b && selectionIsVisible && selectionElement != null && isVisible) selectionProgram.removeElement(selectionElement);
		};
		return selectionIsVisible = b;
	}
	public inline function selectionShow():Void selectionIsVisible = true;
	public inline function selectionHide():Void selectionIsVisible = false;
	var selectFrom : Int = 0;
	var selectTo : Int = 0;
	public function select(from:Int, to:Int):Void {
		if (from < 0) from = 0;
		if (to < 0) to = 0;
		if (from <= to) {
			selectFrom = from;
			selectTo = to;
		} else {
			selectFrom = to;
			selectTo = from;
		};
		if (selectFrom == selectTo) selectionHide() else {
			if (line != null && selectionStyle != null) {
				if (selectTo > line.length) selectTo = line.length;
				setCreateSelectionMasked((isVisible && selectionIsVisible), (selectionElement == null));
			};
			selectionShow();
		};
	}
	public inline function hasSelection():Bool return (selectFrom != selectTo);
	public inline function removeSelection() {
		selectFrom = selectTo = 0;
		selectionHide();
	}
	var cursorProgram : peote.ui.style.interfaces.StyleProgram = null;
	var cursorElement : peote.ui.style.interfaces.StyleElement = null;
	public var cursorStyle(default, set) : Dynamic = null;
	inline function set_cursorStyle(style:peote.ui.style.interfaces.Style):peote.ui.style.interfaces.Style {
		if (cursorElement == null) {
			cursorStyle = style;
			if (style != null && line != null) _createCursorMasked(isVisible && cursorIsVisible);
		} else {
			if (style != null) {
				if (style.getUUID() != cursorStyle.getUUID()) {
					if (isVisible && cursorIsVisible) cursorProgram.removeElement(cursorElement);
					cursorProgram = null;
					cursorStyle = style;
					_createCursorMasked(isVisible && cursorIsVisible);
				} else {
					cursorStyle = style;
					cursorElement.setStyle(style);
					if (isVisible && cursorIsVisible) cursorProgram.update(cursorElement);
				};
			} else {
				if (isVisible && cursorIsVisible) cursorProgram.removeElement(cursorElement);
				cursorStyle = null;
				cursorProgram = null;
				cursorElement = null;
			};
		};
		return cursorStyle;
	}
	public var cursorIsVisible(default, set) : Bool = false;
	inline function set_cursorIsVisible(b:Bool):Bool {
		if (line != null && cursorStyle != null) {
			if (b && !cursorIsVisible) {
				if (cursorElement == null) _createCursorMasked(isVisible) else if (isVisible) cursorProgram.addElement(cursorElement);
			} else if (!b && cursorIsVisible && cursorElement != null && isVisible) cursorProgram.removeElement(cursorElement);
		};
		return cursorIsVisible = b;
	}
	public inline function cursorShow():Void cursorIsVisible = true;
	public inline function cursorHide():Void cursorIsVisible = false;
	public var cursor(default, null) : Int = 0;
	public inline function setCursor(cursor:Int, update:Bool = true, changeOffset:Bool = true) {
		if (cursor < 0) this.cursor = 0 else this.cursor = cursor;
		if (line != null) {
			if (cursor > line.length) this.cursor = line.length;
			_updateCursorOrOffset(update, changeOffset);
		};
	}
	inline function _updateCursorOrOffset(update:Bool, changeOffset:Bool) {
		if (changeOffset) {
			var xOffsetChanged = xOffsetToCursor();
			if (update) {
				if (xOffsetChanged) {
					updateLineLayout(false, false, false, true, false, false, xOffsetChanged);
				} else if (cursorStyle != null) _setCreateCursorMasked((isVisible && cursorIsVisible), (cursorElement == null));
			};
		} else if (update && cursorStyle != null) {
			_setCreateCursorMasked((isVisible && cursorIsVisible), (cursorElement == null));
		};
	}
	public inline function offsetToCursor(update:Bool = true) {
		var xOffsetChanged = xOffsetToCursor();
		if (update && line != null && xOffsetChanged) {
			updateLineLayout(false, false, false, true, false, false, xOffsetChanged);
		};
	}
	@:isVar
	public var text(get, set) : String = null;
	inline function get_text():String {
		if (line == null) return text else return fontProgram.lineGetChars(line);
	}
	inline function set_text(t:String):String {
		if (line == null || t == null) return text = t else {
			setText(t);
			return t;
		};
	}
	var autoSize : Int = 0;
	public var autoWidth(get, set) : Bool;
	inline function get_autoWidth():Bool return (autoSize & 2 > 0);
	inline function set_autoWidth(b:Bool):Bool {
		if (b) autoSize |= 2 else autoSize = autoSize & 1;
		return b;
	}
	public var autoHeight(get, set) : Bool;
	inline function get_autoHeight():Bool return (autoSize & 1 > 0);
	inline function set_autoHeight(b:Bool):Bool {
		if (b) autoSize |= 1 else autoSize = autoSize & 2;
		return b;
	}
	public var hAlign = peote.ui.config.HAlign.LEFT;
	public var vAlign = peote.ui.config.VAlign.CENTER;
	public var xOffset : Float = 0;
	public var yOffset : Float = 0;
	public var leftSpace : Int = 0;
	public var rightSpace : Int = 0;
	public var topSpace : Int = 0;
	public var bottomSpace : Int = 0;
	var maskElement : peote.text.MaskElement;
	public function new(xPosition:Int, yPosition:Int, width:Int, height:Int, zIndex:Int = 0, text:String, font:peote.ui.packed.FontP, ?fontStyle:peote.ui.style.FontStylePacked, ?config:peote.ui.config.TextConfig) {
		super(xPosition, yPosition, width, height, zIndex);
		this.text = text;
		this.font = font;
		if (fontStyle == null) fontStyle = font.createFontStyle();
		this.fontStyle = fontStyle;
		{ };
		if (config != null) {
			backgroundStyle = config.backgroundStyle;
			backgroundSpace = config.backgroundSpace;
			selectionStyle = config.selectionStyle;
			cursorStyle = config.cursorStyle;
			if (config.autoWidth != null) autoWidth = config.autoWidth else if (width == 0) autoWidth = true;
			if (config.autoHeight != null) autoHeight = config.autoHeight else if (height == 0) autoHeight = true;
			if (config.hAlign != null) hAlign = config.hAlign;
			if (config.vAlign != null) vAlign = config.vAlign;
			xOffset = config.xOffset;
			yOffset = config.yOffset;
			if (config.textSpace != null) {
				leftSpace = config.textSpace.left;
				rightSpace = config.textSpace.right;
				topSpace = config.textSpace.top;
				bottomSpace = config.textSpace.bottom;
			};
			if (config.undoBufferSize > 0) undoBuffer = new peote.ui.util.UndoBufferLine(config.undoBufferSize);
		} else {
			if (width == 0) autoWidth = true;
			if (height == 0) autoHeight = true;
		};
	}
	inline function getAlignedXOffset(_xOffset:Float):Float {
		return (autoWidth) ? _xOffset : switch (hAlign) {
			case peote.ui.config.HAlign.CENTER:{
				(width - leftSpace - rightSpace - line.textSize) / 2 + _xOffset;
			};
			case peote.ui.config.HAlign.RIGHT:{
				width - leftSpace - rightSpace - line.textSize + _xOffset;
			};
			default:{
				_xOffset;
			};
		};
	}
	inline function getAlignedYOffset():Float {
		return (autoHeight) ? yOffset : switch (vAlign) {
			case peote.ui.config.VAlign.CENTER:{
				(height - topSpace - bottomSpace - line.height) / 2 + yOffset;
			};
			case peote.ui.config.VAlign.BOTTOM:{
				height - topSpace - bottomSpace - line.height + yOffset;
			};
			default:{
				yOffset;
			};
		};
	}
	inline function xOffsetToCursor():Bool {
		if (autoWidth) return false else {
			var cx = Math.round(getPositionAtChar(cursor));
			var cw = 2;
			if (cx + cw > x + width - rightSpace) {
				setXOffset(getAlignedXOffset(xOffset) - cx - cw + x + width - rightSpace, false, true);
				hAlign = peote.ui.config.HAlign.LEFT;
				return true;
			} else if (cx < x + leftSpace) {
				setXOffset(getAlignedXOffset(xOffset) - cx + x + leftSpace, false, true);
				hAlign = peote.ui.config.HAlign.LEFT;
				return true;
			} else return false;
		};
	}
	inline function createSelectionMasked(addUpdate:Bool) setCreateSelectionMasked(addUpdate, true);
	inline function setCreateSelectionMasked(addUpdate:Bool, create:Bool) {
		var _x = x + leftSpace;
		var _y = y + topSpace;
		var _width = width - leftSpace - rightSpace;
		var _height = height - topSpace - bottomSpace;
		if (masked) {
			if (maskX > leftSpace) _x = x + maskX;
			if (maskY > topSpace) _y = y + maskY;
			if (x + maskX + maskWidth < _x + _width) _width = maskX + maskWidth + x - _x;
			if (y + maskY + maskHeight < _y + _height) _height = maskY + maskHeight + y - _y;
		};
		_setCreateSelection(_x, _y, _width, _height, getAlignedYOffset() + topSpace, addUpdate, create);
	}
	inline function createSelection(x:Int, y:Int, w:Int, h:Int, y_offset:Float, addUpdate:Bool) _setCreateSelection(x, y, w, h, y_offset, addUpdate, true);
	inline function setSelection(x:Int, y:Int, w:Int, h:Int, y_offset:Float, addUpdate:Bool) _setCreateSelection(x, y, w, h, y_offset, addUpdate, false);
	inline function _setCreateSelection(_x:Int, _y:Int, _width:Int, _height:Int, y_offset:Float, addUpdate:Bool, create:Bool) {
		var selectX = Math.round(getPositionAtChar(selectFrom));
		var selectWidth = Math.round(getPositionAtChar(selectTo) - selectX);
		var selectY = Math.round(y + y_offset);
		var selectHeight = Math.round(line.height);
		var mx = 0;
		var my = 0;
		var mw = selectWidth;
		var mh = selectHeight;
		if (selectX < _x) {
			mw -= (_x - selectX);
			mx = _x - selectX;
			if (mw > _width) mw = _width;
		} else if (selectX + selectWidth > _x + _width) mw = _x + _width - selectX;
		if (mw < 0) mw = 0;
		if (selectY < _y) {
			mh -= (_y - selectY);
			my = _y - selectY;
			if (mh > _height) mh = _height;
		} else if (selectY + selectHeight > _y + _height) mh = _y + _height - selectY;
		if (mh < 0) mh = 0;
		if (create) {
			createSelectionStyle(selectX, selectY, selectWidth, selectHeight, mx, my, mw, mh, z);
			if (addUpdate) selectionProgram.addElement(selectionElement);
		} else {
			selectionElement.setMasked(this, selectX, selectY, selectWidth, selectHeight, mx, my, mw, mh, z);
			if (addUpdate) selectionProgram.update(selectionElement);
		};
	}
	inline function _createCursorMasked(addUpdate:Bool) _setCreateCursorMasked(addUpdate, true);
	inline function _setCreateCursorMasked(addUpdate:Bool, create:Bool) {
		var _x = x + leftSpace;
		var _y = y + topSpace;
		var _width = width - leftSpace - rightSpace;
		var _height = height - topSpace - bottomSpace;
		if (masked) {
			if (maskX > leftSpace) _x = x + maskX;
			if (maskY > topSpace) _y = y + maskY;
			if (x + maskX + maskWidth < _x + _width) _width = maskX + maskWidth + x - _x;
			if (y + maskY + maskHeight < _y + _height) _height = maskY + maskHeight + y - _y;
		};
		_setCreateCursor(_x, _y, _width, _height, getAlignedYOffset() + topSpace, addUpdate, create);
	}
	inline function _createCursor(x:Int, y:Int, w:Int, h:Int, y_offset:Float, addUpdate:Bool) _setCreateCursor(x, y, w, h, y_offset, addUpdate, true);
	inline function _setCursor(x:Int, y:Int, w:Int, h:Int, y_offset:Float, addUpdate:Bool) _setCreateCursor(x, y, w, h, y_offset, addUpdate, false);
	inline function _setCreateCursor(_x:Int, _y:Int, _width:Int, _height:Int, y_offset:Float, addUpdate:Bool, create:Bool) {
		_width += 3;
		var cx = Math.round(getPositionAtChar(cursor));
		var cw = 2;
		var cy = Math.round(y + y_offset);
		var ch = Math.round(line.height);
		var mx = 0;
		var my = 0;
		var mw = cw;
		var mh = ch;
		if (cx < _x) {
			mw -= (_x - cx);
			mx = _x - cx;
			if (mw > _width) mw = _width;
		} else if (cx + cw > _x + _width) mw = _x + _width - cx;
		if (mw < 0) mw = 0;
		if (cy < _y) {
			mh -= (_y - cy);
			my = _y - cy;
			if (mh > _height) mh = _height;
		} else if (cy + ch > _y + _height) mh = _y + _height - cy;
		if (mh < 0) mh = 0;
		if (create) {
			createCursorStyle(cx, cy, cw, ch, mx, my, mw, mh, z);
			if (addUpdate) cursorProgram.addElement(cursorElement);
		} else {
			cursorElement.setMasked(this, cx, cy, cw, ch, mx, my, mw, mh, z);
			if (addUpdate) cursorProgram.update(cursorElement);
		};
	}
	override inline function updateVisibleStyle() {
		if (line != null) {
			fontProgram.lineSetStyle(line, fontStyle);
			if (isVisible) fontProgram.lineUpdate(line);
			if (backgroundElement != null) {
				backgroundElement.setStyle(backgroundStyle);
				if (isVisible && backgroundIsVisible) backgroundProgram.update(backgroundElement);
			};
			if (selectionElement != null) {
				selectionElement.setStyle(selectionStyle);
				if (isVisible && selectionIsVisible) selectionProgram.update(selectionElement);
			};
			if (cursorElement != null) {
				cursorElement.setStyle(cursorStyle);
				if (isVisible && cursorIsVisible) cursorProgram.update(cursorElement);
			};
		};
	}
	override inline function updateVisibleLayout():Void {
		if (line != null) updateLineLayout(false);
	}
	override inline function updateVisible():Void {
		if (line != null) updateLineLayout(true);
	}
	inline function updateLineLayout(updateStyle:Bool, updateBgMask:Bool = true, updateSelection:Bool = true, updateCursor:Bool = true, lineUpdatePosition:Bool = true, lineUpdateSize:Bool = true, lineUpdateOffset:Bool = true):Void {
		if (updateStyle) fontProgram.lineSetStyle(line, fontStyle, isVisible);
		if (autoSize > 0) {
			if (autoWidth) width = Std.int(line.textSize) + leftSpace + rightSpace;
			if (autoHeight) height = Std.int(line.height) + topSpace + bottomSpace;
			updatePickable();
		};
		var _x = x + leftSpace;
		var _y = y + topSpace;
		var _width = width - leftSpace - rightSpace;
		var _height = height - topSpace - bottomSpace;
		var y_offset:Float = getAlignedYOffset();
		if (lineUpdatePosition && lineUpdateSize) fontProgram.lineSetPositionSize(line, _x, _y + y_offset, _width, (lineUpdateOffset) ? getAlignedXOffset(xOffset) : null, isVisible) else if (lineUpdatePosition) fontProgram.lineSetPosition(line, _x, _y + y_offset, (lineUpdateOffset) ? getAlignedXOffset(xOffset) : null, isVisible) else if (lineUpdateSize) fontProgram.lineSetSize(line, _width, (lineUpdateOffset) ? getAlignedXOffset(xOffset) : null, isVisible) else if (lineUpdateOffset) fontProgram.lineSetOffset(line, getAlignedXOffset(xOffset), isVisible);
		if (isVisible) {
			{ };
			fontProgram.lineUpdate(line);
		};
		if (updateBgMask) {
			if (masked) {
				if (maskX > leftSpace) _x = x + maskX;
				if (maskY > topSpace) _y = y + maskY;
				if (x + maskX + maskWidth < _x + _width) _width = maskX + maskWidth + x - _x;
				if (y + maskY + maskHeight < _y + _height) _height = maskY + maskHeight + y - _y;
			};
			fontProgram.setMask(maskElement, _x, _y, _width, _height, isVisible);
			if (backgroundElement != null) {
				if (updateStyle) backgroundElement.setStyle(backgroundStyle);
				backgroundElement.setLayout(this, backgroundSpace);
				if (isVisible && backgroundIsVisible) backgroundProgram.update(backgroundElement);
			};
		};
		if (updateSelection && selectionElement != null) {
			if (updateStyle) selectionElement.setStyle(selectionStyle);
			setSelection(_x, _y, _width, _height, y_offset + topSpace, (isVisible && selectionIsVisible));
		};
		if (updateCursor && cursorElement != null) {
			if (updateStyle) cursorElement.setStyle(cursorStyle);
			_setCursor(_x, _y, _width, _height, y_offset + topSpace, (isVisible && cursorIsVisible));
		};
	}
	override inline function onAddVisibleToDisplay() {
		if (line != null) {
			fontProgram.addMask(maskElement);
			if (backgroundIsVisible && backgroundElement != null) backgroundProgram.addElement(backgroundElement);
			if (selectionIsVisible && selectionElement != null) selectionProgram.addElement(selectionElement);
			if (cursorIsVisible && cursorElement != null) cursorProgram.addElement(cursorElement);
			fontProgram.lineAdd(line);
		} else {
			createFontStyle();
			line = fontProgram.createLine(text, x, y, (autoWidth) ? null : width, xOffset, fontStyle);
			text = null;
			if (autoSize > 0) {
				if (autoWidth) width = Std.int(line.textSize) + leftSpace + rightSpace;
				if (autoHeight) height = Std.int(line.height) + topSpace + bottomSpace;
				if (hasMoveEvent != 0) pickableMove.update(this);
				if (hasClickEvent != 0) pickableClick.update(this);
			};
			var _x = x + leftSpace;
			var _y = y + topSpace;
			var _width = width - leftSpace - rightSpace;
			var _height = height - topSpace - bottomSpace;
			var y_offset:Float = getAlignedYOffset();
			fontProgram.lineSetPositionSize(line, _x, _y + y_offset, _width, getAlignedXOffset(xOffset), isVisible);
			fontProgram.lineUpdate(line);
			if (masked) {
				if (maskX > leftSpace) _x = x + maskX;
				if (maskY > topSpace) _y = y + maskY;
				if (x + maskX + maskWidth < _x + _width) _width = maskX + maskWidth + x - _x;
				if (y + maskY + maskHeight < _y + _height) _height = maskY + maskHeight + y - _y;
			};
			maskElement = fontProgram.createMask(_x, _y, _width, _height);
			if (backgroundStyle != null) createBackgroundStyle(backgroundIsVisible);
			if (selectionStyle != null) createSelection(_x, _y, _width, _height, y_offset + topSpace, selectionIsVisible);
			if (cursorStyle != null) _createCursor(_x, _y, _width, _height, y_offset + topSpace, cursorIsVisible);
		};
	}
	override inline function onRemoveVisibleFromDisplay() {
		fontProgram.lineRemove(line);
		fontProgram.removeMask(maskElement);
		if (backgroundIsVisible && backgroundElement != null) backgroundProgram.removeElement(backgroundElement);
		if (selectionIsVisible && selectionElement != null) selectionProgram.removeElement(selectionElement);
		if (cursorIsVisible && cursorElement != null) cursorProgram.removeElement(cursorElement);
	}
	inline function createFontStyle() {
		var fontStylePos = uiDisplay.usedStyleID.indexOf(fontStyle.getUUID());
		if (fontStylePos < 0) {
			if (uiDisplay.autoAddStyles) uiDisplay.autoAddStyleProgram(cast fontProgram = font.createFontProgram(fontStyle, true, 1024, 1024, true), fontStyle.getUUID(), true) else throw ('Error by creating new UITextLine. The style \"' + Type.getClassName(Type.getClass(fontStyle)) + '\" id=' + fontStyle.id + ' is not inside the availableStyle list of UIDisplay.');
		} else {
			fontProgram = cast uiDisplay.usedStyleProgram[fontStylePos];
			if (fontProgram == null) uiDisplay.addProgramAtStylePos(cast fontProgram = font.createFontProgram(fontStyle, true, 1024, 1024, true), fontStylePos);
		};
	}
	inline function createBackgroundStyle(addUpdate:Bool) {
		var stylePos = uiDisplay.usedStyleID.indexOf(backgroundStyle.getUUID());
		if (stylePos < 0) {
			if (uiDisplay.autoAddStyles) uiDisplay.autoAddStyleProgram(cast backgroundProgram = backgroundStyle.createStyleProgram(), backgroundStyle.getUUID()) else throw ('Error by creating background for new UITextLine. The style \"' + Type.getClassName(Type.getClass(backgroundStyle)) + '\" id=' + backgroundStyle.id + ' is not inside the availableStyle list of UIDisplay.');
		} else {
			backgroundProgram = cast uiDisplay.usedStyleProgram[stylePos];
			if (backgroundProgram == null) uiDisplay.addProgramAtStylePos(cast backgroundProgram = backgroundStyle.createStyleProgram(), stylePos);
		};
		backgroundElement = backgroundProgram.createElement(this, backgroundStyle, backgroundSpace);
		if (addUpdate) backgroundProgram.addElement(backgroundElement);
	}
	inline function createSelectionStyle(x:Int, y:Int, w:Int, h:Int, mx:Int, my:Int, mw:Int, mh:Int, z:Int) {
		var stylePos = uiDisplay.usedStyleID.indexOf(selectionStyle.getUUID());
		if (stylePos < 0) {
			if (uiDisplay.autoAddStyles) uiDisplay.autoAddStyleProgram(cast selectionProgram = selectionStyle.createStyleProgram(), selectionStyle.getUUID()) else throw ('Error by creating selection for new UITextLine. The style \"' + Type.getClassName(Type.getClass(selectionStyle)) + '\" id=' + selectionStyle.id + ' is not inside the availableStyle list of UIDisplay.');
		} else {
			selectionProgram = cast uiDisplay.usedStyleProgram[stylePos];
			if (selectionProgram == null) uiDisplay.addProgramAtStylePos(cast selectionProgram = selectionStyle.createStyleProgram(), stylePos);
		};
		selectionElement = selectionProgram.createElementAt(this, x, y, w, h, mx, my, mw, mh, z, selectionStyle);
	}
	inline function createCursorStyle(x:Int, y:Int, w:Int, h:Int, mx:Int, my:Int, mw:Int, mh:Int, z:Int) {
		var stylePos = uiDisplay.usedStyleID.indexOf(cursorStyle.getUUID());
		if (stylePos < 0) {
			if (uiDisplay.autoAddStyles) uiDisplay.autoAddStyleProgram(cast cursorProgram = cursorStyle.createStyleProgram(), cursorStyle.getUUID()) else throw ('Error by creating cursor for new UITextLine. The style \"' + Type.getClassName(Type.getClass(cursorStyle)) + '\" id=' + cursorStyle.id + ' is not inside the availableStyle list of UIDisplay.');
		} else {
			cursorProgram = cast uiDisplay.usedStyleProgram[stylePos];
			if (cursorProgram == null) uiDisplay.addProgramAtStylePos(cast cursorProgram = cursorStyle.createStyleProgram(), stylePos);
		};
		cursorElement = cursorProgram.createElementAt(this, x, y, w, h, mx, my, mw, mh, z, cursorStyle);
	}
	public inline function setInputFocus(e:peote.ui.event.PointerEvent = null, cursorToPointer:Bool = false):Void {
		peote.ui.interactive.input2action.InputTextLine.focusElement = this;
		if (uiDisplay != null) uiDisplay.setInputFocus(this, e);
		if (cursorToPointer) setCursorToPointer(e);
		cursorShow();
	}
	public inline function removeInputFocus() {
		if (uiDisplay != null) uiDisplay.removeInputFocus(this);
		cursorHide();
	}
	public var input2Action : input2action.Input2Action = null;
	public inline function keyDown(keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {
		if (input2Action != null) input2Action.keyDown(keyCode, modifier) else peote.ui.interactive.input2action.InputTextLine.input2Action.keyDown(keyCode, modifier);
	}
	public inline function keyUp(keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {
		if (input2Action != null) input2Action.keyUp(keyCode, modifier) else peote.ui.interactive.input2action.InputTextLine.input2Action.keyUp(keyCode, modifier);
	}
	public inline function setCursorToPointer(e:peote.ui.event.PointerEvent):Void {
		if (uiDisplay != null) setCursorToPosition(e.x);
	}
	public inline function setCursorToPosition(x:Int):Void {
		setCursor(getCharAtPosition(x));
	}
	public function startSelection(e:peote.ui.event.PointerEvent):Void {
		if (uiDisplay != null) uiDisplay.startSelection(this, e);
	}
	public function stopSelection(e:peote.ui.event.PointerEvent = null):Void {
		if (uiDisplay != null) uiDisplay.stopSelection(this, e);
	}
	var selectStartFrom : Int = 0;
	inline function onSelectStart(e:peote.ui.event.PointerEvent):Void {
		removeSelection();
		setCursorToPosition(e.x);
		selectStartFrom = cursor;
		selectionHide();
	}
	inline function onSelectStop(e:peote.ui.event.PointerEvent = null):Void {
		stopSelectOutsideTimer();
		selectNextX = 0;
	}
	inline function onSelect(e:peote.ui.event.PointerEvent):Void {
		if (e.x < leftSpace + x) {
			if (selectNextX != -1) {
				selectNextX = -1;
				startSelectOutsideTimer();
			};
		} else if (e.x > width - rightSpace + x) {
			if (selectNextX != 1) {
				selectNextX = 1;
				startSelectOutsideTimer();
			};
		} else selectNextX = 0;
		if (selectNextX == 0) {
			stopSelectOutsideTimer();
			setCursorToPosition(e.x);
			select(selectStartFrom, cursor);
		} else if (selectNextX == 0) {
			setCursor(getCharAtPosition(e.x));
			select(selectStartFrom, cursor);
		};
	}
	var seletionOutsideTimer = new haxe.Timer(50);
	var seletionOutsideTimerIsRun = false;
	var selectNextX : Int = 0;
	function startSelectOutsideTimer() {
		if (!seletionOutsideTimerIsRun) {
			seletionOutsideTimer = new haxe.Timer(50);
			seletionOutsideTimer.run = selectNextOutside;
			seletionOutsideTimerIsRun = true;
		};
	}
	function stopSelectOutsideTimer() {
		seletionOutsideTimer.stop();
		seletionOutsideTimerIsRun = false;
	}
	function selectNextOutside() {
		if ((selectNextX < 0 && cursor == 0) || (selectNextX > 0 && cursor == line.length)) stopSelectOutsideTimer() else {
			if (selectNextX < 0 && cursor > line.visibleFrom) cursor = line.visibleFrom else if (selectNextX > 0 && cursor < line.visibleTo) cursor = line.visibleTo;
			if (selectNextX != 0) setCursor(cursor + selectNextX);
			select(selectStartFrom, cursor);
		};
	}
	public function setText(text:String, fontStyle:Null<peote.ui.style.FontStylePacked> = null, forceAutoWidth:Null<Bool> = null, forceAutoHeight:Null<Bool> = null, autoUpdate = false) {
		if (fontStyle != null) this.fontStyle = fontStyle;
		if (forceAutoWidth != null) autoWidth = forceAutoWidth;
		if (forceAutoHeight != null) autoHeight = forceAutoHeight;
		if (line != null) {
			setOldTextSize();
			fontProgram.lineSet(line, text, x, y, (autoWidth) ? null : width, xOffset, this.fontStyle, null, isVisible);
			if (selectTo > line.length) selectTo = line.length;
			setCursor(cursor, autoUpdate);
			if (autoUpdate) updateTextOnly(true);
		} else this.text = text;
	}
	var r_az = ~/[a-z]-[a-z]/g;
	var r_AZ = ~/[A-Z]-[A-Z]/g;
	var r_09 = ~/[0-9]-[0-9]/g;
	var restricRegExp : EReg = null;
	public var restrictedChars(default, set) : String = "";
	inline function set_restrictedChars(chars:String):String {
		if (chars == restrictedChars) return chars;
		if (chars == "") {
			restricRegExp = null;
			return restrictedChars = chars;
		};
		var ranges:String = "";
		if (r_az.match(chars)) {
			ranges += r_az.matched(0);
			chars = r_az.replace(chars, "");
		};
		if (r_AZ.match(chars)) {
			ranges += r_AZ.matched(0);
			chars = r_AZ.replace(chars, "");
		};
		if (r_09.match(chars)) {
			ranges += r_09.matched(0);
			chars = r_09.replace(chars, "");
		};
		chars = StringTools.replace(chars, "\\", "\\\\");
		chars = StringTools.replace(chars, "-", "\\-");
		chars = StringTools.replace(chars, "[", "\\[");
		chars = StringTools.replace(chars, "]", "\\]");
		restricRegExp = new EReg("[^" + ranges + chars + "]", "g");
		return restrictedChars = chars;
	}
	public inline function textInput(chars:String):Void {
		if (line == null) return;
		if (restricRegExp != null) chars = restricRegExp.replace(chars, "");
		if (chars == "") return;
		setOldTextSize();
		if (hasSelection()) {
			deleteChars(selectFrom, selectTo);
			setCursor(selectFrom, false, false);
			removeSelection();
		};
		if (chars.length == 1) {
			insertChar(chars, cursor, fontStyle);
			setCursor(cursor + 1, false);
		} else {
			insertChars(chars, cursor, fontStyle);
			setCursor(cursor + chars.length, false);
		};
		updateTextOnly(true);
	}
	var oldTextWidth : Float = 0.0;
	inline function setOldTextSize() oldTextWidth = line.textSize;
	inline function updateTextOnly(updateCursor:Bool) {
		updateLineLayout(false, autoWidth, false, updateCursor, false, autoWidth, !autoWidth);
		if (oldTextWidth != line.textSize) {
			if (_onResizeTextWidth != null) _onResizeTextWidth(this, line.textSize, line.textSize - oldTextWidth);
			if (onResizeTextWidth != null) onResizeTextWidth(this, line.textSize, line.textSize - oldTextWidth);
		};
	}
	public inline function deleteChar() {
		if (line == null) return;
		if (hasSelection()) {
			setOldTextSize();
			deleteChars(selectFrom, selectTo);
			setCursor(selectFrom, false);
			removeSelection();
			updateTextOnly(true);
		} else if (cursor < line.length) {
			setOldTextSize();
			deleteCharAtCursor();
			setCursor(cursor, false);
			updateTextOnly(true);
		};
	}
	public inline function backspace() {
		if (line == null) return;
		if (hasSelection()) {
			setOldTextSize();
			deleteChars(selectFrom, selectTo);
			setCursor(selectFrom, false);
			removeSelection();
			updateTextOnly(true);
		} else if (cursor > 0) {
			setOldTextSize();
			deleteCharAtPos(cursor - 1);
			setCursor(cursor - 1, false);
			updateTextOnly(true);
		};
	}
	public inline function delLeft(toLineStart:Bool = false) {
		if (line == null) return;
		if (cursor > 0) {
			setOldTextSize();
			var from = (toLineStart) ? 0 : fontProgram.lineWordLeft(line, cursor);
			deleteChars(from, cursor);
			if (hasSelection()) {
				if (cursor == selectTo) removeSelection() else {
					selectTo -= cursor - from;
					select(from, selectTo);
				};
			};
			setCursor(from, false);
			updateTextOnly(true);
		};
	}
	public inline function delRight(toLineEnd:Bool = false) {
		if (line == null) return;
		if (cursor < line.length) {
			if (hasSelection()) removeSelection();
			setOldTextSize();
			deleteChars(cursor, (toLineEnd) ? line.length : fontProgram.lineWordRight(line, cursor));
			setCursor(cursor, false);
			updateTextOnly(true);
		};
	}
	public inline function tabulator() {
		textInput("\t");
	}
	public function copyToClipboard() {
		if (line != null && hasSelection()) {
			lime.system.Clipboard.text = fontProgram.lineGetChars(line, selectFrom, selectTo);
		};
	}
	public function cutToClipboard() {
		if (line != null && hasSelection()) {
			setOldTextSize();
			lime.system.Clipboard.text = cutChars(selectFrom, selectTo);
			setCursor(selectFrom, false);
			removeSelection();
			updateTextOnly(true);
		};
	}
	public function pasteFromClipboard() {
		if (lime.system.Clipboard.text != null) textInput(lime.system.Clipboard.text);
	}
	public function selectAll() {
		select(0, line.length - 1);
		setCursor(0, false, false);
	}
	inline function _updateCursorSelection(newCursor:Int, addSelection:Bool) {
		var oldCursor = cursor;
		setCursor(newCursor);
		if (addSelection) {
			if (hasSelection()) {
				if (oldCursor == selectFrom) select(cursor, selectTo) else select(selectFrom, cursor);
			} else select(oldCursor, cursor);
		};
	}
	public inline function cursorStart(addSelection:Bool = false) {
		if (!addSelection && hasSelection()) removeSelection();
		_updateCursorSelection(0, addSelection);
	}
	public inline function cursorEnd(addSelection:Bool = false) {
		if (!addSelection && hasSelection()) removeSelection();
		_updateCursorSelection(line.length, addSelection);
	}
	public inline function cursorLeft(addSelection:Bool = false) {
		if (!addSelection && hasSelection()) {
			setCursor(selectFrom);
			removeSelection();
		} else if (cursor > 0) _updateCursorSelection(cursor - 1, addSelection);
	}
	public inline function cursorRight(addSelection:Bool = false) {
		if (!addSelection && hasSelection()) {
			setCursor(selectTo);
			removeSelection();
		} else if (cursor < line.length) _updateCursorSelection(cursor + 1, addSelection);
	}
	public inline function cursorLeftWord(addSelection:Bool = false) {
		if (!addSelection && hasSelection()) removeSelection();
		if (cursor > 0) _updateCursorSelection(fontProgram.lineWordLeft(line, cursor), addSelection);
	}
	public inline function cursorRightWord(addSelection:Bool = false) {
		if (!addSelection && hasSelection()) removeSelection();
		if (cursor < line.length) _updateCursorSelection(fontProgram.lineWordRight(line, cursor), addSelection);
	}
	public inline function undo() {
		if (hasUndo) {
			var step = undoBuffer.undo();
			if (step != null) {
				if (hasSelection()) removeSelection();
				setOldTextSize();
				switch (step.action) {
					case INSERT:{
						fontProgram.lineDeleteChars(line, step.fromPos, step.toPos, isVisible);
						if (onDeleteText != null) onDeleteText(this, step.fromPos, step.toPos, step.chars);
						setCursor(step.fromPos, false);
					};
					case DELETE:{
						fontProgram.lineInsertChars(line, step.chars, step.fromPos, fontStyle, isVisible);
						if (onInsertText != null) onInsertText(this, step.fromPos, step.toPos, step.chars);
						setCursor(step.toPos, false);
					};
				};
				updateTextOnly(true);
			};
		};
	}
	public inline function redo() {
		if (hasUndo) {
			var step = undoBuffer.redo();
			if (step != null) {
				if (hasSelection()) removeSelection();
				setOldTextSize();
				switch (step.action) {
					case INSERT:{
						fontProgram.lineInsertChars(line, step.chars, step.fromPos, fontStyle, isVisible);
						if (onInsertText != null) onInsertText(this, step.fromPos, step.toPos, step.chars);
						setCursor(step.toPos, false);
					};
					case DELETE:{
						fontProgram.lineDeleteChars(line, step.fromPos, step.toPos, isVisible);
						if (onDeleteText != null) onDeleteText(this, step.fromPos, step.toPos, step.chars);
						setCursor(step.fromPos, false);
					};
				};
				updateTextOnly(true);
			};
		};
	}
	public inline function setStyle(glyphStyle:peote.ui.style.FontStylePacked, from:Int = 0, to:Null<Int> = null) {
		fontStyle = glyphStyle;
		fontProgram.lineSetStyle(line, fontStyle, from, to, isVisible);
	}
	public inline function deleteCharAtCursor() {
		_deleteChar(cursor);
	}
	public inline function deleteCharAtPos(position:Int) {
		_deleteChar(position);
	}
	public inline function insertChar(char:String, position:Int, glyphStyle:peote.ui.style.FontStylePacked = null) {
		fontProgram.lineInsertChar(line, char.charCodeAt(0), position, glyphStyle, isVisible);
		if (hasUndo) undoBuffer.insert(position, position + 1, char);
		if (onInsertText != null) onInsertText(this, position, position + 1, char);
	}
	public inline function insertChars(chars:String, position:Int, glyphStyle:peote.ui.style.FontStylePacked = null) {
		fontProgram.lineInsertChars(line, chars, position, glyphStyle, isVisible);
		if (hasUndo) undoBuffer.insert(position, position + chars.length, chars);
		if (onInsertText != null) onInsertText(this, position, position + chars.length, chars);
	}
	inline function _deleteChar(position:Int = 0) {
		if (hasUndo) undoBuffer.delete(position, position + 1, fontProgram.lineGetChars(line, position, position + 1));
		if (onDeleteText != null) {
			var chars = fontProgram.lineGetChars(line, position, position + 1);
			fontProgram.lineDeleteChar(line, position, isVisible);
			onDeleteText(this, position, position + 1, chars);
		} else fontProgram.lineDeleteChar(line, position, isVisible);
	}
	public inline function deleteChars(from:Int, to:Int) {
		if (hasUndo) undoBuffer.delete(from, to, fontProgram.lineGetChars(line, from, to));
		if (onDeleteText != null) {
			var chars = fontProgram.lineGetChars(line, from, to);
			fontProgram.lineDeleteChars(line, from, to, isVisible);
			onDeleteText(this, from, to, chars);
		} else fontProgram.lineDeleteChars(line, from, to, isVisible);
	}
	public inline function cutChars(from:Int, to:Int):String {
		if (hasUndo || onDeleteText != null) {
			var chars = fontProgram.lineCutChars(line, from, to, isVisible);
			if (hasUndo) undoBuffer.delete(from, to, chars);
			if (onDeleteText != null) onDeleteText(this, from, to, chars);
			return chars;
		} else return fontProgram.lineCutChars(line, from, to, isVisible);
	}
	public inline function getPositionAtChar(position:Int):Float {
		return fontProgram.lineGetPositionAtChar(line, position);
	}
	public inline function getCharAtPosition(xPosition:Float):Int {
		return fontProgram.lineGetCharAtPosition(line, xPosition);
	}
	public inline function setXOffset(xOffset:Float, update:Bool = true, triggerEvent:Bool = false) _setXOffset(xOffset, update, triggerEvent, triggerEvent);
	inline function _setXOffset(xOffset:Float, update:Bool, triggerInternalEvent:Bool, triggerEvent:Bool) {
		if (triggerInternalEvent && _onChangeXOffset != null) _onChangeXOffset(this, xOffset, xOffset - this.xOffset);
		if (triggerEvent && onChangeXOffset != null) onChangeXOffset(this, xOffset, xOffset - this.xOffset);
		this.xOffset = xOffset;
		if (update) updateLineLayout(false, false, true, true, false, false, true);
	}
	public function bindHSlider(slider:peote.ui.interactive.UISlider) {
		slider.setRange(0, Math.min(0, width - leftSpace - rightSpace - textWidth), (width - leftSpace - rightSpace) / textWidth, false, false);
		slider._onChange = function(_, value:Float, _) _setXOffset(Math.round(value), true, false, true);
		_onChangeXOffset = function(_, xOffset:Float, _) slider.setValue(xOffset, true, false);
		_onResizeTextWidth = function(_, _, delta:Float) {
			var s = width - leftSpace - rightSpace;
			if (textWidth < s || textWidth - delta > s) {
				slider.setRange(0, Math.min(0, s - textWidth), s / textWidth, true, false);
			} else {
				slider.setRange(0, Math.min(0, s - textWidth), s / textWidth, false, false);
				slider.setValue(xOffset, true, false);
			};
		};
		setOnResizeWidthSlider(this, function(_, _, _) {
			slider.setRange(0, Math.min(0, width - leftSpace - rightSpace - textWidth), (width - leftSpace - rightSpace) / textWidth, true, false);
		});
	}
	public function unbindHSlider(slider:peote.ui.interactive.UISlider) {
		slider._onChange = null;
		_onChangeXOffset = null;
		setOnResizeWidthSlider(this, null);
		_onResizeTextWidth = null;
	}
	var _onResizeTextWidth : (UITextLineP, Float, Float) -> Void = null;
	var _onChangeXOffset : (UITextLineP, Float, Float) -> Void = null;
	public var onResizeTextWidth : (UITextLineP, Float, Float) -> Void = null;
	public var onChangeXOffset : (UITextLineP, Float, Float) -> Void = null;
	public var onInsertText : (UITextLineP, Int, Int, String) -> Void = null;
	public var onDeleteText : (UITextLineP, Int, Int, String) -> Void = null;
	public var onResizeWidth(never, set) : (UITextLineP, Int, Int) -> Void;
	inline function set_onResizeWidth(f:(UITextLineP, Int, Int) -> Void):(UITextLineP, Int, Int) -> Void return setOnResizeWidth(this, f);
	public var onResizeHeight(never, set) : (UITextLineP, Int, Int) -> Void;
	inline function set_onResizeHeight(f:(UITextLineP, Int, Int) -> Void):(UITextLineP, Int, Int) -> Void return setOnResizeHeight(this, f);
	public var onPointerOver(never, set) : (UITextLineP, peote.ui.event.PointerEvent) -> Void;
	inline function set_onPointerOver(f:(UITextLineP, peote.ui.event.PointerEvent) -> Void):(UITextLineP, peote.ui.event.PointerEvent) -> Void return setOnPointerOver(this, f);
	public var onPointerOut(never, set) : (UITextLineP, peote.ui.event.PointerEvent) -> Void;
	inline function set_onPointerOut(f:(UITextLineP, peote.ui.event.PointerEvent) -> Void):(UITextLineP, peote.ui.event.PointerEvent) -> Void return setOnPointerOut(this, f);
	public var onPointerMove(never, set) : (UITextLineP, peote.ui.event.PointerEvent) -> Void;
	inline function set_onPointerMove(f:(UITextLineP, peote.ui.event.PointerEvent) -> Void):(UITextLineP, peote.ui.event.PointerEvent) -> Void return setOnPointerMove(this, f);
	public var onPointerDown(never, set) : (UITextLineP, peote.ui.event.PointerEvent) -> Void;
	inline function set_onPointerDown(f:(UITextLineP, peote.ui.event.PointerEvent) -> Void):(UITextLineP, peote.ui.event.PointerEvent) -> Void return setOnPointerDown(this, f);
	public var onPointerUp(never, set) : (UITextLineP, peote.ui.event.PointerEvent) -> Void;
	inline function set_onPointerUp(f:(UITextLineP, peote.ui.event.PointerEvent) -> Void):(UITextLineP, peote.ui.event.PointerEvent) -> Void return setOnPointerUp(this, f);
	public var onPointerClick(never, set) : (UITextLineP, peote.ui.event.PointerEvent) -> Void;
	inline function set_onPointerClick(f:(UITextLineP, peote.ui.event.PointerEvent) -> Void):(UITextLineP, peote.ui.event.PointerEvent) -> Void return setOnPointerClick(this, f);
	public var onMouseWheel(never, set) : (UITextLineP, peote.ui.event.WheelEvent) -> Void;
	inline function set_onMouseWheel(f:(UITextLineP, peote.ui.event.WheelEvent) -> Void):(UITextLineP, peote.ui.event.WheelEvent) -> Void return setOnMouseWheel(this, f);
	public var onDrag(never, set) : (UITextLineP, Float, Float) -> Void;
	inline function set_onDrag(f:(UITextLineP, Float, Float) -> Void):(UITextLineP, Float, Float) -> Void return setOnDrag(this, f);
	public var onFocus(never, set) : UITextLineP -> Void;
	inline function set_onFocus(f:UITextLineP -> Void):UITextLineP -> Void return setOnFocus(this, f);
}