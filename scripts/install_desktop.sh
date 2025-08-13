#!/usr/bin/bash

DIR=$(realpath `dirname $0`)

DECL () {
  if [ ! -v $1 ] ; then
    declare -g $1="$2"
  fi
}

VM_NAME="$1"

DECL VM_ICON "$DIR/../assets/LVMI.svg"

LAUNCHER_CMD="$DIR/launcher.sh $VM_NAME"

echo """
[Desktop Entry]
Name=$VM_NAME Terminal
Exec=$LAUNCHER_CMD
Icon="$VM_ICON"
Terminal=false
Type=Application
Categories=GTK;System;TerminalEmulator;
StartupNotify=true
""" >  ~/.local/share/applications/"$VM_NAME".desktop