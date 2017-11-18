#!/usr/bin/env bash
set -eux

BIN_DIR=~/bin/dbg
GIT_DIR=~/.gdb

mkdir -p $BIN_DIR
mkdir -p $GIT_DIR && cd $GIT_DIR

# GDB plugins
git clone https://github.com/longld/peda.git
git clone https://github.com/scwuaptx/Pwngdb.git

# Tools
git clone https://github.com/slimm609/checksec.sh.git
ln -s $GIT_DIR/checksec.sh/checksec $BIN_DIR

git clone https://github.com/sashs/Ropper.git
ln -s $GIT_DIR/Ropper/Ropper.py $BIN_DIR

git clone https://github.com/wapiflapi/villoc.git
ln -s $GIT_DIR/villoc/villoc.py $BIN_DIR

sudo gem install one_gadget

sudo apt install \
    valgrind \
    python-capstone \
    ltrace \
    nasm \
    ;

# pwntools
sudo apt install python2.7 python-pip python-dev git libssl-dev libffi-dev build-essential
pip install --upgrade pip
pip install --upgrade pwntools
