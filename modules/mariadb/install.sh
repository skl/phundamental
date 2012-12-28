#!/bin/bash
###############################################################################
#                                                                             #
#                                                                             #
###############################################################################

MARIADB_VERSION_STRING=$1
[ -z "$1" ] && read -p "Specify MariaDB version (e.g. 5.5.28a): " MARIADB_VERSION_STRING

if [ "${PH_OS}" == "windows" ]; then

    ph_mkdirs /usr/local/src
    cd /usr/local/src

    if [ "${PH_OS_FLAVOUR}" == "7 64bit" ]; then
        MARIADB_INSTALLER_URI="https://downloads.mariadb.org/interstitial/mariadb-${MARIADB_VERSION_STRING}/winx64-packages/mariadb-${MARIADB_VERSION_STRING}-winx64.msi/from/http://mirror2.hs-esslingen.de/mariadb"
        MARIADB_INSTALLER_FILENAME="mariadb-${MARIADB_VERSION_STRING}-winx64.msi"
    else
        MARIADB_INSTALLER_URI="https://downloads.mariadb.org/interstitial/mariadb-${MARIADB_VERSION_STRING}/win32-packages/mariadb-${MARIADB_VERSION_STRING}-win32.msi/from/http://mirror2.hs-esslingen.de/mariadb"
        MARIADB_INSTALLER_FILENAME="mariadb-${MARIADB_VERSION_STRING}-win32.msi"
    fi

    if [ ! -f ${MARIADB_INSTALLER_FILENAME} ]; then
        wget ${MARIADB_INSTALLER_URI}

        if [ ! -f ${MARIADB_INSTALLER_FILENAME} ]; then
            echo "MariaDB MSI installer download failed!"
            exit 1
        fi
    fi

    echo "Running MSI installer..."
    msiexec /i ${MARIADB_INSTALLER_FILENAME} SERVICENAME=MySQL /qn

else

    read -p "Install mariadb dependencies? [y/n]: " REPLY
    [ "$REPLY" == "y" ] && ph_install_packages openssl cmake bison m4

    read -p "Overwrite existing symlinks? [y/n]: " REPLY
    [ "$REPLY" == "y" ] && MARIADB_OVERWRITE_SYMLINKS=true || MARIADB_OVERWRITE_SYMLINKS=false

    ph_mkdirs \
        /usr/local/src

    ph_creategroup mysql
    ph_createuser mysql
    ph_assigngroup mysql mysql

    cd /usr/local/src

    if [ ! -f mariadb-${MARIADB_VERSION_STRING}.tar.gz ]; then
        wget http://ftp.osuosl.org/pub/mariadb/mariadb-${MARIADB_VERSION_STRING}/kvm-tarbake-jaunty-x86/mariadb-${MARIADB_VERSION_STRING}.tar.gz

        if [ ! -f mariadb-${MARIADB_VERSION_STRING}.tar.gz ]; then
            echo "mariadb source download failed!"
            exit 1
        fi
    fi

    tar xzf mariadb-${MARIADB_VERSION_STRING}.tar.gz
    cd mariadb-${MARIADB_VERSION_STRING}

    make clean
    cmake . \
        -DCMAKE_INSTALL_PREFIX=/usr/local/mariadb-${MARIADB_VERSION_STRING} \
        -DMYSQL_DATADIR=/usr/local/mariadb-${MARIADB_VERSION_STRING}/data

    make -j ${PH_NUM_CPUS} && make install

    chown -R mysql:mysql /usr/local/mariadb-${MARIADB_VERSION_STRING}
    chmod -R 0755 /usr/local/mariadb-${MARIADB_VERSION_STRING}/data

    cd /usr/local/mariadb-${MARIADB_VERSION_STRING}
    cp support-files/my-medium.cnf /etc/my.cnf

    ph_search_and_replace "#skip-networking" "skip-networking" /etc/my.cnf
    ph_search_and_replace "^socket" "#socket" /etc/my.cnf
    ph_search_and_replace "^#innodb" "innodb" /etc/my.cnf

    scripts/mysql_install_db --user=mysql

    if $MARIADB_OVERWRITE_SYMLINKS ; then
        ph_symlink /usr/local/mariadb-${MARIADB_VERSION_STRING} /usr/local/mysql

        for i in `ls -1 /usr/local/mariadb-${MARIADB_VERSION_STRING}/bin`; do
            ph_symlink /usr/local/mariadb-${MARIADB_VERSION_STRING}/bin/$i /usr/local/bin/$i
        done
    fi

    case "${PH_OS}" in \
        "linux")
            case "${PH_OS_FLAVOUR}" in \
                "arch")
                ph_symlink /usr/local/mariadb-${MARIADB_VERSION_STRING}/support-files/mysql.server /etc/rc.d/mysql
                /etc/rc.d/mysql start
                ;;

                "suse")
                ph_symlink /usr/local/mariadb-${MARIADB_VERSION_STRING}/support-files/mysql.server /etc/init.d/mysql
                /etc/init.d/mysql start

                chkconfig --level 3 mysql on
                ;;

                *)
                ph_symlink /usr/local/mariadb-${MARIADB_VERSION_STRING}/support-files/mysql.server /etc/init.d/mysql
                /etc/init.d/mysql start
            esac
        ;;

        *)
            echo "mariadb startup script not implemented for this OS... starting manually"
            /usr/local/mariadb-${MARIADB_VERSION_STRING}/bin/mysqld_safe --user=mysql >/dev/null &
    esac

    /usr/local/mariadb-${MARIADB_VERSION_STRING}/bin/mysql_secure_installation
fi
