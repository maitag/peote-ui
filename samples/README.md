# Peote UI - Samples

There are 2 ways how to use peote-ui.


## PeoteUIDisplay (extends [peote-view](https://github.com/maitag/peote-view) Display)

This is the simplest way where interactive elements can be placed 
directly by x/y values inside the Display with a given size.

Available elements you can add:
- UIElement
- UIDisplay (extends peote-view Display)
- UITextLine<FontStyle>

TODO:
- UITextPage<FontStyle> 

You can also put this ui-elements into layout by using peote-layout lib,
see here for some samples: [peote-layout/samples/peote-ui](https://github.com/maitag/peote-layout/tree/main/samples/peote-ui)


## PeoteUI 

Here the PeoteUI itself and all widgets are layout-container abstracts of [peote-layout](https://github.com/maitag/peote-layout).
So you can create a userinterface where all is contained into a nesting structure to make the inner elements scalable
in depend to the outer size. This can be useful e.g. to automatically fit your UI to different display-sizes.

Available Widgets:
- Div
- TextLine
...
(more widgets will be followed soon!)