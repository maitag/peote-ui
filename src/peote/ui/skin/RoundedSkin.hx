package peote.ui.skin;

import peote.view.Buffer;
import peote.view.Program;
import peote.view.Element;
import peote.view.Color;

import peote.ui.UIDisplay;
import peote.ui.interactive.InteractiveElement;

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
	
	#if (!peoteui_no_masking)
	@custom("mx") @varying public var mx:Int = 0;
	@custom("my") @varying public var my:Int = 0;
	@custom("mw") @varying public var mw:Int = 0;
	@custom("mh") @varying public var mh:Int = 0;
	#end
	
	//var OPTIONS = {  };
	
	var buffer:Buffer<RoundedSkinElement>;
	
	public inline function new(uiElement:InteractiveElement, defaultStyle:RoundedStyle, buffer:Buffer<RoundedSkinElement>)
	{
		this.buffer = buffer;
		_updateStyle(uiElement, defaultStyle);
		_updateLayout(uiElement, defaultStyle);
		buffer.addElement(this);
	}
	
	public inline function update(uiElement:InteractiveElement, defaultStyle:Dynamic)
	{
		_updateStyle(uiElement, defaultStyle);
		_updateLayout(uiElement, defaultStyle);
		if (uiElement.isVisible) buffer.updateElement(this);
	}
	
	public inline function updateLayout(uiElement:InteractiveElement, defaultStyle:Dynamic)
	{
		_updateLayout(uiElement, defaultStyle);
		if (uiElement.isVisible) buffer.updateElement(this);
	}
	
	public inline function updateStyle(uiElement:InteractiveElement, defaultStyle:Dynamic)
	{
		_updateStyle(uiElement, defaultStyle);
		if (uiElement.isVisible) buffer.updateElement(this);
	}
	
	public inline function remove():Bool
	{
		buffer.removeElement(this);
		return (buffer.length() == 0);
	}
	
	inline function _updateStyle(uiElement:InteractiveElement, defaultStyle:Dynamic)
	{
		color = (uiElement.style.color!=null) ? uiElement.style.color : defaultStyle.color;
		borderColor = (uiElement.style.borderColor!=null) ? uiElement.style.borderColor : defaultStyle.borderColor;
		borderSize = (uiElement.style.borderSize!=null) ? uiElement.style.borderSize : defaultStyle.borderSize;
		borderRadius = (uiElement.style.borderRadius != null) ? uiElement.style.borderRadius : defaultStyle.borderRadius;
	}
	
	inline function _updateLayout(uiElement:InteractiveElement, defaultStyle:Dynamic)
	{
		x = uiElement.x;
		y = uiElement.y;
		w = uiElement.width;
		h = uiElement.height;
		z = uiElement.z;
		
		#if (!peoteui_no_masking)
		if (uiElement.masked) { // if some of the edges is cut by mask for scroll-area
			mx = uiElement.maskX;
			my = uiElement.maskY;
			mw = mx + uiElement.maskWidth;
			mh = my + uiElement.maskHeight;
		} else {
			mx = 0;
			my = 0;
			mw = w;
			mh = h;
		}
		#end
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
	
	public inline function addElement(uiDisplay:UIDisplay, uiElement:InteractiveElement)
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
	
	public inline function removeElement(uiDisplay:UIDisplay, uiElement:InteractiveElement)
	{
		if (uiElement.isVisible && uiElement.skinElement.remove())
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
	
	public inline function updateElement(uiDisplay:UIDisplay, uiElement:InteractiveElement)
	{
		uiElement.skinElement.update(uiElement, defaultStyle);
	}
	
	public inline function updateElementStyle(uiDisplay:UIDisplay, uiElement:InteractiveElement)
	{
		uiElement.skinElement.updateStyle(uiElement, defaultStyle);
	}
	
	public inline function updateElementLayout(uiDisplay:UIDisplay, uiElement:InteractiveElement)
	{
		uiElement.skinElement.updateLayout(uiElement, defaultStyle);
	}
	
	public inline function createDefaultStyle():Dynamic {
		return new RoundedStyle();
	}
	
	public inline function setCompatibleStyle(style:Dynamic):Dynamic {
		
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
	
	inline function createProgram(buffer:Buffer<RoundedSkinElement>):Program {
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
			"+
			#if (!peoteui_no_masking)
			"
			float rectMask (vec2 pos, vec2 size, vec4 mask)
			{
				pos = pos * size;
				if (pos.x < mask.x || pos.x > mask.z || pos.y < mask.y || pos.y > mask.w) return 0.0;
				else return 1.0;
			}
			"+
			#end
			
			#if peoteui_no_masking
			"vec4 compose (vec4 c, vec4 borderColor, float borderSize, float borderRadius)"+
			#else
			"vec4 compose (vec4 c, vec4 borderColor, float borderSize, float borderRadius, vec4 mask)"+
			#end
			"
			{
				float radius =  max(borderSize+1.0, min(borderRadius, min(vSize.x, vSize.y) / 2.0));
				
				// rounded rectangle
				//c = mix(c, vec4(0.0, 0.0, 0.0, 0.0), roundedBox(vTexCoord, vSize, borderSize, radius));				
				c = mix(c, vec4(borderColor.rgb, 0.0), roundedBox(vTexCoord, vSize, borderSize, radius));				
				// border
				c = mix(c, borderColor, roundedBorder(vTexCoord, vSize, borderSize, radius));
			"+
				#if (!peoteui_no_masking)
				"c = c * rectMask(vTexCoord, vSize, mask);"+
				#end
			"
				return c;
			}
			"
		);
		
		#if peoteui_no_masking
		program.setColorFormula('compose(color, borderColor, borderSize, borderRadius)');
		#else
		program.setColorFormula('compose(color, borderColor, borderSize, borderRadius, vec4(mx, my, mw, mh))');
		#end
		program.discardAtAlpha(0.9);
		program.alphaEnabled = true;
		return program;
	}
}