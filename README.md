This mod provides set of alphanumeric LED marquee panels, controlled by Mesecons' Digilines mod.

Simply place one or more panels, and set a channel on just the left-most or upper-left one.

Then send a character, a string, or one of several control words or codes to that channel from a Mesecons Lua Controller and the mod will try to display it.

A single character will be displayed on the connected panel. A numeric message (i.e. not a string) will display the first digit on the connected panel.

Strings will be displayed using all panels in a lineup, so long as they all face the same way, starting from the panel the Lua Controller is connected to, going left to right. The other panels in the line do not need to be connected to anything - think of them as being connected together internally. Only the panel at the far left need be connected to the Lua Controller.

The string will spread down the line until either a panel is found that faces the wrong way, or has a channel that's not empty/nil and is set to something other than what the first is set to, or if a node is encountered that is not an alpha-numeric panel at all.

Panels to the left of the connected one are ignored (unless they, too, have their own connections).

You can also stack up a wall of LED panels, of any horizontal and vertical amount. If you then set a channel on the upper left panel, leave the others un-set, and connect a LuaController to it via digilines, the whole wall of panels will be treated as a multi-line display.

Long strings sent to that channel will be displayed starting at the upper-left and working from left to right, top to bottom, wrapping from line to line as appropriate (similar to printing to a shell terminal).

As with a single line, printing continues from node to node until the program either finds a panel with a different non-empty channel than the first one, or if it finds a panel that's facing the wrong way.

If the program finds something other than a panel, it wraps to the next line. If it finds something other than a panel twice in a row, that signals that text has wrapped off of the last row, and printing is cut off there.

Lines of panels don't need to be all the same length, the program will wrap as needed, with the left margin always being aligned with the panel the LuaController is connected to.

Strings are trimmed to 1 kB.

Panels are not erased between prints.

Any unrecognized symbol or character, whether part of a string or singularly is ignored, except as noted below.

This mod uses the full ISO-8859-1 character set (see https://en.wikipedia.org/wiki/ISO/IEC_8859-1 for details), plus a bunch of symbols stuffed into the normally-empty 128-159 range that should be useful on this sort of display:

* 128,129: musical notes
* 130-140: box drawing glyphs
* 141-144: block shades
* 145-152: arrows
* 153-156: explosion/splat
* 157-159: smileys

If a string is prefixed with character code 255, it is treated as UTF-8 and passed through a simple translation function.  Only characters with codes greater than 159 are altered; normal ASCII text, color codes, control codes, and the above symbols are passed through unchanged.  Note that in this mode, a character code over 159 is treated as the first byte of a two-byte symbol.

The panels also respond to these control messages:

* "off_multi" or "clear" turns all panels in a lineup or wall off - essentially a "clear screen" command.
* "allon_multi" turns on all LEDs of all panels in a lineup/wall (by filling them with char #144, i.e. the reverse of "clear").
* "start_scroll" starts the last-displayed message scrolling to the left, automatically moving, and automatically re-starting.  The scroll action will spread across and down a multi-line wall (just set a new, different channel on the first row you want to exclude).
* "stop_scroll" actually does nothing, since all printable messages automatically stop the timer, but it's a human-readable way to indicate it.
* "scroll_speed" followed by a decimal number (in the string, not a byte value) sets the time between scroll steps.  Minimum 0.5s, maximum 5s.
* "scroll_step" will immediately advance the last-displayed message by one character.  Omit the "start_scroll" and "scroll_speed" keywords, and use this instead if you want to let your LuaController control the scrolling speed.

If you need vertical scrolling, you will have to handle that yourself (since the size of a screen/wall is not hard-coded).

A byte value of 0 to 27 in a string will change colors (i.e. string.char(0 to 27) ).

Color values 0 to 11 are:

Red (0), orange, yellow, lime, green, aqua, cyan, sky blue, blue, violet, magenta, or red-violet (11)

Colors 12 to 23 are the same as 0 to 11, but lower brightness.

Colors 24 - 27 are white, light grey, medium grey, and dim grey (or think of them as full bright white, a bit less bright, medium brightness, and dim white).

The last color that was used is stored in the left-most/upper-left "master" panel's metadata, and defaults to red. It should persist across reboots.

A byte value of 28 in a string will act as a line feed (I would have used 10, but that's a color code :-P )

A byte value of 29 in a string signals a cursor position command. The next two byte values select a column and row, respectively. The next character after the row byte will be printed there, and the rest of the string then continues printing from that spot onward with normal line wrapping, colors and so forth. Note that any string that does NOT contain cursor positioning commands will automatically start printing at the upper-left.

Any number of color, line feed, and cursor position commands may be present in a string, making it possible to "frame-buffer" a screen full of text into a string before printing it.

You can use "get" and "getstr" to read the one character from the connected panel. These messages will not read the other panels in the lineup/wall.

All panels emit a small amount of light when displaying something.

The panels only mount on a wall.

The "master"/connected panel stores the last-displayed message and some other details in its metadata, so you may occasionally need to dig and re-place the panel if things go wonky (this won't happen during normal use, but it may happen if you're making lots of changes to the panels' layout, channel names, etc)
