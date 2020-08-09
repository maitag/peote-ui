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
			ui = new UIDisplay(20, 10, window.width, window.height, Color.GREY1);
			peoteView.addDisplay(ui);
			
			var mySkin = new Skin();
			
			var myStyle = new Style();
			myStyle.color = Color.GREY1;
			myStyle.borderColor = Color.GREY5;
			myStyle.borderSize = 4.0;
			myStyle.borderRadius = 40.0;
			
			trace("NEW BUTTON -----");
			var b1:Button = new Button(20, 10, 200, 100, mySkin, myStyle);
			ui.add(b1);
			
			b1.onMouseOver = onOver.bind(Color.GREY2);
			b1.onMouseOut = onOut.bind(Color.GREY1);
			b1.onMouseUp = onUp.bind(Color.GREY5);
			b1.onMouseDown = onDown.bind(Color.YELLOW);
			b1.onMouseClick = onClick;
			
			var myStyle2 = new Style();
			myStyle2.color = Color.GREY1;
			myStyle2.borderColor = Color.GREY5;
			myStyle2.borderSize = 2.0;

			trace("NEW BUTTON -----");
			var b2:Button = new Button(120, 60, 200, 100, mySkin, myStyle2);
			ui.add(b2);
			
			b2.onMouseOver = onOver.bind(Color.GREY2);
			b2.onMouseOut = onOut.bind(Color.GREY1);
			b2.onMouseMove = onMove;
			b2.onMouseUp = onUp.bind(Color.GREY5);
			b2.onMouseDown = onDown.bind(Color.RED);
			b2.onMouseClick = onClick;
			
			//trace("REMOVE onMouseClick -----"); b1.onMouseClick = null;	
			//ui.remove(b1);
			//ui.add(b1);
						
			//ui.update(b1);
			//ui.updateAll();
			
			// ---- Dragging -----
			
			trace("NEW SLIDER -----");
			var background = new Button(350, 10, 300, 30, mySkin, myStyle2);
			ui.add(background);
			
			var dragger = new Button(350, 10, 50, 30, mySkin, myStyle);
			dragger.onMouseOver = onOver.bind(Color.GREY2);
			dragger.onMouseOut = onOut.bind(Color.GREY1);
			
			dragger.setDragArea(350, 10, 300, 30); // x, y, width, height
			dragger.onMouseDown = function(b:Button, x:Int, y:Int) {
				b.startDragging(x, y);
				//b.style.color = Color.RED;
				//b.update();
			}
			dragger.onMouseUp = function(b:Button, x:Int, y:Int) {
				b.stopDragging();
			}
			dragger.onMouseWheel = function(b:Button, dx:Float, dy:Float, deltaMode:MouseWheelMode) {
				trace("MouseWheel:",dx,dy, deltaMode);
			}
			ui.add(dragger);

			
			
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}
	
	// --------------------------------------------------
	public function onOver(color:Color, button:Button, x:Int, y:Int) {
		button.style.color = color;
		button.style.borderColor = Color.GREY7;
		button.update();
		trace(" -----> onMouseOver", x, y);
	}
	
	public function onOut(color:Color, button:Button, x:Int, y:Int) {
		button.style.color = color;
		button.style.borderColor = Color.GREY5;
		button.update();
		trace(" -----> onMouseOut", x, y);
	}
	
	public function onMove(button:Button, x:Int, y:Int) {
		trace(" -----> onMouseMove", x, y);
	}
	
	public function onUp(borderColor:Color, button:Button, x:Int, y:Int) {
		button.style.borderColor = borderColor;
		button.update();
		trace(" -----> onMouseUp", x, y);
	}
	
	public function onDown(borderColor:Color, button:Button, x:Int, y:Int) {
		button.style.borderColor = borderColor;
		//button.x += 30;
		button.update();
		trace(" -----> onMouseDown", x, y);
	}
	
	public function onClick(button:Button, x:Int, y:Int) {
		//button.y += 30; button.update();
		trace(" -----> onMouseClick", x, y);
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