#!/usr/bin/env bash

PROGRAM="OpenSSH_"
MAJOR=$(ssh -V 2>&1 | sed "s/${PROGRAM}\([0-9]\).*/\1/")
MINOR=$(ssh -V 2>&1 | sed "s/${PROGRAM}6.\([0-9]\).*/\1/")


cat ~/.myconf/.ssh/config | tr '\n' '\f' | sed "s!\[${PROGRAM}[$((MAJOR))-9].[$((MINOR+1))-9][^]]*\]!!" | tr '\f' '\n' > ~/.myconf/.ssh/config-compatible

if ! [ -h ~/.ssh/config ]; then
	echo "~/.ssh/config not a symlink, aborting"
	exit 1
fi

diff -u ~/.myconf/.ssh/config ~/.myconf/.ssh/config-compatible
if [ "$?" -ne 0 ]; then
	echo "Linking compatible version as changes are detected"
	ln -fs ~/.myconf/.ssh/config-compatible ~/.ssh/config
else
	echo "Linking original version as no changes are detected"
	ln -fs ~/.myconf/.ssh/config ~/.ssh/config
fi
