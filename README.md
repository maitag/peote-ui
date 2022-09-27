# Peote UI - Userinterface for [peote-view](https://github.com/maitag/peote-view)

->work in progress<-

To see whats working at now look into [`samples/`](https://github.com/maitag/peote-ui/samples) folder!


## Installation and Dependencies:

for fast opengl-rendering:
```
haxelib git peote-view https://github.com/maitag/peote-view
haxelib git peote-view https://github.com/maitag/peote-text
```

While `PeoteUI` and it's widget-workflow is depend on:
```haxelib git peote-view https://github.com/maitag/peote-layout```
you can also using `PeoteUIDisplay` and layout it manually like into sample here: [peote-layout/samples/peote-ui](https://github.com/maitag/peote-layout/tree/main/samples/peote-ui).

To map keyboard-shortcuts or using gamepad for input-control:
```haxelib git peote-view https://github.com/maitag/input2action```

Finally install the lib itself by:
```haxelib git peote-view https://github.com/maitag/peote-ui```

## How to use

There are 2 ways how to use peote-ui.

### PeoteUIDisplay (extends [peote-view](https://github.com/maitag/peote-view) Display)

This is the simplest way where interactive elements can be placed 
directly by x/y values inside the Display with a given size.

Available elements you can add:
- UIElement
- UIDisplay (extends peote-view Display)
- UITextLine<FontStyle>

TODO:
- UITextPage<FontStyle> 


### PeoteUI 

Here the PeoteUI itself and all widgets are layout-container abstracts of [peote-layout](https://github.com/maitag/peote-layout).
So you can create a userinterface where all is contained into a nesting structure to make the inner elements scalable
in depend to the outer size. This can be useful e.g. to automatically fit your UI to different display-sizes.

Available Widgets:
- Div
- TextLine
...
(more widgets will be followed)