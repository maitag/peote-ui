package peote.ui.skin;

import peote.view.Buffer;
import peote.view.Program;
import peote.view.Element;
import peote.view.Color;

import peote.ui.interactive.UIDisplay;
import peote.ui.interactive.UIElement;

import peote.ui.style.RoundedStyle;
import peote.ui.skin.interfaces.Skin;
import peote.ui.skin.interfaces.SkinElement;

class RoundedSkinElement implements SkinElement implements Element
{
	// from style
	@color public var color:Color;
	@color public var borderColor:Color;
	
	@custom @varying public var borderSize:Float;
	@custom @varying public var borderRadius:Float;
	
	@posX public var x:Int=0;
	@posY public var y:Int=0;
	@sizeX @varying public var w:Int=100;
	@sizeY @varying public var h:Int=100;
	@zIndex public var z:Int = 0;
	//var OPTIONS = {  };
	
	var buffer:Buffer<RoundedSkinElement>;
	
	public inline function new(uiElement:UIElement, defaultStyle:RoundedStyle, buffer:Buffer<RoundedSkinElement>)
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
		
		color = (uiElement.style.color!=null) ? uiElement.style.color : defaultStyle.color;
		borderColor = (uiElement.style.borderColor!=null) ? uiElement.style.borderColor : defaultStyle.borderColor;
		borderSize = (uiElement.style.borderSize!=null) ? uiElement.style.borderSize : defaultStyle.borderSize;
		borderRadius = (uiElement.style.borderRadius!=null) ? uiElement.style.borderRadius : defaultStyle.borderRadius;
	}
}

@:allow(peote.ui)
class RoundedSkin implements Skin
{
	public var type(default, never) = SkinType.Rounded;
	public var defaultStyle:RoundedStyle;
	
	var displays:Int = 0;

	#if (peoteui_maxDisplays == "1")
		var displayProgram:Program;
		var displayBuffer:Buffer<RoundedSkinElement>;
	#else
		var displayProgram = new haxe.ds.Vector<Program>(UIDisplay.MAX_DISPLAYS);
		var displayBuffer  = new haxe.ds.Vector<Buffer<RoundedSkinElement>>(UIDisplay.MAX_DISPLAYS);
	#end
	
	public function new(defaultStyle:RoundedStyle = null)
	{
		if (defaultStyle != null) this.defaultStyle = defaultStyle;
		else this.defaultStyle = new RoundedStyle();
	}

	public inline function notIntoDisplay(uiDisplay:UIDisplay):Bool {
		return ((displays & (1 << uiDisplay.number))==0);
	}
	
	public function addElement(uiDisplay:UIDisplay, uiElement:UIElement)
	{
		if (notIntoDisplay(uiDisplay))
		{
			displays |= 1 << uiDisplay.number;
			var buffer = new Buffer<RoundedSkinElement>(16, 8);
			var program = createProgram(buffer);
			#if (peoteui_maxDisplays == "1")
				displayProgram = program;
				displayBuffer = buffer;
			#else
				displayProgram.set(uiDisplay.number, program);
				displayBuffer.set(uiDisplay.number, buffer);
			#end
			uiDisplay.addProgram(program); // TODO: better also uiDisplay.addSkin() to let clear all skins at once from inside UIDisplay
			uiElement.skinElement = new RoundedSkinElement(uiElement, defaultStyle, buffer);
		}
		else
			#if (peoteui_maxDisplays == "1")
				uiElement.skinElement = new RoundedSkinElement(uiElement, defaultStyle, displayBuffer);
			#else
				uiElement.skinElement = new RoundedSkinElement(uiElement, defaultStyle, displayBuffer.get(uiDisplay.number));
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
	
	public function createDefaultStyle():Dynamic {
		return new RoundedStyle();
	}
	
	public function setCompatibleStyle(style:Dynamic):Dynamic {
		
		if (style == null) return defaultStyle;
		else if (style.compatibleSkins & type > 0) return style;
		else {
			return new RoundedStyle(
				(style.color != null) ? style.color : defaultStyle.color,
				(style.borderColor != null) ? style.borderColor : defaultStyle.borderColor,
				(style.borderSize != null) ? style.borderSize : defaultStyle.borderSize,
				(style.borderRadius != null) ? style.borderRadius : defaultStyle.borderRadius
			);		
		}
	}
	
	private function createProgram(buffer:Buffer<RoundedSkinElement>):Program {
		var program = new Program(buffer);
		
		// ------- ShaderStyle -------------
		
		program.injectIntoFragmentShader(
			"
			float roundedBox (vec2 pos, vec2 size, float padding, float radius)
			{
				radius -= padding;
				pos = (pos - 0.5) * size;
				size = 0.5 * size - vec2(radius, radius) - vec2(padding, padding);
				
				float d = length(max(abs(pos), size) - size) - radius;
				//return d;
				//return step(0.5, d );
				return smoothstep( 0.0, 1.0,  d );
			}
			
			float roundedBorder (vec2 pos, vec2 size, float thickness, float radius)
			{
				
				radius -= thickness / 2.0;
				pos = (pos - 0.5) * size;
				size = 0.5 * (size - vec2(thickness, thickness)) - vec2(radius, radius);
				
				float s = 0.5 / thickness * 2.0;
				
				float d = length(max(abs(pos), size) - size) - radius;				
				//return 1.0 - abs( d / thickness );
				//return 1.0 - step(0.5, abs( d / thickness ));
				return smoothstep( 0.5+s, 0.5-s, abs(d / thickness)  );
				//return smoothstep( 0.5+s, 0.5-s, abs( d / thickness ) * (1.0 + s) );
			}
			
			vec4 compose (vec4 c, vec4 borderColor, float borderSize, float borderRadius)
			{
				float radius =  max(borderSize+1.0, min(borderRadius, min(vSize.x, vSize.y) / 2.0));
				
				// rounded rectangle
				//c = mix(c, vec4(0.0, 0.0, 0.0, 0.0), roundedBox(vTexCoord, vSize, borderSize, radius));				
				c = mix(c, vec4(borderColor.rgb, 0.0), roundedBox(vTexCoord, vSize, borderSize, radius));				
				// border
				c = mix(c, borderColor, roundedBorder(vTexCoord, vSize, borderSize, radius));
				
				return c;
			}
			"
		);
		
		program.setColorFormula('compose(color, borderColor, borderSize, borderRadius)');
		program.discardAtAlpha(0.9);
		program.alphaEnabled = true;
		return program;
	}
}