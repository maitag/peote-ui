package peote.ui.layout;

import utils.NestedArray;
import peote.ui.layout.LayoutElement;

import jasper.Variable;
import jasper.Solver;
import jasper.Constraint;
import jasper.Strength;

class Layout
{
	var rootLayout:LayoutElement;
	var editableLayoutVars:Array<Variable>;
	var layoutsToUpdate:Array<LayoutElement>;
	var constraints:Array<Constraint>;
	
	var solver:Solver;
	
	public function new(rootLayout:LayoutElement=null, constraints:NestedArray<Constraint>=null) 
	{
		this.rootLayout = rootLayout;
		this.constraints = constraints;
				
		solver = new Solver();
		
		if (rootLayout != null) {
			solver.addEditVariable(rootLayout.width, Strength.create( 0, 900, 0));
			solver.addEditVariable(rootLayout.height, Strength.create( 0, 900, 0));
		}
		
		if (constraints != null) addConstraints(constraints);
	}
	
	public function toSuggest(editableLayoutVars:Array<Variable>=null) // TODO
	{
		this.editableLayoutVars = editableLayoutVars;
		if (editableLayoutVars != null) {
			for (editableLayoutVar in editableLayoutVars) {
				solver.addEditVariable(editableLayoutVar, Strength.create( 0, 900, 0));
			}
		}
	}
	
	public function toUpdate(layoutsToUpdate:Array<LayoutElement>=null) // TODO
	{
		this.layoutsToUpdate = layoutsToUpdate;		
	}
	
	public inline function addConstraints(constraints:Array<Constraint>):Layout
	{
		for (constraint in constraints) {
			solver.addConstraint(constraint);
		}
		return this;
	}
	
	public inline function removeConstraints(constraints:Array<Constraint>):Layout
	{
		for (constraint in constraints) {
			solver.removeConstraint(constraint);
		}
		return this;
	}
	
	public inline function addConstraint(constraint:Constraint):Layout
	{
		solver.addConstraint(constraint);
		return this;
	}
	
	public inline function removeConstraint(constraint:Constraint):Layout
	{
		solver.removeConstraint(constraint);
		return this;
	}
	
	public inline function suggestValues(values:Array<Int>):Layout
	{
		var start:Int = 0;
		if (rootLayout != null) {
			solver.suggestValue(rootLayout.width, values[0]);
			solver.suggestValue(rootLayout.height, values[1]);
			start = 2;
		}
		if (editableLayoutVars != null) {
			for (i in start...values.length) {
				solver.suggestValue(editableLayoutVars[i], values[i]);
			}
		}
		return this;
	}
	
	public inline function suggest(layoutVar: Variable, value:Int):Layout
	{
		solver.suggestValue(layoutVar, value);
		return this;
	}
	
	public inline function update()
	{
        solver.updateVariables();
		if (rootLayout != null) {
			rootLayout.update();
			rootLayout.updateChilds();
		}
		if (layoutsToUpdate != null) {
			for (layout in layoutsToUpdate) layout.update();
		}		
	}

}

