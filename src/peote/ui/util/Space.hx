package peote.ui.util;

@:structInit
class Space 
{
	public var left  :Int = 0;
	public var top   :Int = 0;
	public var right :Int = 0;
	public var bottom:Int = 0;
	
	public inline function new(left:Int = 0, top:Int = 0, right:Int = 0, bottom:Int = 0) 
	{
		this.left   = left;
		this.top    = top;
		this.right  = right;
		this.bottom = bottom;
	}
	
}