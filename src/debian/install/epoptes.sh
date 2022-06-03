#!/usr/bin/env bash
set -e

if [ $1 == "server" ]; then pkg="epoptes"; fi
if [ $1 == "client" ]; then pkg="epoptes-client"; fi

echo "Install $pkg"
apt-get update 
apt-get install -y $pkg
apt-get clean -y
