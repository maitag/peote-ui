package peote.ui.layout;

import peote.ui.layout.NestedArray;
import peote.ui.layout.LayoutElement;

import jasper.Variable;
import jasper.Solver;
import jasper.Constraint;
import jasper.Strength;

class Layout
{
	var rootLayout:LayoutElement;
	var layoutsToUpdate:Array<LayoutElement>;
	var constraints:Array<Constraint>;
	
	var solver:Solver;
	
	public function new(rootLayout:LayoutElement=null, constraints:NestedArray<Constraint>=null) 
	{
		this.rootLayout = rootLayout;
		this.constraints = constraints;
				
		solver = new Solver();
		
		// TODO: addSuggest
		if (rootLayout != null) {
			solver.addEditVariable(rootLayout.width, Strength.create( 0, 900, 0));
			solver.addEditVariable(rootLayout.height, Strength.create( 0, 900, 0));
		}
		
		if (constraints != null) addConstraints(constraints);
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

	// ----------------- variables
	
	public function addVariable(editableLayoutVar:Variable)
	{
		if (!solver.hasEditVariable(editableLayoutVar)) {
			solver.addEditVariable(editableLayoutVar, Strength.create( 0, 900, 0));
		}
	}
	
	public function removeVariable(editableLayoutVar:Variable)
	{
		if (solver.hasEditVariable(editableLayoutVar)) {
			solver.removeEditVariable(editableLayoutVar);
		}
	}
	
	public inline function setVariable(layoutVar: Variable, value:Int):Layout
	{
		solver.suggestValue(layoutVar, value);
		return this;
	}
	
	public inline function setRootSize(width:Int, height:Int):Layout
	{
		solver.suggestValue(rootLayout.width, width);
		solver.suggestValue(rootLayout.height, height);
		return this;
	}
	
	
	// ----------------- update layoutelement positions
	public function toUpdate(layoutsToUpdate:Array<LayoutElement>=null) // TODO
	{
		this.layoutsToUpdate = layoutsToUpdate;		
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
	
	public function cleanElements()
	{
		// TODO: remove all updateChilds
	}

}

