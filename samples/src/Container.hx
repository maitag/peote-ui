package;

#if Container

import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;

import peote.view.PeoteView;
import peote.view.Color;
import peote.ui.UIDisplay;
import peote.ui.widgets.Button;
import peote.ui.widgets.Draggable;
import peote.ui.skin.Skin;
import peote.ui.skin.Style;
import peote.ui.layout.LayoutElement;
import peote.ui.layout.Layout;
import peote.ui.layout.LayoutContainer;

class Container
{
	var peoteView:PeoteView;
	var ui:UIDisplay;
	var mySkin = new Skin();
	
	var button:Button;
	var draggable:Draggable;
			
	var layout:Layout;
	
	public function new(window:Window)
	{
		try {			
			peoteView = new PeoteView(window.context, window.width, window.height);
			ui = new UIDisplay(0, 0, window.width, window.height, Color.GREY3);
			peoteView.addDisplay(ui);
			
			
			
			// WORK IN PROGRESS
			
			
			
			button = new Button(50, 10, 300, 30, mySkin, new Style(Color.BLUE));
			ui.add(button);
			
			draggable = new Draggable(
				// dragging area (defining the position and size of rectangular dragging area) 
				50, 10, 300, 30, // x, y, width, height
				// minimum size of draggable
				50, 30, // minWidth, minHeight
				mySkin, new Style(Color.GREEN)
			);
			ui.add(draggable);
			
			// TODO:

			// only getter:
			//trace(draggable.x, draggable.width);
			
			//draggable.relativeX = 1; // sets x position to max x value
			//draggable.relativeWidth = 1; // sets width to max-width
			//draggable.relativeWidth = 0.5; // sets width to 50% of available
			
			// draggable.onDrag
			
			
			// TODO: add child elements to button !
			
			// TODO: MASKING / SCROLLING
			
			// TODO: test 
			//  1) manual placing 
			//  2) via jasper-layout

			//putIntoLayout();
			
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}

	// ----------------------------------------------------------------
	

	// ----------------------------------------------------------------

		
	public function putIntoLayout()
	{
		layout = new Layout
		(
			peoteView, // root Layout (automatically set width and height as suggestable and all childs toUpdate)
			[
				new Box(peoteView,
				[
					new HBox(ui,
					[
						new Box(button, Width.min(200), Height.min(200) , LSpace.is(10,100), RSpace.is(10,100)),
					])
				]),
				
				
			]
		);
		layout.suggestValues([peoteView.width, peoteView.height]).update();
	}

	
	
	
	// ----------------------------------------
	// -------------- events ------------------
	// ----------------------------------------	
	public function resize(width:Int, height:Int)
	{
		peoteView.resize(width, height);
		layout.suggestValues([width, height]).update(); // calculates new Layout and updates all Elements
	}
	
	public function render() peoteView.render();

	// delegate mouse-events to UIDisplay
	public function onTextInput (text:String):Void {}
	public function onWindowLeave () ui.onWindowLeave();
	public function onMouseMove (x:Float, y:Float) ui.onMouseMove(peoteView, x, y);
	public function onMouseDown (x:Float, y:Float, button:MouseButton) ui.onMouseDown(peoteView, x, y, button);
	public function onMouseUp (x:Float, y:Float, button:MouseButton) ui.onMouseUp(peoteView, x, y, button);
	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier) ui.onKeyDown(keyCode, modifier);	
	public function onWindowActivate() //ui.onWindowActivate();	
	{
		#if html5
		//reFocus(); // TODO: delegate this event also to ui
		#end
	}
	
	public function onPreloadComplete ():Void { trace("preload complete"); }
	public function update(deltaTime:Int):Void {}
}

#end