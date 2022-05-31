#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

# should also source $STARTUPDIR/generate_container_user.sh
source $HOME/.bashrc

## correct forwarding of shutdown signal
cleanup () {
    kill -s SIGTERM $!
    exit 0
}
trap cleanup SIGINT SIGTERM

echo -e "\n------------------ start dbus ------------------"
dbus-daemon --config-file=/usr/share/dbus-1/system.conf --print-address

## cascade the next start script
echo -e "\n------------------- vnc_startup.sh -------------------------"
/dockerstartup/vnc_startup.sh $@
