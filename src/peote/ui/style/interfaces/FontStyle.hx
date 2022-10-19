package peote.ui.style.interfaces;

#if !macro
@:remove
@:autoBuild(peote.ui.style.interfaces.FontStyleMacro.build())
interface FontStyle extends StyleID {
	
}

@:remove
class FontStyleMacro {}
#else

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.Log;

class FontStyleMacro 
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
			default: Context.error("Type for FontStyle expected", Context.currentPos());
		}
		
		#if peoteui_debug_macro
		Log.trace('preparing Fontstyle: $classname');
		#end
		
		// ------------------------------
		
		var fields = Context.getBuildFields();
		peote.ui.style.interfaces.Style.StyleMacro.preapareFields(fields, (++FontStyleMacro.UUID) << 21, classname );
		
		//for (field in fields) trace(new haxe.macro.Printer().printField(field)); trace("");
		
		return fields;
	}
	
}
#end

