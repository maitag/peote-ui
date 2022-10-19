# Peote UI - Userinterface for [peote-view](https://github.com/maitag/peote-view)

->work in progress<-

To see whats working at now look into [`samples/`](https://github.com/maitag/peote-ui/tree/master/samples) folder!


## Installation and Dependencies:

For fast opengl-rendering:
```
haxelib git peote-view https://github.com/maitag/peote-view
haxelib git peote-text https://github.com/maitag/peote-text
```


To put ui-elements into a nested layout:
```
haxelib git peote-layout https://github.com/maitag/peote-layout
```
While `PeoteUI` and it's widget-workflow is depend on [peote-layout](https://github.com/maitag/peote-layout),
you can also using `PeoteUIDisplay` and layout it manually like into sample here: [peote-layout/samples/peote-ui](https://github.com/maitag/peote-layout/tree/main/samples/peote-ui).


To map keyboard-shortcuts or using gamepad for input-control you need [input2action](https://github.com/maitag/input2action):
```
haxelib git peote-view https://github.com/maitag/input2action
```


Finally install the lib itself by:
```
haxelib git peote-view https://github.com/maitag/peote-ui
```


## How to use

There are 2 ways how to use peote-ui.

### PeoteUIDisplay

This is the simplest way where interactive elements can be placed 
directly by x/y values inside the Display with a given size.

Available elements you can add:
- UIElement (for simple buttons)
- UIDisplay (to make an peote-view Display interactive)
- UITextLine<FontStyle> (text, textinput and button)

TODO:
- UITextPage<FontStyle>  (fully textfield)


### PeoteUI 

Here the PeoteUI itself and all widgets are layout-container abstracts of [peote-layout](https://github.com/maitag/peote-layout).
So you can create a userinterface where all is contained into a nesting structure to make the inner elements scalable
in depend to the outer size. This can be useful e.g. to automatically fit your UI to different display-sizes.

Available Widgets:
- Div
- TextLine
...
(more widgets will be followed!)