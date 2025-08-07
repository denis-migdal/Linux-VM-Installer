#!/usr/bin/bash

VM_NAME="$1"

DECL () {
  if [ ! -v $1 ] ; then
    declare -g $1="$2"
  fi
}

DECL VM_LOGIN zeus

# Preseed (read from input if not given)
if [[ $2 == "-" ]] ; then
    tmp_preseed=$(mktemp /tmp/preseed.XXXXXX)
    cat > "$tmp_preseed"
    VM_PRESEED="$tmp_preseed"
else
    VM_PRESEED="$2"
fi

if [ ! -v "VM_ISO" ] ; then

    tmp_iso=$(mktemp /tmp/debian.XXXXXX.iso)

    wget -O "$tmp_iso" https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-12.11.0-amd64-DVD-1.iso
    
    VM_ISO="$tmp_iso"
fi
if [ ! -v "VM_ADDON" ] ; then

    tmp_addon=$(mktemp /tmp/addon.XXXXXX.iso)

    wget -O "$tmp_addon" https://download.virtualbox.org/virtualbox/7.0.0_BETA3/VBoxGuestAdditions_7.0.0_BETA3.iso
    
    VM_ADDON="$tmp_addon"
fi

EXTRA_KERNEL_PARAMETERS="auto=true preseed/file=/cdrom/preseed.cfg priority=critical quiet splash noprompt noshell automatic-ubiquity --"

if [[ "$VM_DEBUG" == "true" ]] ; then
    EXTRA_KERNEL_PARAMETERS="DEBCONF_DEBUG=5 $EXTRA_KERNEL_PARAMETERS"
else
    HEADLESS="--type headless"
fi

# Install Debian
DIR=$(dirname $(readlink -f $0))
VMREADY_SERVICE=$(cat "$DIR"/vmready.service)

# TODO: grub...
POST_INSTALL=$(cat <<- CEOF
    echo "$VMREADY_SERVICE" > /target/etc/systemd/system/VMReady.service
    ln -s /etc/systemd/system/VMReady.service /target/etc/systemd/system/multi-user.target.wants/VMReady.service
    
    cp /target/opt/VBoxGuestAdditions-*/bin/VBoxControl /target/opt/VBoxGuestAdditions-*/bin/VBoxClient

    echo 'http_proxy="$http_proxy"' >> /target/etc/environment
    echo 'https_proxy="$https_proxy"' >> /target/etc/environment
CEOF
)

# cp Ctrl -> Client due to bug :
# https://forums.virtualbox.org/viewtopic.php?p=533624#p533624

VBoxManage unattended install "$VM_NAME" \
    --iso "$VM_ISO" \
    --install-additions --additions-iso="$VM_ADDON" \
    --script-template="$VM_PRESEED" \
    --post-install-command="/target/bin/bash -c '$POST_INSTALL'" \
    --extra-install-kernel-parameters="$EXTRA_KERNEL_PARAMETERS" \
    --user "$VM_LOGIN"

# Start VM for install
VBoxManage startvm "$VM_NAME" $HEADLESS

# Waiting end of installation
VBoxManage guestproperty wait "$VM_NAME" VMReady

# remove temporary files.
if [ -v tmp_preseed ] ; then
    rm "$tmp_preseed"
fi
if [ -v tmp_iso ] ; then
    rm "$tmp_iso"
fi
if [ -v tmp_addon ] ; then
    rm "$tmp_addon"
fi

echo "==== DONE ===="

# Brut... (can't detach non-headless)
VBoxManage controlvm "$VM_NAME" poweroff

echo "==== DONE2 ===="