#!/usr/bin/env bash

TMPDIR="$HOME/.tmp"
BKUPDIR="$TMPDIR/.oldconf/`date +%Y%m%d%H%M%S`"
mkdir -p "$BKUPDIR"
mkdir -p "$TMPDIR/.vimbak"
mkdir -p "$TMPDIR/.vimtmp"



#.bashrc
if [ -f ~/.bashrc ] && !([ -h ~/.bashrc ]); then
	cp ~/.bashrc "$BKUPDIR/"
fi
ln -fs ~/.myconf/.bashrc ~/.bashrc

#.gitconfig
if [ -f ~/.gitconfig ] && !([ -h ~/.gitconfig ]); then
	cp ~/.gitconfig "$BKUPDIR/"
fi
ln -fs ~/.myconf/.gitconfig ~/.gitconfig

#.ssh/config
if [ -f ~/.ssh/config ] && !([ -h ~/.ssh/config ]); then
	mkdir -p "$BKUPDIR/.ssh"
	cp ~/.ssh/config "$BKUPDIR/.ssh/"
fi
mkdir -p ~/.ssh/
ln -fs ~/.myconf/.ssh/config ~/.ssh/config

#.tmux.conf
if [ -f ~/.tmux.conf ] && !([ -h ~/.tmux.conf ]);	then
	cp ~/.tmux.conf "$BKUPDIR/"
fi
ln -fs ~/.myconf/.tmux.conf ~/.tmux.conf

#.vimrc
if [ -f ~/.vimrc ] && !([ -h ~/.vimrc ]); then
	cp ~/.vimrc "$BKUPDIR/"
fi
ln -fs ~/.myconf/.vimrc ~/.vimrc

#.vim
if [ -d ~/.vim ] && !([ -h ~/.vim ]); then
	mv ~/.vim "$BKUPDIR/"
fi
ln -fns ~/.myconf/.vim ~/.vim

#BIN
if [ -d ~/Dropbox/Code/gitted/bin ]; then
	if [ -d ~/bin ] && !([ -h ~/bin ]); then
		mv ~/bin "$BKUPDIR/"
	fi
	ln -fns ~/Dropbox/Code/bin ~/bin
fi

rmdir "$BKUPDIR" 2>/dev/null
if [ $? -ne 0 ]; then
	echo "Config installed. Old config saved to $BKUPDIR"
	exit 0
else
	echo "Config already installed."
	exit 0
fi
