#!/bin/bash

if [ $UID -eq 0 ]
then
  SUDO=''
else
  SUDO='sudo'
  if ! command -v sudo > /dev/null
  then
    echo "sudo not found but required to setup mirrors"
    exit 1
  fi
fi

${SUDO} apt-get update
${SUDO} apt-get install -y wget apt-transport-https gnupg lsb-release build-essential gfortran curl git sudo cmake cmake-curses-gui python3-pip

${SUDO} add-apt-repository ppa:neovim-ppa/unstable
${SUDO} apt-get install -y neovim

if [[ `lsb_release -si` == "Ubuntu" ]]
then
  wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | ${SUDO} tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
  echo "deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ $(lsb_release -sc) main" | ${SUDO} tee /etc/apt/sources.list.d/kitware.list >/dev/null
  ${SUDO} apt-get update
  ${SUDO} apt-get upgrade -y cmake cmake-curses-gui
fi

if [[ ! -f $HOME/.local/bin/pre-commit ]]
then
  /usr/bin/python3 -m pip install --user pre-commit
fi

sudo apt install zsh

./setup.sh
