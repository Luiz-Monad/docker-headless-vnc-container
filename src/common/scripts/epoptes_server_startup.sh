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

## start the service
echo -e "\n---------------- start epoptes server ----------------------"
if [[ $DEBUG == true ]]; then echo "/usr/bin/twistd3 epoptes"; fi
/usr/bin/twistd3 epoptes &> $STARTUPDIR/epoptes_startup.log

## configure session
echo -e "\n------------------- config session -------------------------"
cp /usr/share/applications/epoptes.desktop $HOME/Desktop/
cp /usr/share/applications/epoptes.desktop $HOME/.config/autostart
echo -e "[Desktop Entry]\nHidden=True" > $HOME/.config/autostart/epoptes-client.desktop
useradd --uid 1000 --user-group --groups epoptes --home-dir $HOME/ --shell /bin/bash default_headless
chown -R 1000:1000 $HOME/.config
chown -R 1000:1000 $HOME/Desktop
chmod ugo+rwx $HOME/.config/autostart/*.desktop
chmod ugo+rwx $HOME/Desktop/*.desktop

## cascade the next start script
echo -e "\n------------------- vnc_startup.sh -------------------------"
# /dockerstartup/vnc_startup.sh $@
su default_headless --pty --preserve-environment -c "/dockerstartup/vnc_startup.sh $@"
