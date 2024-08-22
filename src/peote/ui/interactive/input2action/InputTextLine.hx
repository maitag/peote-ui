package peote.ui.interactive.input2action;

import lime.ui.KeyCode;

import input2action.Input2Action;
import input2action.KeyboardAction;
import input2action.ActionConfig;
import input2action.ActionMap;
import peote.ui.interactive.interfaces.ActionTextLine;

class InputTextLine 
{
	public static var input2Action:Input2Action;	
	public static var keyboardAction:KeyboardAction;	
	public static var focusElement:ActionTextLine;

	public static inline function init() {
		input2Action = new Input2Action();
		keyboardAction = new KeyboardAction(actionConfig, actionMap);
		input2Action.addKeyboard(keyboardAction);
	}
		
	public static var actionConfig:ActionConfig =
	[
		{ action: "deleteChar" , keyboard: KeyCode.DELETE, single:true },
		{ action: "backspace"  , keyboard: KeyCode.BACKSPACE, single:true },
		
		{ action: "delLeft" , keyboard: [
			[KeyCode.LEFT_CTRL, KeyCode.BACKSPACE ], [KeyCode.RIGHT_CTRL, KeyCode.BACKSPACE ],
			[KeyCode.LEFT_SHIFT, KeyCode.BACKSPACE ], [KeyCode.RIGHT_SHIFT, KeyCode.BACKSPACE ] 		
		] },
		{ action: "delRight", keyboard: [
			[KeyCode.LEFT_CTRL, KeyCode.DELETE ], [KeyCode.RIGHT_CTRL, KeyCode.DELETE ],
			[KeyCode.LEFT_SHIFT, KeyCode.DELETE ], [KeyCode.RIGHT_SHIFT, KeyCode.DELETE ]
		] },
		
		{ action: "tabulator", keyboard: KeyCode.TAB },
		
		{ action: "copyToClipboard"   , keyboard: [ KeyCode.COPY,  [KeyCode.LEFT_CTRL, KeyCode.C], [KeyCode.RIGHT_CTRL, KeyCode.C] ] },
		{ action: "cutToClipboard"    , keyboard: [ KeyCode.CUT,   [KeyCode.LEFT_CTRL, KeyCode.X], [KeyCode.RIGHT_CTRL, KeyCode.X] ] },
		{ action: "pasteFromClipboard", keyboard: [ KeyCode.PASTE, [KeyCode.LEFT_CTRL, KeyCode.V], [KeyCode.RIGHT_CTRL, KeyCode.V] ] },
		
		{ action: "shiftModifier", keyboard: [KeyCode.LEFT_SHIFT, KeyCode.RIGHT_SHIFT] },
		
		{ action: "selectAll" , keyboard: [ [KeyCode.LEFT_CTRL, KeyCode.A ], [KeyCode.RIGHT_CTRL, KeyCode.A ] ] },
		
		{ action: "undo" , keyboard: [ [KeyCode.LEFT_CTRL, KeyCode.Z ], [KeyCode.RIGHT_CTRL, KeyCode.Z ] ] },
		{ action: "redo" , keyboard: [ [KeyCode.LEFT_CTRL, KeyCode.Y ], [KeyCode.RIGHT_CTRL, KeyCode.Y ] ] },
		
		{ action: "cursorStart", keyboard: KeyCode.HOME, single:true },
		{ action: "cursorEnd"  , keyboard: KeyCode.END , single:true },
		
		{ action: "cursorLeft" , keyboard: KeyCode.LEFT , single:true },
		{ action: "cursorRight", keyboard: KeyCode.RIGHT, single:true },
		{ action: "cursorLeftWord" , keyboard: [ [KeyCode.LEFT_CTRL, KeyCode.LEFT ], [KeyCode.RIGHT_CTRL, KeyCode.LEFT ] ] },
		{ action: "cursorRightWord", keyboard: [ [KeyCode.LEFT_CTRL, KeyCode.RIGHT], [KeyCode.RIGHT_CTRL, KeyCode.RIGHT] ] },
		
	];
	
	public static var actionMap = new ActionMap(
	[
		"deleteChar"  => { action:deleteChar , repeatKeyboardDefault:true },
		"backspace"   => { action:backspace  , repeatKeyboardDefault:true },
		
		"delLeft" => { action:delLeft , repeatKeyboardDefault:true },
		"delRight"=> { action:delRight, repeatKeyboardDefault:true },
		
		"tabulator"   => { action:tabulator  , repeatKeyboardDefault:true },
		
		"copyToClipboard"      => { action:copyToClipboard },
		"cutToClipboard"       => { action:cutToClipboard  },
		"pasteFromClipboard"   => { action:pasteFromClipboard, repeatKeyboardDefault:true },
		
		"shiftModifier"      => { action:shiftModifier, up:true },
		
		"selectAll"       => { action:selectAll },
		
		"undo" => { action:undo , repeatKeyboardDefault:true },
		"redo" => { action:redo , repeatKeyboardDefault:true },
		
		"cursorStart"     => { action:cursorStart },
		"cursorEnd"       => { action:cursorEnd },
		
		"cursorLeft"  => { action:cursorLeft , repeatKeyboardDefault:true },
		"cursorRight" => { action:cursorRight, repeatKeyboardDefault:true },
		"cursorLeftWord"  => { action:cursorLeftWord , repeatKeyboardDefault:true },
		"cursorRightWord" => { action:cursorRightWord, repeatKeyboardDefault:true },
	]);
	
	static inline function deleteChar(_,_) focusElement.deleteChar();
	static inline function backspace (_,_) focusElement.backspace();
	
	static inline function delLeft (_,_) focusElement.delLeft(isShift);
	static inline function delRight(_,_) focusElement.delRight(isShift);
	
	static inline function tabulator(_,_) focusElement.tabulator();
	
	static inline function copyToClipboard   (_,_) focusElement.copyToClipboard();
	static inline function cutToClipboard    (_,_) focusElement.cutToClipboard();
	static inline function pasteFromClipboard(_,_) focusElement.pasteFromClipboard();
	
	static var isShift:Bool = false;
	static inline function shiftModifier(isDown:Bool, _) isShift = isDown;
	
	static inline function selectAll(_,_) focusElement.selectAll();
	
	static inline function undo(_,_) focusElement.undo();
	static inline function redo(_,_) focusElement.redo();
	
	static inline function cursorStart(_,_) focusElement.cursorStart(isShift);
	static inline function cursorEnd  (_,_) focusElement.cursorEnd(isShift);
	
	static inline function cursorLeft (_,_) focusElement.cursorLeft(isShift);
	static inline function cursorRight(_,_) focusElement.cursorRight(isShift);
	static inline function cursorLeftWord (_,_) focusElement.cursorLeftWord(isShift);
	static inline function cursorRightWord(_,_) focusElement.cursorRightWord(isShift);	

	
}