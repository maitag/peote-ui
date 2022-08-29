package peote.ui.style;

import peote.view.Color;
import peote.ui.style.interfaces.Style;
import peote.ui.util.Unique;

//@multiSlot    // multiple slots per texture to store multiple unicode-ranges
//@multiTexture // multiple textures to store multiple unicode-ranges
@packed        // glyphes are packed into textureatlas with ttfcompile (gl3font)
@:structInit
class FontStylePacked implements Style
{

	//@global public var color:Color = Color.BLUE;
	public var color:Color = Color.GREEN;
	
	//@global public var width:Float = 10.0;
	public var width:Float = 16;
	//@global public var height:Float = 16.0;
	public var height:Float = 16;
	
	//@global public var zIndex:Int = 0;
	//public var zIndex:Int = 0;
	
	//@global public var rotation:Float = 90;
	//public var rotation:Float = 0;
	
	//@global public var tilt:Float = 0.5;
	public var tilt:Float = 0.0;
	
	//@global public var weight = 0.48;
	//public var weight:Float = 0.5;
	
	// additional spacing after each letter
	//@global public var letterSpace:Float = 2.0;
	//public var letterSpace:Float = 2.0;
	
	// -----------------------------------------
	
	static var ID:Int = Unique.id;
	inline function getID():Int return ID;
	
	public function new(id:Int = 0) {
		this.id = id;
	}
	
	public var id(default, null):Int;
	
	public var backgroundStyle:Style;
	public var selectionStyle:Style;
	public var cursorStyle:Style;

	public inline function copy():FontStylePacked
	{
		return new FontStylePacked(id);
	}
}