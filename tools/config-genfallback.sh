#!/usr/bin/env bash

PROGRAM="OpenSSH_"
MAJOR=$(ssh -V 2>&1 | sed "s/${PROGRAM}\([0-9]\).*/\1/")
MINOR=$(ssh -V 2>&1 | sed "s/${PROGRAM}${MAJOR}.\([0-9]\).*/\1/")

conf_home="$HOME/.myconf/home"

cat $conf_home/.ssh/config | tr '\n' '\f' | sed "s!\[${PROGRAM}[${MAJOR}-9].[$(expr $MINOR + 1)-9][^]]*\]!!" | tr '\f' '\n' > $conf_home/.ssh/config-compatible

if ! [ -h ~/.ssh/config ]; then
	echo "~/.ssh/config not a symlink, aborting"
	exit 1
fi

diff -u $conf_home/.ssh/config $conf_home/.ssh/config-compatible
if [ "$?" -ne 0 ]; then
	echo "Linking compatible version as changes are detected"
	ln -fs $conf_home/.ssh/config-compatible ~/.ssh/config
else
	echo "Linking original version as no changes are detected"
	ln -fs $conf_home/.ssh/config ~/.ssh/config
fi
