package;

#if ButtonLayout

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

import peote.layout.LayoutContainer;
import peote.layout.Size;


class ButtonLayout 
{
	var peoteView:PeoteView;
	var ui:UIDisplay;
	var mySkin = new Skin();
		
	var uiLayoutContainer:LayoutContainer;
	
	public function new(window:Window)
	{
		peoteView = new PeoteView(window.context, window.width, window.height);
		ui = new UIDisplay(0, 0, window.width, window.height, Color.GREY3);
		peoteView.addDisplay(ui);
		
		var red   = new Button(mySkin, new Style(Color.RED));
		var green = new Button(mySkin, new Style(Color.GREEN));
		var blue  = new Button(mySkin, new Style(Color.BLUE));
		var yellow= new Button(mySkin, new Style(Color.YELLOW));
		var grey  = new Button(mySkin, new Style(Color.GREY1));		
		var cyan  = new Button(mySkin, new Style(Color.CYAN));		

		ui.add(red); ui.add(green); ui.add(blue); ui.add(yellow); ui.add(grey); ui.add(cyan); 
			
		
		uiLayoutContainer = new Box( ui , { width:Size.limit(100,700), relativeChildPositions:true },
		[                                                          
			new Box( red , { width:Size.limit(100,600) },
			[                                                      
				new Box( green,  { width:Size.limit(50, 300), height:Size.limit(100,400) }),							
				new Box( blue,   { width:Size.span(50, 150), height:Size.limit(100,300), left:Size.min(50) } ),
				new Box( yellow, { width:Size.limit(50, 150), height:Size.limit(200,200), left:Size.span(0,100), right:50 } ),
			])
		]);
		
		uiLayoutContainer.init();
		uiLayoutContainer.update(peoteView.width, peoteView.height);
	}

	// ----------------------------------------------------------------
	public function switchLayout() {
		
/*		switch (layoutNumber) {
			case 0: testLayoutuiLayoutContainer();
			//case 1: testLayoutRows();
			//case 2: testLayoutScroll();
			default:
		}
*/
	}
	

/*	
	// ----------------------------------------------------------------
	public function testLayoutRows()
	{
		layout = new Layout
		(
			peoteView, // root Layout (automatically set width and height as suggestable and all childs toUpdate)
			[
				new Box(peoteView,
				[
					new HBox(ui,
					[
						new Box(red,   200, 200 ,LSpace.is(10,50)),
						new Box(green, Width.is(200,250),  LSpace.is(10,20), RSpace.is(10,20), TSpace.is(50) ),
						new VBox(blue, Width.is(100, 250), RSpace.is(10, 50), 
						[	
							new Box(yellow, 100, Height.is(50,100), TSpace.is(50,100) ),
							new Box(cyan, Width.is(100,150), 100, LSpace.is(0,50), TSpace.is(0,15)),
							new Box(grey, Height.is(50), TSpace.is(0,30), BSpace.min(50) )
						])
					])
				]),
				
				
			]
		);
		layout.setRootSize(peoteView.width, peoteView.height).update();
	}

	
	// ----------------------------------------------------------------
	public function testLayoutScroll()
	{
		layout = new Layout
		(
			peoteView, // root Layout (automatically set width and height as suggestable and all childs toUpdate)
			[
				new Box(peoteView,
				[
					new HBox(ui,
					[
						new Box(red,   200, 200 ,LSpace.is(10,50)),
						new Box(green, Width.is(200,250),  LSpace.is(10,20), RSpace.is(10,20), TSpace.is(50) ),
						new Scroll(blue, Width.is(50, 350), RSpace.is(10, 50), 
						[	
							new Box(yellow, 200, Height.is(50,100) ),
							new Box(cyan, Width.is(100,150), 100, LSpace.is(0,50), TSpace.is(0,15)),
							new Box(grey, Height.is(50), TSpace.is(0,30), BSpace.min(50) )
						])
					])
				]),
				
				
			]
		);
		layout.addVariable(blue.layout.xScroll);
		//layout.removeVariable(blue.layout.width);
		
		//layout.setVariable(blue.layout.xScroll, 100);
		layout.setRootSize(peoteView.width, peoteView.height);
		layout.update();
	}

	
*/	
	
	// ----------------------------------------
	// -------------- events ------------------
	// ----------------------------------------
	
	public function resize(width:Int, height:Int)
	{
		peoteView.resize(width, height);
		
		// calculates new Layout and updates all Elements 
		uiLayoutContainer.update(width, height);
	}
	
	public function render() peoteView.render();

	
	var sizeEmulation = false;
	
	public function onMouseMove (x:Float, y:Float) {
		ui.onMouseMove(x, y);
		if (sizeEmulation) uiLayoutContainer.update(Std.int(x),Std.int(y));
	}
	public function onMouseDown (x:Float, y:Float, button:MouseButton) ui.onMouseDown(x, y, button);
	public function onMouseUp (x:Float, y:Float, button:MouseButton) {
		ui.onMouseUp(x, y, button);
		sizeEmulation = !sizeEmulation; 
		if (sizeEmulation) uiLayoutContainer.update(x,y);
		else uiLayoutContainer.update(peoteView.width, peoteView.height);
	}
	public function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:MouseWheelMode):Void {}
	public function onTouchStart (touch:Touch):Void {}
	public function onTouchMove (touch:Touch):Void {}
	public function onTouchEnd (touch:Touch):Void {}
	public function onTouchCancel(touch:Touch):Void {}
	
	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
/*		switch (keyCode) {
			case KeyCode.RIGHT:
				layoutNumber = (layoutNumber + 1) % maxLayout;
				switchLayout();
			case KeyCode.LEFT:
				layoutNumber--;
				if (layoutNumber < 0) layoutNumber = maxLayout-1;
				switchLayout();
			case KeyCode.NUMPAD_PLUS:
				layout.setVariable(blue.layout.xScroll, Std.int(blue.layout.xScroll.m_value + 1));
				layout.update();
			case KeyCode.NUMPAD_MINUS:
				layout.setVariable(blue.layout.xScroll, Std.int(blue.layout.xScroll.m_value - 1));
				layout.update();
			default:
		}
*/	}
	public function onKeyUp (keyCode:KeyCode, modifier:KeyModifier):Void {}
	public function onTextInput (text:String):Void {}
	public function onTextEdit(text:String, start:Int, length:Int):Void {}

	public function onWindowActivate():Void {};
	public function onWindowLeave () ui.onWindowLeave();
	
	public function onPreloadComplete ():Void { trace("preload complete"); }
	public function update(deltaTime:Int):Void {}
}

#end