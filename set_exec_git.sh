#!/bin/bash
find src/ | grep -F .sh | xargs git add --chmod=+x
find src/ | grep -F .desktop | xargs git add --chmod=+x
