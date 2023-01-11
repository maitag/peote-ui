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
import peote.ui.style.SliderStyle;
import peote.ui.style.TextStyle;

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
		//new Font<MyFontStyle>("assets/fonts/tiled/hack_ascii.json").load( onFontLoaded );
	}
	
	public function onFontLoaded(font:Font<MyFontStyle>) // don'T forget argument-type here !
	{					
		peoteView = new PeoteView(window);
		uiDisplay = new PeoteUIDisplay(0, 0, window.width, window.height, 0x1f1f1fff);
		peoteView.addDisplay(uiDisplay);		
						
		var fontStyle = new MyFontStyle();		
		var boxStyle = new BoxStyle(0x0e1306ff);
		var textStyle:TextStyle = {
			backgroundStyle:boxStyle,
			selectionStyle:BoxStyle.createById(1, Color.GREY3), // new ID for new Layer
			cursorStyle:BoxStyle.createById(2, Color.RED)       // new ID for new Layer
		}
		
		// -------------------------------
		// ------ simple TextPage --------
		// -------------------------------		
		
		var assetPath = AssetMacro.wget(
			"https://www.gutenberg.org/cache/epub/919/pg919.txt", "assets/testdata/spinoza-ethic-I.txt"
			//"https://ia800308.us.archive.org/10/items/SartreLaNause1974/Sartre%20-%20La%20naus%C3%A9e%20-%201974_djvu.txt", "assets/testdata/satre-la-nausee.txt"
		);
		
		Loader.text( assetPath,
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
					textStyle //boxStyle
				);
				// set events
				textPage.onPointerDown = function(t:UITextPage<MyFontStyle>, e:PointerEvent) {
					t.setInputFocus(e, true);			
					//t.startSelection(e);
				}
				textPage.onPointerUp = function(t:UITextPage<MyFontStyle>, e:PointerEvent) {
					//t.stopSelection(e);
				}
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
