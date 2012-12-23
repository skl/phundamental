#!/bin/bash
###############################################################################
#                                                                             #
#                                                                             #
###############################################################################

MARIADB_VERSION_STRING=$1
[ -z "$1" ] && read -p "Specify mariadb version (e.g. 5.5.28): " MARIADB_VERSION_STRING

read -p "Install mariadb dependencies? [y/n]: " REPLY
[ "$REPLY" == "y" ] && ph_install_packages openssl cmake

read -p "Overwrite existing symlinks? [y/n]: " REPLY
[ "$REPLY" == "y" ] && MARIADB_OVERWRITE_SYMLINKS=true || MARIADB_OVERWRITE_SYMLINKS=false

ph_mkdirs \
    /usr/local/src \
    /etc/mysql-${MARIADB_VERSION_STRING} \
    /usr/local/mysql \
    /var/run/mysqld \
    /var/log/mysql-${MARIADB_VERSION_STRING}

ph_creategroup mysql
ph_createuser mysql
ph_assigngroup mysql mysql

cd /usr/local/src

if [ ! -f mariadb-${MARIADB_VERSION_STRING}.tar.gz ]; then
    wget http://ftp.osuosl.org/pub/mariadb/mariadb-${MARIADB_VERSION_STRING}/kvm-tarbake-jaunty-x86/mariadb-${MARIADB_VERSION_STRING}.tar.gz

    if [ ! -f mariadb-${MARIADB_VERSION_STRING}.tar.gz ]; then
        echo "mariadb source download failed!"
        return 1
    fi
fi

tar xzf mariadb-${MARIADB_VERSION_STRING}.tar.gz
cd mariadb-${MARIADB_VERSION_STRING}

# Compile with recommended settings
[ "${PH_ARCH}" == "64bit" ] && BUILD/compile-pentium64-max || BUILD/compile-pentium-max

chown -R mysql /usr/local/mysql

cd /usr/local/mysql
scripts/mysql_install_db --user=mysql

if $MARIADB_OVERWRITE_SYMLINKS ; then
    for i in `ls -1 /usr/local/mysql/bin`; do
        ph_symlink /usr/local/mysql/bin/$i /usr/local/bin/$i
    done
fi

case "${PH_OS}" in \
    "linux")
        case "${PH_OS_FLAVOUR}" in \
            "arch")
            #cp ${PH_INSTALL_DIR}/modules/mariadb/mariadb.in /etc/rc.d/mariadb-${MARIADB_VERSION_STRING}
            #/etc/rc.d/mariadb-${MARIADB_VERSION_STRING} start
            ;;

            *)
            #cp ${PH_INSTALL_DIR}/modules/mariadb/mariadb.in /etc/init.d/mariadb-${MARIADB_VERSION_STRING}
            #/etc/init.d/mariadb-${MARIADB_VERSION_STRING} start
        esac
    ;;

    *)
        echo "mariadb startup script not implemented for this OS... starting manually"
        bin/mysqld_safe --user=mysql >/dev/null &
esac

echo ""
echo "mariadb ${MARIADB_VERSION_STRING} has been installed!"
