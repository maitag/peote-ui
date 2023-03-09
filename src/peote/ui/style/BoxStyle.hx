package peote.ui.style;

import peote.view.Color;
import peote.view.Element;
import peote.view.Program;
import peote.view.Buffer;

import peote.ui.interactive.Interactive;
import peote.ui.style.interfaces.Style;
import peote.ui.style.interfaces.StyleProgram;
import peote.ui.style.interfaces.StyleElement;

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
		
	public inline function new(style:Dynamic, uiElement:Interactive = null)
	{
		setStyle(style);
		if (uiElement != null) setLayout(uiElement);
	}
	
	public inline function setStyle(style:Dynamic)
	{
		color = style.color;
	}
	
	public inline function setLayout(uiElement:Interactive)
	{
		z = uiElement.z;
		
		#if (peoteui_no_masking)
		x = uiElement.x;
		y = uiElement.y;
		w = uiElement.width;
		h = uiElement.height;
		#else
		if (uiElement.masked) { // if some of the edges is cut by mask for scroll-area
			x = uiElement.x + uiElement.maskX;
			y = uiElement.y + uiElement.maskY;
			w = uiElement.maskWidth;
			h = uiElement.maskHeight;
		} else {
			x = uiElement.x;
			y = uiElement.y;
			w = uiElement.width;
			h = uiElement.height;
		}
		#end		
	}
	
	public inline function setMasked(uiElement:Interactive, _x:Int, _y:Int, _w:Int, _h:Int, _mx:Int, _my:Int, _mw:Int, _mh:Int, _z:Int)
	{
		z = _z;
		#if (peoteui_no_masking)
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		#else
		x = _x + _mx;
		y = _y + _my;
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

	public inline function createElement(uiElement:Interactive, style:Dynamic):StyleElement
	{
		return new BoxStyleElement(style, uiElement);
	}
	
	public inline function createElementAt(uiElement:Interactive, x:Int, y:Int, w:Int, h:Int, mx:Int, my:Int, mw:Int, mh:Int, z:Int, style:Dynamic):StyleElement
	{
		var e = new BoxStyleElement(style);
		e.setMasked(uiElement, x, y, w, h, mx, my, mw, mh, z);
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
