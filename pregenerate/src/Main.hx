package;

import haxe.macro.Context;
import haxe.macro.Tools.TExprTools;
#if macro
import haxe.macro.Expr;
import haxe.macro.Printer;
#end

import haxe.CallStack;
import sys.FileSystem;
import sys.io.File;

import lime.app.Application;

class Main extends Application
{	
	override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try start()
				catch (_) trace(CallStack.toString(CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}

	public function start()
	{
		var map:Map<String,String>;


		// ------ GENERATE PACKED --------

		map = generate("P", "Packed", "peote.ui.packed");

		// create directory
		if (!FileSystem.exists("packed")) FileSystem.createDirectory("packed");

		// save into files
		for (name => content in map) {
			trace('save packed/$name.hx');
			File.saveContent('packed/$name.hx',content);
		}

		map = generate_ui("P", "Packed", "peote.ui.packed");
		trace('UITextLineP.hx'); File.saveContent('UITextLineP.hx',map.get("UITextLineP"));
		trace('UITextPageP.hx'); File.saveContent('UITextPageP.hx',map.get("UITextPageP"));
		

		// ------ GENERATE TILED --------
		
		map = generate("T", "Tiled", "peote.ui.tiled");

		// create directory
		if (!FileSystem.exists("tiled")) FileSystem.createDirectory("tiled");

		// save into files
		for (name => content in map) {
			trace('save tiled/$name.hx');
			File.saveContent('tiled/$name.hx',content);
		}

		map = generate_ui("T", "Tiled", "peote.ui.tiled");
		trace('UITextLineT.hx'); File.saveContent('UITextLineT.hx',map.get("UITextLineT"));
		trace('UITextPageT.hx'); File.saveContent('UITextPageT.hx',map.get("UITextPageT"));
		
	
	}

	macro static function generate_ui(postfix:String, postfixStyle:String, p:String):Expr
		{
			#if macro
			// trace( postfix );
	
			var pack = 'package peote.ui.interactive;\n';
	
			var nameValueMap:Array<Expr> = [];
	
			var textLineTypeDef = peote.ui.interactive.UITextLine.UITextLineMacro.getTypeDefinition(
				'UITextLine$postfix', // className
				'peote.ui.style', // styleModule
				'FontStyle$postfixStyle', // styleName
				TPath({ pack:['peote.ui.style'], name:'FontStyle$postfixStyle', params:[] }),  // styleType
				TPath({ pack:[], name:'UITextLine$postfix', params:[] }),  // uiTextLineType
				TPath({ pack:[p], name:'Line$postfix', params:[] }),  // lineType
				TPath({ pack:[p], name:'Font$postfix', params:[] }),  // fontType
				TPath({ pack:[p], name:'FontProgram$postfix', params:[] })  // fontProgramType
			);
			nameValueMap.push(macro $v{'UITextLine$postfix'} => $v{pack + new Printer().printTypeDefinition(textLineTypeDef)});
			
			var textPageTypeDef = peote.ui.interactive.UITextPage.UITextPageMacro.getTypeDefinition(
				'UITextPage$postfix', // className
				'peote.ui.style', // styleModule
				'FontStyle$postfixStyle', // styleName
				TPath({ pack:['peote.ui.style'], name:'FontStyle$postfixStyle', params:[] }),  // styleType
				TPath({ pack:[], name:'UITextPage$postfix', params:[] }),  // uiTextPageType
				TPath({ pack:[p], name:'Page$postfix', params:[] }),  // pageType
				TPath({ pack:[p], name:'PageLine$postfix', params:[] }),  // pageLineType
				TPath({ pack:[p], name:'Font$postfix', params:[] }),  // fontType
				TPath({ pack:[p], name:'FontProgram$postfix', params:[] })  // fontProgramType
			);
			nameValueMap.push(macro $v{'UITextPage$postfix'} => $v{pack + new Printer().printTypeDefinition(textPageTypeDef)});
			
	
			return macro $a{nameValueMap};
			#end
		}


		// -----------------------------------------------------------------------------------------------
		// -----------------------------------------------------------------------------------------------
		// -----------------------------------------------------------------------------------------------
			

	macro static function generate(postfix:String, postfixStyle:String, p:String):Expr
	{
		#if macro
		// trace( postfix );

		var pack = 'package $p;\n';

		var nameValueMap:Array<Expr> = [];
		
		var glyphTypeDef = peote.text.Glyph.GlyphMacro.getTypeDefinition(
			'Glyph$postfix', // className
			'peote.ui.style', // styleModule
			'FontStyle$postfixStyle', // styleName
			TPath({ pack:['peote.ui.style'], name:'FontStyle$postfixStyle', params:[] })  // styleType 
		);
		glyphTypeDef.meta = [ {name:":allow", params:[ Context.parse(p, Context.currentPos()) ], pos:Context.currentPos()} ];
		nameValueMap.push(macro $v{'Glyph$postfix'} => $v{pack + new Printer().printTypeDefinition(glyphTypeDef)});

		var pageLineTypeDef = peote.text.PageLine.PageLineMacro.getTypeDefinition(
			'PageLine$postfix', // className
			'peote.ui.style', // styleModule
			'FontStyle$postfixStyle', // styleName
			TPath({ pack:[], name:'Glyph$postfix', params:[] })  // glyphType 
		);
		pageLineTypeDef.meta = [ {name:":allow", params:[ Context.parse(p, Context.currentPos()) ], pos:Context.currentPos()} ];
		nameValueMap.push(macro $v{'PageLine$postfix'} => $v{pack + new Printer().printTypeDefinition(pageLineTypeDef)});
		
		var lineTypeDef = peote.text.Line.LineMacro.getTypeDefinition(
			'Line$postfix', // className
			'peote.ui.style', // styleModule
			'FontStyle$postfixStyle', // styleName
			TPath({ pack:[], name:'Glyph$postfix', params:[] }),  // glyphType 
			{ pack:[], name:'PageLine$postfix', params:[] }  // pageLinePath
		);
		lineTypeDef.meta = [ {name:":allow", params:[ Context.parse(p, Context.currentPos()) ], pos:Context.currentPos()} ];
		nameValueMap.push(macro $v{'Line$postfix'} => $v{pack + new Printer().printTypeDefinition(lineTypeDef)});
		
		var pageTypeDef = peote.text.Page.PageMacro.getTypeDefinition(
			'Page$postfix', // className
			'peote.ui.style', // styleModule
			'FontStyle$postfixStyle', // styleName
			TPath({ pack:[], name:'PageLine$postfix', params:[] })  // pageLineType 
		);
		pageTypeDef.meta = [ {name:":allow", params:[ Context.parse(p, Context.currentPos()) ], pos:Context.currentPos()} ];
		nameValueMap.push(macro $v{'Page$postfix'} => $v{pack + new Printer().printTypeDefinition(pageTypeDef)});

		var fontTypeDef = peote.text.Font.FontMacro.getTypeDefinition(
			'Font$postfix', // className
			{ pack:['peote.ui.style'], name:'FontStyle$postfixStyle', params:[] }, // stylePath
			['peote.ui.style'], // stylePack
			'peote.ui.style', // styleModule
			'FontStyle$postfixStyle', // styleName
			TPath({ pack:['peote.ui.style'], name:'FontStyle$postfixStyle', params:[] }),  // styleType
			TPath({ pack:[], name:'Glyph$postfix', params:[] }),  // glyphType
			TPath({ pack:[], name:'Line$postfix', params:[] }),  // lineType
			TPath({ pack:[], name:'Font$postfix', params:[] }),  // fontType
			TPath({ pack:[], name:'FontProgram$postfix', params:[] }),  // fontProgramType
			{ pack:[], name:'FontProgram$postfix', params:[] },  // fontProgramPath
			{ pack:[], name:'Glyph$postfix', params:[] },  // glyphPath
			{ pack:[], name:'Line$postfix', params:[] },  // linePath
			TPath({ pack:['peote.ui.interactive'], name:'UITextLine$postfix', params:[] }),  // uiTextLineType
			{ pack:['peote.ui.interactive'], name:'UITextLine$postfix', params:[] },  // uiTextLinePath
			TPath({ pack:['peote.ui.interactive'], name:'UITextPage$postfix', params:[] }),  // uiTextPageType
			{ pack:['peote.ui.interactive'], name:'UITextPage$postfix', params:[] }  // uiTextPagePath
		);
		nameValueMap.push(macro $v{'Font$postfix'} => $v{pack + "@:access(peote.text.FontConfig)\n" + new Printer().printTypeDefinition(fontTypeDef)});
		
		var fontProgramTypeDef = peote.text.FontProgram.FontProgramMacro.getTypeDefinition(
			'FontProgram$postfix', // className
			'peote.ui.style', // styleModule
			'FontStyle$postfixStyle', // styleName
			TPath({ pack:['peote.ui.style'], name:'FontStyle$postfixStyle', params:[] }),  // styleType
			TPath({ pack:[], name:'Glyph$postfix', params:[] }),  // glyphType
			TPath({ pack:[], name:'Line$postfix', params:[] }),  // lineType
			TPath({ pack:[], name:'PageLine$postfix', params:[] }),  // pageLineType
			TPath({ pack:[], name:'Font$postfix', params:[] }),  // fontType
			TPath({ pack:[], name:'Page$postfix', params:[] }),  // PageType
			{ pack:[], name:'Glyph$postfix', params:[] },  // glyphPath
			{ pack:[], name:'Line$postfix', params:[] },  // linePath
			{ pack:[], name:'PageLine$postfix', params:[] },  // pageLinePath
			{ pack:[], name:'Page$postfix', params:[] }  // pagePath
		);
		nameValueMap.push(macro $v{'FontProgram$postfix'} => $v{pack + "@:access(peote.text.FontConfig)\n" + new Printer().printTypeDefinition(fontProgramTypeDef)});
		

		return macro $a{nameValueMap};
		#end
	}


}
