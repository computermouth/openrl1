#!/bin/bash -e

if [[ ! -n $1 || ! -n $2 || ! -n 3 || ! -n 4 ]] ; then
	echo "E: bad args"
	echo "   usage: $0 <font> <charset> <size> <output_name>"
	exit 1
fi

FILE=$1
CHARSET=$2
SIZE=$3
OUTPUT=$4

# glyph or cropping
gorc_t='{"x": 0, "y": 0, "width": 0, "height": 0}'
# kerning
kern_t='{"x": 0, "y": 0, "z": 0}'

REAL=$(dirname $(realpath $0))

template=$(cat $REAL/template.json)

height=-1
width_marker=0

out_name="$OUTPUT.png"
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
		-font $REAL/ttf/$FILE.ttf \
		-antialias \
		-pointsize $SIZE \
		label:$prefix"$ch" \
		$REAL/png/$out.png
	
	h=$(identify -format "%h" $REAL/png/$out.png)
	w=$(identify -format "%w" $REAL/png/$out.png)
	
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

done < $REAL/charset/$CHARSET.txt

json=$(echo $json | jq ".content.verticalLineSpacing=$height")

# build final texture
LIST=$(find $REAL/png/*.png)
convert $LIST +append $REAL/xnb/$out_name

# write out json
echo $json | jq . > $REAL/xnb/$OUTPUT.json

# build xnb
xnbcli pack $REAL/xnb/$OUTPUT.json
