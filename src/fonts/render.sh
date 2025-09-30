#!/bin/bash -e

if [[ ! -n $1 || ! -n $2 ]] ; then
	echo "E: no directory provided"
	echo "   usage: $0 <font.ttf> <size>"
	exit 1
fi

FILE=$1
SIZE=$2

while IFS= read -r -n1 ch; do
# ch=$(printf "\\U0021")
# convert -background none -fill white -font ./arimo/Arimo-Regular.ttf -pointsize 12 pango:$ch out.png
# ^ something like this


  #~ # convert char to hex, usable as filename
  #~ fname=$(printf "%s" "$ch" | xxd -p)
  #~ printf "%s" "$ch" | convert -background none -fill white -font $FILE -pointsize $SIZE \
    #~ label:@- "output/dirname/$SIZE_$fname.png"
done < chars.txt

