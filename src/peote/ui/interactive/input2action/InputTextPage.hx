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
		{ action: "deleteChar" , keyboard: KeyCode.DELETE },
		{ action: "backspace"  , keyboard: KeyCode.BACKSPACE },
		{ action: "tabulator"  , keyboard: KeyCode.TAB },
		
		{ action: "copyToClipboard"   , keyboard: [ KeyCode.COPY,  [KeyCode.LEFT_CTRL, KeyCode.C], [KeyCode.RIGHT_CTRL, KeyCode.C] ] },
		{ action: "cutToClipboard"    , keyboard: [ KeyCode.CUT,   [KeyCode.LEFT_CTRL, KeyCode.X], [KeyCode.RIGHT_CTRL, KeyCode.X] ] },
		{ action: "pasteFromClipboard", keyboard: [ KeyCode.PASTE, [KeyCode.LEFT_CTRL, KeyCode.V], [KeyCode.RIGHT_CTRL, KeyCode.V] ] },
		
		{ action: "selectModifier", keyboard: [KeyCode.LEFT_SHIFT, KeyCode.RIGHT_SHIFT] },
		
		{ action: "cursorLeft" , keyboard: KeyCode.LEFT , single:true },
		{ action: "cursorRight", keyboard: KeyCode.RIGHT, single:true },		
		{ action: "cursorLeftWord" , keyboard: [ [KeyCode.LEFT_CTRL, KeyCode.LEFT ], [KeyCode.RIGHT_CTRL, KeyCode.LEFT ] ], single:true},
		{ action: "cursorRightWord", keyboard: [ [KeyCode.LEFT_CTRL, KeyCode.RIGHT], [KeyCode.RIGHT_CTRL, KeyCode.RIGHT] ], single:true},
		
		//{ action: "selectLeft" , keyboard: [ [KeyCode.LEFT_SHIFT, KeyCode.LEFT ], [KeyCode.RIGHT_SHIFT, KeyCode.LEFT ] ] },
		//{ action: "selectRight", keyboard: [ [KeyCode.LEFT_SHIFT, KeyCode.RIGHT ], [KeyCode.RIGHT_SHIFT, KeyCode.RIGHT ] ] },
		
		{ action: "cursorUp"   , keyboard: KeyCode.UP  , single:true },
		{ action: "cursorDown" , keyboard: KeyCode.DOWN, single:true },
		
		//{ action: "selectUp"   , keyboard: [ [KeyCode.LEFT_SHIFT, KeyCode.UP   ], [KeyCode.RIGHT_SHIFT, KeyCode.UP   ] ] },
		//{ action: "selectDown" , keyboard: [ [KeyCode.LEFT_SHIFT, KeyCode.DOWN ], [KeyCode.RIGHT_SHIFT, KeyCode.DOWN ] ] },
		
		{ action: "enter"      , keyboard: [KeyCode.RETURN, KeyCode.RETURN2, KeyCode.NUMPAD_ENTER] },
		
		// TODO
		//KeyCode.HOME
		//KeyCode.END
		// SELECT ALL
		// UNDO
		// REDO
	];
	
	public static var actionMap:ActionMap = [
		"deleteChar"  => { action:deleteChar , repeatKeyboardDefault:true },
		"backspace"   => { action:backspace  , repeatKeyboardDefault:true },
		"tabulator"   => { action:tabulator  , repeatKeyboardDefault:true },
		
		"copyToClipboard"      => { action:copyToClipboard   , repeatKeyboardDefault:true },
		"cutToClipboard"       => { action:cutToClipboard  },
		"pasteFromClipboard"   => { action:pasteFromClipboard, repeatKeyboardDefault:true },
		
		"selectModifier"      => { action:selectModifier, up:true },
		
		"cursorLeft"      => { action:cursorLeft     , repeatKeyboardDefault:true },
		"cursorRight"     => { action:cursorRight    , repeatKeyboardDefault:true },
		"cursorLeftWord"  => { action:cursorLeftWord , repeatKeyboardDefault:true },
		"cursorRightWord" => { action:cursorRightWord, repeatKeyboardDefault:true },		
		
		//"selectLeft"      => { action:selectLeft     , repeatKeyboardDefault:true },
		//"selectRight"     => { action:selectRight    , repeatKeyboardDefault:true },

		"cursorUp"    => { action:cursorUp   , repeatKeyboardDefault:true },
		"cursorDown"  => { action:cursorDown , repeatKeyboardDefault:true },
		
		//"selectUp"    => { action:selectUp   , repeatKeyboardDefault:true },
		//"selectDown"  => { action:selectDown , repeatKeyboardDefault:true },
		
		"enter"       => { action:enter      , repeatKeyboardDefault:true },
	];
	
	
	public static inline function init() {
		input2Action = new Input2Action(actionConfig, actionMap);
		input2Action.setKeyboard();
	}
	
	
	public static var input2Action:Input2Action;	
	public static var focusElement:ActionTextPage;		
	
	static inline function deleteChar (_,_) focusElement.deleteChar();
	static inline function backspace  (_,_) focusElement.backspace();
	static inline function tabulator  (_,_) focusElement.tabulator();
	
	static inline function copyToClipboard   (_,_) focusElement.copyToClipboard();
	static inline function cutToClipboard    (_,_) focusElement.cutToClipboard();
	static inline function pasteFromClipboard(_, _) focusElement.pasteFromClipboard();
	
	static var addSelection:Bool = false;
	static inline function selectModifier (isDown:Bool, _) addSelection = isDown;
	
	static inline function cursorLeft     (_,_) focusElement.cursorLeft(addSelection);
	static inline function cursorRight    (_,_) focusElement.cursorRight(addSelection);
	static inline function cursorLeftWord (_,_) focusElement.cursorLeftWord();
	static inline function cursorRightWord(_,_) focusElement.cursorRightWord();	
	
	//static inline function selectLeft (_,_) focusElement.cursorLeft(true);
	//static inline function selectRight(_,_) focusElement.cursorRight(true);

	static inline function cursorUp   (_,_) focusElement.cursorUp();
	static inline function cursorDown (_,_) focusElement.cursorDown();
	
	//static inline function selectUp  (_,_) focusElement.cursorUp(true);
	//static inline function selectDown(_,_) focusElement.cursorDown(true);

	static inline function enter(_,_) focusElement.enter();

	
}