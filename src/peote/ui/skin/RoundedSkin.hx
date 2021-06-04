package peote.ui.skin;

import peote.ui.interactive.InteractiveDisplay;
import peote.ui.interactive.InteractiveElement;
import peote.ui.skin.RoundedStyle;
import peote.ui.skin.interfaces.Skin;
import peote.ui.skin.interfaces.SkinElement;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Element;
import peote.view.Color;


@:allow(peote.ui)
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
	
	public function new(uiElement:InteractiveElement, defaultStyle:RoundedStyle) update(uiElement, defaultStyle);
	
	public inline function update(uiElement:InteractiveElement, defaultStyle:Dynamic)
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

	var displayProgBuff = new Map<InteractiveDisplay,{program:Program, buffer:Buffer<RoundedSkinElement>}>();
	
	public function new(defaultStyle:RoundedStyle = null)
	{
		if (defaultStyle != null) this.defaultStyle = defaultStyle;
		else this.defaultStyle = new RoundedStyle();
	}
	
	public function addElement(uiDisplay:InteractiveDisplay, uiElement:InteractiveElement)
	{
		var d = displayProgBuff.get(uiDisplay);
		if (d == null) {
			var buffer = new Buffer<RoundedSkinElement>(16, 8);
			d = { program: createProgram(buffer), buffer: buffer };
			displayProgBuff.set(uiDisplay, d);
			uiDisplay.addProgram(d.program);
		}		
		var skinElement = new RoundedSkinElement(uiElement, defaultStyle);
		d.buffer.addElement(skinElement);
		uiElement.skinElement = skinElement;
	}
	
	public function removeElement(uiDisplay:InteractiveDisplay, uiElement:InteractiveElement)
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
	
	public function updateElement(uiDisplay:InteractiveDisplay, uiElement:InteractiveElement)
	{
		uiElement.skinElement.update(uiElement, defaultStyle);
		var d = displayProgBuff.get(uiDisplay);
		if (d != null) d.buffer.updateElement( cast uiElement.skinElement );
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