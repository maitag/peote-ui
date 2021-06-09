package peote.ui.skin;

import peote.view.Buffer;
import peote.view.Program;
import peote.view.Element;
import peote.view.Color;

import peote.ui.interactive.UIDisplay;
import peote.ui.interactive.UIElement;

import peote.ui.skin.SimpleStyle;
import peote.ui.skin.interfaces.Skin;
import peote.ui.skin.interfaces.SkinElement;

class SimpleSkinElement implements SkinElement implements Element
{
	// from style
	@color public var color:Color;
		
	@posX public var x:Int=0;
	@posY public var y:Int=0;	
	@sizeX @varying public var w:Int=100;
	@sizeY @varying public var h:Int = 100;
	@zIndex public var z:Int = 0;
	//var OPTIONS = {  };
	
	var buffer:Buffer<SimpleSkinElement>;
	
	public inline function new(uiElement:UIElement, defaultStyle:SimpleStyle, buffer:Buffer<SimpleSkinElement>)
	{
		this.buffer = buffer;
		_update(uiElement, defaultStyle);
		buffer.addElement(this);
	}
	
	public inline function update(uiElement:UIElement, defaultStyle:Dynamic)
	{
		_update(uiElement, defaultStyle);
		buffer.updateElement(this);
	}
	
	public inline function remove():Bool
	{
		buffer.removeElement(this);
		return (buffer.length() == 0);
	}
	
	inline function _update(uiElement:UIElement, defaultStyle:Dynamic)
	{
		x = uiElement.x;
		y = uiElement.y;
		w = uiElement.width;
		h = uiElement.height;
		z = uiElement.z;
		
		color = (uiElement.style.color != null) ? uiElement.style.color : defaultStyle.color;
	}
}

@:allow(peote.ui)
class SimpleSkin implements Skin
{
	public var type(default, never) = SkinType.Simple;
	public var defaultStyle:SimpleStyle;
	
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

	public inline function notIntoDisplay(uiDisplay:UIDisplay):Bool {
		return ((displays & (1 << uiDisplay.number))==0);
	}

	public function addElement(uiDisplay:UIDisplay, uiElement:UIElement)
	{
		if (notIntoDisplay(uiDisplay))
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
			uiDisplay.addProgram(program); // TODO: better also uiDisplay.addSkin() to let clear all skins at once from inside UIDisplay
			uiElement.skinElement = new SimpleSkinElement(uiElement, defaultStyle, buffer);
		}
		else
			#if (peoteui_maxDisplays == "1")
				uiElement.skinElement = new SimpleSkinElement(uiElement, defaultStyle, displayBuffer);
			#else
				uiElement.skinElement = new SimpleSkinElement(uiElement, defaultStyle, displayBuffer.get(uiDisplay.number));
			#end
	}
	
	public function removeElement(uiDisplay:UIDisplay, uiElement:UIElement)
	{
		if (uiElement.skinElement.remove()) 
		{
			// for the last element into buffer remove from displays bitmask
			displays &= ~(1 << uiDisplay.number);
			
			#if (peoteui_maxDisplays == "1")
				uiDisplay.removeProgram(displayProgram);
			#else
				uiDisplay.removeProgram(displayProgram.get(uiDisplay.number));
			#end			
						
			// TODO:
			//d.buffer.clear();
			//d.program.clear();
		}
	}
	
	public function updateElement(uiDisplay:UIDisplay, uiElement:UIElement)
	{
		uiElement.skinElement.update(uiElement, defaultStyle);
	}
	
	public function setCompatibleStyle(style:Dynamic):Dynamic {
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