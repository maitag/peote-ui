package peote.ui.style;

import peote.view.Color;
import peote.ui.style.interfaces.FontStyle;


//@multiSlot    // multiple slots per texture to store multiple unicode-ranges
//@multiTexture // multiple textures to store multiple unicode-ranges
@:structInit
class FontStyleTiled implements FontStyle
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
			
	// -------------------------------------
}