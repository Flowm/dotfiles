#!/usr/bin/env bash
set -eux

mkdir -p ~/dev/cloned
cd ~/dev/cloned

# gdb plugins
git clone https://github.com/torvalds/linux.git
git clone https://github.com/qemu/qemu.git
git clone https://github.com/systemd/systemd.git
