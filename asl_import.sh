#!/usr/bin/bash

DIR=$(realpath `dirname $0`)

VM_NAME="ASL"

VM_OVA="/home/scratch/denmigda/ASLO/ASLO.ova"
VM_DIR=~"/scratch/$VM_NAME"

./scripts/vm_import.sh "$VM_OVA" "$VM_DIR"

# SSH
./scripts/install_ssh.sh $VM_NAME

# launcher
./scripts/launcher.sh $VM_NAME
./scripts/install_desktop.sh $VM_NAME