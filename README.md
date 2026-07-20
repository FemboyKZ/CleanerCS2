# CleanerCS2

A simple Metamod plugin that allows you to filter out console prints with regular expressions.
Supports both Windows and Linux.

## Example config

```txt
// Write regular expression in here to prevent them from being printed in the console
.*UNEXPECTED LONG FRAME DETECTED.*
.*weapon services didn't find a shoot position.*
.*generating substitute command \d+ from \d+.*
```

## Installation

1. Download the latest release from the [releases page](https://github.com/Source2ZE/CleanerCS2/releases/)
2. Extract the contents of the archive to your server's `addons` directory
3. Edit the `addons/cleanercs2/config.cfg` file to your liking (see the example config above)

## Commands

- `conclear_reload` - Reloads the configuration file

## Building from source

### Xmake

[Xmake](https://xmake.io/#/getting_started) is used to build the project.

1. Clone the repository and its submodules
2. Run `xmake` in the root directory of the repository

### Docker

```sh
docker compose run --rm --build build
```

To build without compose:

```sh
docker build -t cleanercs2-build .
docker run --rm -v "$PWD/output:/output" cleanercs2-build
```

### AMBuild

(re2 static at `/opt/re2`):

```sh
mkdir build && cd build
python3 ../configure.py --enable-optimize --re2-root /opt/re2
ambuild
```
