#!/usr/bin/bash
# https://wiki.debian.org/ManipulatingISOs#Appending_Boot_Parameters_to_the_ISO

ISODIR="$1"
DST_ISO="$2"

genisoimage -r -J -b isolinux/isolinux.bin -c isolinux/boot.cat \
	-no-emul-boot -boot-load-size 4 -boot-info-table \
	-o "$DST_ISO" "$ISODIR"

# isohybrid "$DST_ISO"