#!/bin/bash

cat <<EOA
     _             _                   _       _
 ___| |_ _ _ ___ _| |___ _____ ___ ___| |_ ___| |
| . |   | | |   | . | .'|     | -_|   |  _| .'| |
|  _|_|_|___|_|_|___|__,|_|_|_|___|_|_|_| |__,|_|
EOA
echo -n '|_|'

for i in `ls -1 ${WHEREAMI}/functions.d`; do
    echo -n '.'
    . ${WHEREAMI}/functions.d/$i
done

echo -e "Bootstrap complete \n"
