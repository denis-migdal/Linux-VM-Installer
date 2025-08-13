#!/usr/bin/bash

VM_OVA="$1"
VM_DIR="$2"
VM_NAME=$(basename "$VM_DIR")

vboxmanage import "$VM_OVA" --vsys 0 --basefolder "$VM_DIR" --vmname "$VM_NAME"