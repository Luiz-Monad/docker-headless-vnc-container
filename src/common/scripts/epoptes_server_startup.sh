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

echo -e "\n---------------- start epoptes server ----------------------"

## config env
echo -e "\nSetting env..."
echo -e "REVERSE_PORT=$EPOPTES_REVERSE_PORT" >> /etc/default/epoptes
echo -e "PORT=$EPOPTES_PORT" >> /etc/default/epoptes

## start the service
if [[ $DEBUG == true ]]; then echo "/usr/bin/twistd3 epoptes"; fi
/usr/bin/twistd3 epoptes &> $STARTUPDIR/epoptes_startup.log

## log connect options
EPOPTES_IP=$(hostname -i)
echo -e "\ntwistd3 epoptes \n\t=> connect epoptes-client on $EPOPTES_IP:$EPOPTES_PORT"
echo -e "\t   use the variable SERVER=$EPOPTES_IP"

## configure session
echo -e "\nSetting desktop session..."
cp /usr/share/applications/epoptes.desktop $HOME/Desktop/
cp /usr/share/applications/epoptes.desktop $HOME/.config/autostart
echo -e "[Desktop Entry]\nHidden=True" > $HOME/.config/autostart/epoptes-client.desktop

## configure user permissions
echo -e "\nSetting users..."
useradd --uid 1000 --user-group --groups epoptes --home-dir $HOME/ --shell /bin/bash default_headless
chown -R 1000:1000 $HOME/.config
chown -R 1000:1000 $HOME/Desktop
chmod ugo+rwx $HOME/.config/autostart/*.desktop
chmod ugo+rwx $HOME/Desktop/*.desktop

## cascade the next start script
echo -e "\n------------------- vnc_startup.sh -------------------------"
# /dockerstartup/vnc_startup.sh $@
su default_headless --pty --preserve-environment -c "/dockerstartup/vnc_startup.sh $@"
