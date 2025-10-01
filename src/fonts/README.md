
## How to replace fonts

The font workflow is basically the following:
 - look at what fonts they're using for what (unpack Arial12.xnb, look at the .png)
 - make a list of the characters they use (characterMap in Arial12.json)
 - grab a new font that looks close (I found an Arial clone on Google Fonts (make sure it's got a usable LICENSE))
 - rebake the font textures with the new font and the old character list
   - put the charset (a file containing each used character) in `charset/$yourfile.txt`
   - add the font and it's license to `ttf`
   - TODO -- rework the `png` folder so that its more reusable
   - `./render.sh FONTNAME CHARSET FONTSIZE OUTPUTNAME`
   - for our Arial12 replacement, thats: `./render.sh Arimo-Bold Arial12 16 Arial12`
   - copy `xnb/Arial12.xnb` to your RogueLegacy/Content/Fonts directory


## Things that need work

1. `png` directory is going to get dirty between builds, encapsulate it somewhere
2. script only works for ASCII for now, pretty likely we'll need UTF8
   a. I did previously have UTF8 working with `pango` instead of `label` for imagemagick (convert), but it does some shitty anti-aliasing that I didn't like, but will have to do if we need utf8

## Things that were intentionally left out

- font kerning
- font clipping
- atlas packing

Kerning is probably going to be the biggest difference, but still something I don't feel is important at the moment.

Atlas packing -- the new Arial12.png is 3KB larger than the old one, who cares.
   
