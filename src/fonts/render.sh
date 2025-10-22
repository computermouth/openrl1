#!/bin/bash -e

REAL=$(dirname $(realpath $0))

if [[ ! -n $1 || ! -f $REAL/conf/$1 ]] ; then
	echo "E: missing/bad conf"
	echo "   usage: $0 <conf>"
	echo ""
	echo "   available configs:"
	echo "   =================="
for I in $(ls $REAL/conf/*.conf); do
	echo "   - $(basename $I)"
done
	exit 1
fi

. $REAL/conf/$1

# glyph or cropping
gorc_t='{"x": 0, "y": 0, "width": 0, "height": 0}'
# kerning
kern_t='{"x": 0, "y": 0, "z": 0}'


template=$(cat $REAL/template.json)

height=-1
width_marker=0
height_marker=0
reset_counter=0

# create namespaced directory for this font
rm -rf "$REAL/png/$OUTNAME"
mkdir -p "$REAL/png/$OUTNAME"

FINAL_PNG="$OUTNAME.png"
json=$(echo $template | jq ".content.texture.export=\"$FINAL_PNG\"")

while IFS= read -r -n1 ch; do

	dec=$(printf "%d" "'$ch")

	# EOF, I guess
	if [[ "$dec" == "0" ]]; then
		continue
	fi

	# escape anything outside ascii printable
	# but still inside ascii, 255 is just a guess, probably not perfect
	# if there's ever extra \\ in the render, this is why
	if [[ $dec -lt 255 ]] \
	&& [[ ! "$ch" =~ [a-zA-Z0-9,._+:@%/-!\"#$\&\'()*] ]] \
	|| [[ $dec -eq 26479 ]] \
	|| [[ $dec -eq 26497 ]] \
	|| [[ $dec -eq 65311 ]]; \
	then
		prefix="\\\\"
	else
		prefix=""
	fi

	# get a friendly name for output
	out=$(printf "%04d" $dec)

	PNG=$REAL/png/$OUTNAME/$out.png
	LABEL="$prefix$ch"
	FONT=$REAL/ttf/$TTF

	# source the conf again
	# now that all the variables are backfilled
	. $REAL/conf/$1

	# render each character to a png
	convert $ARGS

	h=$(identify -format "%h" $REAL/png/$OUTNAME/$out.png)
	w=$(identify -format "%w" $REAL/png/$OUTNAME/$out.png)
	
	if [[ "$height" == "-1" ]]; then
		height=$h
	elif [[ "$height" != "$h" ]]; then
		echo "E: height variance $height != $h"
		exit 1
	fi
	
	# insert ch in characterMap
	json=$(echo $json | jq --arg in "$ch" '.content.characterMap += [$in]')
	# add kerning (defaults)
	kern=$(echo $kern_t | jq ".y=$w" )
	json=$(echo $json | jq ".content.kerning += [$kern]")
	
	# add glyph
	glyph=$(echo $gorc_t | jq ".x=$width_marker|.y=$height_marker|.width=$w|.height=$h")
	json=$(echo $json | jq ".content.glyphs += [$glyph]")
	
	# add cropping
	crop=$(echo $gorc_t | jq ".x=0|.y=0|.width=$w|.height=$h")
	json=$(echo $json | jq ".content.cropping += [$crop]")
	
	width_marker=$((width_marker + w))

	# this limit could be ~32000, but this is more digestable
	if [[ $width_marker -gt 2000 ]]; then
		width_marker=0
		height_marker=$h
		reset_counter=$((reset_counter+1))
		LIST=$(find $REAL/png/$OUTNAME/[0-9]*.png)
		padded_number=$(printf "%03d" "$reset_counter")
		convert $LIST +append $REAL/png/$OUTNAME/o$padded_number.png
		rm $REAL/png/$OUTNAME/[0-9]*.png
	fi
	
	## old debug code
	#~ if [[ $width_marker -eq 6781 ]]; then
		#~ echo $dec
	#~ fi

done < $REAL/charset/$CHARSET

LIST=$(find $REAL/png/$OUTNAME/[0-9]*.png)
if [[ "x$LIST" != "x" ]]; then
	reset_counter=$((reset_counter+1))
	padded_number=$(printf "%03d" "$reset_counter")
	convert $LIST +append $REAL/png/$OUTNAME/o$padded_number.png
	rm $REAL/png/$OUTNAME/[0-9]*.png
fi

json=$(echo $json | jq ".content.verticalLineSpacing=$height")

# build final texture
LIST=$(find $REAL/png/$OUTNAME/o*.png)
convert $LIST -append $REAL/xnb/$FINAL_PNG

# write out json
echo $json | jq . > $REAL/xnb/$OUTNAME.json

# build xnb
xnbcli pack $REAL/xnb/$OUTNAME.json
