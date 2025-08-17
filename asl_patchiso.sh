#!/usr/bin/bash

VM_ISO_SRC="$1"
VM_ISO_DST="$2"
DIR=$(dirname $(readlink -f $0))

ISODIR=$(mktemp -d /tmp/XXXXXX.iso)

"$DIR"/scripts/iso_extract.sh "$VM_ISO_SRC" "$ISODIR"

"$DIR"/scripts/iso_patch.sh "$ISODIR"

cat << EOF >> "$ISODIR/install/postinstall.sh"
#TLDR
chroot /target /bin/bash -c '
# fix env variables
export HOME=/root
export PATH="\$PATH:/usr/local/bin"

set -x
echo "\$PATH" > /PATH
pipx install pipx
apt purge -y --autoremove pipx
/root/.local/bin/pipx install --global pipx
hash -r
pipx install --global tldr

# cache (> 100 years)
echo "TLDR_CACHE_MAX_AGE=1000000" >> /etc/environment
mkdir /usr/local/share/tldr
mkdir /home/zeus/.cache
chown -R zeus:zeus /home/zeus/.cache
ln -s /usr/local/share/tldr /home/zeus/.cache/tldr
ln -s /usr/local/share/tldr /root/.cache/tldr
tldr -u
'
EOF

"$DIR"/scripts/iso_build.sh "$ISODIR" "$VM_ISO_DST"
rm -rf "$ISODIR"