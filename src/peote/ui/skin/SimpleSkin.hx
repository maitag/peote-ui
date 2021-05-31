package peote.ui.skin;

import peote.ui.interactive.UIDisplay;
import peote.ui.interactive.UIElement;
import peote.ui.skin.SimpleStyle;
import peote.ui.skin.interfaces.Skin;
import peote.ui.skin.interfaces.SkinElement;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Element;
import peote.view.Color;

@:allow(peote.ui)
class SimpleSkinElement implements SkinElement implements Element
{
	// from style
	@color public var color:Color;
		
	@posX public var x:Int=0;
	@posY public var y:Int=0;	
	@sizeX @varying public var w:Int=100;
	@sizeY @varying public var h:Int=100;
	@zIndex public var z:Int = 0;
	//var OPTIONS = {  };
	
	public function new(uiElement:UIElement, defaultStyle:SimpleStyle) update(uiElement, defaultStyle);
	
	public inline function update(uiElement:UIElement, defaultStyle:Dynamic)
	{
		x = uiElement.x;
		y = uiElement.y;
		w = uiElement.width;
		h = uiElement.height;
		z = uiElement.z;
		
		color = (uiElement.style.color!=null) ? uiElement.style.color : defaultStyle.color;		
	}
}

@:allow(peote.ui)
class SimpleSkin implements Skin
{
	public var type(default, never) = SkinType.Simple;
	public var defaultStyle:SimpleStyle;
	
	var displayProgBuff = new Map<UIDisplay,{program:Program, buffer:Buffer<SimpleSkinElement>}>();
	
	public function new(defaultStyle:SimpleStyle = null)
	{
		if (defaultStyle != null) this.defaultStyle = defaultStyle;
		else this.defaultStyle = new SimpleStyle();
	}
	
	public function addElement(uiDisplay:UIDisplay, uiElement:UIElement)
	{
		var d = displayProgBuff.get(uiDisplay);
		if (d == null) {
			var buffer = new Buffer<SimpleSkinElement>(16, 8);
			d = { program: createProgram(buffer), buffer: buffer };
			displayProgBuff.set(uiDisplay, d);
			uiDisplay.addProgram(d.program);
		}		
		var skinElement = new SimpleSkinElement(uiElement, defaultStyle);
		d.buffer.addElement(skinElement);
		uiElement.skinElement = skinElement;
	}
	
	public function removeElement(uiDisplay:UIDisplay, uiElement:UIElement)
	{
		var d = displayProgBuff.get(uiDisplay);
		if (d != null) {
			d.buffer.removeElement( cast uiElement.skinElement );
			if (d.buffer.length() == 0) {
				uiDisplay.removeProgram(d.program);
				trace("ui-skin: clear buffer and program");
				// TODO:
				//d.buffer.clear();
				//d.program.clear();
				displayProgBuff.remove(uiDisplay);
			}
		} else throw("Error: can not removeElement() because it is not added!"); //TODO: this should never be thrown
		
	}
	
	public function updateElement(uiDisplay:UIDisplay, uiElement:UIElement)
	{
		uiElement.skinElement.update(uiElement, defaultStyle);
		var d = displayProgBuff.get(uiDisplay);
		if (d != null) d.buffer.updateElement( cast uiElement.skinElement );		
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
	
	private function createProgram(buffer:Buffer<SimpleSkinElement>):Program {
		return new Program(buffer);
	}
}