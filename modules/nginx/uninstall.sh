#!/bin/bash
###############################################################################
#                                                                             #
#                                                                             #
###############################################################################

PH_NGINX_INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PH_INSTALL_DIR="$( cd "${PH_NGINX_INSTALL_DIR}" && cd ../../ && pwd )"
. ${PH_INSTALL_DIR}/bootstrap.sh

read -p "Specify nginx version [1.4.5]: " NGINX_VERSION_STRING

# Default version
[ -z ${NGINX_VERSION_STRING} ] && NGINX_VERSION_STRING="1.4.5"

NGINX_VERSION_INTEGER=`echo ${NGINX_VERSION_STRING} | tr -d '.' | cut -c1-3`
NGINX_VERSION_INTEGER_FULL=`echo ${NGINX_VERSION_STRING} | tr -d '.'`
NGINX_VERSION_MAJOR=`echo ${NGINX_VERSION_STRING} | cut -d. -f1`
NGINX_VERSION_MINOR=`echo ${NGINX_VERSION_STRING} | cut -d. -f2`
NGINX_VERSION_RELEASE=`echo ${NGINX_VERSION_STRING} | cut -d. -f3`

read -p "Specify installation directory [/usr/local/nginx-${NGINX_VERSION_MAJOR}.${NGINX_VERSION_MINOR}]: " NGINX_PREFIX
read -p "Specify nginx configuration directory [/etc/nginx-${NGINX_VERSION_MAJOR}.${NGINX_VERSION_MINOR}]: " NGINX_CONFIG_PATH

# Default prefix and configuration path
[ -z ${NGINX_PREFIX} ] && NGINX_PREFIX="/usr/local/nginx-${NGINX_VERSION_MAJOR}.${NGINX_VERSION_MINOR}"
[ -z ${NGINX_CONFIG_PATH} ] && NGINX_CONFIG_PATH="/etc/nginx-${NGINX_VERSION_MAJOR}.${NGINX_VERSION_MINOR}"

NGINX_DIRS="${NGINX_PREFIX} ${NGINX_CONFIG_PATH}"

for i in ${NGINX_DIRS}; do
    [ -d ${i} ] && rm -rvf ${i}
done

NGINX_SYMLINKS="/etc/nginx /usr/local/nginx /var/log/nginx /usr/local/bin/nginx"

for i in ${NGINX_SYMLINKS}; do
    [ -L ${i} ] && rm -i ${i}
done

case "${PH_OS}" in
"linux")
    case "${PH_OS_FLAVOUR}" in
    "debian")
        PH_INIT_SCRIPT=/etc/init.d/nginx-${NGINX_VERSION_STRING}

        [ -f ${PH_INIT_SCRIPT} ] && {
            update-rc.d nginx-${NGINX_VERSION_STRING} remove
            ${PH_INIT_SCRIPT} stop
            rm ${PH_INIT_SCRIPT}
        }
        ;;

    "suse")
        PH_INIT_SCRIPT=/etc/init.d/nginx-${NGINX_VERSION_STRING}

        [ -f ${PH_INIT_SCRIPT} ] && {
            chkconfig --set nginx-${NGINX_VERSION_STRING} off
            ${PH_INIT_SCRIPT} stop
            rm ${PH_INIT_SCRIPT}
        }
        ;;

    *)
        PH_INIT_SCRIPT=/etc/init.d/nginx-${NGINX_VERSION_STRING}

        [ -f ${PH_INIT_SCRIPT} ] && {
            ${PH_INIT_SCRIPT} stop
            rm ${PH_INIT_SCRIPT}
        }
        ;;
    esac
    ;;

"mac")
    launchctl quit nginx
    launchctl unload /Library/LaunchAgents/org.nginx.nginx.plist
    rm /Library/LaunchAgents/org.nginx.nginx.plist
    ;;

*)
    echo "Init script removal not implemented!"
    ;;
esac

echo ""
echo "nginx ${NGINX_VERSION_STRING} has been uninstalled."
