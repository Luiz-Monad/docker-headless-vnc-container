#!/bin/bash

[ -z `ps -C vncserver -o pid=` ] && exit 0 || exit 1;
