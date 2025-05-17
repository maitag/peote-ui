# Peote UI - Userinterface for [peote-view](https://github.com/maitag/peote-view)

->work in progress<-


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
haxelib git input2action https://github.com/maitag/input2action
```


Finally install the lib itself by:
```
haxelib git peote-ui https://github.com/maitag/peote-ui
```

### Samples and usecases

Samples can be found into [peote-ui-samples](https://github.com/maitag/peote-ui-samples) repository.
Some into [peote-playground](https://github.com/maitag/peote-playground) also using it, e.g. [here](https://github.com/maitag/peote-playground/net/chat).

First usecase here: [lyapunow fractalgenerator](https://github.com/maitag/haxe-lyapunow).


## How to use

There are 2 ways how to use peote-ui.

### PeoteUIDisplay

This is the simplest way where interactive elements can be placed 
directly by x/y values inside the Display with a given size.

Available elements you can add:
- Interactive (have no Style so its hidden and only interacts)
- UIElement (for simple buttons)
- UISlider
- UIArea
- UIDisplay (to make any peote-view Display interactive)

macro generated text elements for Font<FontStyle>:
- UITextLine<FontStyle>
- UITextPage<FontStyle>

pregenerated text elements for peote.ui.tiled.FontT (Font<FontStyleTiled>):
- UITextLineT
- UITextPageT

pregenerated text elements for peote.ui.packed.FontP (Font<FontStylePacked>):
- UITextLineP
- UITextPageP



You can also put this ui-elements into layout by using peote-layout lib,
see here for some samples: [peote-layout/samples/peote-ui](https://github.com/maitag/peote-layout/tree/main/samples/peote-ui)


### PeoteUI (TODO)

Here the PeoteUI itself and all widgets are layout-container abstracts of [peote-layout](https://github.com/maitag/peote-layout).
So you can create a userinterface where all is contained into a nesting structure to make the inner elements scalable
in depend to the outer size. This can be useful e.g. to automatically fit your UI to different display-sizes.

Available Widgets at now:
- Div
- TextLine
...
(more widgets later!)