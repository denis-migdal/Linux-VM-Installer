#!/usr/bin/bash

VM_NAME="$1"

DECL () {
  if [ ! -v $1 ] ; then
    declare -g $1="$2"
  fi
}

DIR=$(realpath `dirname $0`)

DECL VM_SSH_KEYS "$DIR/../assets/keys/LVMI"
DECL VM_SSH_PORT 8022
DECL VM_IP "127.0.0.1"

mkdir -p ~/.ssh/keys/{priv,pub}

cp "$VM_SSH_KEYS"     ~/.ssh/keys/priv/$VM_NAME
cp "$VM_SSH_KEYS".pub ~/.ssh/keys/pub/$VM_NAME.pub

echo """
Host $VM_NAME
        Hostname $VM_IP
        IdentityFile ~/.ssh/keys/priv/$VM_NAME
        Port $VM_SSH_PORT
""" >> ~/.ssh/config