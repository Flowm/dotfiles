#!/bin/bash

mkdir -p ~/.tmp/.oldconf
mkdir -p ~/.tmp
mkdir -p ~/.tmp/.vimbak
mkdir -p ~/.tmp/.vimtmp

#.bashrc
if [ -f ~/.bashrc ]
	then cp ~/.bashrc ~/.tmp/.oldconf/
fi
ln -fs ~/.myconf/.bashrc ~/.bashrc

#.gitconfig
if [ -f ~/.gitconfig ]
	then cp ~/.gitconfig ~/.tmp/.oldconf/
fi
ln -fs ~/.myconf/.gitconfig ~/.gitconfig

#.ssh/config
if [ -f ~/.ssh/config ]
	mkdir -p ~/.tmp/.oldconf/.ssh
	then cp ~/.ssh/config ~/.tmp/.oldconf/
fi
mkdir -p ~/.ssh/
chmod 600 ~/.myconf/.ssh/config
ln -fs ~/.myconf/.ssh/config ~/.ssh/config

#.tmux.conf
if [ -f ~/.tmux.conf ]
	then cp ~/.tmux.conf ~/.tmp/.oldconf/
fi
ln -fs ~/.myconf/.tmux.conf ~/.tmux.conf

#.vimrc
if [ -f ~/.vimrc ]
	then cp ~/.vimrc ~/.tmp/.oldconf/
fi
ln -fs ~/.myconf/.vimrc ~/.vimrc

#.vim
if [ -a ~/.vim ] && !([ -h ~/.vim ])
	then cp -r ~/.vim ~/.tmp/.oldconf/
	rm -r ~/.vim/
fi
ln -fns ~/.myconf/.vim ~/.vim
