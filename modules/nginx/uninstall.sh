#!/bin/bash
###############################################################################
#                                                                             #
#                                                                             #
###############################################################################

PH_NGINX_INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PH_INSTALL_DIR="$( cd "${PH_NGINX_INSTALL_DIR}" && cd ../../ && pwd )"
. ${PH_INSTALL_DIR}/bootstrap.sh

read -p "Specify nginx version (e.g. 1.2.7): " NGINX_VERSION_STRING

NGINX_DIRS="/etc/nginx-${NGINX_VERSION_STRING} /var/log/nginx-${NGINX_VERSION_STRING} /usr/local/nginx-${NGINX_VERSION_STRING}"

for i in ${NGINX_DIRS}; do
    [ -d ${i} ] && rm -rf ${i}
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
