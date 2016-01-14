#!/bin/bash

# newrez

# Marc Brumlik, Tailored Software Inc, tsi-inc@comcast.net

# up to v 0.8
# use 'xrandr' to scale video output to the display

# v 0.9
# Wed Jan  2 05:23:54 CST 2013
# rewrite to handle mouse boundaries when scaled (mouse confined)
# by setting requested resolution to the unused VGA1 device
# then scaling that for display on the LVDS1 device

# v 1.1
# Fri Dec 20 08:28:08 CST 2013
# fixed issue where setting to "default" after some other resulution
# left mouse-area at prior resolution

umask 000

# resolution can optionally be specified on command line
newrez=$1

# we MUST be running xrandr 1.3 or higher
if xrandr -v | grep "RandR version 1.[012]"
	then	zenity --info --title="XRandR version is too old" --text="You must be running Xrandr
version 1.3 or newer!
Time to upgrade your system  :-)"
		exit 0
fi

# find the currently connected devices, make a list
devices=`xrandr -q | grep connected | grep -v disconnected | cut -d"(" -f1`

# there MUST be a "connected" LVDS1 and a "disconnected" VGA1
current=`xrandr -q`

if echo "$current" | grep "LVDS1 connected" >/dev/null
	then	: OK
	else	zenity --info --title="PROBLEM" --text="Current display must be LVDS1"; exit 0
fi
if echo "$current" | grep "VGA1 disconnected" >/dev/null
	then	: OK
	else	zenity --info --title="IMPORTANT" --text="The VGA1 display resolution may be affected by this change"
fi

default=`echo "$current" | grep -A 1 "^LVDS1" | tail -1 | awk '{print $1}'`
H=`echo $default | cut -d'x' -f1`
V=`echo $default | cut -d'x' -f2`
HZ=`echo $default | awk '{print $2}' | tr -d '[*+]'`

# echo DEFAULT: $default $H $V

if [ -z "$newrez" ]
	then	while true
		do
			newrez=`zenity --entry --title="Set New Resolution" \
				--text="Default Resolution: $default\n\nNew size (eg 1280x750 or 1450x1000)\n   -or- \"default\""` || exit 0
			case $newrez in
				default|[0-9]*x[0-9]*)	break ;;
			esac
		done
fi

case $newrez in
	default)	xrandr --output LVDS1 --mode $default --scale 1x1
			xrandr --addmode VGA1 $default
			xrandr --newmode $default $newmode
			xrandr --output VGA1 --mode $default --scale 1x1
			exit 0 ;;
esac

newH=`echo $newrez | cut -d'x' -f1`
newV=`echo $newrez | cut -d'x' -f2`
modeline=`cvt $newH $newV $HZ | grep Modeline`
newmode=`echo "$modeline" | sed 's/^.*"//'`
cvtrez=`echo "$modeline" | sed -e 's/_.*//' -e 's/^.*"//'`

if [ "$newrez" != "$cvtrez" ]
	then	newrez=$cvtrez
		newH=`echo $newrez | cut -d'x' -f1`
		newV=`echo $newrez | cut -d'x' -f2`
fi

scaleH=`echo -e "scale=10\n$newH / $H\nquit" | bc`
scaleV=`echo -e "scale=10\n$newV / $V\nquit" | bc`

if echo "$current" | grep -A 100 "^VGA1" | grep $newrez >/dev/null
	then	: already there
	else	xrandr --newmode "$newrez" $newmode
		xrandr --addmode VGA1 $newrez
fi

if xrandr --output VGA1 --mode $newrez --output LVDS1 --fb $newrez --scale $scaleH"x"$scaleV 2>&1 | tee -a /tmp/xrandr.err
	then	: success
	else	zenity --info --title="Xrandr produced this error" --text="`cat /tmp/xrandr.err`"

The problem could be that Your video driver
does not support xrandr version 1.3
		rm -f /tmp/xrandr.err
fi
