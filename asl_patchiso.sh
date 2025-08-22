#!/usr/bin/bash

VM_ISO_SRC="$1"
VM_ISO_DST="$2"

#ISODIR=$(mktemp -d)
ISODIR="/var/tmp/debian.iso.d"
mkdir "$ISODIR"

export VM_ASSETS="screenrc bin lsd.yaml keys/LVMI.pub VMReady.service"

DIR=$(dirname $(readlink -f $0))
"$DIR"/scripts/iso_extract.sh "$VM_ISO_SRC" "$ISODIR"
"$DIR"/scripts/iso_patch.sh "$ISODIR"

cat << EOF >> "$ISODIR/install/postinstall.sh"

# screenrc
cp /cdrom/install/screenrc -t /target/etc/

# lsd
mkdir /target/etc/lsd
cp /cdrom/install/lsd.yaml -T /target/etc/lsd/config.yaml

# cmd
cp /cdrom/install/bin/* -t /target/usr/local/bin/
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