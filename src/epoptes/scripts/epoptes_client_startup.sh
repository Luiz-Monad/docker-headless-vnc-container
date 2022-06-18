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

echo -e "\n---------------- start epoptes client ----------------------"

## config env
echo -e "\nSetting env..."
echo -e "export SERVER=$EPOPTES_SERVER" >> /etc/default/epoptes-client
echo -e "export PORT=$EPOPTES_PORT" >> /etc/default/epoptes-client
chmod ugo+rwx /etc/default/epoptes-client

## import the certificate
echo -e "\nInstalling server certificate..."
epoptes-client -c

## configure session
echo -e "\nSetting desktop session..."
echo -e "[Desktop Entry]\nHidden=False" > $HOME/.config/autostart/epoptes-client.desktop

## configure user permissions
echo -e "\nSetting users..."
useradd --uid 1000 --user-group --home-dir $HOME/ --shell /bin/bash default_headless
chown -R 1000:1000 $HOME/.config
chown -R 1000:1000 $HOME/Desktop
chmod ugo+rwx $HOME/Desktop/*.desktop

## cascade the next start script
echo -e "\n------------------- vnc_startup.sh -------------------------"
# /dockerstartup/vnc_startup.sh $@
su default_headless --pty --preserve-environment -c "/dockerstartup/vnc_startup.sh $@"
