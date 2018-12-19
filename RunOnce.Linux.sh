#!/bin/bash

if [ ! -d "$XDG_DATA_HOME/love/openSMB2" ]; then
  mkdir $XDG_DATA_HOME/love
  mkdir $XDG_DATA_HOME/love/openSMB2
fi

echo Copying levels into user data directory...

cp -r _move_to_saves_directory/* $XDG_DATA_HOME/love/openSMB2/

read -n 1 -s -r -p "Installation complete! Press any key to continue..."
echo