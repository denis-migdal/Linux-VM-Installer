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
    VM_ISO="$tmp_iso"

    OS_VERSION="12.11.0"

    wget -O "$VM_ISO" https://cdimage.debian.org/mirror/cdimage/archive/$OS_VERSION/amd64/iso-dvd/debian-$OS_VERSION-amd64-DVD-1.iso
    
    #TODO: need to patch it...
fi

EXTRA_KERNEL_PARAMETERS="auto=true preseed/file=/cdrom/preseed.cfg priority=critical quiet splash noprompt noshell automatic-ubiquity --"

if [[ "$VM_DEBUG" == "true" ]] ; then
    EXTRA_KERNEL_PARAMETERS="DEBCONF_DEBUG=5 $EXTRA_KERNEL_PARAMETERS"
else
    HEADLESS="--type headless"
fi

VBoxManage unattended install "$VM_NAME" \
    --iso "$VM_ISO" \
    --install-additions \
    --script-template="$VM_PRESEED" \
    --post-install-command="/target/bin/bash /cdrom/install/postinstall.sh" \
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

# Brut... (can't detach non-headless)
VBoxManage controlvm "$VM_NAME" poweroff