
### openrl1

This project aims to create a complete, free asset pack for use with the [RogueLegacy1](https://github.com/flibitijibibo/RogueLegacy1) codebase.

A LICENSE will be determined by contributing members, but it'll be something extremely permissive like MIT, CC-BY-SA, or similar.

## Building with Docker

The easiest build process is with Docker:
```
$ make docker

# or

$ docker build -t openrl1 .
$ docker run -it -e UID=$(UID) -v $(PWD):/build -w /build --rm openrl1 make docker-all
```

## Building natively

You can also build natively. On Debian-like operating systems, install the following dependencies

```
$ sudo apt install -y make jq imagemagick unzip
```

You will also need to install [xnbcli](https://github.com/LeonBlade/xnbcli/releases/tag/v1.0.7) and add it to your `$PATH`.

## The plan

- Determine what files are required to run the game
- Replace all of them with new custom resources (sprites, sounds, music)
- Package and distribute the asset pack as a drop-in replacement for the original
- Potentially package and distribute the game code + asset pack as a full game distributable ([more info here](https://github.com/flibitijibibo/RogueLegacy1/issues/2))

## What is being worked on? What still needs to be done?

You can find information and status in the `progress.txt` file, it details which files still have yet to be replaced, if there's a process defined for replacing them, and what types the files are. I've just finished a working build process for the fonts. Check it out in `src/fonts`.

## How does process get defined

1. Unpack the files in question with [xnbcli](https://github.com/LeonBlade/xnbcli)
2. If these files can be generated via smaller primitives and scripts, do so (ttf + charset -> Arial12.png -> Font/Arial12.xnb)
3. If the files can't be generated, provide drop-in replacements (likely going to be the case for hero(ine) names, spritesheets and sounds)
4. Add it to the Makefile

## Where can we organize?

I've created a [Discord server](https://discord.gg/mp4zDfKefj) to get a quick place set up.
