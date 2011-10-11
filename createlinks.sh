#!/bin/bash

mkdir -p ~/.oldconf
mkdir -p ~/.tmp
mkdir -p ~/.tmp/.vimbak
mkdir -p ~/.tmp/.vimtmp

#.bashrc
if [ -f ~/.bashrc ]
	then cp ~/.bashrc ~/.oldconf/
fi
ln -fs ~/.myconf/.bashrc ~/.bashrc

#.gitconfig
if [ -f ~/.gitconfig ]
	then cp ~/.gitconfig ~/.oldconf/
fi
ln -fs ~/.myconf/.gitconfig ~/.gitconfig

#.ssh/config
if [ -f ~/.ssh/config ]
	then cp ~/.ssh/config ~/.oldconf/
fi
mkdir -p ~/.ssh/
chmod 600 ~/.myconf/.ssh/config
ln -fs ~/.myconf/.ssh/config ~/.ssh/config

#.tmux.conf
if [ -f ~/.tmux.conf ]
	then cp ~/.tmux.conf ~/.oldconf/
fi
ln -fs ~/.myconf/.tmux.conf ~/.tmux.conf

#.vimrc
if [ -f ~/.vimrc ]
	then cp ~/.vimrc ~/.oldconf/
fi
ln -fs ~/.myconf/.vimrc ~/.vimrc

#.vim
if [ -a ~/.vim ] && !([ -h ~/.vim ])
	then cp -r ~/.vim ~/.oldconf/
	rm -r ~/.vim/
fi
ln -fs ~/.myconf/.vim ~/.vim
