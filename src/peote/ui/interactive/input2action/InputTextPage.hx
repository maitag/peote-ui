package peote.ui.interactive.input2action;

import lime.ui.KeyCode;

import input2action.Input2Action;
import input2action.ActionConfig;
import input2action.ActionMap;
import peote.ui.interactive.interfaces.ActionTextPage;

class InputTextPage
{

	// static functions to call the focused elements actions for input2action
	
	public static var actionConfig:ActionConfig = [
		{ action: "cursorLeft" , keyboard: KeyCode.LEFT  },
		{ action: "cursorRight", keyboard: KeyCode.RIGHT },
		{ action: "cursorUp"   , keyboard: KeyCode.UP    },
		{ action: "cursorDown" , keyboard: KeyCode.DOWN  },
		//KeyCode.DELETE
		//KeyCode.BACKSPACE
		//KeyCode.HOME
		//KeyCode.END
		// SELECT ALL
		// CUT
		// COPY
		// PASTE
		// PAGE_UP...
	];
	
	public static var actionMap:ActionMap = [
		"cursorLeft"  => { action:cursorLeft , repeatKeyboardDefault:true },
		"cursorRight" => { action:cursorRight, repeatKeyboardDefault:true },
		"cursorUp"    => { action:cursorUp   , repeatKeyboardDefault:true },
		"cursorDown"  => { action:cursorDown , repeatKeyboardDefault:true },
	];
	
	
	public static inline function init() {
		input2Action = new Input2Action(actionConfig, actionMap);
		input2Action.setKeyboard();
	}
	
	
	public static var input2Action:Input2Action;	
	public static var focusElement:ActionTextPage;		
	
	static inline function cursorLeft (_,_) focusElement.cursorLeft();
	static inline function cursorRight(_,_) focusElement.cursorRight();
	static inline function cursorUp   (_,_) focusElement.cursorUp();
	static inline function cursorDown (_,_) focusElement.cursorDown();

	
}