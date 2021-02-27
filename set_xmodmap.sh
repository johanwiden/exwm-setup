#!/bin/bash
echo DISPLAY $DISPLAY >>/tmp/jw_xmodmap
/usr/bin/xmodmap -verbose /home/jw/.Xmodmap.exwm 2>&1 >>/tmp/jw_xmodmap
