#!/usr/bin/env bash
set -eux

mkdir -p ~/.gdb
cd ~/.gdb

# gdb plugins
git clone https://github.com/longld/peda.git
git clone https://github.com/scwuaptx/Pwngdb.git

# Tools
git clone https://github.com/david942j/one_gadget.git
git clone https://github.com/sashs/Ropper.git
git clone https://github.com/wapiflapi/villoc.git

# apt
sudo apt install \
    valgrind \
    python-capstone \
    ltrace \
    nasm \
    ;
