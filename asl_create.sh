#!/usr/bin/bash

DIR=$(realpath `dirname $0`)

VM_NAME="ASLO"
VM_DIR=~/scratch/"$VM_NAME"

export VM_EXTRA_PACKAGES="openssh-server pipx lsd gdu trash-cli sudo members cryptsetup archivemount"

"$DIR"/scripts/vm_create.sh $VM_NAME "$VM_DIR"
sleep 1
"$DIR"/scripts/preseed.sh | "$DIR"/scripts/vm_install.sh $VM_NAME -

# TODO: uncomment
# "$DIR"/scripts/vm_export.sh $VM_NAME "$VM_DIR"/$VM_NAME.ova