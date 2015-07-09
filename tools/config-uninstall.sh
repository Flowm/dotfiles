#!/usr/bin/env bash
set -eu

if [ $# -ne 0 ]; then
	set -x
	rm -rf .bash_logout .bash_profile .bashrc .gitconfig .tmux.conf .vim .vimrc .zsh .zshrc .shcfg .ssh/config .myconf/tmp
fi

