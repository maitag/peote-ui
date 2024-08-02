package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.ui.Touch;

import peote.view.PeoteView;
import peote.view.Color;

import peote.layout.ContainerType;

import peote.text.Font;

import peote.ui.style.FontStyleTiled;
import peote.ui.style.RoundBorderStyle;

import peote.ui.PeoteUI;
import peote.ui.interactive.UITextLine;
import peote.ui.event.PointerEvent;
import peote.ui.widget.Div;
import peote.ui.widget.TextLine;


import peote.layout.Size;


class WidgetLayout extends Application
{
	var peoteView:PeoteView;
	var ui:PeoteUI;
	
	var uiResizeMode = false;
	
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

	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);
		
		// load the FONT:
		new Font<FontStyleTiled>("assets/fonts/tiled/hack_ascii.json").load( onFontLoaded );
	}
	
	public function onFontLoaded(font:Font<FontStyleTiled>)
	{
		var myStyle = new RoundBorderStyle();
		myStyle.color = Color.GREY1;
		myStyle.borderColor = Color.GREY5;
		myStyle.borderSize = 4.0;
		myStyle.borderRadius = 40.0;

		var fontStyleTiled = new FontStyleTiled();
		fontStyleTiled.height = 25;
		fontStyleTiled.width = 25;
		fontStyleTiled.color = Color.WHITE;
		
		ui = new PeoteUI(ContainerType.BOX, {
			#if peotelayout_debug
			name: "PeoteUI",
			#end
			bgColor:Color.GREY1,
			//left:10,
			//right:10,
		},
		[
			
			// later into widget-component
			new Div(
			{
				#if peotelayout_debug
				name: "Div",
				#end
				top:20,
				//left:20,
				width:Size.limit(200, 300),
				height:50,

				style:myStyle,
				
				onPointerOver:onOverOut.bind(Color.BLUE),
				onPointerOut:onOverOut.bind(Color.GREY1),
				onPointerDown: function(widget:Div, e:PointerEvent)
				{					
					var t:TextLine = widget.childs[0];
					
					// 1)
					//var interactiveTextLine:InteractiveTextLine<FontStyleTiled> = t.getLayoutedTextLine();
					//interactiveTextLine.fontStyle.color = Color.BLACK;
					//interactiveTextLine.updateStyle();
					//interactiveTextLine.update();
					
					// 2)
					t.fontStyle.color = Color.BLACK;
					t.update();
					
					widget.style.color = Color.YELLOW;
					//widget.parent.bgColor = Color.YELLOW; // TODO
					widget.layoutElement.update();
				},
				onPointerUp: function(widget:Div, e:PointerEvent) {
					var t:TextLine = widget.childs[0];
					
					t.fontStyle.color = Color.WHITE;
					t.update();
					
					widget.style.color = Color.BLUE;
					//widget.parent.bgColor = Color.YELLOW; // TODO
					widget.layoutElement.update();
				},
				
			},
			[   // TODO:
				new TextLine( font, fontStyleTiled, "TextLine",
				{
					#if peotelayout_debug
					name: "TextLine",
					#end
					width:Size.limit(100, 200),
					//top:Size.span(0.2),
					//bottom:Size.span(0.2),
					height:25, // <- TODO: by FontSize !
					
					onPointerOver: function (t:TextLine, e:PointerEvent) {
							trace("onPointerOver:Textfield");
							
							// 1)
							t.fontStyle.color = Color.RED;
							
							// 2)
							//var fontStyle:FontStyleTiled = t.fontStyle;
							//trace(Type.typeof(fontStyle));
							//fontStyle.color = Color.RED;
							
							// 3)
							//var fs = new FontStyleTiled();
							//fs.color = Color.RED;
							//t.fontStyle = fs;
							
							// 4)
							//fontStyleTiled.color = Color.RED;
							//t.fontStyle = fontStyleTiled;
							
							t.updateStyle();
						}
					,	
					onPointerOut:
						function (t:TextLine, e:PointerEvent) {
							trace("onPointerOut:Textfield");
							
							// 5
							var interactiveTextLine:UITextLine<FontStyleTiled> = t.getLayoutedTextLine();
							interactiveTextLine.fontStyle.color = Color.WHITE;
							interactiveTextLine.updateStyle();
						}
						
				}),
					
			]),
		
			// button for quick resize testing
			new Div({
				width:50, height:50, right:0, bottom:0, style:new RoundBorderStyle(),
				onPointerDown: function(widget:Div, e:PointerEvent) {uiResizeMode = true; ui.mouseEnabled = false;} ,
				onPointerOver: onOverOut.bind(Color.BLUE),
				onPointerOut: onOverOut.bind(Color.GREY1),
			}),			
				
/*			// later into widget -> new VScrollArea()
			new HBox(
			[
				new VScroll(),
				new VSlider({width:30}),
			]),
*/			
		]);
		
		ui.init();
		peoteView.addDisplay(ui);
		ui.update(peoteView.width, peoteView.height);
		
		#if android
		ui.mouseEnabled = false;
		#end
		PeoteUI.registerEvents(window); // to fetch all input events
		
	}

	// --------------------------------------------------
	public function onOverOut(color:Color, widget:Div, e:PointerEvent) {
		//trace(widget.parent);
		//widget.parent.uiElement.color = Color.RED;
		
		//TODO:
		//switch(widged.Type) {
		//	case(WidgetType.TextLine) 
		
		widget.style.color = color;
		widget.style.borderColor = Color.GREY7;
		widget.updateStyle();
	}
	

	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	
	// ----------------- MOUSE EVENTS ------------------------------
	override function onMouseMove (x:Float, y:Float) {
		if (uiResizeMode && x>0 && y>0) ui.update(x, y);
	}

	override function onMouseDown (x:Float, y:Float, button:MouseButton) {
		if (uiResizeMode) {
			uiResizeMode = false;
			ui.update(peoteView.width, peoteView.height);
			ui.mouseEnabled = true;
		}
	}

	// ----------------- TOUCH EVENTS ------------------------------
	override function onTouchMove (touch:Touch) {
		var x:Int = Math.round(touch.x * peoteView.width);
		var y:Int = Math.round(touch.y * peoteView.height);
		if (uiResizeMode && x>0 && y>0) ui.update(x, y);
	}
	
	override function onTouchEnd (touch:Touch) {
		if (uiResizeMode) {
			uiResizeMode = false;
			ui.update(peoteView.width, peoteView.height);
			ui.mouseEnabled = true;
		}
	}
	
	
	// TODO: delegate to PeoteUI also!
	
	// ----------------- KEYBOARD EVENTS ---------------------------
	override function onKeyDown (keyCode:KeyCode, modifier:KeyModifier) {
		switch (keyCode) {
			#if html5
			case KeyCode.TAB: untyped __js__('event.preventDefault();');
			#end
			case KeyCode.F: window.fullscreen = !window.fullscreen;
			default:
		}
		//PeoteUI.keyDown(keyCode, modifier);
	}
	
	//public override function onKeyUp (keyCode:KeyCode, modifier:KeyModifier) PeoteUI.keyUp(keyCode, modifier);
	//public override function onTextEdit(text:String, start:Int, length:Int) PeoteUI.textEdit(text, start, length);
	//public override function onTextInput (text:String):Void PeoteUI.textInput(text);

}
