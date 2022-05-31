#!/usr/bin/env bash
set -e

echo "Install epoptes client"
apt-get update 
apt-get install -y epoptes-client
apt-get clean -y
