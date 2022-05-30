#!/bin/bash
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

## start the service
echo -e "\n---------------- start epoptes client ----------------------"
/sbin/start-stop-daemon --start --oknodo --quiet -b --exec /usr/sbin/epoptes-client

## cascade the next start script
echo -e "\n------------------- vnc_startup.sh -------------------------"
/dockerstartup/vnc_startup.sh $@
