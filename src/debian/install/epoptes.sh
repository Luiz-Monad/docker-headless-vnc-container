#!/usr/bin/env bash
set -e

echo "Install epoptes server"
apt-get update 
apt-get install -y epoptes
apt-get clean -y
