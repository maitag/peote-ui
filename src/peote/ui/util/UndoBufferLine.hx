package peote.ui.util;

import haxe.ds.Vector;

@:structInit
class UndoItemLine 
{
	public var action:UndoAction;
	public var fromPos:Int;
	public var toPos:Int;
	public var chars:String;
}

class UndoBufferLine
{
	var buffer:Vector<UndoItemLine>;
	
	var prevItem:UndoItemLine;
	
	var start(default, null):Int = 0;
	var pos  (default, null):Int = 0;
	var end  (default, null):Int = 0;
	
	public function new(size:Int) 
	{
		buffer = new Vector<UndoItemLine>(size+1);
	}
	
	inline function nextPos()
	{
		if (++pos >= buffer.length) pos = 0;
		if (pos == start) 
			if (++start >= buffer.length) start = 0; 
	}
	
	inline function prevPos() 
	{
		if (--pos < 0) pos = buffer.length - 1;
	}
	
	
	public inline function undo():UndoItemLine 
	{		
		if (pos == start) return null; // no more undo
		prevItem = null;
		prevPos();
		return buffer.get(pos);
	}
	
	public inline function redo():UndoItemLine
	{		
		if (pos == end) return null; // no more undo
		prevItem = null;
		var step = buffer.get(pos);
		nextPos();
		return step;
	}
	
	// add UndoActions to Buffer
	public inline function insert(fromPos:Int, toPos:Int, chars:String) 
	{		
		if (prevItem != null && prevItem.action == UndoAction.INSERT && prevItem.toPos == fromPos)
		{
			prevItem.toPos = toPos;
			prevItem.chars += chars;
			//trace("INSERT CONTINUE", pos, prevItem, prevItem.chars);
		}
		else {
			prevItem = {
				action:UndoAction.INSERT,
				fromPos:fromPos,
				toPos:toPos,
				chars:chars
			}
			//trace("INSERT", pos, prevItem, chars);
			buffer.set( pos, prevItem);
			nextPos();
			end = pos;
		}
	}
	
	public inline function delete(fromPos:Int, toPos:Int, chars:String) 
	{		
		if (prevItem != null && prevItem.action == UndoAction.DELETE &&	(prevItem.fromPos == fromPos || prevItem.fromPos == toPos) )			
		{
			if (prevItem.fromPos == fromPos) {
				prevItem.toPos += toPos-fromPos;
				prevItem.chars += chars;
			} else {
				prevItem.fromPos = fromPos;
				prevItem.chars = chars + prevItem.chars;
			}
			//trace("DELETE CONTINUE", pos, prevItem, prevItem.chars);
		}
		else {
			prevItem = {
				action:UndoAction.DELETE,
				fromPos:fromPos,
				toPos:toPos,
				chars:chars
			}
			//trace("DELETE", pos, prevItem, chars);
			buffer.set( pos, prevItem);
			nextPos();
			end = pos;
		}		
	}
	
	
}