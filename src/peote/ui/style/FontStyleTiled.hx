package peote.ui.style;

import peote.view.Color;
import peote.ui.util.Unique;
import peote.ui.style.interfaces.FontStyle;
import peote.ui.style.interfaces.StyleID;


//@multiSlot    // multiple slots per texture to store multiple unicode-ranges
//@multiTexture // multiple textures to store multiple unicode-ranges
@:structInit
class FontStyleTiled implements FontStyle implements StyleID
{
	//@global public var color:Color = Color.BLACK;
	public var color:Color = Color.BLACK;
	
	//@global public var width:Float = 16.0;
	public var width:Float = 10.0;
	//@global public var height:Float = 16.0;
	public var height:Float = 18.0;
	
	//@global public var zIndex:Int = 0;
	//public var zIndex:Int = 0;
	
	//@global public var rotation:Float = 90;
	//public var rotation:Float = 0;
	
	//@global public var tilt:Float = 0.0;
	public var tilt:Float = 0.0;
	
	// additional spacing after each letter
	//@global public var letterSpace:Float = 2.0;
	public var letterSpace:Float = 0.0;
	
	//public var bgColor:Color = Color.BLACK;
			
	// -----------------------------------------
	
	static var ID:Int = Unique.fontStyleID;
	public inline function getID():Int return ID;
	public var id(default, null):Int = 0;
		
	public function new(
		?color:Null<Color>,
		?width:Null<Float>,
		?height:Null<Float>,
		?tilt:Null<Float>,
		?letterSpace:Null<Float>
	) {
		if (color  != null) this.color  = color;
		if (width  != null) this.width  = width;
		if (height != null) this.height = height;
		if (tilt   != null) this.tilt   = tilt;
		if (letterSpace != null) this.letterSpace = letterSpace;
	}
	
	static public function createById(id:Int, ?style:FontStyleTiled,
		?color:Null<Color>,
		?width:Null<Float>,
		?height:Null<Float>,
		?tilt:Null<Float>,
		?letterSpace:Null<Float>
	):FontStyleTiled {
		var newStyle = (style != null) ? style.copy(color, width, height, tilt ,letterSpace) : new FontStyleTiled(color, width, height, tilt ,letterSpace);
		newStyle.id = id;
		return newStyle;
	}
	
	public inline function copy(
		?color:Null<Color>,
		?width:Null<Float>,
		?height:Null<Float>,
		?tilt:Null<Float>,
		?letterSpace:Null<Float>
	):FontStyleTiled {
		var newStyle = new FontStyleTiled(
			(color  != null) ? color  : this.color,		
			(width  != null) ? width  : this.width,		
			(height != null) ? height : this.height,
			(tilt   != null) ? tilt   : this.tilt,
			(letterSpace != null) ? letterSpace : this.letterSpace	
		);
		newStyle.id = id;
		return newStyle;
	}
	
}