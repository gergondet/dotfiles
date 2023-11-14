#!/bin/bash

if [ ! -d ~/.oh-my-zsh/ ]
then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
if [ ! -d ~/.oh-my-zsh/custom/themes/powerlevel10k/ ]
then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi
cp zsh/.zshrc ~/
cp zsh/.p10k.zsh ~/

cp -r nvim ~/.config/
echo "[Neovim] Launch neovim to initialize plugins then run mason-install.sh"

cp git/.gitignore ~/
git config --global core.excludesfiles ~/.gitignore
git config --global user.email pierre.gergondet@gmail.com
git config --global user.name "Pierre Gergondet"

cp tmux/.tmux.conf ~
if [ ! -d ~/.tmux/plugins/tpm ]
then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  echo "[TMUX] Launch tmux and type Ctrl+b+I"
fi

if [ ! -f ~/.ssh/id_rsa ]
then
  mkdir -p ~/.ssh
  scp pbs@dinauz.org:~/.ssh/id_rsa ~/.ssh
fi
if [ ! -f ~/.gnupg/secring.gpg ]
then
  mkdir -p ~/.gnupg
  scp pbs@dinauz.org:~/.gnupg/secring.gpg ~/.gnupg
fi
