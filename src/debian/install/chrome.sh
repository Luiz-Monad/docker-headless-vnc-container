#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Chromium Browser"
apt-get update 
apt-get install -y chromium chromium-l10n
apt-get clean -y
