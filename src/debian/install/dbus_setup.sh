#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Setup dbus"
dbus-uuidgen > /var/lib/dbus/machine-id
mkdir -p /var/run/dbus
chmod 777 /var/run/dbus
