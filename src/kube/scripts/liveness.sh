#!/bin/bash

[ -z `ps -C vncserver -o pid=` ] && exit 1 || exit 0;
