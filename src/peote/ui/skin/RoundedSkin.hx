package peote.ui.skin;

import peote.ui.interactive.UIDisplay;
import peote.ui.interactive.UIElement;
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
	
	public function new(uiElement:UIElement) update(uiElement);
	
	public inline function update(uiElement:UIElement)
	{
		x = uiElement.x;
		y = uiElement.y;
		w = uiElement.width;
		h = uiElement.height;
		z = uiElement.z;
		color = uiElement.style.color;
		borderColor = uiElement.style.borderColor;
		borderSize = uiElement.style.borderSize;
		borderRadius = uiElement.style.borderRadius;
	}
}

@:allow(peote.ui)
class RoundedSkin implements Skin
{
	var displayProgBuff = new Map<UIDisplay,{program:Program, buffer:Buffer<RoundedSkinElement>}>();
	
	public function new()
	{
	}
	
	public function addElement(uiDisplay:UIDisplay, uiElement:UIElement)
	{
		var d = displayProgBuff.get(uiDisplay);
		if (d == null) {
			var buffer = new Buffer<RoundedSkinElement>(16, 8);
			d = { program: createProgram(buffer), buffer: buffer };
			displayProgBuff.set(uiDisplay, d);
			uiDisplay.addProgram(d.program);
		}		
		var skinElement = new RoundedSkinElement(uiElement);
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
		var d = displayProgBuff.get(uiDisplay);
		if (d != null) d.buffer.updateElement( cast uiElement.skinElement );
	}
	
	public function createDefaultStyle():Style {
		return new Style();
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