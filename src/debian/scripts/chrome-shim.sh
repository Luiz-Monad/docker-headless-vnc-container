#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

VNC_RES_W=${VNC_RESOLUTION%x*}
VNC_RES_H=${VNC_RESOLUTION#*x}
/usr/bin/chromium --no-sandbox --start-maximized --user-data-dir --temp-profile --window-size=$VNC_RES_W,$VNC_RES_H --window-position=0,0 $@
