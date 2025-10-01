
### openrl1

This project aims to create a complete, free asset pack for use with the [RogueLegacy1](https://github.com/flibitijibibo/RogueLegacy1) codebase.

A LICENSE will be determined by contributing members, but it'll be something extremely permissive like MIT, CC-BY-SA, or similar.

## The plan

- Determine what files are required to run the game
- Replace all of them with new custom resources (sprites, sounds, music)
- Package and distribute the asset pack as a drop-in replacement for the original
- Potentially package and distribute the game code + asset pack as a full game distributable ([more info here](https://github.com/flibitijibibo/RogueLegacy1/issues/2))

## What is being worked on?

I've just finished a working build process for the fonts. So far it only works for solid color ascii fonts. Check it out in `src/fonts`.

## What still needs to be done?

There's a file at the root of this repository `files.txt` marking which files still have yet to be replaced, and what types the files are.

## How are we gonna replace those files?

There's a few XNB packers/unpackers I found out there that can be used against to original data to get info like how the fonts and sprites are packed. Here's [a web-based one](https://lybell-art.github.io/xnb-js/). For the fonts I've been using [xnbcli](https://github.com/LeonBlade/xnbcli)

## Where can we organize?

I've created a [Discord server](https://discord.gg/mp4zDfKefj) to get a quick place set up.
