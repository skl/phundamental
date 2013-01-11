#!/bin/bash
###############################################################################
#                                                                             #
#                                                                             #
###############################################################################

if test -z "$1"
then
    echo "nginx version must be specified! e.g. ./install.sh 1.2.3"
    exit
fi

# e.g. 1.2.3
NGINX_VERSION_STRING=$1

/etc/init.d/nginx stop

rm -rf /etc/nginx
rm -rf /var/log/nginx
rm /var/log/nginx
rm -rf /usr/local/nginx

chkconfig --set nginx off
rm /etc/init.d/nginx

# @TODO
# launchctl quit nginx
# launchctl unload /Library/LaunchAgents/org.nginx.nginx.plist
# rm /Library/LaunchAgents/org.nginx.nginx.plist

echo ""
echo "nginx ${NGINX_VERSION_STRING} has been uninstalled."
