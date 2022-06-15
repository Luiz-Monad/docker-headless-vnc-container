#!/usr/bin/env bash
set -e

#prepare
apt-get install -y git > .tmp
git config --global advice.detachedHead false

#do
echo "...patch"
git clone https://github.com/Luiz-Monad/epoptes.git 
pushd epoptes && git checkout bcac14a0bc9c9e874af45b3bf2a9a41657adc1ef && popd
cp -v -f -R epoptes/epoptes-client/ /usr/share/
if [ $1 == "server" ]; then
    cp -v -f -R epoptes/epoptes/ /usr/lib/python3/dist-packages/
    cp -v -f -R epoptes/twisted/ /usr/lib/python3/dist-packages/
    cp -v -f epoptes/data/client-functions /usr/share/epoptes/
fi;

#clean
apt-get remove -y git > .tmp
apt-get clean -y > .tmp
rm -f -R epoptes/
rm -f .tmp
