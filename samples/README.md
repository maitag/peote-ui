# Peote UI - Samples

There are 3 ways how to use peote-ui.


## UIDisplay (extends [peote-view](https://github.com/maitag/peote-view) Display)

This is the simplest way where interactive elements can be placed 
directly by x/y values inside the Display with a given size.

Available elements to add:
- InteractiveElement
- InteractiveTextLine<FontStyle>
- InteractiveDisplay (extends peote-view Display)



## LayoutedUIDisplay (extends UIDisplay)

This kind of Display and it's elements can be bind to containers of [peote-layout](https://github.com/maitag/peote-layout) lib,
so position, size and masking will be set automatically by the layout.

Available elements to add:
- LayoutedElement (extends InteractiveElement)
- LayoutedTextLine<FontStyle> (extends InteractiveTextLine<FontStyle>)
- LayoutedDisplay (extends InteractiveDisplay)



## PeoteUI 

Here the PeoteUI itself and all widgets are layout-container abstracts of [peote-layout](https://github.com/maitag/peote-layout).

Available Widgets:
- Div
- TextLine
