#!/bin/bash

# Change to the directory of this script.
cd "$(dirname "$0")" && cd "$(pwd -P)"

# Source font file and build character map.
HEADLINE_FONT=${HEADLINE_FONT:-shell-sans.sf}
. $HEADLINE_FONT
declare -A HEADLINE_MAP
for ((i=0;i<${#characters};i++)); do
	HEADLINE_MAP[${characters:i:1}]=$i;
done

render_text()
{
	declare -a lines
	for ((i=0;i<${#1};i++)); do
		j=0
		c=${1:i:1}
		let letter_start=${HEADLINE_MAP[$c]}*letter_height+data_start
		while read -r line; do
			cur_line=${lines[j]:0:-$kern_width}
			cur_last=${lines[j]:(-$kern_width)}
			new_first=${line::$kern_width}
			new_line=${line:$kern_width}
			kern=${kern_map["$cur_last$new_first"]-$new_first}
			lines[j]="$cur_line$kern$new_line"
			((j++))
			# Use process substution to avoid spawning a subshell, this
			# renders a single character.
		done < <(tail -n+$letter_start $HEADLINE_FONT | head -n$letter_height)
	done
	for ((i=0;i<letter_height;i++)); do
		echo ${lines[$i]}
	done
}

IFS=''
while read -r line; do render_text "$line"; done < \
	<([ -n "$1" ] && echo "$@" || cat)
