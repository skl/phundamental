#!/bin/bash
###############################################################################
#                                                                             #
#                                                                             #
###############################################################################

PH_MARIADB_INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PH_INSTALL_DIR="$( cd "${PH_MARIADB_INSTALL_DIR}" && cd ../../ && pwd )"
. ${PH_INSTALL_DIR}/bootstrap.sh

MARIADB_VERSION_STRING=$1
[ -z "$1" ] && read -p "Specify mariadb version (e.g. 5.5.28a): " MARIADB_VERSION_STRING

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
                "arch")
                if [ -L "/etc/rc.d/mysql" ]; then
                    /etc/rc.d/mysql stop
                    rm /etc/rc.d/mysql
                fi
                ;;

                "suse")
                if [ -L "/etc/init.d/mysql" ]; then
                    chkconfig --level 3 mysql off
                    /etc/init.d/mysql stop
                    rm /etc/init.d/mysql
                fi
                ;;

                *)
                if [ -L "/etc/init.d/mysql" ]; then
                    /etc/init.d/mysql stop
                    rm /etc/init.d/mysql
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

rm -rf \
    /usr/local/src/mariadb-${MARIADB_VERSION_STRING} \
    /usr/local/src/mariadb-${MARIADB_VERSION_STRING}.tar.gz \
    /usr/local/mariadb-${MARIADB_VERSION_STRING}

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
