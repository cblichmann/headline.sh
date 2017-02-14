#!/bin/bash
# headline.sh version 0.2
# Copyright (c)2015-2017 Christian Blichmann
#
# ASCII-art font renderer
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

# Implements GNU's "readlink -f" portably.
canonical_path()
{
	file=$1
	cd $(dirname "$file")
	file=$(basename "$file")
	limit=0
	while [ -L "$file" -a $limit -lt 1000 ]; do
		file=$(readlink "$file")
		cd "$(dirname "$file")"
		file=$(basename "$file")
		limit=$(($limit+1))
	done
	echo "$(pwd -P)/$file"
}

# Change to the directory of this script.
THIS=$(basename "$0")
THIS_DIR=$(dirname "$(canonical_path "$0")")
cd "$THIS_DIR"

HEADLINE_FONT=${HEADLINE_FONT:-shell-sans.sf}
if [ ! -r "$HEADLINE_FONT" ]; then
	>&2 echo "$THIS: cannot access font file '$HEADLINE_FONT'"
	exit 2
fi

# Source font file and build character map.
. "$HEADLINE_FONT"
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
