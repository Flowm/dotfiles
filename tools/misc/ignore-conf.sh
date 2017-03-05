#!/usr/bin/env bash

case "$1" in
    i*)
		git update-index --assume-unchanged .gitconfig
        ;;
    t*)
		git update-index --no-assume-unchanged .gitconfig
        ;;
    *)
        echo "$0 i(gnore) | t(rack)"
        exit 1
esac
