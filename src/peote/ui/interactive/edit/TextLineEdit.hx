package peote.ui.interactive.edit;

import input2action.ActionMap;
import peote.ui.interactive.interfaces.TextLine;

@:access(peote.ui.interactive)
class TextLineEdit 
{
	public var textLine:TextLine;
	
	public var actionMap:ActionMap;
	
	public function new() {
		actionMap = [
			"cursorLeft"  => { action:cursorCharLeft },
			//"cursorRight" => { action:cursorCharRight },
		];
		
	}
	
	public function textInput(chars:String)
	{
		trace("textInput:", chars);
	}
	
	
	
	public function cursorCharLeft(_, _) cursorLeft(false, false);
	//static public function cursorWordLeft(_, _) cursorLeft(false, true);
	//static public function selectCharLeft(_, _) cursorLeft(true, false);
	//static public function selectWordLeft(_, _) cursorLeft(true, true);
	//
	//static public function cursorCharRight(_, _) cursorRight(false, false);
	//static public function cursorWordRight(_, _) cursorRight(false, true);
	//static public function selectCharRight(_, _) cursorRight(true, false);
	//static public function selectWordRight(_, _) cursorRight(true, true);
	
	
	inline function cursorLeft(isShift:Bool, isCtrl:Bool)
	{
		trace("cursor left");
/*		if (hasSelection && !isShift) {
			if (select_from < select_to) cursorSet(select_from);
		}
		else if (cursor > 0) {
			if (!hasSelection && isShift) selectionStart(cursor);
			if (isCtrl) {
				do cursor-- while (cursor > 0 && line.getGlyph(cursor).char == 32);
				while (cursor > 0 && line.getGlyph(cursor-1).char != 32) cursor--;
			}
			else cursor--;
			
			cursorElem.x = fontProgram.lineGetPositionAtChar(line, cursor);
			fontProgram.updateBackground(cursorElem);
			if (isShift) selectionSetTo(cursor);
		}
		if (!isShift) selectionSetTo(select_from);
*/
	}
/*	
	inline function cursorRight(isShift:Bool, isCtrl:Bool)
	{
		trace("cursor right");
		if (hasSelection && !isShift) {
			if (select_from > select_to) cursorSet(select_from);
		}
		else if (cursor < line.length) {
			if (!hasSelection && isShift) selectionStart(cursor);
			if (isCtrl) {
				do cursor++ while (cursor < line.length && line.getGlyph(cursor).char != 32);
				while (cursor < line.length && line.getGlyph(cursor).char == 32) cursor++;
			}
			else cursor++;
			cursorElem.x = fontProgram.lineGetPositionAtChar(line, cursor);
			fontProgram.updateBackground(cursorElem);
			if (isShift) selectionSetTo(cursor);
		}
		if (!isShift) selectionSetTo(select_from);
	}
*/
	
}