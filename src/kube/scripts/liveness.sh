#!/bin/bash

[ `ps -C vncserver -o pid=`0 -gt 0 ] && exit 0 || exit 1;
