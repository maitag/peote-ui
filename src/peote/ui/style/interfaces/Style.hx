package peote.ui.style.interfaces;

#if !macro
@:remove
@:autoBuild(peote.ui.style.interfaces.StyleMacro.build())
interface Style extends StyleID {
	public function createStyleProgram():StyleProgram;	
}

@:remove
class StyleMacro {}
#else

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.Log;

class StyleMacro
{
	static var UUID:Int = 0;
	
	macro static public function build():Array<Field>
	{
		var c = Context.getLocalClass().get();
		if (c.meta.has(":processed")) return null;
		c.meta.add(":processed", [], c.pos);
		
		// ---------------------------------------

		var classname:String = switch (Context.getLocalType()) {
			case TInst(t, _): t.toString();
			default: Context.error("Type for Style expected", Context.currentPos());
		}
		
		#if peoteui_debug_macro
		Log.trace('preparing Style: $classname');	
		#end
		
		// ------------------------------

		var fields = Context.getBuildFields();		
		StyleMacro.preapareFields(fields, (++StyleMacro.UUID) << 11, classname );
		
		//for (field in fields) trace(new haxe.macro.Printer().printField(field)); trace("");
		
		return fields;
	}

	
	// ----------------------------------------------------------------------
	// ------------ for both, Style and FontStyle macro ---------------------
	// ----------------------------------------------------------------------
				
	static public function preapareFields(fields:Array<Field>, uuid:Int, className:String)
	{
		var c = className.split(".");
		var classPack = (c.length > 1) ? c.splice(0, c.length - 1) : [];
		className = c[0]; //trace(classPack, className);
		
		// ------ collect used vars -----
		var nameType = new Array<{name:String, type:TypePath}>();		
		for (f in fields) {
			switch (f.kind) {	
				case FVar(type, val): nameType.push( {name:f.name, type:switch (type) {case TPath(tp):tp; default:null;} });
				default: //trace(f.kind);
			}
		}
		//trace(nameType);

		
		// ------ generate new() constructor ------
		
		//var newAndCopyArgs = [ for (v in nameType) {name:v.name, type:TPath({ name:"Null<"+v.type.name+">", pack:[], params:[] }), opt:true, value:null} ],
		var newAndCopyArgs = [ for (v in nameType) {name:v.name, type:(v.type == null) ? null : TPath({ name:v.type.name, pack:[], params:[] }), opt:false, value:macro null} ];
		
		var newFun:Function = {
			args:newAndCopyArgs,
			//expr: macro $b{ [ for (v in nameType) macro if ($i{v.name} != null)  $i{'this.${v.name}'} = $i{v.name} ] }
			expr: macro $b{ [ for (v in nameType) Context.parse('if (${v.name} != null) this.${v.name} = ${v.name}', Context.currentPos()) ] },
			ret:null
		}		
		fields.push({
			name: "new",
			access: [Access.APublic, Access.AInline],
			//access: [Access.APublic],
			kind: FieldType.FFun(newFun),
			pos: Context.currentPos()
		});				
		//trace(new haxe.macro.Printer(" ").printField(fields[fields.length-1]));

		
		// ------ generate copy() ------
		
		var copyFun:Function = {
			args:newAndCopyArgs,
			expr:Context.parse(
				'{var newStyle = new $className(' +
					[for (v in nameType) '(${v.name} != null) ? ${v.name} : this.${v.name}'].join(",") +
				');' +
				'newStyle.id = id;' +
				'return newStyle;}'
				,Context.currentPos()
			),
			ret: TPath({ name:className, pack:[], params:[] })
		}		
		fields.push({
			name: "copy",
			//access: [Access.APublic, Access.AInline], // better no inline here cos of neko
			access: [Access.APublic],
			//meta: [{name:":keep", pos:Context.currentPos()}],
			kind: FieldType.FFun(copyFun),
			pos: Context.currentPos()
		});		
		//trace(new haxe.macro.Printer().printField(fields[fields.length-1]));
		
		
		// ------ generate createById() ------
		
		var arguments = [ for (v in nameType) v.name].join(", ");
		var createByIdFun:Function = {
			args:[
				{name:"id", type:macro:Int, opt:false, value:null},
				{name:"style", type:TPath({ name:className, pack:[], params:[] }), opt:false, value:macro null}
			].concat([ for (v in nameType) {name:v.name, type:(v.type == null) ? null : TPath({ name:v.type.name, pack:[], params:[] }), opt:false, value:macro null} ]),
			expr:Context.parse(
				'{var newStyle = (style != null) ? style.copy($arguments) : new $className($arguments);' +
				'newStyle.id = id;' +
				'return newStyle;}'
				,Context.currentPos()
			),
			ret: TPath({ name:className, pack:[], params:[] })
		}		
		fields.push({
			name: "createById",
			//access: [Access.AStatic, Access.APublic, Access.AInline], // better no inline here cos of neko
			access: [Access.AStatic, Access.APublic],
			//meta: [{name:":keep", pos:Context.currentPos()}],
			kind: FieldType.FFun(createByIdFun),
			pos: Context.currentPos()
		});		
		//trace(new haxe.macro.Printer().printField(fields[fields.length-1]));
		
		
		// ----- Adding ID-Helpers -------
		
		fields.push({
			name:  "ID",
			access:  [Access.APrivate, Access.AStatic],
			kind: FieldType.FVar(macro:Int, macro $v{uuid} ),
			pos: Context.currentPos()
		});
		
		// ------------------------------
				
		fields.push({
			name:  "id",
			access:  [Access.APublic],
			kind: FieldType.FProp("default", "null", macro:Int, macro 0),
			pos: Context.currentPos()
		});
		
		// ------------------------------
				
		fields.push({
			name: "getUUID",
			access: [Access.APublic, Access.AInline],
			//access: [Access.APublic],
			//meta: [{name:":keep", pos:Context.currentPos()}],
			kind: FFun({
				args:[],
				expr: macro return (ID|id),
				ret: macro:Int
			}),
			pos: Context.currentPos()
		});
		
		// ------------------------------
				
		fields.push({
			name: "isFontStyle",
			access: [Access.APublic, Access.AInline],
			//access: [Access.APublic],
			//meta: [{name:":keep", pos:Context.currentPos()}],
			kind: FFun({
				args:[],
				expr: macro return (ID >= (1 << 21)),
				ret: macro:Bool
			}),
			pos: Context.currentPos()
		});

	}
}
#end
