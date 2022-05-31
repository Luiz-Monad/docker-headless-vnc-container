#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

ln -s $1/chrome-shim.sh /usr/bin/chromium-browser
ln -s /usr/bin/chromium-browser /usr/bin/google-chrome

find /usr | grep chromium.png | xargs dirname | xargs -I @ ln -s @/chromium.png @/chromium-browser.png
