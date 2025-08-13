#!/usr/bin/bash

DIR=$(realpath `dirname $0`)

VM_NAME="ASLO"
VM_DIR=~"/scratch/$VM_NAME"

"$DIR"/scripts/vm_create.sh $VM_NAME "$VM_DIR"
"$DIR"/scripts/preseed.sh | "$DIR"/scripts/vm_install.sh $VM_NAME -

"$DIR"/scripts/vm_export.sh $VM_NAME "$VM_DIR"/$VM_NAME.ova