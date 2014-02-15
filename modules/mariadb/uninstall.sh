#!/bin/bash
###############################################################################
#                                                                             #
#                                                                             #
###############################################################################

PH_MARIADB_INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PH_INSTALL_DIR="$( cd "${PH_MARIADB_INSTALL_DIR}" && cd ../../ && pwd )"
. ${PH_INSTALL_DIR}/bootstrap.sh

read -p "Specify mariadb version (e.g. 5.5.29): " MARIADB_VERSION_STRING

read -p "Remove symlinks? [y/n]: " REPLY
[ "$REPLY" == "y" ] && MARIADB_OVERWRITE_SYMLINKS=true || MARIADB_OVERWRITE_SYMLINKS=false

if $MARIADB_OVERWRITE_SYMLINKS ; then
    # Clear out /usr/local/bin
    for i in `ls -1 /usr/local/mariadb-${MARIADB_VERSION_STRING}/bin`; do
        if [ -L "/usr/local/bin/$i" ]; then
            rm /usr/local/bin/$i
        fi
    done

    # Stop mysql and remove startup scripts
    case "${PH_OS}" in \
        "linux")
            case "${PH_OS_FLAVOUR}" in \
                "suse")
                if [ -L "/etc/init.d/mariadb-${MARIADB_VERSION_STRING}" ]; then
                    chkconfig --level 3 mariadb-${MARIADB_VERSION_STRING} off
                    /etc/init.d/mariadb-${MARIADB_VERSION_STRING} stop
                    rm /etc/init.d/mariadb-${MARIADB_VERSION_STRING}
                fi
                ;;

                "debian")
                if [ -L "/etc/init.d/mariadb-${MARIADB_VERSION_STRING}" ]; then
                    /etc/init.d/mariadb-${MARIADB_VERSION_STRING} stop
                    update-rc.d mariadb-${MARIADB_VERSION_STRING} remove
                    rm /etc/init.d/mariadb-${MARIADB_VERSION_STRING}
                fi
                ;;

                *)
                if [ -L "/etc/init.d/mariadb-${MARIADB_VERSION_STRING}" ]; then
                    /etc/init.d/mariadb-${MARIADB_VERSION_STRING} stop
                    rm /etc/init.d/mariadb-${MARIADB_VERSION_STRING}
                fi
            esac
        ;;

        "mac")
            launchctl quit mysql
            launchctl unload /Library/LaunchAgents/org.mysql.mysqld.plist
            rm /Library/LaunchAgents/org.mysql.mysqld.plist
        ;;

        *)
            echo "mariadb startup script not implemented for this OS... stopping manually"
            kill `ps -ef | grep -v grep | grep /usr/local/mariadb-${MARIADB_VERSION_STRING}/bin/mysqld_safe | awk '{print $2}'`
    esac

    [ -L "/usr/local/mysql" ] && rm /usr/local/mysql
fi

rm -rf /usr/local/mariadb-${MARIADB_VERSION_STRING}

if [ -f "/etc/my.cnf" ]; then
    read -p "Delete '/etc/my.cnf'? [y/n]" REPLY
    [ "$REPLY" == "y" ] && rm -f /etc/my.cnf
fi

read -p "Delete mysql user and group? [y/n]" REPLY
if [ "$REPLY" == "y" ]; then
    ph_deletegroup mysql
    ph_deleteuser mysql
fi

echo ""
echo "MariaDB ${MARIADB_VERSION_STRING} has been uninstalled!"
