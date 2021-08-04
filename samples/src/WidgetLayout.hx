package;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.ui.Touch;
import peote.layout.ContainerType;

import peote.view.PeoteView;
import peote.view.Color;

import peote.text.Font;
import peote.ui.fontstyle.FontStyleTiled;

import peote.ui.skin.RoundedSkin;
import peote.ui.style.RoundedStyle;

import peote.ui.PeoteUI;
import peote.ui.layouted.LayoutedTextLine;
import peote.ui.event.PointerEvent;
import peote.ui.widget.Div;
import peote.ui.widget.TextLine;


import peote.layout.Size;


class WidgetLayout extends Application
{
	var peoteView:PeoteView;
	var ui:PeoteUI;
	
	var uiResizeMode = false;
	
	public function new() super();
	
	public override function onWindowCreate() {
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES: initPeoteView(window); // start sample
			default: throw("Sorry, only works with OpenGL.");
		}
	}
	
	public function initPeoteView(window:Window) {
		try {			
			peoteView = new PeoteView(window.context, window.width, window.height);
			
			// load the FONT:
			new Font<FontStyleTiled>("assets/fonts/tiled/hack_ascii.json").load( onFontLoaded );
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}
	
	public function onFontLoaded(font:Font<FontStyleTiled>) {
		try {
			
			var mySkin = new RoundedSkin();
			
			var myStyle = new RoundedStyle();
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

					skin:mySkin,
					style:myStyle,
					
					onPointerOver:onOverOut.bind(Color.BLUE),
					onPointerOut:onOverOut.bind(Color.GREY1),
					onPointerDown: function(widget:Div, e:PointerEvent) {
						//widget.style.color = Color.YELLOW;
						//widget.parent.style.color = Color.YELLOW;
						
						var t:TextLine = widget.childs[0];
						var layoutedTextLine:LayoutedTextLine<FontStyleTiled> = t.getLayoutedTextLine();
						layoutedTextLine.fontStyle.color = Color.BLACK;
						layoutedTextLine.updateStyle();
						layoutedTextLine.update();
						
						widget.layoutElement.update();
					},
					onPointerUp: function(widget:Div, e:PointerEvent) {
						var t:TextLine = widget.childs[0];
						var layoutedTextLine:LayoutedTextLine<FontStyleTiled> = t.getLayoutedTextLine();
						layoutedTextLine.fontStyle.color = Color.WHITE;
						layoutedTextLine.updateStyle();
						layoutedTextLine.update();
						
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
						
						onPointerOver:
							function (t:TextLine, e:PointerEvent) {
								trace("onOverTextfield");
								
								//var fontStyle:FontStyleTiled = t.getFontStyle();
								//var fontStyle = t.getFontStyle();
								//fontStyle.color = Color.RED;
								
								var layoutedTextLine:LayoutedTextLine<FontStyleTiled> = t.getLayoutedTextLine();
								layoutedTextLine.fontStyle.color = Color.RED;
								layoutedTextLine.updateStyle();
								
								layoutedTextLine.update();
							}
						,	
						onPointerOut:
							function (t:TextLine, e:PointerEvent) {
								trace("onOutTextfield");
								
								//var fontStyle:FontStyleTiled = t.getFontStyle();
								//var fontStyle = t.getFontStyle();
								//fontStyle.color = Color.RED;
								
								var layoutedTextLine:LayoutedTextLine<FontStyleTiled> = t.getLayoutedTextLine();
								layoutedTextLine.fontStyle.color = Color.WHITE;
								layoutedTextLine.updateStyle();
								
								layoutedTextLine.update();
							}
							
					}),
						
				]),
			
				// button for quick resize testing
				new Div({
					width:50, height:50, right:0, bottom:0, skin:mySkin, style:new RoundedStyle(),
					onPointerDown: function(widget:Div, e:PointerEvent) {uiResizeMode = true; ui.pointerEnabled = false;} ,
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
			ui.pointerEnabled = true;
			
			#if android
			ui.mouseEnabled = false;
			#end
			PeoteUI.registerEvents(window); // to fetch all input events
			
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}

	// --------------------------------------------------
	public inline function onOverOut(color:Color, widget:Div, e:PointerEvent) {
		//trace(widget.parent);
		//widget.parent.uiElement.color = Color.RED;
		
		//TODO:
		//switch(widged.Type) {
		//	case(WidgetType.TextLine) 
		
		widget.style.color = color;
		widget.style.borderColor = Color.GREY7;
		//TODO: widget.updateStyle();
		widget.layoutElement.update();
		//TODO: widget.updateLayout();
		//TODO: widget.update();
	}

	

	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	public override function render(context:lime.graphics.RenderContext) peoteView.render();
	public override function onWindowResize (width:Int, height:Int) peoteView.resize(width, height);
	
	// ----------------- MOUSE EVENTS ------------------------------
	public override function onMouseMove (x:Float, y:Float) {
		if (uiResizeMode && x>0 && y>0) ui.update(x, y);
	}

	public override function onMouseDown (x:Float, y:Float, button:MouseButton) {
		if (uiResizeMode) {
			uiResizeMode = false;
			ui.update(peoteView.width, peoteView.height);
			ui.pointerEnabled = true;
		}
	}

	// ----------------- TOUCH EVENTS ------------------------------
	public override function onTouchMove (touch:Touch) {
		var x:Int = Math.round(touch.x * peoteView.width);
		var y:Int = Math.round(touch.y * peoteView.height);
		if (uiResizeMode && x>0 && y>0) ui.update(x, y);
	}
	
	public override function onTouchEnd (touch:Touch) {
		if (uiResizeMode) {
			uiResizeMode = false;
			ui.update(peoteView.width, peoteView.height);
			ui.pointerEnabled = true;
		}
	}
	
	
	// TODO: delegate to PeoteUI also!
	
	// ----------------- KEYBOARD EVENTS ---------------------------
	public override function onKeyDown (keyCode:KeyCode, modifier:KeyModifier) {
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
