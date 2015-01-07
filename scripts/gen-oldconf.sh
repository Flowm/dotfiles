#!/usr/bin/env bash

PROGRAM="OpenSSH_"
MAJOR=$(ssh -V 2>&1 | sed "s/${PROGRAM}\([0-9]\).*/\1/")
MINOR=$(ssh -V 2>&1 | sed "s/${PROGRAM}6.\([0-9]\).*/\1/")


cat ~/.myconf/.ssh/config | tr '\n' '\f' | sed "s!\[${PROGRAM}[$((MAJOR))-9].[$((MINOR+1))-9][^]]*\]!!" | tr '\f' '\n' > ~/.myconf/.ssh/config-compatible
ln -fs ~/.myconf/.ssh/config-compatible ~/.ssh/config

diff -u ~/.myconf/.ssh/config ~/.myconf/.ssh/config-compatible
