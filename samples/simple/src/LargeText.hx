package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Color;

import peote.text.Font;

import peote.ui.PeoteUIDisplay;
import peote.ui.interactive.UITextPage;
import peote.ui.interactive.UISlider;
import peote.ui.event.PointerEvent;
import peote.ui.style.BoxStyle;
import peote.ui.style.TextLineStyle;
import peote.ui.style.SliderStyle;

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
				catch (_) trace(CallStack.toString(CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}

	// ---------------------------------------------------------------------------
	// --- before starting PeoteUIDisplay, it have to load the fonts at first  ---
	// ---------------------------------------------------------------------------

	public function startSample(window:Window)
	{
		new Font<MyFontStyle>("assets/fonts/packed/hack/config.json").load( onFontLoaded );
	}
	
	public function onFontLoaded(font:Font<MyFontStyle>) // don'T forget argument-type here !
	{					
		peoteView = new PeoteView(window);
		uiDisplay = new PeoteUIDisplay(0, 0, window.width, window.height, 0x1f1f1fff);
		peoteView.addDisplay(uiDisplay);		
						
		var fontStyle = new MyFontStyle();		
		var boxStyle = new BoxStyle(0x0e1306ff);
		
		// -------------------------------
		// ------ simple TextPage --------
		// -------------------------------		
		
		var url = "https://www.gutenberg.org/cache/epub/919/pg919.txt";		
		
		// TODO:  m a c r o - s p i c e  here to cache the data into asset-folder
		// so if it not already exists it should load it from url into evidence room
		// PLEASE help me (and Rudy -> NOT YOU <- this time!)
		
		Loader.text( url, // path
			function(loaded:Int, size:Int) trace('loading progress ' + Std.int(loaded / size * 100) + "%" , ' ($loaded / $size)'),
			function(errorMsg:String) trace('error $errorMsg'),
			function(text:String) // on load
			{
				// ------ text area ------
				
				var textPage = new UITextPage<MyFontStyle>(
					0, 0,
					{width:760, height:560, leftSpace:8, topSpace:6},
					text,
					font,
					fontStyle,
					boxStyle
				);
				uiDisplay.add(textPage);
				
				
				// ------ sliders --------
				
				var sliderStyle:SliderStyle = {
					backgroundStyle: boxStyle,
					draggerStyle: boxStyle.copy(Color.GREEN),
				};
				
				var hSlider = new UISlider(0, 562, 760, 40, sliderStyle);
				//setSliderEvents(hSlider);
				uiDisplay.add(hSlider);
				
				var vSlider = new UISlider(762, 0, 40, 560, sliderStyle);
				//setSliderEvents(vSlider);
				uiDisplay.add(vSlider);
				
				hSlider.onChange = function(uiSlider:UISlider, percent:Float) {
					//trace( 'hSlider at: ${percent*100}%' );
					textPage.xOffset = - (textPage.textWidth - 760) * percent;
					textPage.updateLayout();
				}
				
				vSlider.onChange = function(uiSlider:UISlider, percent:Float) {
					//trace( 'vSlider at: ${percent*100}%' );
					textPage.yOffset = - (textPage.textHeight - 560) * percent;
					textPage.updateLayout();
				}
				
				
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
