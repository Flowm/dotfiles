#!/bin/bash

mkdir -p ~/.oldconf

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
ln -fs ~/.myconf/.ssh/config ~/.ssh/config

#.vimrc
if [ -f ~/.vimrc ]
	then cp ~/.vimrc ~/.oldconf/
fi
ln -fs ~/.myconf/.vimrc ~/.vimrc

#.vim
if [ -d ~/.vim ]
	then cp ~/.vim ~/.oldconf/
fi
ln -s ~/.myconf/.vim/ ~/.vim
