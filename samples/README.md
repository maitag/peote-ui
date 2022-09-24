# Peote UI - Samples

There are 2 ways how to use peote-ui.


## UIDisplay (extends [peote-view](https://github.com/maitag/peote-view) Display)

This is the simplest way where interactive elements can be placed 
directly by x/y values inside the Display with a given size.

Available elements to add:
- InteractiveElement
- InteractiveTextLine<FontStyle>
- InteractiveTextPage<FontStyle> (TODO!)
- InteractiveDisplay (extends peote-view Display)

You can also put this ui-elements into layout by using peote-layout lib,
see here for some samples: ...


## PeoteUI 

Here the PeoteUI itself and all widgets are layout-container abstracts of [peote-layout](https://github.com/maitag/peote-layout).

Available Widgets:
- Div
- TextLine
...