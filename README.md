```
 _             _ _  _            ___ _   
| |-.---.---.-| | ||-|---.---.  | __| |-.
|   | -_| - | - | || |   | -_| _|__ |   |
|_|_|___|__.|__.|__|_|_|_|___||_|___|_|_|
```

headline.sh is a small Bash shell script to print banner text to the terminal
in different fonts.

Examples
--------

The default font is called Shell Sans (in file shell-sans.sf) and is expected
to be in the same directory as the main script.

```bash
./headline.sh 'bash rules!'
 _       ___ _             _      ___  _ 
| |-.---| __| |-. .---.-.-| |.---| __|| |
| - | - |__ |   | |  _| | | || -_|__ ||_|
|.__|__.|___|_|_| |_| |__.|__|___|___||_|
```

You can also change the font by setting the `HEADLINE_FONT` environment
variable:
```bash
HEADLINE_FONT=midnight.sf ./headline.sh Midnight
┌─┬─┐     ┐           ┐      
│ │ │ .   │     .     │      
│ │ │ ┐ ┌─┤ ┬─┐ ┐ ┌─┬ ├─┐ ┼  
│ │ │ │ │ │ │ │ │ │ │ │ │ │  
┴   ┴ ┴ └─┴ ┴ ┴ ┴ └─┤ ┴ ┴ └┘ 
                   ─┘
```

Font format
-----------

Font files are themselves simple Bash scripts that are sourced from the main
script. They define a few variables followed by the raw font data in heredoc
syntax.

The format for a font with only the letters 'a' and 'b' looks like this:
```
# Letter height of the font in terminal lines
letter_height=1
# Number of the first line of this file with actual font data 
data_start=13
# The characters this font defines
characters='ab'
# Simple kerning support, see below. Not used in this font.
declare -A kern_map=()
kern_width=1
# Make this file sourceable. After this line, headline.sh expects
# length(characters) * letter_height lines of font data.
return; cat <<EOF
a 
b 
EOF
```
The lines defining each letter should be of the same lenght and end in the
amount of whitespace that optimally separates adjacent letters in the final
output.

### "Kerning"

If you want -- like in Shell Sans - letters to line up and/or merge nicely,
there is some faux kerning support.
To use this, first decide on a "kerning width", which is the number of
trailing characters of each letter definition to be looked at for kerning,
the default being 1.
headline.sh first renders the text as if no kerning was specified.
Sub-strings are then replaced according to the defined `kern_map`. Each key
consists of 2 * kern_with characters to be replaced at the end of each letter.
The value specifies the replacement characters. Unmapped strings get replaced
with whitespace.

Shell Sans defines its `kern_map` as follows:
```bash
declare -A kern_map=( ['|.']='|' ['. ']='.' ['| ']='|' ['/ ']='/' ['\ ']='\')
```  

Compare Shell Sans with and without `kern_map`:
```
headline.sh a b  | HEADLINE_FONT=/tmp/nokern.sf headline.sh a b
       _         |        _   
.---. | |-.      | .---  | |-.
| - | | - |      | | -   | - |
|__.| |.__|      | |__.  |.__|
```
The version with kerning replaced the combination `. ` and `| ` with `.` and
`|`, respectively.

Bugs
----

  - Many missing characters. Completed so far are:
    * Digital: ` .:ABCDEFGHIJKLMNOPQRSTUVWXYZ`
    * Shell Sans: ` !"#$%+,-.12345:;[]_abcdefghijklmnopqrstuvwxyz|äöüCNST`
    * Midnight: `dghintM`
    * Null: ` -_.!|abcdefghijklmnopqrstuvwxyzäöüCNST`
  - Uses Bash-isms
  - Error messages could be nicer
  - No distribution packages


Copyright/License
-----------------

headline.sh version 0.3
Copyright (c)2015-2020 Christian Blichmann <headline-sh@blichmann.eu>

headline.sh is licensed under a two-clause BSD license, see the LICENSE file
for details.
