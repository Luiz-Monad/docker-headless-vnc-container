#!/bin/bash
### every exit != 0 fails the script
set -e

# should also source $STARTUPDIR/generate_container_user.sh
source $HOME/.bashrc

if [[ $1 =~ -s|--skip ]]; then
    echo -e "\n\n------------------ SKIP STARTUP -----------------"
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

## import the certificate
echo -e "\n---------------- install certificate -----------------------"
echo -e "export SERVER=$SERVER\n" > /etc/default/epoptes-client
epoptes-client -c

## configure session
echo -e "\n------------------- config session -------------------------"
useradd --uid 1000 --user-group --home-dir $HOME/ --shell /bin/bash default_headless
echo -e "[Desktop Entry]\nHidden=False" > $HOME/.config/autostart/epoptes-client.desktop

## cascade the next start script
echo -e "\n------------------- vnc_startup.sh -------------------------"
/dockerstartup/vnc_startup.sh $@
