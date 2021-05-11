package;

#if WidgetLayout

import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.ui.MouseWheelMode;
import lime.ui.Touch;

import peote.view.PeoteView;
import peote.view.Color;

import peote.ui.skin.Skin;
import peote.ui.skin.Style;

import peote.ui.PeoteUI;
import peote.ui.widget.*;

import peote.layout.Size;


class WidgetLayout 
{
	var peoteView:PeoteView;
	var mySkin = new Skin();
		
	var ui:PeoteUI;
	
	public function new(window:Window)
	{
		peoteView = new PeoteView(window.context, window.width, window.height);		
		
		var mySkin = new Skin();
		
		var myStyle = new Style();
		myStyle.color = Color.GREY1;
		myStyle.borderColor = Color.GREY5;
		myStyle.borderSize = 4.0;
		myStyle.borderRadius = 40.0;

		
		ui = new PeoteUI({
			left:10,
			right:10,
		},
		[
			
			// later into widget -> new LabelButton()
/*			new Box(
			{
				//onPointerOver:onOver.bind(Color.BLUE),
				onPointerClick: function(uiElement:UIElement, e:PointerEvent) {
					uiElement.child[0].style.color = Color.RED;
				},
				
			},
			[
				new TextLine(),
			]),
*/		
		
		
/*			// later into widget -> new VScrollArea()
			new HBox(
			[
				new VScroll(),
				new VSlider({width:30}),
			]),
*/			
		]);
		
		ui.init();
		ui.update(peoteView.width, peoteView.height);
		peoteView.addDisplay(ui);
	}

	// --------------------------------------------------
/*	public inline function onOver(color:Color, uiElement:UIElement, e:PointerEvent) {
		uiElement.style.color = color;
		uiElement.style.borderColor = Color.GREY7;
		uiElement.updateStyle();
		//uiElement.updateLayout();
		trace(" -----> onPointerOver", e);
	}
*/
	// ----------------------------------------
	// -------------- events ------------------
	// ----------------------------------------
	public inline function render() peoteView.render();
	public inline function resize(width:Int, height:Int) {
		peoteView.resize(width, height);
		// todo: peoteUi.resize
		ui.update(width, height);
	}
	
	// delegate events to UIDisplay
	public inline function onMouseMove (x:Float, y:Float) ui.onMouseMove(x, y);
	public inline function onMouseDown (x:Float, y:Float, button:MouseButton) {}//ui.onMouseDown(x, y, button);
	public inline function onMouseUp (x:Float, y:Float, button:MouseButton) {}//ui.onMouseUp(x, y, button);
	public inline function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:MouseWheelMode) {}//ui.onMouseWheel(deltaX, deltaY, deltaMode);
	
	public inline function onTouchMove (touch:Touch):Void {}//ui.onTouchMove(touch);
	public inline function onTouchStart (touch:Touch):Void {}//ui.onTouchStart(touch);
	public inline function onTouchEnd (touch:Touch):Void {}//ui.onTouchEnd(touch);
	public inline function onTouchCancel(touch:Touch):Void {}//ui.onTouchCancel(touch);
	
	public inline function onKeyDown (keyCode:KeyCode, modifier:KeyModifier) {}//ui.onKeyDown(keyCode, modifier);
	public inline function onKeyUp (keyCode:KeyCode, modifier:KeyModifier):Void  {}//ui.onKeyUp(keyCode, modifier);
	public inline function onTextInput (text:String):Void {}//ui.onTextInput(text);
	public inline function onTextEdit(text:String, start:Int, length:Int):Void {}

	public inline function onWindowLeave () {}//ui.onWindowLeave();
	public inline function onWindowActivate():Void {};
	
	
	public inline function onPreloadComplete ():Void { trace("preload complete"); }
	public inline function update(deltaTime:Int):Void {}
}

#end