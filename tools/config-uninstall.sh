#!/usr/bin/env bash
set -eu

if [ $# -ne 0 ]; then
	set -x
fi

files=(
		'.bash_logout'
		'.bash_profile'
		'.bashrc'
		'.gitconfig'
		'.tmux.conf'
		'.vim'
		'.vimrc'
		'.zsh'
		'.zshrc'
		'.ssh/config'
		)

cd $HOME
for file in "${files[@]}"; do
	if [ -L $file ]; then
		rm $file
	fi
done

rm -rf '.shcfg'
rm -rf '.myconf/tmp'
