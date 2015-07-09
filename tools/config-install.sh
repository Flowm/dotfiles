#!/usr/bin/env bash
set -eu

if [ $# -ne 0 ]; then
	set -x
fi

conf_dir="$HOME/.myconf"
conf_home="$conf_dir/home"
conf_tmp="$conf_dir/tmp"
conf_hist="$conf_dir/history"
targt_dir="$HOME"

echo "Link all files in conf_home"
find "$conf_home" -mindepth 1 -maxdepth 1 -type f
find "$conf_home" -mindepth 1 -maxdepth 1 -type f -exec ln -fs {} "$targt_dir/" \;

echo "Create tmp dirs and link"
for d in ".vim" ".zsh"; do
	tmp_dir="$conf_tmp/$d"
	mkdir -p "$tmp_dir"
	echo "$tmp_dir"
	ln -fs "$tmp_dir" "$targt_dir/"
done

echo "Link all files and folders in subdirectories of conf_home"
for d in $(find "$conf_home" -mindepth 1 -maxdepth 1 -type d); do
	new_dir="$targt_dir/$(basename $d)"
	mkdir -p "$new_dir"
	find "$d" -mindepth 1 -maxdepth 1
	find "$d" -mindepth 1 -maxdepth 1 -exec ln -nfs {} "$new_dir/" \;
done

mkdir -p $conf_tmp/.vimbak
mkdir -p $conf_tmp/.vimtmp
$conf_dir/tools/config-genfallback.sh

mkdir -p $conf_hist

echo "Initializing submodules"
cd "$conf_dir"
git submodule update --init --recursive
ln -nfs "$conf_dir/contrib/antigen" "$conf_tmp/.zsh/"
