#!/bin/sh
#
# Copyright (C) 2004-2006 Nokia Corporation. All rights reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# version 2 as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA

AF_PIDDIR=/tmp/af-piddir
if [ ! -d $AF_PIDDIR ]; then
	# note, no write to flash involved here
	mkdir $AF_PIDDIR
	# I'm not the only one writing here
	chmod 777 $AF_PIDDIR
fi
PIDFILE=$AF_PIDDIR/fb-progress.pid
IMGDIR=/usr/share/icons/hicolor/scalable/hildon
LOGO=startup_nokia_logo.png
BAR=indicator_update_white

SECS=9

case "$1" in
start)	
	# don't show progress bar if device started to ACTDEAD first
        BOOTREASON=`cat /proc/bootreason`
        if [ "x$BOOTREASON" != "xcharger" \
	     -a ! -f /tmp/skip-fb-progress.tmp ]; then
        	echo "Starting: fb-progress"
        	fb-progress -l $IMGDIR/$LOGO -g $IMGDIR/$BAR $SECS > /dev/null 2>&1 &
        	echo "$!" > $PIDFILE
        	chmod 666 $PIDFILE
	fi
        rm -f /tmp/skip-fb-progress.tmp
	;;
stop)	if [ -f $PIDFILE ]; then
		PID=$(cat $PIDFILE)
		if [ -d /proc/$PID ]; then
			kill -TERM $PID
		fi
		rm $PIDFILE
	fi
        # this is for the case of USER -> ACTDEAD -> USER
        touch /tmp/skip-fb-progress.tmp
	;;
restart)
	echo "$0: not implemented"
	exit 1
	;;
force-reload)
	echo "$0: not implemented"
	exit 1
	;;
*)	echo "Usage: $0 {start|stop}"
	exit 1
	;;
esac
