#!/usr/bin/env bash

echo "Install kubectl"
wget -qO- https://dl.k8s.io/release/v1.24.2/bin/linux/amd64/kubectl > /usr/bin/kubectl
chmod +x /usr/bin/kubectl
