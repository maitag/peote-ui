package peote.ui.interactive.input2action;

import input2action.Input2Action;
import input2action.ActionConfig;
import input2action.ActionMap;
import peote.ui.interactive.interfaces.ActionTextPage;

class InputTextPage
{

	// static functions to call the focused elements actions for input2action
	
	public static var actionConfig:ActionConfig = [
		{ action: "cursorCharLeft" , keyboard: lime.ui.KeyCode.LEFT  },
		{ action: "cursorCharRight", keyboard: lime.ui.KeyCode.RIGHT },
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
		"cursorCharLeft"  => { action:cursorCharLeft , repeatKeyboardDefault:true },
		"cursorCharRight" => { action:cursorCharRight, repeatKeyboardDefault:true },
	];
	
	
	public static inline function init() {
		input2Action = new Input2Action(actionConfig, actionMap);
		input2Action.setKeyboard();
	}
	
	
	public static var input2Action:Input2Action;
	
	public static var focusElement:ActionTextPage;
		
	
	static inline function cursorCharLeft(_,_)  focusElement.cursorCharLeft();
	static inline function cursorCharRight(_,_) focusElement.cursorCharRight();

	
}