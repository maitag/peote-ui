package peote.ui.style;

import peote.view.Color;
import peote.view.Element;
import peote.view.Program;
import peote.view.Buffer;

import peote.ui.interactive.Interactive;
import peote.ui.style.interfaces.Style;
import peote.ui.style.interfaces.StyleProgram;
import peote.ui.style.interfaces.StyleElement;
import peote.ui.config.Space;

@:structInit
class RoundBorderStyle implements Style
{	
	// style
	public var color       :Color = Color.GREY3;
	public var borderColor :Color = Color.GREY4;
	public var borderSize  :Float = 1.0;
	public var borderRadius:Float = 6.0;
	
	// -----------------------------------------	
	//@:keep inline function createStyleProgram():RoundBorderStyleProgram return new RoundBorderStyleProgram();
	@:keep public inline function createStyleProgram():StyleProgram return new RoundBorderStyleProgram();
}


// -------------------------------------------------------------------
// ---------------- peote-view Element and Program -------------------
// -------------------------------------------------------------------

class RoundBorderStyleElement implements StyleElement implements Element
{
	// style
	@color var color:Color;
	@color var borderColor:Color;	
	@custom @varying var borderSize:Float;
	@custom @varying var borderRadius:Float;
		
	// layout
	@posX public var x:Int=0;
	@posY public var y:Int=0;	
	@sizeX @varying public var w:Int=100;
	@sizeY @varying public var h:Int = 100;
	@zIndex public var z:Int = 0;
	
	#if (!peoteui_no_masking)
	@custom("mx") @varying var mx:Int = 0;
	@custom("my") @varying var my:Int = 0;
	@custom("mw") @varying var mw:Int = 0;
	@custom("mh") @varying var mh:Int = 0;
	#end
	
	//var OPTIONS = {  };
		
	public inline function new(style:Dynamic, uiElement:Interactive = null, space:Space = null)
	{
		setStyle(style);
		if (uiElement != null) setLayout(uiElement, space);
	}
	
	public inline function setStyle(style:Dynamic)
	{
		color        = style.color;
		borderColor  = style.borderColor;
		borderSize   = style.borderSize;
		borderRadius = style.borderRadius;
	}
	
	public inline function setLayout(uiElement:Interactive, space:Space = null)
	{
		z = uiElement.z;
		
		if (space != null) {
			x = uiElement.x + space.left;
			y = uiElement.y + space.top;
			w = uiElement.width - space.left - space.right;
			h = uiElement.height - space.top - space.bottom;
		} else {
			x = uiElement.x;
			y = uiElement.y;
			w = uiElement.width;
			h = uiElement.height;
		}
		
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
	
	public inline function setMasked(uiElement:Interactive, _x:Int, _y:Int, _w:Int, _h:Int, _mx:Int, _my:Int, _mw:Int, _mh:Int, _z:Int, space:Space = null)
	{
		z = _z;
		
		if (space != null) {
			x = _x + space.left;
			y = _y + space.top;
			w = _w - space.left - space.right;
			h = _h - space.top - space.bottom;
		} else {
			x = _x;
			y = _y;
			w = _w;
			h = _h;
		}
		
		#if (!peoteui_no_masking)
		mx = _mx;
		my = _my;
		mw = mx + _mw;
		mh = my + _mh;
		#end
	}
	
}

class RoundBorderStyleProgram extends Program implements StyleProgram
{
	inline function getBuffer():Buffer<RoundBorderStyleElement> return cast buffer;
	
	public function new()
	{
		super(new Buffer<RoundBorderStyleElement>(1024, 1024));
		
		// ------- ShaderStyle -------------
		
		injectIntoFragmentShader(
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
		setColorFormula('compose(color, borderColor, borderSize, borderRadius)');
		#else
		setColorFormula('compose(color, borderColor, borderSize, borderRadius, vec4(mx, my, mw, mh))');
		#end

		// TODO: make that optional!
		//discardAtAlpha(0.9);
		blendEnabled = true;
	}

	public inline function createElement(uiElement:Interactive, style:Dynamic, space:Space = null):StyleElement
	{
		return new RoundBorderStyleElement(style, uiElement, space);
	}
	
	public inline function createElementAt(uiElement:Interactive, x:Int, y:Int, w:Int, h:Int, mx:Int, my:Int, mw:Int, mh:Int, z:Int, style:Dynamic, space:Space = null):StyleElement
	{
		var e = new RoundBorderStyleElement(style);
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
