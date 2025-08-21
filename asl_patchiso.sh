#!/usr/bin/bash

VM_ISO_SRC="$1"
VM_ISO_DST="$2"
DIR=$(dirname $(readlink -f $0))

ISODIR="/var/tmp/debian.iso.d"
mkdir "$ISODIR"
#ISODIR=$(mktemp -d )

"$DIR"/scripts/iso_extract.sh "$VM_ISO_SRC" "$ISODIR"
"$DIR"/scripts/iso_patch.sh "$ISODIR"

cp "$DIR"/assets/lsd.yaml "$ISODIR/install/lsd.yaml"
cp -r "$DIR"/assets/bin "$ISODIR/install/"

cat << EOF >> "$ISODIR/install/postinstall.sh"

# lsd
mkdir /target/etc/lsd
cp /cdrom/install/lsd.yaml /target/etc/lsd/config.yaml

# cmd
cp /cdrom/install/bin/* /target/usr/local/bin/
chmod +x /target/usr/local/bin/*

chroot /target /bin/bash -c '
# fix env variables
export HOME=/root
export PATH="\$PATH:/usr/local/bin"

set -x

# sudo
usermod zeus -G sudo -a

# tldr
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

# lsd
mkdir -p /root/.config/lsd/
mkdir -p /home/zeus/.config/lsd/
ln -s /etc/lsd/config.yaml /root/.config/lsd/config.yaml
ln -s /etc/lsd/config.yaml /home/zeus/.config/lsd/config.yaml

echo "alias ls='lsd'" >> /root/.bashrc
echo "alias ls='lsd'" >> /home/zeus/.bashrc

'
EOF

"$DIR"/scripts/iso_build.sh "$ISODIR" "$VM_ISO_DST"
#rm -rf "$ISODIR"