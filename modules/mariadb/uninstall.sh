#!/bin/bash

PH_MARIADB_INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PH_INSTALL_DIR="$( cd "${PH_MARIADB_INSTALL_DIR}" && cd ../../ && pwd )"
. ${PH_INSTALL_DIR}/bootstrap.sh

read -p "Specify MariaDB version [10.0.11]: " MARIADB_VERSION_STRING
[ -z ${MARIADB_VERSION_STRING} ] && MARIADB_VERSION_STRING="10.0.11"

MARIADB_VERSION_INTEGER=`echo ${MARIADB_VERSION_STRING} | tr -d '.' | cut -c1-3`
MARIADB_VERSION_INTEGER_FULL=`echo ${MARIADB_VERSION_STRING} | tr -d '.'`
MARIADB_VERSION_MAJOR=`echo ${MARIADB_VERSION_STRING} | cut -d. -f1`
MARIADB_VERSION_MINOR=`echo ${MARIADB_VERSION_STRING} | cut -d. -f2`
MARIADB_VERSION_RELEASE=`echo ${MARIADB_VERSION_STRING} | cut -d. -f3`

read -p "Specify installation directory [/usr/local/mariadb-${MARIADB_VERSION_MAJOR}.${MARIADB_VERSION_MINOR}]: " MARIADB_PREFIX
[ -z ${MARIADB_PREFIX} ] && MARIADB_PREFIX="/usr/local/mariadb-${MARIADB_VERSION_MAJOR}.${MARIADB_VERSION_MINOR}"

if ph_ask_yesno "Remove symlinks?"; then
    MARIADB_OVERWRITE_SYMLINKS=true
else
    MARIADB_OVERWRITE_SYMLINKS=false
fi

if $MARIADB_OVERWRITE_SYMLINKS ; then
    # Clear out /usr/local/bin
    [ -d ${MARIADB_PREFIX}/bin ] && {
        for i in `ls -1 ${MARIADB_PREFIX}/bin`; do
            [ -L /usr/local/bin/$i ] && rm /usr/local/bin/$i
        done
    }
fi

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
        kill `ps -ef | grep -v grep | grep ${MARIADB_PREFIX}/bin/mysqld_safe | awk '{print $2}'`
esac

if $MARIADB_OVERWRITE_SYMLINKS ; then
    [ -L "/usr/local/mysql" ] && rm /usr/local/mysql
fi

rm -rf ${MARIADB_PREFIX}

[ -f /etc/my.cnf ] && rm -i /etc/my.cnf

if [ "${PH_OS}" != "windows" ]; then
    case "${PH_OS}" in \
    "linux")
        SUGGESTED_USER="mysql"
        ;;

    "mac")
        SUGGESTED_USER="_mysql"
        ;;
    esac

    if ph_ask_yesno "Delete user and group?"; then
        read -p "Specify MariaDB user [${SUGGESTED_USER}]: " MARIADB_USER
        [ -z ${MARIADB_USER} ] && MARIADB_USER="${SUGGESTED_USER}"

        read -p "Specify MariaDB group [${SUGGESTED_USER}]: " MARIADB_GROUP
        [ -z ${MARIADB_GROUP} ] && MARIADB_GROUP="${SUGGESTED_USER}"

        ph_deletegroup ${MARIADB_GROUP}
        ph_deleteuser ${MARIADB_USER}
    fi
fi

echo
echo "MariaDB ${MARIADB_VERSION_STRING} has been uninstalled!"
