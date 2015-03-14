#!/usr/bin/env bash

set -eux

CONFDIR="$HOME/.myconf"
CONFHOME="$CONFDIR/home"
CONFTMP="$CONFDIR/tmp"
NEWHOME="$HOME"

# Link all files in CONFHOME
find "$CONFHOME/" -mindepth 1 -maxdepth 1 -type f
find "$CONFHOME/" -mindepth 1 -maxdepth 1 -type f -exec ln -fs {} "$NEWHOME/" \;

for DIR in ".vim" ".zsh"; do
	TMP="$CONFTMP/$DIR"
	mkdir -p "$TMP"
	ln -fs "$TMP" "$NEWHOME/"
done

# Link all files and folders in subdirectories of CONFHOME
for DIR in $(find "$CONFHOME/" -mindepth 1 -maxdepth 1 -type d); do
	NEWDIR="$NEWHOME/$(basename $DIR)"
	mkdir -p "$NEWDIR"
	find "$DIR" -mindepth 1 -maxdepth 1
	find "$DIR" -mindepth 1 -maxdepth 1 -exec ln -dfs {} "$NEWDIR/" \;
done
