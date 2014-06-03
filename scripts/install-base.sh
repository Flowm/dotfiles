#!/usr/bin/env bash

if [ `lsb_release -si` == 'Ubuntu' ]; then
	STAGE="/etc/z_apt-base"
	if [ ! -e $STAGE ]; then
		/home/vagrant/.myconf/instdb/apt-base
		touch $STAGE
	fi
fi
