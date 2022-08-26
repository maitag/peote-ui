package peote.ui.style;

import peote.view.Color;
import peote.ui.skin.SkinType;
import peote.view.Element;
import peote.view.Program;
import peote.view.Buffer;

import peote.ui.UIDisplay;
import peote.ui.interactive.InteractiveElement;
import peote.ui.style.interfaces.Style;
import peote.ui.style.interfaces.StyleProgram;
import peote.ui.style.interfaces.StyleElement;
import peote.ui.util.Unique;

@:structInit
@:access(peote.ui)
class SimpleStyle implements Style
{
	public var color:Null<Color> = Color.GREY2;
	
	
	public function new(?color:Color) 
	{
		if (color != null) this.color = color;
	}
	
	public var id(default, never) = Unique.id;
	
	function createStyleProgram():StyleProgram {
		return new SimpleStyleProgram();
	}
	
	public inline function copy():SimpleStyle
	{
		return new SimpleStyle(color);
	}
	
}


// ------------------------------------------------------------------------
// ------------- SimpleStyle peote-view Element and Program ---------------
// ------------------------------------------------------------------------

class SimpleStyleElement implements StyleElement implements Element
{
	// from style
	@color var color:Color;
		
	@posX var x:Int=0;
	@posY var y:Int=0;	
	@sizeX @varying var w:Int=100;
	@sizeY @varying var h:Int = 100;
	@zIndex var z:Int = 0;
	
	//var OPTIONS = {  };
	
	// TODO: try to remove this and use from StyleProgram instead!
	var buffer:Buffer<SimpleStyleElement>;
	
	inline function new(uiElement:InteractiveElement, buffer:Buffer<SimpleStyleElement>)
	{
		this.buffer = buffer;
		_updateStyle(uiElement);
		_updateLayout(uiElement);
		buffer.addElement(this);
	}
	
	inline function update(uiElement:InteractiveElement)
	{
		_updateStyle(uiElement);
		_updateLayout(uiElement);
		if (uiElement.isVisible) buffer.updateElement(this);
	}
	
	inline function updateLayout(uiElement:InteractiveElement)
	{
		_updateLayout(uiElement);
		if (uiElement.isVisible) buffer.updateElement(this);
	}
	
	inline function updateStyle(uiElement:InteractiveElement)
	{
		_updateStyle(uiElement);
		if (uiElement.isVisible) buffer.updateElement(this);
	}
	
	inline function remove():Bool
	{
		buffer.removeElement(this);
		return (buffer.length() == 0);
	}
	
	inline function _updateStyle(uiElement:InteractiveElement)
	{
		color = uiElement.style.color;
	}
	
	inline function _updateLayout(uiElement:InteractiveElement)
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
}

@:access(peote.ui)
class SimpleStyleProgram implements StyleProgram
{
	var displays:Int = 0;
	
	var program:Program;
	var buffer:Buffer<SimpleStyleElement>;
	
	public function new()
	{
		var buffer = new Buffer<SimpleStyleElement>(16, 8);
		var program = createProgram(buffer);
	}

	inline function addElement(uiDisplay:UIDisplay, uiElement:InteractiveElement)
	{
/*		if (uiDisplay.skinNotAdded(displays))
		{
			displays |= 1 << uiDisplay.number;
			var buffer = new Buffer<SimpleStyleElement>(16, 8);
			var program = createProgram(buffer);
			displayProgram = program;
			displayBuffer = buffer;
			uiDisplay.addSkinProgram(program);
		}
*/		
		uiElement.styleElement = new SimpleStyleElement(uiElement, buffer);
	}
	
	// TODO: try out all here by using the buffer
	
	inline function removeElement(uiDisplay:UIDisplay, uiElement:InteractiveElement):Bool
	{
/*		if (uiElement.isVisible && uiElement.styleElement.remove()) 
		{
			// for the last element into buffer remove from displays bitmask
			displays &= ~(1 << uiDisplay.number);
			
			uiDisplay.removeSkinProgram(displayProgram);
						
			// TODO:
			//d.buffer.clear();
			//d.program.clear();
		}
*/	
		return uiElement.styleElement.remove(); // return true id it was the last element
	}
	
	inline function updateElement(uiDisplay:UIDisplay, uiElement:InteractiveElement)
	{
		uiElement.styleElement.update(uiElement);
	}
	
	inline function updateElementStyle(uiDisplay:UIDisplay, uiElement:InteractiveElement)
	{
		uiElement.styleElement.updateStyle(uiElement);
	}
	
	inline function updateElementLayout(uiDisplay:UIDisplay, uiElement:InteractiveElement)
	{
		uiElement.styleElement.updateLayout(uiElement);
	}
		
	inline function createProgram(buffer:Buffer<SimpleStyleElement>):Program {
		return new Program(buffer);
	}
}