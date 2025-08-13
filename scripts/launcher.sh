#!/usr/bin/bash

DECL () {
  if [ ! -v $1 ] ; then
    declare -g $1="$2"
  fi
}

VM_NAME="$1"

DECL VM_USER "zeus"
DECL VM_IP   "127.0.0.1"
DECL VM_SSH_PORT "8022"

VM_STATUS=`VBoxManage showvminfo "$VM_NAME" | grep State`
if [[ "$VM_STATUS" != *"running"* ]]; then
	VBoxManage startvm "$VM_NAME" --type headless
fi

IS_READY=`VBoxManage guestproperty get "$VM_NAME" VMReady | grep -v WARNING`
if [[ "$IS_READY" != "Value: true" ]]; then
	VBoxManage guestproperty wait $VM_NAME VMReady
fi

xfce4-terminal --title "$VM_NAME" --color-bg "#400000" --hide-menubar -x ssh -p $VM_SSH_PORT $VM_USER@$VM_IP -o StrictHostKeyChecking=accept-new