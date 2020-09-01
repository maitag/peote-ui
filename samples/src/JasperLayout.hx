package;

#if JasperLayout

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
import peote.ui.layout.LayoutElement;
import peote.ui.layout.LayoutContainer;
import peote.ui.layout.Layout;

import jasper.Constraint;
import jasper.Strength;

class JasperLayout 
{
	var peoteView:PeoteView;
	var ui:UIDisplay;
	var mySkin = new Skin();
	
	var red:Button; var green:Button; var blue:Button;	var yellow:Button; var grey:Button; var cyan:Button;
			
	var layout:Layout;
	var layoutNumber:Int = 2;
	var maxLayout:Int = 3;
	
	public function new(window:Window)
	{
		try {			
			peoteView = new PeoteView(window.context, window.width, window.height);
			ui = new UIDisplay(0, 0, window.width, window.height, Color.GREY3);
			peoteView.addDisplay(ui);
			
			red   = new Button(mySkin, new Style(Color.RED));
			green = new Button(mySkin, new Style(Color.GREEN));
			blue  = new Button(mySkin, new Style(Color.BLUE));
			yellow= new Button(mySkin, new Style(Color.YELLOW));
			grey  = new Button(mySkin, new Style(Color.GREY1));		
			cyan  = new Button(mySkin, new Style(Color.CYAN));		

			ui.add(red); ui.add(green); ui.add(blue); ui.add(yellow); ui.add(grey); ui.add(cyan); 
			switchLayout();
			
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}

	// ----------------------------------------------------------------
	public function switchLayout() {
		red.x = green.x = blue.x = yellow.x = grey.x = cyan.x = -1000;
		// TODO: should work same
		ui.updateAll();
		
		switch (layoutNumber) {
			case 0: testLayoutNestedBoxes();
			case 1: testLayoutRows();
			case 2: testLayoutScroll();
			default:
		}
	}
	
	// ----------------------------------------------------------------
	public function testLayoutNestedBoxes()
	{
		layout = new Layout
		(
			peoteView, // root Layout (automatically set width and height as suggestable and all childs toUpdate)
			[
				new Box(peoteView,
				[
					new Box( ui   , Width.is(100,700),
					[                                                          
						new Box( red  , Width.is(100,600),
						[                                                      
							new Box( green,  Width.is(50, 300),  Height.is(100,400)),							
							new Box( blue,   Width.min(50, 150), Height.is(100,300), LSpace.min(50) ),
							new Box( yellow, Width.is(50, 150),  Height.is(200,200), LSpace.min(0,100), RSpace.is(50) ),
						])
					])
				])
				
			]
		);
		layout.setRootSize(peoteView.width, peoteView.height).update();
	}

	
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
						new Scroll(blue, Width.is(50, 250), RSpace.is(10, 50), 
						[	
							new Box(yellow, 100, Height.is(50,100) ),
							new Box(cyan, Width.is(100,150), 100, LSpace.is(0,50), TSpace.is(0,15)),
							new Box(grey, Height.is(50), TSpace.is(0,30), BSpace.min(50) )
						])
					])
				]),
				
				
			]
		);
		// layout.suggestValues([peoteView.width, peoteView.height]).update();
		//layout.addVariable(blue.layout.width);
		//layout.removeVariable(blue.layout.width);
		
		//layout.setVariable(blue.layout.width, 100);
		layout.setRootSize(peoteView.width, peoteView.height);
		layout.update();
	}

	
	
	
	// ----------------------------------------
	// -------------- events ------------------
	// ----------------------------------------
	
	public function resize(width:Int, height:Int)
	{
		peoteView.resize(width, height);
		
		// calculates new Layout and updates all Elements 
		layout.setRootSize(width, height).update();
		// trace(ui.width);
	}
	
	public function render() peoteView.render();

	
	var sizeEmulation = false;
	
	public function onMouseMove (x:Float, y:Float) {
		ui.onMouseMove(x, y);
		if (sizeEmulation) layout.setRootSize(Std.int(x),Std.int(y)).update();
	}
	public function onMouseDown (x:Float, y:Float, button:MouseButton) ui.onMouseDown(x, y, button);
	public function onMouseUp (x:Float, y:Float, button:MouseButton) {
		ui.onMouseUp(x, y, button);
		sizeEmulation = !sizeEmulation; 
		if (sizeEmulation) layout.setRootSize(Std.int(x), Std.int(y)).update();
		else layout.setRootSize(peoteView.width, peoteView.height).update();
	}
	public function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:MouseWheelMode):Void {}
	public function onTouchStart (touch:Touch):Void {}
	public function onTouchMove (touch:Touch):Void {}
	public function onTouchEnd (touch:Touch):Void {}
	public function onTouchCancel(touch:Touch):Void {}
	
	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			case KeyCode.RIGHT:
				layoutNumber = (layoutNumber + 1) % maxLayout;
				switchLayout();
			case KeyCode.LEFT:
				layoutNumber--;
				if (layoutNumber < 0) layoutNumber = maxLayout-1;
				switchLayout();
			default:
		}
	}
	public function onKeyUp (keyCode:KeyCode, modifier:KeyModifier):Void {}
	public function onTextInput (text:String):Void {}
	public function onTextEdit(text:String, start:Int, length:Int):Void {}

	public function onWindowActivate():Void {};
	public function onWindowLeave () ui.onWindowLeave();
	
	public function onPreloadComplete ():Void { trace("preload complete"); }
	public function update(deltaTime:Int):Void {}
}

#end