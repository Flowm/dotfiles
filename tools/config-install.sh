#!/usr/bin/env bash
set -eu

usage() { echo "Usage: $0 [-dh]" 1>&2; exit 1; }

while getopts ":dh" o; do
	case $o in
		d)
			debug=true; set -x
			;;
		*)
			usage
			;;
	esac
done
shift $(($OPTIND - 1))

conf_dir="$HOME/.myconf"
conf_bin="$conf_dir/bin"
conf_home="$conf_dir/home"
conf_tmp="$conf_dir/tmp"
conf_hist="$conf_dir/history"
target_dir="$HOME"

echo "Fix permissions of scripts folder"
chmod +x $conf_dir/tools/*
chmod +x $conf_bin/*

echo "Link all files in conf_home"
find "$conf_home" -mindepth 1 -maxdepth 1 -type f
find "$conf_home" -mindepth 1 -maxdepth 1 -type f -exec ln -fs {} "$target_dir/" \;

echo "Link myconf bin"
mkdir -p "$target_dir/bin/"
ln -nfs "$conf_bin" "$target_dir/bin/myconf"

echo "Create tmp dirs and link"
for d in ".vim"; do
	tmp_dir="$conf_tmp/$d"
	mkdir -p "$tmp_dir"
	echo "$tmp_dir"
	ln -fs "$tmp_dir" "$target_dir/"
done
mkdir -p $conf_tmp/.vimbak
mkdir -p $conf_tmp/.vimtmp

echo "Link all files and folders in subdirectories of conf_home"
for d in $(find "$conf_home" -mindepth 1 -maxdepth 1 -type d); do
	new_dir="$target_dir/$(basename $d)"
	mkdir -p "$new_dir"
	find "$d" -mindepth 1 -maxdepth 1
	find "$d" -mindepth 1 -maxdepth 1 -exec ln -nfs {} "$new_dir/" \;
done

echo "Setup ethernal history folder"
mkdir -p $conf_hist
chmod -R 700 $conf_hist

echo "Initializing submodules"
cd "$conf_dir"
#git submodule update --init --recursive
ln -nfs "$conf_dir/contrib/oh-my-zsh" "$target_dir/.oh-my-zsh"

echo "Install vundle"
vim -E -c "silent PluginInstall" -c "qall" &> /dev/null || true
