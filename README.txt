    **********************
    *   Mindsweeper 1.0  *
    * (c)Lauren Rad 2024 *
    **********************

See LICENSE for license information.

--Compatibility--
Compatible with Tandy Color Computer systems with 16K memory and up, using Color BASIC or Extended Color BASIC.
Use tape image "sweep.wav" for standard BASIC, "sweepext.wav" for Extended BASIC.
Not currently compatible with Dragon systems or DISK BASIC systems. Feel free to port it over though if you want.

--Objective--
Reveal all tiles that aren't mines. You know how it works.
The upper left tile is 'safe'. This will never have a mine.

--Controls--
Up/W: Move cursor up
Left/A: Move cursor left
Down/S: Move cursor down
Right/D: Move cursor right
Space: Reveal a tile
F: Flag a tile

--Technical Stuff--
This is written in BASIC with ASM routines to allow for use of hi-res graphics on standard BASIC.
The common source file SWPG.BAS is not intended to be run directly; SWPZ.BAS and SWPZX.BAS are for standard and extended BASIC respectively.
If making any edits to the common source file, use the "basic_crunch.awk" script (uses gawk extensions). This will reduce the source size from a readable form, and use live comments in the original source to produce code for the target platform (standard or extended).
Thanks to Ciaran Anscomb for the XRoar emulator and asm6809 assembler; these were used extensively to create this.
Use asm6809_to_bas.py to take the text listing output from asm6809 and turn it into a list of integers for DATA statements.

--Other--
You can contact me at lauren@cybertapes.com for any questions. Thanks for checking it out!

