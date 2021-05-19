package peote.ui.widget.container;
import peote.layout.LayoutContainer;
import peote.layout.LayoutOptions;
import peote.layout.ContainerType;
import peote.ui.interactive.Button;

import peote.ui.skin.Skin;
import peote.ui.skin.Style;

typedef BoxLayoutOptions = {
	> LayoutOptions,
	?skin:Skin,
	?style:Style,
}

@:access(peote.layout.LayoutContainer.childs)
@:forward
abstract Box(LayoutContainer) from LayoutContainer to LayoutContainer {
	public inline function new(boxLayout:BoxLayoutOptions = null, innerLayoutContainer:Array<LayoutContainer> = null) 
	{
		this = new LayoutContainer(ContainerType.BOX,
			new Button(0, 0, 0, 0, boxLayout.skin, boxLayout.style),
			boxLayout, innerLayoutContainer);

	}
	
	public var button(get, never):Button;
	public inline function get_button():Button return cast this.layoutElement;
	
	@:to public inline function toButton():Button return button;
	
	
	
	
	
}
