package peote.ui.style;

import peote.view.Color;
import peote.view.Element;
import peote.view.Program;
import peote.view.Buffer;

import peote.ui.interactive.InteractiveElement;
import peote.ui.style.interfaces.Style;
import peote.ui.style.interfaces.StyleID;
import peote.ui.style.interfaces.StyleProgram;
import peote.ui.style.interfaces.StyleElement;
import peote.ui.util.Unique;

@:structInit
class RoundBorderStyle implements Style implements StyleID
{	
	// style
	public var color       :Color = Color.GREY2;
	public var borderColor :Color = Color.GREY6;
	public var borderSize  :Float =  4.0;
	public var borderRadius:Float = 20.0;
	
	// -----------------------------------------	
	
	static var ID:Int = Unique.styleID;
	public inline function getID():Int return ID;
	public var id(default, null):Int = 0;
		
	public function new(
		?color       :Null<Color>,
		?borderColor :Null<Color>,
		?borderSize  :Null<Float>,
		?borderRadius:Null<Float> 
	) {
		if (color        != null) this.color        = color;		
		if (borderColor  != null) this.borderColor  = borderColor;
		if (borderSize   != null) this.borderSize   = borderSize;
		if (borderRadius != null) this.borderRadius = borderRadius;
	}
	
	static public function createById(id:Int, ?style:RoundBorderStyle,
		?color:Null<Color>,
		?borderColor :Null<Color>,
		?borderSize  :Null<Float>,
		?borderRadius:Null<Float> 
	):RoundBorderStyle {
		var newStyle = (style != null) ? style.copy(color, borderColor, borderSize, borderRadius) : new RoundBorderStyle(color, borderColor, borderSize, borderRadius);
		newStyle.id = id;
		return newStyle;
	}
	
	public inline function copy(
		?color       :Null<Color>,
		?borderColor :Null<Color>,
		?borderSize  :Null<Float>,
		?borderRadius:Null<Float> 
	):RoundBorderStyle {
		var newStyle = new RoundBorderStyle(
			(color        != null) ? color        : this.color,		
			(borderColor  != null) ? borderColor  : this.borderColor,
			(borderSize   != null) ? borderSize   : this.borderSize,
			(borderRadius != null) ? borderRadius : this.borderRadius
		);
		newStyle.id = id;
		return newStyle;
	}

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
	@posX var x:Int=0;
	@posY var y:Int=0;	
	@sizeX @varying var w:Int=100;
	@sizeY @varying var h:Int = 100;
	@zIndex var z:Int = 0;
	
	#if (!peoteui_no_masking)
	@custom("mx") @varying var mx:Int = 0;
	@custom("my") @varying var my:Int = 0;
	@custom("mw") @varying var mw:Int = 0;
	@custom("mh") @varying var mh:Int = 0;
	#end
	
	//var OPTIONS = {  };
		
	public inline function new(uiElement:InteractiveElement)
	{
		setStyle(uiElement.style);
		setLayout(uiElement);
	}
	
	inline function setStyle(style:Dynamic)
	{
		color        = style.color;
		borderColor  = style.borderColor;
		borderSize   = style.borderSize;
		borderRadius = style.borderRadius;
	}
	
	inline function setLayout(uiElement:InteractiveElement)
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

class RoundBorderStyleProgram extends Program implements StyleProgram
{
	inline function getBuffer():Buffer<RoundBorderStyleElement> return cast buffer;
	
	public function new()
	{
		super(new Buffer<RoundBorderStyleElement>(16, 8));
		
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
		//discardAtAlpha(0.9);
		alphaEnabled = true;
	}

	inline function createElement(uiElement:InteractiveElement):StyleElement
	{
		return new RoundBorderStyleElement(uiElement);
	}
	
	inline function addElement(styleElement:StyleElement)
	{
		getBuffer().addElement(cast styleElement);
	}
	
	inline function update(styleElement:StyleElement)
	{
		getBuffer().updateElement(cast styleElement);
	}
	
	inline function removeElement(styleElement:StyleElement)
	{
		getBuffer().removeElement(cast styleElement);
	}
	
}
