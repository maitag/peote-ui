package peote.ui.skin;

import peote.view.Buffer;
import peote.view.Program;
import peote.view.Element;
import peote.view.Color;

import peote.ui.UIDisplay;
import peote.ui.interactive.InteractiveElement;

import peote.ui.style.SimpleStyle;
import peote.ui.skin.interfaces.Skin;
import peote.ui.skin.interfaces.SkinElement;


class SimpleSkinElement implements SkinElement implements Element
{
	// from style
	@color var color:Color;
		
	@posX var x:Int=0;
	@posY var y:Int=0;	
	@sizeX @varying var w:Int=100;
	@sizeY @varying var h:Int = 100;
	@zIndex var z:Int = 0;
	
	//var OPTIONS = {  };
	
	var buffer:Buffer<SimpleSkinElement>;
	
	inline function new(uiElement:InteractiveElement, defaultStyle:SimpleStyle, buffer:Buffer<SimpleSkinElement>)
	{
		this.buffer = buffer;
		_updateStyle(uiElement, defaultStyle);
		_updateLayout(uiElement, defaultStyle);
		buffer.addElement(this);
	}
	
	inline function update(uiElement:InteractiveElement, defaultStyle:Dynamic)
	{
		_updateStyle(uiElement, defaultStyle);
		_updateLayout(uiElement, defaultStyle);
		if (uiElement.isVisible) buffer.updateElement(this);
	}
	
	inline function updateLayout(uiElement:InteractiveElement, defaultStyle:Dynamic)
	{
		_updateLayout(uiElement, defaultStyle);
		if (uiElement.isVisible) buffer.updateElement(this);
	}
	
	inline function updateStyle(uiElement:InteractiveElement, defaultStyle:Dynamic)
	{
		_updateStyle(uiElement, defaultStyle);
		if (uiElement.isVisible) buffer.updateElement(this);
	}
	
	inline function remove():Bool
	{
		buffer.removeElement(this);
		return (buffer.length() == 0);
	}
	
	inline function _updateStyle(uiElement:InteractiveElement, defaultStyle:Dynamic)
	{
		color = (uiElement.style.color != null) ? uiElement.style.color : defaultStyle.color;
	}
	
	inline function _updateLayout(uiElement:InteractiveElement, defaultStyle:Dynamic)
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

@:access(peote.ui.skin)
class SimpleSkin implements Skin
{
	public var type(default, never) = SkinType.Simple;
	
	var defaultStyle:SimpleStyle;	
	var displays:Int = 0;
	
	#if (peoteui_maxDisplays == "1")
		var displayProgram:Program;
		var displayBuffer:Buffer<SimpleSkinElement>;
	#else
		var displayProgram = new haxe.ds.Vector<Program>(UIDisplay.MAX_DISPLAYS);
		var displayBuffer  = new haxe.ds.Vector<Buffer<SimpleSkinElement>>(UIDisplay.MAX_DISPLAYS);
	#end
	
	public function new(defaultStyle:SimpleStyle = null)
	{
		if (defaultStyle != null) this.defaultStyle = defaultStyle;
		else this.defaultStyle = new SimpleStyle();
	}

	inline function addElement(uiDisplay:UIDisplay, uiElement:InteractiveElement)
	{
		if (uiDisplay.skinNotAdded(displays))
		{
			displays |= 1 << uiDisplay.number;
			var buffer = new Buffer<SimpleSkinElement>(16, 8);
			var program = createProgram(buffer);
			#if (peoteui_maxDisplays == "1")
				displayProgram = program;
				displayBuffer = buffer;
			#else
				displayProgram.set(uiDisplay.number, program);
				displayBuffer.set(uiDisplay.number, buffer);
			#end
			uiDisplay.addSkinProgram(program);
			uiElement.skinElement = new SimpleSkinElement(uiElement, defaultStyle, buffer);
		}
		else
			#if (peoteui_maxDisplays == "1")
				uiElement.skinElement = new SimpleSkinElement(uiElement, defaultStyle, displayBuffer);
			#else
				uiElement.skinElement = new SimpleSkinElement(uiElement, defaultStyle, displayBuffer.get(uiDisplay.number));
			#end
	}
	
	inline function removeElement(uiDisplay:UIDisplay, uiElement:InteractiveElement)
	{
		if (uiElement.isVisible && uiElement.skinElement.remove()) 
		{
			// for the last element into buffer remove from displays bitmask
			displays &= ~(1 << uiDisplay.number);
			
			#if (peoteui_maxDisplays == "1")
				uiDisplay.removeSkinProgram(displayProgram);
			#else
				uiDisplay.removeSkinProgram(displayProgram.get(uiDisplay.number));
			#end			
						
			// TODO:
			//d.buffer.clear();
			//d.program.clear();
		}
	}
	
	inline function updateElement(uiDisplay:UIDisplay, uiElement:InteractiveElement)
	{
		uiElement.skinElement.update(uiElement, defaultStyle);
	}
	
	inline function updateElementStyle(uiDisplay:UIDisplay, uiElement:InteractiveElement)
	{
		uiElement.skinElement.updateStyle(uiElement, defaultStyle);
	}
	
	inline function updateElementLayout(uiDisplay:UIDisplay, uiElement:InteractiveElement)
	{
		uiElement.skinElement.updateLayout(uiElement, defaultStyle);
	}
	
	inline function setCompatibleStyle(style:Dynamic):Dynamic {
		if (style == null) return defaultStyle;
		else if (style.compatibleSkins & type > 0) return style;
		else {
			return new SimpleStyle(
				(style.color != null) ? style.color : defaultStyle.color
			);			
		}
	}
	
	inline function createProgram(buffer:Buffer<SimpleSkinElement>):Program {
		return new Program(buffer);
	}
}