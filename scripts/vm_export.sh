#!/usr/bin/bash

VM_NAME="$1"
VM_OVA="$2"

vboxmanage export "$VM_NAME" --output "$VM_OVA"