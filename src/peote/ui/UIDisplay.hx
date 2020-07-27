package peote.ui;

import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import peote.ui.widgets.Pickable;
import peote.ui.widgets.UIElement;
import peote.view.PeoteGL;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;


@:allow(peote.ui)
class UIDisplay extends Display 
{
	var uiElements:Array<UIElement>;
	
	var overBuffer:Buffer<Pickable>;
	var overProgram:Program;
	
	var clickBuffer:Buffer<Pickable>;
	var clickProgram:Program;
	
	var lastOverIndex:Int = -1;
	var lastDownIndex:Int = -1;
	
	//var skins:Array<Skin>; // TODO: no references
	
	var draggingElements:Array<UIElement>;

	public function new(x:Int, y:Int, width:Int, height:Int, color:Color=0x00000000) 
	{
		super(x, y, width, height, color);
		
		// elements for mouseOver/Out ----------------------
		overBuffer = new Buffer<Pickable>(16, 8); // TODO: fill with constants
		overProgram = new Program(overBuffer);
				
		// elements for mouseDown/Up ----------------------
		clickBuffer = new Buffer<Pickable>(16,8); // TODO: fill with constants
		clickProgram = new Program(clickBuffer);
	
		uiElements = new Array<UIElement>();
		draggingElements = new Array<UIElement>();
		//skins = new Array<Skin>();
	}
	
	override private function setNewGLContext(newGl:PeoteGL)
	{
		super.setNewGLContext(newGl);
		overProgram.setNewGLContext(newGl);
		clickProgram.setNewGLContext(newGl);
	}
	
	public function add(uiElement:UIElement):Void {
		//TODO
		uiElements.push(uiElement);
		uiElement.onAddToDisplay(this);
	}
	
	public function remove(uiElement:UIElement):Void {
		//TODO
		uiElements.remove(uiElement);
		uiElement.onRemoveFromDisplay(this);
	}
	
	public function removeAll():Void {
		//TODO
	}
	
	public function update(uiElement:UIElement):Void {
		uiElement.update();
		//TODO
	}
	
	public function updateAll():Void {
		for (uiElement in uiElements)
			uiElement.update();
		//TODO
	}
	
	// ----------------------------------------
	public function startDragging(uiElement:UIElement):Void {
		if (! uiElement.isDragging) {
			uiElement.isDragging = true;
			draggingElements.push(uiElement);
		} //TODO: #if peoteui_debug -> else WARNING: already in dragmode
	}

	public function stopDragging(uiElement:UIElement):Void {
		if (uiElement.isDragging) {
			uiElement.isDragging = false;
			draggingElements.remove(uiElement);
		} //TODO: #if peoteui_debug -> else WARNING: is not into dragmode
	}

	
	
	// ----------------------------------------
	
	// TODO: onTouch, touchpoints
	
	public function onMouseMove (peoteView:PeoteView, x:Float, y:Float):Void
	{
		try {
			var pickedElement = peoteView.getElementAt(x, y, this, overProgram);
			if (pickedElement != lastOverIndex) {
				// TODO: bubbling only for container-elements
				// so no over and out to the parent-elements if bubbling is enabled into a child!
				if (lastOverIndex >= 0) 
					overBuffer.getElement(lastOverIndex).uiElement.mouseOut( Std.int(x), Std.int(y) );
				if (pickedElement >= 0) 
					overBuffer.getElement(pickedElement).uiElement.mouseOver(  Std.int(x), Std.int(y) );
				lastOverIndex = pickedElement;
			}
			// Dragging
			for (uiElement in draggingElements) {
				uiElement.dragTo(Std.int(x), Std.int(y));
				update(uiElement);
			}
		}
		catch (e:Dynamic) trace("ERROR:", e);
		
	}

	public function onWindowLeave ():Void {
		//trace("onWindowLeave");
		if (lastOverIndex >= 0) {
			overBuffer.getElement(lastOverIndex).uiElement.mouseOut( -1, -1) ;
			lastOverIndex = -1;
		}
		if (lastDownIndex >= 0) { 
			clickBuffer.getElement(lastDownIndex).uiElement.mouseUp( -1, -1 );
			lastDownIndex = -1;
			lockMouseDown = false;
		}
	}
	
	var lockMouseDown = false;
	public function onMouseDown (peoteView:PeoteView, x:Float, y:Float, button:MouseButton):Void
	{
		try {
			if (!lockMouseDown) 
			{
				lastDownIndex = peoteView.getElementAt( x, y, this, clickProgram ) ;
				if (lastDownIndex >= 0) {
					clickBuffer.getElement(lastDownIndex).uiElement.mouseDown( Std.int(x), Std.int(y) );
					lockMouseDown = true;
				}
			}
			//var pickedElements = peoteView.getAllElementsAt(x, y, display, clickProgram);
			//trace(pickedElements);
			
		}
		catch (e:Dynamic) trace("ERROR:", e);
		
	}
	
	public function onMouseUp (peoteView:PeoteView, x:Float, y:Float, button:MouseButton):Void
	{
		try {
			if (lastDownIndex >= 0) {
				var pickedElement = peoteView.getElementAt(x, y, this, clickProgram);
				clickBuffer.getElement(lastDownIndex).uiElement.mouseUp( Std.int(x), Std.int(y) );
				if (pickedElement == lastDownIndex) {
					clickBuffer.getElement(pickedElement).uiElement.mouseClick( Std.int(x), Std.int(y) );
				}
				lastDownIndex = -1;
				lockMouseDown = false;
			}			
			//var pickedElements = peoteView.getAllElementsAt(x, y, display, clickProgram);
			//trace(pickedElements);
			
		}
		catch (e:Dynamic) trace("ERROR:", e);
		
	}

	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			//case KeyCode.NUMPAD_PLUS:
			default:
		}
	}
	
}


