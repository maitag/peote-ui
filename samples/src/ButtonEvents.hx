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
import peote.ui.interactive.UIDisplay;
import peote.ui.interactive.Button;
import peote.ui.skin.Skin;
import peote.ui.skin.Style;
import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;

class ButtonEvents 
{
	var peoteView:PeoteView;
	var uiDisplay:UIDisplay;
	
	public function new(window:Window)
	{
		try {			
			peoteView = new PeoteView(window.context, window.width, window.height);
			uiDisplay = new UIDisplay(0, 0, window.width, window.height, Color.GREY1);
			peoteView.addDisplay(uiDisplay);
			
			var mySkin = new Skin();
			
			
			// Take care that every Button have its own Style if changing style-params into eventhandler
			// or alternatively create different styles for over/out/click and so on
			
			var myStyle = new Style();
			myStyle.color = Color.GREY1;
			myStyle.borderColor = Color.GREY5;
			myStyle.borderSize = 4.0;
			myStyle.borderRadius = 40.0;
			
			trace("NEW BUTTON -----");
			var b1:Button = new Button(20, 0, 200, 100, mySkin, myStyle);
			uiDisplay.add(b1);
			
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
			uiDisplay.add(b2);
			
			b2.onPointerOver = onOver.bind(Color.GREY2);
			b2.onPointerOut = onOut.bind(Color.GREY1); // only fire if there was some over before!
			b2.onPointerMove = onMove;
			b2.onPointerDown = onDown.bind(Color.RED);
			b2.onPointerUp = onUp.bind(Color.GREY5);   // only fire if there was some down before!
			b2.onPointerClick = onClick;
			
			//trace("REMOVE onPointerClick -----"); b1.onPointerClick = null;
			//uiDisplay.remove(b1);
			//uiDisplay.add(b1);
						
			//uiDisplay.update(b1);
			//uiDisplay.updateAll();
			
			// ---- Dragging -----
			
			trace("NEW SLIDER -----");			
			var myStyle3 = new Style();
			myStyle3.color = Color.GREY1;
			myStyle3.borderColor = Color.GREY5;
			myStyle3.borderSize = 3.0;
			myStyle3.borderRadius = 20.0;

			var background = new Button(10, 140, 350, 60, mySkin, myStyle2);
			uiDisplay.add(background);
			
			var dragger = new Button(10, 140, 100, 60, mySkin, myStyle3);
			dragger.onPointerOver = onOver.bind(Color.BLUE);
			dragger.onPointerOut = onOut.bind(Color.GREY1);
			
			dragger.setDragArea(10, 140, 350, 60); // x, y, width, height
			dragger.onPointerDown = function(b:Button, e:PointerEvent) {
				trace(" -----> onPointerDown", e);
				b.startDragging(e);
				b.style.color = Color.GREEN;
				b.update();
			}
			dragger.onPointerUp = function(b:Button, e:PointerEvent) {
				trace(" -----> onPointerUp", e);
				b.stopDragging(e);
				b.style.color = Color.BLUE;
				b.update();
			}
			dragger.onMouseWheel = function(b:Button, e:WheelEvent) {
				trace("MouseWheel:", e);
			}
			uiDisplay.add(dragger);

			trace("NEW DragArea -----");
			var myStyle4 = new Style();
			myStyle4.color = Color.GREY1;
			myStyle4.borderColor = Color.GREY5;
			myStyle4.borderSize = 3.0;
			myStyle4.borderRadius = 40.0;
			
			var draggAreaBG = new Button(10, 200, 350, 350, mySkin, myStyle4);
			uiDisplay.add(draggAreaBG);

			var draggArea = new Button(250, 250, 80, 80, mySkin, myStyle4);
			draggArea.setDragArea(10, 200, 350, 350); // x, y, width, height
			draggArea.onPointerDown = function(b:Button, e:PointerEvent) {
				trace(" -----> onPointerDown", e);
				b.startDragging(e);
				b.style.color = Color.GREEN;
				b.update();
			}
			draggArea.onPointerUp = function(b:Button, e:PointerEvent) {
				trace(" -----> onPointerUp", e);
				b.stopDragging(e);
				b.style.color = Color.GREY1;
				b.update();
			}
			uiDisplay.add(draggArea);

			
			// TODO: make button to switch between
			//uiDisplay.mouseEnabled = false;
			//uiDisplay.touchEnabled = false;
			peoteView.zoom = 2;

			#if android
			uiDisplay.mouseEnabled = false;
			peoteView.zoom = 3;
			#end
			
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}
	
	// --------------------------------------------------
	public inline function onOver(color:Color, button:Button, e:PointerEvent) {
		button.style.color = color;
		button.style.borderColor = Color.GREY7;
		button.update();
		trace(" -----> onPointerOver", e);
	}
	
	public inline function onOut(color:Color, button:Button, e:PointerEvent) {
		button.style.color = color;
		button.style.borderColor = Color.GREY5;
		button.update();
		trace(" -----> onPointerOut", e);
	}
	
	public inline function onMove(button:Button, e:PointerEvent) {
		trace(" -----> onPointerMove", e);
	}
	
	public inline function onDown(borderColor:Color, button:Button, e:PointerEvent) {
		button.style.borderColor = borderColor;
		//button.x += 30;
		button.update();
		trace(" -----> onPointerDown", e);
	}
	
	public inline function onUp(borderColor:Color, button:Button, e:PointerEvent) {
		button.style.borderColor = borderColor;
		button.update();
		trace(" -----> onPointerUp", e);
	}
	
	public inline function onClick(button:Button, e:PointerEvent) {
		//button.y += 30; button.update();
		trace(" -----> onPointerClick", e);
	}
	// --------------------------------------------------

	// delegate events to UIDisplay
	public inline function onMouseMove (x:Float, y:Float) uiDisplay.onMouseMove(x, y);
	public inline function onMouseDown (x:Float, y:Float, button:MouseButton) uiDisplay.onMouseDown(x, y, button);
	public inline function onMouseUp (x:Float, y:Float, button:MouseButton) uiDisplay.onMouseUp(x, y, button);
	public inline function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:MouseWheelMode) uiDisplay.onMouseWheel(deltaX, deltaY, deltaMode);
	
	public inline function onTouchMove (touch:Touch):Void uiDisplay.onTouchMove(touch);
	public inline function onTouchStart (touch:Touch):Void uiDisplay.onTouchStart(touch);
	public inline function onTouchEnd (touch:Touch):Void uiDisplay.onTouchEnd(touch);
	public inline function onTouchCancel(touch:Touch):Void uiDisplay.onTouchCancel(touch);
	
	public inline function onKeyDown (keyCode:KeyCode, modifier:KeyModifier) uiDisplay.onKeyDown(keyCode, modifier);
	public inline function onKeyUp (keyCode:KeyCode, modifier:KeyModifier):Void  uiDisplay.onKeyUp(keyCode, modifier);
	public inline function onTextInput (text:String):Void uiDisplay.onTextInput(text);
	public inline function onTextEdit(text:String, start:Int, length:Int):Void {}

	public inline function onWindowLeave () uiDisplay.onWindowLeave();
	public inline function onWindowActivate():Void {};
	
	
	
	
	public inline function render() peoteView.render();
	public inline function resize(width:Int, height:Int) peoteView.resize(width, height);
	
	public inline function onPreloadComplete ():Void { trace("preload complete"); }
	public inline function update(deltaTime:Int):Void {}
}
#end