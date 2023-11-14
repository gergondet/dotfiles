#!/bin/bash

echo "deb http://debian.sur5r.net/i3/ `lsb_release -sc` universe" > /etc/apt/sources.list.d/sur5r-i3.list
sudo apt update && sudo apt install i3 i3-wm

curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

mkdir -p ~/devel/tools/
git clone --recursive git@github.com:polybar/polybar
cd polybar
./build.sh

cp -r i3 ~/.config/
cp -r polybar ~/.config/
cp -r kitty ~/.config/
