# Peote UI - Samples

There are 3 ways how to use peote-ui.


## UIDisplay (extends peote-view Display)

This is the simplest way where interactive elements can be placed 
directly by x/y values inside the Display with a given size.

Available elements to add:
- InteractiveElement
- InteractiveTextLine<FontStyle>
- InteractiveDisplay (extends peote-view Display)



## LayoutedUIDisplay (extends peote-view Display)

The Display and layouted elements can be bind to containers of peote-layout lib.
Position, size and masking depends on the container settings into a nested layout-tree.

Available elements to add:
- LayoutedElement (extends InteractiveElement)
- LayoutedTextLine<FontStyle> (extends InteractiveTextLine)
- LayoutedDisplay (extends peote-view Display)



## PeoteUI 

Here the PeoteUI itself and all widgets are layout-container abstracts of peote-layout.

Available Widgets:
- Div
- TextLine
