#!/usr/bin/bash
# https://wiki.debian.org/ManipulatingISOs#Appending_Boot_Parameters_to_the_ISO

SRC_ISO="$1"
ISODIR="$2"

bsdtar -xf "$SRC_ISO" -C "$ISODIR"
chmod -R +w "$ISODIR"