#!/usr/bin/bash

DIR=$(realpath `dirname $0`)

VM_NAME="ASLO"
VM_DIR=~/scratch/"$VM_NAME"

export VM_EXTRA_PACKAGES="openssh-server pipx"
export VM_POSTINSTALL=$(cat << EOF
#TLDR
in-target pipx install pipx
in-target apt purge -y --autoremove pipx
in-target hash -r
in-target pipx ensurepath --global

in-target pipx install tldr
in-target ln -s /root/.cache/tldr /home/zeus/.cache/tldr
in-target tldr -u
EOF
)

"$DIR"/scripts/vm_create.sh $VM_NAME "$VM_DIR"
sleep 1
"$DIR"/scripts/preseed.sh | "$DIR"/scripts/vm_install.sh $VM_NAME -

"$DIR"/scripts/vm_export.sh $VM_NAME "$VM_DIR"/$VM_NAME.ova