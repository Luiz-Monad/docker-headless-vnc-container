#!/bin/bash

[ `netstat -an4 | grep :789 | wc -l` -ge 1 ] && exit 0 || exit 1;
