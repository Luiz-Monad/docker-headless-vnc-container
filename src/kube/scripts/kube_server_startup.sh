#!/bin/bash
### every exit != 0 fails the script
set -e

# should also source $STARTUPDIR/generate_container_user.sh
source $HOME/.bashrc

if [[ $1 =~ -s|--skip ]]; then
    echo -e "\n\n-------------------- SKIP STARTUP -------------------"
    echo -e "\n\n------------------ EXECUTE COMMAND ------------------"
    echo "Executing command: '${@:2}'"
    exec "${@:2}"
fi

## correct forwarding of shutdown signal
cleanup () {
    kill -s SIGTERM $!
    exit 0
}
trap cleanup SIGINT SIGTERM

## configure tools
echo -e "\nSetting tools..."
mkdir -p $HOME/.kube
cp /config/kube-config $HOME/.kube/config
chown -R 1000:1000 $HOME/.kube
chmod -R ugo+rwx $HOME/.kube

## cascade the next start script
echo -e "\n---------------- epoptes_server_startup.sh -----------------"
/dockerstartup/epoptes_server_startup.sh $@

