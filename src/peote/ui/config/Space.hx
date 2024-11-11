package peote.ui.config;

@:structInit
class Space 
{
	public var left  :Int;
	public var top   :Int;
	public var right :Int;
	public var bottom:Int;
	
	public inline function new(left:Int = 0, top:Int = 0, right:Int = 0, bottom:Int = 0) 
	{
		this.left   = left;
		this.top    = top;
		this.right  = right;
		this.bottom = bottom;
	}
	
	public inline function copy():Space
	{
		return new Space(left, top, right, bottom);
	}
	
	public inline function setRelative(width:Int, height:Int,
		sizeW:Null<Int>, sizePercentW:Null<Float>, offsetW:Null<Int>, offsetPercentW:Null<Float>,
		sizeH:Null<Int>, sizePercentH:Null<Float>, offsetH:Null<Int>, offsetPercentH:Null<Float>) 
	{
		setRelativeWidth(width, sizeW, sizePercentW, offsetW, offsetPercentW);
		setRelativeHeight(height, sizeH, sizePercentH, offsetH, offsetPercentH);
	}
	
	public inline function setRelativeWidthOrHeight(isVertical:Bool, width:Int, height:Int, size:Null<Int>, sizePercent:Null<Float>, offset:Null<Int>, offsetPercent:Null<Float>) 
	{
		if (isVertical) setRelativeWidth(width, size, sizePercent, offset, offsetPercent);
		else setRelativeHeight(height, size, sizePercent, offset, offsetPercent);
	}
	
	public inline function setRelativeWidth(width:Int, size:Null<Int>, sizePercent:Null<Float>, offset:Null<Int>, offsetPercent:Null<Float>) 
	{
		if (size != null || sizePercent != null)
		{
			if (sizePercent != null) {
				var innerWidth = Std.int( (size == null) ? width * sizePercent : Math.max(size, width * sizePercent) );
				if (offsetPercent != null)
					left = Std.int( (width - innerWidth) * offsetPercent + ((offset != null) ? offset : 0) );
				else left = (offset == null) ? Std.int( (width - innerWidth) * 0.5) : offset;
				right = width - left - innerWidth;
			} else {
				if (offsetPercent != null)
					left = Std.int( (width - size) * offsetPercent + ((offset != null) ? offset : 0) );
				else left = (offset == null) ? Std.int( (width - size) * 0.5) : offset;
				right = width - left - size;
			}					
		}
	}
	
	public inline function setRelativeHeight(height:Int, size:Null<Int>, sizePercent:Null<Float>, offset:Null<Int>, offsetPercent:Null<Float>) 
	{
		if (size != null || sizePercent != null)
		{
			if (sizePercent != null) {
				var innerHeight = Std.int( (size == null) ? height * sizePercent : Math.max(size, height * sizePercent) );
				if (offsetPercent != null)
					top = Std.int( (height - innerHeight) * offsetPercent + ((offset != null) ? offset : 0) );
				else top = (offset == null) ? Std.int( (height - innerHeight) * 0.5) : offset;
				bottom = height - top - innerHeight;
			} else {
				if (offsetPercent != null)
					top = Std.int( (height - size) * offsetPercent + ((offset != null) ? offset : 0) );
				else top = (offset == null) ? Std.int( (height - size) * 0.5) : offset;
				bottom = height - top - size;
			}					
		}
	}
	
}