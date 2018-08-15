# LED marquee mod 

*by Vanessa Dannenberg*

This mod provides set of alphanumeric LED marquee panels, controlled by Mesecons' Digilines mod.

Simply place a panel segment, right-click it, and set a channel.

Then send a character, or one of several control words to that channel from a Mesecons Lua Controller and the mod will try to display it.

The panels respond to singular characters from the standard 7-bit ASCII character set, or entire strings composed of such.

A single character will be displayed on the connected panel.

Strings will be displayed to all panels in a lineup, so long as they all face the same way, starting from the panel the Lua Controller is connected to, going left to right.  The other panels in the line do not need to be connected to anything - think of them as being connected together internally.  Only the panel at the far left need be connected to the Lua Controller.

The string will spread until either a panel is found that faces the wrong way, or has a channel that's not empty/nil and is set to something other than what the first is set to, or if a node is encountered that is not an alpha-numeric panel at all.

Panels to the left of the connected one are ignored in the case of strings.

You can put multiple lines of panels end to end to form independent displays, so long as the panels that start each of the lines have unique channel names set.

The string is padded with spaces and then trimmed to 64 characters.

Any unrecognized symbol or character outside the ASCII 32 - 129 range, whether part of a string or singularly is ignored.

The panels also respond to these control messages:

* "off", "colon" and "period" act the same as on the numeric panels.  Note that neither a colon nor a period actually look all that great on a 15-segment
  display, so use a classic panel for those, if you can.
* "del" or character code 127 displays an all-on square, but without segment #15 (the bottom, chevron-shaped one).
* "allon" or character code 128 will display an all-on square, with segment #15 lit also.
* "cursor" or character code 129 will display just segment 15.
* "off_multi" turns all panels in a lineup off
* "allon_multi" turns on all segments of all panels in a lineup.

You can use "get" and "getstr" to read the one character from the first, connected panel.  These messages will not read the other panels in the lineup.

All panels emit a small amount of light when displaying something.

The panels only mount on a wall.
