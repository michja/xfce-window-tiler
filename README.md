# xfce-window-tiler
A tiling window placement system with gaps and animated transitions

![](demo.gif)
[(watch on youtube for smoother transitions)](https://www.youtube.com/watch?v=d0XaWcGuOsg)

## About
Easily move windows around a nine segment grid with animated transitions.

## Installation
None required. Clone the repository and run tile.sh as detailed below.

## Usage
Call tile.sh with co-ordinates as parameters  
e.g. to move a window to the Top Left corner  
`./tile.sh T L`  
to stretch over more than a quarter of the screen use Middle (M)  
`./tile.sh M R`  
will cover the right side of the screen. Or  
`../tile.sh M M`  
to go full screen.

## Keyboard Shortcuts
This script works best with a numpad. The 9 section grid maps exactly onto the 1-9 keys. Recommended hotkeys are `ctrl + super + [1-9]`.

### Using numpad shortcuts separate from number row keys

Mapping shortcuts to the numbers 1-9 could be annoying if you use your top row number keys for other shortcuts like I do. One solution is to use .Xmodmap to remap the numpad keys to F keys (1 = F1, 2 = F2) and setup keyboard shortcuts for the F keys.   

That way you can double up on the amount of shortcuts within reach.  

This repo includes an .Xmodmap file which will setup the remap for you. Copy the file to your home directory.  
`cp .Xmodmap ~`  

It'll be loaded next time you login. And apply the changes now by running  
`xmodmap ~/.Xmodmap`

## Support
This script has been tested on ubuntu + XFCE. It uses XFCE workspace margins to calculate window positions. If you have issues with the positions with another window manager drop me a message and I can point you in the right direction.
