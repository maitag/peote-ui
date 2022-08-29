package peote.ui.style.interfaces;

@:allow(peote.ui)
interface Style {
	private function getID():Int;
	public var id(default, null):Int;
}
