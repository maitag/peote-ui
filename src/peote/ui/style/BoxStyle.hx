package peote.ui.style;

import peote.view.Color;
import peote.view.Element;
import peote.view.Program;
import peote.view.Buffer;

import peote.ui.interactive.Interactive;
import peote.ui.style.interfaces.Style;
import peote.ui.style.interfaces.StyleProgram;
import peote.ui.style.interfaces.StyleElement;
import peote.ui.util.Space;

@:structInit
class BoxStyle implements Style
{
	// style
	public var color:Color = Color.GREY2;
		
	// -----------------------------------------	
	//@:keep inline function createStyleProgram():BoxStyleProgram return new BoxStyleProgram();
	@:keep public inline function createStyleProgram():StyleProgram return new BoxStyleProgram();
}


// -------------------------------------------------------------------
// ---------------- peote-view Element and Program -------------------
// -------------------------------------------------------------------

class BoxStyleElement implements StyleElement implements Element
{
	// style
	@color var color:Color;
		
	// layout
	@posX public var x:Int=0;
	@posY public var y:Int=0;	
	@sizeX @varying public var w:Int=100;
	@sizeY @varying public var h:Int = 100;
	@zIndex public var z:Int = 0;
	
	//var OPTIONS = {  };
		
	public inline function new(style:Dynamic, uiElement:Interactive = null, space:Space = null)
	{
		setStyle(style);
		if (uiElement != null) setLayout(uiElement, space);
	}
	
	public inline function setStyle(style:Dynamic)
	{
		color = style.color;
	}
	
	public inline function setLayout(uiElement:Interactive, space:Space = null)
	{
		z = uiElement.z;		
		if ( 
			#if (peoteui_no_masking)
			false
			#else 
			uiElement.masked
			#end	
		) { // if some of the edges is cut by mask for scroll-area
			if (space != null) {
				x = uiElement.x + space.left + uiElement.maskX;
				y = uiElement.y + space.top + uiElement.maskY;
			} else {
				x = uiElement.x + uiElement.maskX;
				y = uiElement.y + uiElement.maskY;
			}
			w = uiElement.maskWidth;
			h = uiElement.maskHeight;
		} else {
			if (space != null) {
				x = uiElement.x + space.left;
				y = uiElement.y + space.top;
				w = uiElement.width - space.left -space.right;
				h = uiElement.height - space.top -space.bottom;
			} else {
				x = uiElement.x;
				y = uiElement.y;
				w = uiElement.width;
				h = uiElement.height;
			}
		}
	}
	
	public inline function setMasked(uiElement:Interactive, _x:Int, _y:Int, _w:Int, _h:Int, _mx:Int, _my:Int, _mw:Int, _mh:Int, _z:Int, space:Space = null)
	{
		z = _z;
		#if (peoteui_no_masking)
		if (space != null) {
			x = _x + space.left;
			y = _y + space.top;
			w = _w - space.left -space.right;
			h = _h - space.top -space.bottom;
		} else {
			x = _x;
			y = _y;
			w = _w;
			h = _h;
		}
		#else
		if (space != null) {
			x = _x + space.left + _mx;
			y = _y + space.top + _my;
		} else {
			x = _x + _mx;
			y = _y + _my;
		}
		w = _mw;
		h = _mh;
		#end		
	}
}

class BoxStyleProgram extends Program implements StyleProgram
{
	inline function getBuffer():Buffer<BoxStyleElement> return cast buffer;
	
	public inline function new()
	{
		super(new Buffer<BoxStyleElement>(1024, 1024));
	}

	public inline function createElement(uiElement:Interactive, style:Dynamic, space:Space = null):StyleElement
	{
		return new BoxStyleElement(style, uiElement, space);
	}
	
	public inline function createElementAt(uiElement:Interactive, x:Int, y:Int, w:Int, h:Int, mx:Int, my:Int, mw:Int, mh:Int, z:Int, style:Dynamic, space:Space = null):StyleElement
	{
		var e = new BoxStyleElement(style);
		e.setMasked(uiElement, x, y, w, h, mx, my, mw, mh, z, space);
		return e;
	}
	
	public inline function addElement(styleElement:StyleElement)
	{
		getBuffer().addElement(cast styleElement);
	}
	
	public inline function update(styleElement:StyleElement)
	{
		getBuffer().updateElement(cast styleElement);
	}
	
	public inline function removeElement(styleElement:StyleElement)
	{
		getBuffer().removeElement(cast styleElement);
	}
	
}
