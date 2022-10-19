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

		#if peoteui_debug_macro
		var classname:String = switch (Context.getLocalType()) {
			case TInst(t, _): t.toString();
			default: Context.error("Type for Style expected", Context.currentPos());
		}
		Log.trace('preparing Style: $classname');	
		#end
		
		// ------------------------------

		var fields = Context.getBuildFields();		
		StyleMacro.preapareFields(fields, (++StyleMacro.UUID) << 11 );
		
		//for (field in fields) trace(new haxe.macro.Printer().printField(field)); trace("");
		
		return fields;
	}

	
	// ----------------------------------------------------------------------
	// ------------ for both, Style and FontStyle macro ---------------------
	// ----------------------------------------------------------------------
				
	static inline public function preapareFields(fields:Array<Field>, uuid:Int)
	{
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
