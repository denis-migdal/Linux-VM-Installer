#!/usr/bin/bash

VM_NAME="$1"

DECL () {
  if [ ! -v $1 ] ; then
    declare -g $1="$2"
  fi
}

DECL USER          "zeus"

# TODO: preseed generate
DIR=$(dirname $(readlink -f $0))
ISO=$(echo "$DIR"/../debian-*-amd64-DVD-1.iso)
ADDON_ISO=$(echo "$DIR"/../VBoxGuestAdditions_*.iso)
PRESEED="${args['--preseed']}"
# "--type headless"

# Install Debian
VMREADY_SERVICE=$(cat <<- EOF
    [Unit]
    Description=VMReady
    After=sshd.target

    [Service]
    Type=simple
    User=root
    ExecStart=/usr/bin/VBoxControl guestproperty set VMReady true

    [Install]
    WantedBy=multi-user.target
EOF
)

POST_INSTALL=$(cat <<- CEOF
    echo "$VMREADY_SERVICE" > /target/etc/systemd/system/VMReady.service
    ln -s /etc/systemd/system/VMReady.service /target/etc/systemd/system/multi-user.target.wants/VMReady.service
    
    echo 'http_proxy="http://proxyau.iut.uca.fr:8080"' >> /target/etc/environment
    echo 'https_proxy="http://proxyau.iut.uca.fr:8080"' >> /target/etc/environment
    
    #TODO: Other post install
CEOF
)

VBoxManage unattended install "$VM_NAME" \
    --iso "$ISO" \
    --install-additions --additions-iso="$ADDON_ISO" \
    --script-template="$PRESEED" \
    --user="$USER" \
    --proxy "$http_proxy" \
    --post-install-command="/target/bin/bash -c '$POST_INSTALL'"

# Start VM for install
VBoxManage startvm "$VM_NAME" $HEADLESS

# TODO: wait for shutdown
VBoxManage guestproperty wait "$VM_NAME" VMReady

echo "==== DONE ===="

# Brut... (can't detach non-headless)
VBoxManage controlvm "$VM_NAME" poweroff