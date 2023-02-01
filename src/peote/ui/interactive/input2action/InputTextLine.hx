package peote.ui.interactive.input2action;

import lime.ui.KeyCode;

import input2action.Input2Action;
import input2action.ActionConfig;
import input2action.ActionMap;
import peote.ui.interactive.interfaces.ActionTextLine;

class InputTextLine 
{

	// static functions to call the focused elements actions for input2action
	
	public static var actionConfig:ActionConfig = [
		{ action: "deleteChar" , keyboard: KeyCode.DELETE },		
		{ action: "backspace"  , keyboard: KeyCode.BACKSPACE },
		{ action: "tabulator"  , keyboard: KeyCode.TAB },
		
		{ action: "copyToClipboard"   , keyboard: [ KeyCode.COPY,  [KeyCode.LEFT_CTRL, KeyCode.C], [KeyCode.RIGHT_CTRL, KeyCode.C] ] },
		{ action: "cutToClipboard"    , keyboard: [ KeyCode.CUT,   [KeyCode.LEFT_CTRL, KeyCode.X], [KeyCode.RIGHT_CTRL, KeyCode.X] ] },
		{ action: "pasteFromClipboard", keyboard: [ KeyCode.PASTE, [KeyCode.LEFT_CTRL, KeyCode.V], [KeyCode.RIGHT_CTRL, KeyCode.V] ] },
		
		{ action: "cursorLeft" , keyboard: KeyCode.LEFT  },
		{ action: "cursorRight", keyboard: KeyCode.RIGHT },
		
		// TODO
		//KeyCode.HOME
		//KeyCode.END
		// SELECT ALL
		// CUT
		// UNDO
		// REDO
	];
	
	public static var actionMap:ActionMap = [
		"deleteChar"  => { action:deleteChar , repeatKeyboardDefault:true },
		"backspace"   => { action:backspace  , repeatKeyboardDefault:true },
		"tabulator"   => { action:tabulator  , repeatKeyboardDefault:true },
		
		"copyToClipboard"      => { action:copyToClipboard },
		"cutToClipboard"       => { action:cutToClipboard  },
		"pasteFromClipboard"   => { action:pasteFromClipboard, repeatKeyboardDefault:true },
		
		"cursorLeft"  => { action:cursorLeft , repeatKeyboardDefault:true },
		"cursorRight" => { action:cursorRight, repeatKeyboardDefault:true },
	];
	
	
	public static inline function init() {
		input2Action = new Input2Action(actionConfig, actionMap);
		input2Action.setKeyboard();
	}
	
	
	public static var input2Action:Input2Action;	
	public static var focusElement:ActionTextLine;
		
	static inline function deleteChar (_,_) focusElement.deleteChar();
	static inline function backspace  (_,_) focusElement.backspace();
	static inline function tabulator  (_,_) focusElement.tabulator();
	
	static inline function copyToClipboard   (_,_) focusElement.copyToClipboard();
	static inline function cutToClipboard    (_,_) focusElement.cutToClipboard();
	static inline function pasteFromClipboard(_,_) focusElement.pasteFromClipboard();
	
	static inline function cursorLeft (_,_) focusElement.cursorLeft();
	static inline function cursorRight(_,_) focusElement.cursorRight();

	
}