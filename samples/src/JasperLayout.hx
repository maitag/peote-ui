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
	var layoutNumber:Int = 0;
	
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
			case 0: testManualConstraints();
			case 1: testManualRowConstraints();
			case 2: testLayoutNestedBoxes();
			case 3: testLayoutRows();
			case 4: testLayoutScroll();
			default:
		}
	}
	
	// ----------------------------------------------------------------
	
	public function testManualConstraints()
	{
		ui.layout.reset();
		grey.layout.reset();

		layout = new Layout ([
			// constraints
			(peoteView.layout.x == 0) | Strength.REQUIRED,
			(peoteView.layout.y == 0) | Strength.REQUIRED,

			ui.layout.centerX == peoteView.layout.centerX,
			ui.layout.top == 10,
			(ui.layout.width == peoteView.layout.width - 20) | Strength.WEAK,
			(ui.layout.bottom == peoteView.layout.bottom - 10) | Strength.WEAK,
			(ui.layout.width <= 1000) | Strength.WEAK,

			(grey.layout.centerX == ui.layout.centerX) | Strength.WEAK,
			(grey.layout.y == ui.layout.y + 0.1*ui.layout.height) | Strength.WEAK,
			//(grey.layout.centerY == ui.layout.centerY) | Strength.MEDIUM,
			
			(grey.layout.width  == ui.layout.width  / 1.1) | Strength.WEAK,
			(grey.layout.height == ui.layout.height / 2.0  - 20) | Strength.WEAK,
			
			(grey.layout.width <= 600) | Strength.MEDIUM,
			(grey.layout.width >= 200) | Strength.MEDIUM,
			(grey.layout.height <= 400) | Strength.MEDIUM,
			(grey.layout.height >= 200) | Strength.MEDIUM
		]);
		
		// adding constraints afterwards:
		var limitHeight:Constraint = (ui.layout.height <= 800) | Strength.WEAK;
		layout.addConstraint(limitHeight);
		
		// that constraints can also be removed again:
		// layout.removeConstraint(limitHeight);
		
		// UI-Displays and UI-Elements to update
		layout.toUpdate([ui, grey]);
		
		// editable Vars (used in suggest() and suggestValues())	
		layout.toSuggest([peoteView.layout.width, peoteView.layout.height]);
		
		// set the constraints editable values to actual view size and updating (same as in onResize)
		layout.suggestValues([peoteView.width, peoteView.height]).update();
	}

	// ----------------------------------------------------------------
		
	public function testManualRowConstraints()
	{
		ui.layout.reset();
		red.layout.reset();
		green.layout.reset();
		blue.layout.reset();
		
		layout = new Layout ([
			// constraints for the Displays
			(peoteView.layout.x == 0) | Strength.REQUIRED,
			(peoteView.layout.y == 0) | Strength.REQUIRED,

			(ui.layout.centerX == peoteView.layout.centerX) | new Strength(200),
			//(ui.layout.left == peoteView.layout.left) | new Strength(300),
			//(ui.layout.right == peoteView.layout.right) | new Strength(200),
			(ui.layout.width == peoteView.layout.width) | new Strength(100),
			
			(ui.layout.top == 0) | Strength.MEDIUM,
			(ui.layout.bottom == peoteView.layout.bottom) | Strength.MEDIUM,
			(ui.layout.width <= 1000) | Strength.MEDIUM,
		
			// constraints for ui-elements
			
			// size restriction
			(red.layout.width <= 100) | new Strength(500),
			(red.layout.width >= 50) | new Strength(500),
			//(red.layout.width == 100) | new Strength(500),
			
			(green.layout.width <= 200) | new Strength(500),
			(green.layout.width >= 100) | new Strength(500),
			//(green.layout.width == 200) | new Strength(500),
			
			(blue.layout.width <= 300) | new Strength(500),
			(blue.layout.width >= 150) | new Strength(500),
			//(blue.layout.width == 300) | new Strength(500),
			
			// manual hbox constraints
			
			//(red.layout.width   == (ui.layout.width) * ((100+ 50)/2) / ((100+50)/2 + (200+100)/2 + (300+150)/2)) | Strength.WEAK,
			//(green.layout.width == (ui.layout.width) * ((200+100)/2) / ((100+50)/2 + (200+100)/2 + (300+150)/2)) | Strength.WEAK,
			//(blue.layout.width  == (ui.layout.width) * ((300+150)/2) / ((100+50)/2 + (200+100)/2 + (300+150)/2)) | Strength.WEAK,
			
			(red.layout.width == green.layout.width) | Strength.WEAK,
			//(red.layout.width == blue.layout.width) | Strength.WEAK,
			(green.layout.width == blue.layout.width) | Strength.WEAK,
			
			(red.layout.left == ui.layout.left) | new Strength(400),
			(green.layout.left == red.layout.right ) | new Strength(400),
			(blue.layout.left == green.layout.right ) | new Strength(400),
			(blue.layout.right == ui.layout.right) | new Strength(300),
			//(blue.layout.right == ui.layout.right) | Strength.WEAK,
			
			(red.layout.top == ui.layout.top) | Strength.MEDIUM,
			(red.layout.bottom == ui.layout.bottom) | Strength.MEDIUM,
			(green.layout.top == ui.layout.top) | Strength.MEDIUM,
			(green.layout.bottom == ui.layout.bottom) | Strength.MEDIUM,
			(blue.layout.top == ui.layout.top) | Strength.MEDIUM,
			(blue.layout.bottom == ui.layout.bottom) | Strength.MEDIUM,			
		]);
				
		layout.toUpdate([ui, red, green, blue]); // UI-Displays and UI-Elements to update
		layout.toSuggest([peoteView.layout.width, peoteView.layout.height]); // editable Vars (used in suggest() and suggestValues())	
		layout.suggestValues([peoteView.width, peoteView.height]).update(); // set the constraints editable values to actual view size and updating (same as in onResize)
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
		layout.suggestValues([peoteView.width, peoteView.height]).update();
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
		layout.suggestValues([peoteView.width, peoteView.height]).update();
	}

	
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
						new Scroll(blue, Width.is(20, 250), RSpace.is(10, 50), 
						[	
							new Box(yellow, 100, Height.is(50,100) ),
							new Box(cyan, Width.is(100,150), 100, LSpace.is(0,50), TSpace.is(0,15)),
							new Box(grey, Height.is(50), TSpace.is(0,30), BSpace.min(50) )
						])
					])
				]),
				
				
			]
		);
		// TODO: layout.addSuggest([blue.layout.width]);
		layout.suggestValues([peoteView.width, peoteView.height]).update();
		// TODO: layout.suggestValues([peoteView.width, peoteView.height, 100]).update();
	}

	
	
	
	// ----------------------------------------
	// -------------- events ------------------
	// ----------------------------------------
	
	public function resize(width:Int, height:Int)
	{
		peoteView.resize(width, height);
		
		// calculates new Layout and updates all Elements 
		layout.suggestValues([width, height]).update();
		// or layout.suggest(peoteView.layout.width, width).suggest(peoteView.layout.height, height).update();
		// trace(ui.width);
	}
	
	public function render() peoteView.render();

	
	var sizeEmulation = false;
	
	public function onMouseMove (x:Float, y:Float) {
		ui.onMouseMove(x, y);
		if (sizeEmulation) layout.suggestValues([Std.int(x),Std.int(y)]).update();
	}
	public function onMouseDown (x:Float, y:Float, button:MouseButton) ui.onMouseDown(x, y, button);
	public function onMouseUp (x:Float, y:Float, button:MouseButton) {
		ui.onMouseUp(x, y, button);
		sizeEmulation = !sizeEmulation; 
		if (sizeEmulation) layout.suggestValues([Std.int(x), Std.int(y)]).update();
		else layout.suggestValues([peoteView.width, peoteView.height]).update();
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
				layoutNumber = (layoutNumber + 1) % 5;
				switchLayout();
			case KeyCode.LEFT:
				layoutNumber--;
				if (layoutNumber < 0) layoutNumber = 4;
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