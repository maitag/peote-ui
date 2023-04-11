package peote.ui.util;

import haxe.ds.Vector;

@:enum abstract UndoAction(Int) from Int to Int
{
	public static inline var INSERT = 0;
	public static inline var DELETE = 1;
}

@:structInit
class UndoItem 
{
	public var action:UndoAction;
	public var fromLine:Int;
	public var toLine:Int;
	public var fromPos:Int;
	public var toPos:Int;
	public var chars:String;
}

class UndoBuffer
{
	var buffer:Vector<UndoItem>;
	
	var prevItem:UndoItem;
	
	var start(default, null):Int = 0;
	var pos  (default, null):Int = 0;
	var end  (default, null):Int = 0;
	
	public function new(size:Int) 
	{
		buffer = new Vector<UndoItem>(size);
	}
	
	inline function nextPos() {
		if (++pos >= buffer.length) pos = 0;
		if (pos == start) 
			if (++start >= buffer.length) start = 0; 
	}
	
	inline function prevPos() {
		if (--pos < 0) pos = buffer.length - 1;
	}
	
	
	public inline function undo():UndoItem {
		
		if (pos == start) return null; // no more undo
		
		prevPos();
		return buffer.get(pos);
	}
	
	// add UndoActions to Buffer
	public inline function insert(fromLine:Int, toLine:Int, fromPos:Int, toPos:Int, chars:String) {
		
		if (prevItem != null && prevItem.action == UndoAction.INSERT && prevItem.toLine == fromLine && prevItem.toPos == fromPos) {
			prevItem.toLine = toLine;
			prevItem.toPos = toPos;
			prevItem.chars += chars;
			trace("INSERT CONTINUE", pos, prevItem);
		}
		else {
			prevItem = {
				action:UndoAction.INSERT,
				fromLine:fromLine,
				toLine:toLine,
				fromPos:fromPos,
				toPos:toPos,
				chars:chars
			}
			trace("INSERT", pos, prevItem);
			buffer.set( pos, prevItem);
			nextPos();
			end = pos;
		}
		
	}
	
}