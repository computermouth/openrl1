#!/bin/bash -e

if [[ ! -n $1 || ! -n $2 ]] ; then
	echo "E: bad args"
	echo "   usage: $0 </path/to/font.ttf> <size>"
	exit 1
fi

FILE=$1
SIZE=$2

# glyph or cropping
gorc_t='{"x": 0, "y": 0, "width": 0, "height": 0}'
# kerning
kern_t='{"x": 0, "y": 0, "z": 0}'

template=$(cat template.json)

height=-1
width_marker=0

out_name="$(basename $FILE)_$SIZE.png"
json=$(echo $template | jq ".content.texture.export=\"$out_name\"")

while IFS= read -r -n1 ch; do

	dec=$(printf "%d" "'$ch")

	# EOF, I guess
	if [[ "$dec" == "0" ]]; then
		continue
	fi

	# escape anything outside this range
	if [[ ! "$ch" =~ [a-zA-Z0-9,._+:@%/-] ]]; then
		prefix="\\"
	else
		prefix=""
	fi

	# get a friendly name for output
	out=$(printf "%04d" $dec)

	# render each character to a png
	convert \
		-background none \
		-fill white \
		-font $FILE \
		-pointsize $SIZE \
		label:$prefix"$ch" \
		png/$out.png
	
	h=$(identify -format "%h" png/$out.png)
	w=$(identify -format "%w" png/$out.png)
	
	if [[ "$height" == "-1" ]]; then
		height=$h
	elif [[ "$height" != "$h" ]]; then
		echo "W: height variance $height != $h"
		height=$h
	fi
	
	# insert ch in characterMap
	json=$(echo $json | jq --arg in "$ch" '.content.characterMap += [$in]')
	# add kerning (defaults)
	json=$(echo $json | jq ".content.kerning += [$kern_t]")
	
	# add glyph
	glyph=$(echo $gorc_t | jq ".x=$width_marker|.y=0|.width=$w|.height=$h")
	json=$(echo $json | jq ".content.glyphs += [$glyph]")
	
	# add cropping
	crop=$(echo $gorc_t | jq ".x=0|.y=0|.width=$w|.height=$h")
	json=$(echo $json | jq ".content.cropping += [$crop]")
	
	width_marker=$((width_marker + w))

done < chars.txt

json=$(echo $json | jq ".content.verticalLineSpacing=$height")

# build final texture
LIST=$(find png/*.png)
convert $LIST +append xnb/$out_name

# write out json
echo $json | jq . > xnb/$(basename $FILE)_$SIZE.json
