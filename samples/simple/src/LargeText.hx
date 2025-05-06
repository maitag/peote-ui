package;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Color;

import peote.text.Font;

import peote.ui.PeoteUIDisplay;
import peote.ui.interactive.*;
import peote.ui.style.*;
import peote.ui.config.*;
import peote.ui.event.*;

import peote.ui.style.interfaces.FontStyle;

import utils.Loader;

// ------------------------------------------
// --- using a custom FontStyle here --------
// ------------------------------------------

@packed // this is need for ttfcompile fonts! (Delta Lucas https://github.com/deltaluca/gl3font#ttfcompile)
@:structInit
class MyFontStyle implements FontStyle
{
	public var color:Color = Color.GREEN;
	public var width:Float = 24;
	public var height:Float = 24;
	@global public var weight = 0.5; //0.49 <- more thickness (only for ttfcompiled fonts!)
}


/*@:structInit
class MyFontStyle implements FontStyle
{
	@global public var color:Color = Color.GREEN;
	@global public var width:Float = 10;
	@global public var height:Float = 17;
	@global public var weight = 0.5; //0.49 <- more thickness (only for ttfcompiled fonts!)
}
*/

// ------------------------------------
// -------- application start  --------
// ------------------------------------

class LargeText extends Application
{
	var peoteView:PeoteView;
	var uiDisplay:PeoteUIDisplay;
	
	override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try startSample(window)
				catch (_) trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}

	// ---------------------------------------------------------------------------
	// --- before starting PeoteUIDisplay, it have to load the fonts at first  ---
	// ---------------------------------------------------------------------------

	public function startSample(window:Window)
	{
		new Font<MyFontStyle>("assets/fonts/packed/hack/config.json").load( onFontLoaded );
		//new Font<MyFontStyle>("assets/fonts/tiled/hack_ascii.json").load( onFontLoaded );
	}
	
	public function onFontLoaded(font:Font<MyFontStyle>) // don'T forget argument-type here !
	{					
		peoteView = new PeoteView(window);
		uiDisplay = new PeoteUIDisplay(0, 0, window.width, window.height, 0x1f1f1fff);
		peoteView.addDisplay(uiDisplay);
		
		var fontStyle = new MyFontStyle();		
		var boxStyle = new BoxStyle(0x0e1306ff);
		var textConfig:TextConfig = {
			backgroundStyle:boxStyle,
			selectionStyle:BoxStyle.createById(1, 0x226c11ff), // new ID for new Layer
			cursorStyle:BoxStyle.createById(2, Color.RED),     // new ID for new Layer
			textSpace:{ left:8, right:8, top:6, bottom:6 }
		}
		
		// -------------------------------
		// ------ simple TextPage --------
		// -------------------------------		
		
		var assetPath = AssetMacro.wget(
			"https://www.gutenberg.org/files/55108/55108-0.txt", "assets/testdata/hegel-scienceOfLogic.txt"
			// "https://www.gutenberg.org/cache/epub/919/pg919.txt", "assets/testdata/spinoza-ethic-I.txt"
			// "https://ia800308.us.archive.org/10/items/SartreLaNause1974/Sartre%20-%20La%20naus%C3%A9e%20-%201974_djvu.txt", "assets/testdata/satre-la-nausee.txt"
		);
		
		Loader.text( assetPath,
			function(loaded:Int, size:Int) trace('loading progress ' + Std.int(loaded / size * 100) + "%" , ' ($loaded / $size)'),
			function(errorMsg:String) trace('error $errorMsg'),
			function(text:String) // on load
			{
				// ------ text area ------
				
				var textPage = new UITextPage<MyFontStyle>(
					0, 0,
					uiDisplay.width  - 30,
					uiDisplay.height - 30,
					text,
					font, fontStyle,
					textConfig
				);
				
				// set events
				textPage.onPointerDown = function(t:UITextPage<MyFontStyle>, e:PointerEvent) {
					//t.setInputFocus(e, true);			
					t.setInputFocus(e);			
					t.startSelection(e);
				}
				textPage.onPointerUp = function(t:UITextPage<MyFontStyle>, e:PointerEvent) {
					t.stopSelection(e);
				}
				
				uiDisplay.add(textPage);
				
				
				// ------ sliders --------
				
				var sliderConfig:SliderConfig = {
					backgroundStyle: boxStyle.copy(0x123107ff),
					draggerStyle: boxStyle.copy(0x227111ff),
					draggerLength: 30,
				};
				
				var hSlider = new UISlider(0, uiDisplay.height-30, uiDisplay.width - 30, 30, sliderConfig);
				uiDisplay.add(hSlider);
				
				var vSlider = new UISlider(uiDisplay.width - 30, 0, 30, uiDisplay.height - 30, sliderConfig);
				uiDisplay.add(vSlider);
				
				// mousewheel events
				hSlider.onMouseWheel = (_, e:WheelEvent) -> hSlider.setWheelDelta( e.deltaY );
				vSlider.onMouseWheel = (_, e:WheelEvent) -> vSlider.setWheelDelta( e.deltaY );
				textPage.onMouseWheel = (_, e:WheelEvent) -> vSlider.setDelta( ((e.deltaY > 0) ? 1 : -1 ) * 80.0 );
				
				// -----------------------------------------------------------------------
				
				// resize handler
				peoteView.onResize = (width:Int, height:Int) -> {
					uiDisplay.width = width;
					uiDisplay.height = height;
					
					textPage.height = uiDisplay.height - 30;
					textPage.width  = uiDisplay.width  - 30;
					textPage.updateLayout();
					
					hSlider.top = textPage.bottom;
					hSlider.width = textPage.width;
					hSlider.updateLayout();
					
					vSlider.left = textPage.right;
					vSlider.height = textPage.height;
					vSlider.updateLayout();
				};
				
				// --------------------------------------------------------
				
				// bindings for sliders _onChange and textPage-events
				
				textPage.bindHSlider(hSlider); // _onResizeWidth, _onResizeTextWidth, _onChangeXOffset
				textPage.bindVSlider(vSlider); // _onResizeHeight, _onResizeTextHeight, _onChangeYOffset
												
/*				// all here automatic after binding textpage to sliders
				
				hSlider.setRange( 0, Math.min(0, textPage.width  - textPage.leftSpace - textPage.rightSpace  - textPage.textWidth ), (textPage.width  - textPage.leftSpace - textPage.rightSpace )  / textPage.textWidth  , false, false );
				vSlider.setRange( 0, Math.min(0, textPage.height - textPage.topSpace  - textPage.bottomSpace - textPage.textHeight), (textPage.height - textPage.topSpace  - textPage.bottomSpace)  / textPage.textHeight , false, false);
				
				hSlider.onChange = function(uiSlider:UISlider, value:Float, percent:Float) {
					textPage.setXOffset(value);
				}
				vSlider.onChange = function(uiSlider:UISlider, value:Float, percent:Float) {
					textPage.setYOffset(value);
				}
				
				textPage.onResizeWidth = textPage.onResizeTextWidth = (_, width:Float, deltaWidth:Float) -> {
					hSlider.setRange( 0, Math.min(0, textPage.width  - textPage.leftSpace - textPage.rightSpace - textPage.textWidth ), (textPage.width  - textPage.leftSpace - textPage.rightSpace )  / textPage.textWidth  , true, false );
				}
				textPage.onResizeHeight = textPage.onResizeTextHeight = (_, height:Float, deltaHeight:Float) -> {
					vSlider.setRange( 0, Math.min(0, textPage.height - textPage.topSpace  - textPage.bottomSpace - textPage.textHeight), (textPage.height - textPage.topSpace  - textPage.bottomSpace)  / textPage.textHeight , true, false);
				}
				
				textPage.onChangeXOffset = (_, xOffset:Float, deltaXOffset:Float) -> {
					hSlider.setValue( xOffset);
				}
				textPage.onChangeYOffset = (_, yOffset:Float, deltaYOffset:Float) -> {
					vSlider.setValue( yOffset);
				}
*/				
				
			}
		);				
		
		
		
		
		// ------------------------------
		// ------------------------------
		// ------------------------------
		
		#if android
		uiDisplay.mouseEnabled = false;
		peoteView.zoom = 3;
		#end
		
		// TODO: set what events to register (mouse, touch, keyboard ...)
		PeoteUIDisplay.registerEvents(window);

	}
	
}
