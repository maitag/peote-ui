package;

#if ButtonEvents
import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.ui.MouseWheelMode;
import lime.ui.Touch;

import peote.view.PeoteView;
import peote.view.Color;
import peote.ui.UIDisplay;
import peote.ui.widgets.Button;
import peote.ui.skin.Skin;
import peote.ui.skin.Style;

class ButtonEvents 
{
	var peoteView:PeoteView;
	var ui:UIDisplay;
	
	public function new(window:Window)
	{
		try {			
			peoteView = new PeoteView(window.context, window.width, window.height);
			ui = new UIDisplay(0, 0, window.width, window.height, Color.GREY1);
			peoteView.addDisplay(ui);
			
			var mySkin = new Skin();
			
			
			// Take care that every Button have its own Style if changing style-params into eventhandler
			// or alternatively create different styles for over/out/click and so on
			
			var myStyle = new Style();
			myStyle.color = Color.GREY1;
			myStyle.borderColor = Color.GREY5;
			myStyle.borderSize = 4.0;
			myStyle.borderRadius = 40.0;
			
			trace("NEW BUTTON -----");
			var b1:Button = new Button(20, 10, 200, 100, mySkin, myStyle);
			ui.add(b1);
			
			b1.onPointerOver = onOver.bind(Color.GREY2);
			b1.onPointerOut = onOut.bind(Color.GREY1); // only fire if there was some over before!
			b1.onPointerDown = onDown.bind(Color.YELLOW);
			b1.onPointerUp = onUp.bind(Color.GREY5);   // only fire if there was some down before!
			b1.onPointerClick = onClick;
			
			var myStyle2 = new Style();
			myStyle2.color = Color.GREY1;
			myStyle2.borderColor = Color.GREY5;
			myStyle2.borderSize = 2.0;

			trace("NEW BUTTON -----");
			var b2:Button = new Button(120, 60, 200, 100, mySkin, myStyle2);
			ui.add(b2);
			
			b2.onPointerOver = onOver.bind(Color.GREY2);
			b2.onPointerOut = onOut.bind(Color.GREY1); // only fire if there was some over before!
			b2.onPointerMove = onMove;
			b2.onPointerDown = onDown.bind(Color.RED);
			b2.onPointerUp = onUp.bind(Color.GREY5);   // only fire if there was some down before!
			b2.onPointerClick = onClick;
			
			//trace("REMOVE onPointerClick -----"); b1.onPointerClick = null;
			//ui.remove(b1);
			//ui.add(b1);
						
			//ui.update(b1);
			//ui.updateAll();
			
			// ---- Dragging -----
			
			var myStyle3 = new Style();
			myStyle3.color = Color.GREY1;
			myStyle3.borderColor = Color.GREY5;
			myStyle3.borderSize = 3.0;
			myStyle3.borderRadius = 20.0;

			trace("NEW SLIDER -----");
			var background = new Button(350, 10, 300, 30, mySkin, myStyle2);
			ui.add(background);
			
			var dragger = new Button(350, 10, 50, 30, mySkin, myStyle3);
			dragger.onPointerOver = onOver.bind(Color.BLUE);
			dragger.onPointerOut = onOut.bind(Color.GREY1);
			
			dragger.setDragArea(350, 10, 300, 30); // x, y, width, height
			dragger.onPointerDown = function(b:Button, x:Int, y:Int) {
				trace(" -----> onPointerDown", x, y);
				b.startDragging(x, y);
				b.style.color = Color.GREEN;
				b.update();
			}
			dragger.onPointerUp = function(b:Button, x:Int, y:Int) {
				trace(" -----> onPointerUp", x, y);
				b.stopDragging();
				b.style.color = Color.GREY1;
				b.update();
			}
			dragger.onMouseWheel = function(b:Button, dx:Float, dy:Float, deltaMode:MouseWheelMode) {
				trace("MouseWheel:",dx,dy, deltaMode);
			}
			ui.add(dragger);

			
			// TODO: make button to switch between
			ui.mouseEnabled = false;
			//ui.touchEnabled = false;
			
			#if android
			peoteView.zoom = 3;
			ui.mouseEnabled = false;
			#end
			
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}
	
	// --------------------------------------------------
	public function onOver(color:Color, button:Button, x:Int, y:Int) {
		button.style.color = color;
		button.style.borderColor = Color.GREY7;
		button.update();
		trace(" -----> onPointerOver", x, y);
	}
	
	public function onOut(color:Color, button:Button, x:Int, y:Int) {
		button.style.color = color;
		button.style.borderColor = Color.GREY5;
		button.update();
		trace(" -----> onPointerOut", x, y);
	}
	
	public function onMove(button:Button, x:Int, y:Int) {
		trace(" -----> onPointerMove", x, y);
	}
	
	public function onUp(borderColor:Color, button:Button, x:Int, y:Int) {
		button.style.borderColor = borderColor;
		button.update();
		trace(" -----> onPointerUp", x, y);
	}
	
	public function onDown(borderColor:Color, button:Button, x:Int, y:Int) {
		button.style.borderColor = borderColor;
		//button.x += 30;
		button.update();
		trace(" -----> onPointerDown", x, y);
	}
	
	public function onClick(button:Button, x:Int, y:Int) {
		//button.y += 30; button.update();
		trace(" -----> onPointerClick", x, y);
	}
	// --------------------------------------------------

	// delegate events to UIDisplay
	public function onMouseMove (x:Float, y:Float) ui.onMouseMove(x, y);
	public function onMouseDown (x:Float, y:Float, button:MouseButton) ui.onMouseDown(x, y, button);
	public function onMouseUp (x:Float, y:Float, button:MouseButton) ui.onMouseUp(x, y, button);
	public function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:MouseWheelMode) ui.onMouseWheel(deltaX, deltaY, deltaMode);
	
	public function onTouchStart (touch:Touch):Void ui.onTouchStart(touch);
	public function onTouchMove (touch:Touch):Void ui.onTouchMove(touch);
	public function onTouchEnd (touch:Touch):Void ui.onTouchEnd(touch);
	public function onTouchCancel(touch:Touch):Void ui.onTouchCancel(touch);
	
	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier) ui.onKeyDown(keyCode, modifier);
	public function onKeyUp (keyCode:KeyCode, modifier:KeyModifier):Void  ui.onKeyUp(keyCode, modifier);
	public function onTextInput (text:String):Void ui.onTextInput(text);
	public function onTextEdit(text:String, start:Int, length:Int):Void {}

	public function onWindowLeave () ui.onWindowLeave();
	public function onWindowActivate():Void {};
	
	
	
	
	public function render() peoteView.render();
	public function resize(width:Int, height:Int) peoteView.resize(width, height);
	
	public function onPreloadComplete ():Void { trace("preload complete"); }
	public function update(deltaTime:Int):Void {}
}
#end