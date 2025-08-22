#!/bin/bash

DECL () {
  if [ ! -v $1 ] ; then
    declare -g $1="$2"
  fi
}

DECL VM_LOGIN    zeus
DECL VM_ASSETS  "keys/LVMI.pub VMReady.service"

INSTALL_DIR="$1/install/"
DIR=$(dirname $(readlink -f $0))

rm -r "$INSTALL_DIR"/*

for ASSET in $VM_ASSETS; do
    cp -r "$DIR/../assets/$ASSET" -t "$INSTALL_DIR/"
done

cat <<EOF > "$INSTALL_DIR/postinstall.sh"
#!/usr/bin/bash

set -x

cp /cdrom/install/postinstall.sh -t /target/root/

mkdir /target/home/$VM_LOGIN/.ssh
cp /cdrom/install/LVMI.pub -T /target/home/$VM_LOGIN/.ssh/authorized_keys

cp /cdrom/install/VMReady.service -t /target/etc/systemd/system/
ln -s /etc/systemd/system/VMReady.service /target/etc/systemd/system/multi-user.target.wants/VMReady.service

sed -i 's#GRUB_TIMEOUT=5#GRUB_TIMEOUT=0#' /target/etc/default/grub
echo "GRUB_TIMEOUT_STYLE=hidden" >> /target/etc/default/grub

chroot /target update-grub
#in-target update-grub

# dunno why we need to manually edit /boot/grub/grub.cfg
sed -i 's#timeout=5#timeout=0#g' /target/boot/grub/grub.cfg
sed -i 's#timeout_style=menu#timeout_style=hidden#g' /target/boot/grub/grub.cfg

echo 'http_proxy="$http_proxy"' >> /target/etc/environment
echo 'https_proxy="$https_proxy"' >> /target/etc/environment

EOF