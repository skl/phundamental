#!/bin/bash
###############################################################################
#                                                                             #
#                                                                             #
###############################################################################

PH_MARIADB_INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PH_INSTALL_DIR="$( cd "${PH_MARIADB_INSTALL_DIR}" && cd ../../ && pwd )"
. ${PH_INSTALL_DIR}/bootstrap.sh

if ph_is_installed mysql ; then
    echo "MySQL is already installed!"
    ls -l `which mysql` | awk '{print $9 $10 $11}'
    mysql --version

    read -p "Do you wish to continue with the MariaDB installation? [y/n] " REPLY
    [ $REPLY == "n" ] && { return 1 || exit 1; }
fi

read -p "Specify MariaDB version (e.g. 5.5.28a): " MARIADB_VERSION_STRING

if [ "${PH_OS}" == "windows" ]; then

    ph_mkdirs /usr/local/src
    cd /usr/local/src

    if [ "${PH_OS_FLAVOUR}" == "7 64bit" ]; then
        MARIADB_INSTALLER_URI="http://ftp.osuosl.org/pub/mariadb/mariadb-${MARIADB_VERSION_STRING}/winx64-packages/mariadb-${MARIADB_VERSION_STRING}-winx64.msi"
        MARIADB_INSTALLER_FILENAME="mariadb-${MARIADB_VERSION_STRING}-winx64.msi"
    else
        MARIADB_INSTALLER_URI="http://ftp.osuosl.org/pub/mariadb/mariadb-${MARIADB_VERSION_STRING}/win32-packages/mariadb-${MARIADB_VERSION_STRING}-win32.msi"
        MARIADB_INSTALLER_FILENAME="mariadb-${MARIADB_VERSION_STRING}-win32.msi"
    fi

    if [ ! -f ${MARIADB_INSTALLER_FILENAME} ]; then
        wget ${MARIADB_INSTALLER_URI}

        if [ ! -f ${MARIADB_INSTALLER_FILENAME} ]; then
            echo "MariaDB MSI installer download failed!"
            return 1 || exit 1
        fi
    fi

    echo "Running MSI installer..."
    msiexec /i ${MARIADB_INSTALLER_FILENAME} SERVICENAME=MySQL /qn

else

    ph_install_packages\
        bison\
        cmake\
        gcc\
        m4\
        make\
        ncurses\
        openssl\
        wget

    read -p "Overwrite existing symlinks? [y/n]: " REPLY
    [ "$REPLY" == "y" ] && MARIADB_OVERWRITE_SYMLINKS=true || MARIADB_OVERWRITE_SYMLINKS=false

    ph_mkdirs /usr/local/src

    ph_creategroup mysql
    ph_createuser mysql
    ph_assigngroup mysql mysql

    cd /usr/local/src

    if [ ! -f mariadb-${MARIADB_VERSION_STRING}.tar.gz ]; then
        wget http://ftp.osuosl.org/pub/mariadb/mariadb-${MARIADB_VERSION_STRING}/kvm-tarbake-jaunty-x86/mariadb-${MARIADB_VERSION_STRING}.tar.gz

        if [ ! -f mariadb-${MARIADB_VERSION_STRING}.tar.gz ]; then
            echo "mariadb source download failed!"
            return 1 || exit 1
        fi
    fi

    tar xzf mariadb-${MARIADB_VERSION_STRING}.tar.gz
    cd mariadb-${MARIADB_VERSION_STRING}

    make clean
    cmake . \
        -DCMAKE_INSTALL_PREFIX=/usr/local/mariadb-${MARIADB_VERSION_STRING} \
        -DMYSQL_DATADIR=/usr/local/mariadb-${MARIADB_VERSION_STRING}/data \
            && { make -j ${PH_NUM_THREADS} && make install; } || \
                { echo "./configure failed! Check dependencies and re-run the installer."; exit 1; }

    chown -R mysql:mysql /usr/local/mariadb-${MARIADB_VERSION_STRING}
    chmod -R 0755 /usr/local/mariadb-${MARIADB_VERSION_STRING}/data

    cd /usr/local/mariadb-${MARIADB_VERSION_STRING}
    cp support-files/my-medium.cnf /etc/my.cnf

    ph_search_and_replace "^skip-networking" "#skip-networking" /etc/my.cnf
    ph_search_and_replace "^socket" "#socket" /etc/my.cnf
    ph_search_and_replace "^#innodb" "innodb" /etc/my.cnf

    scripts/mysql_install_db --user=mysql

    ph_symlink /usr/local/mariadb-${MARIADB_VERSION_STRING} /usr/local/mysql ${MARIADB_OVERWRITE_SYMLINKS}

    for i in `ls -1 /usr/local/mariadb-${MARIADB_VERSION_STRING}/bin`; do
        ph_symlink /usr/local/mariadb-${MARIADB_VERSION_STRING}/bin/$i /usr/local/bin/$i ${MARIADB_OVERWRITE_SYMLINKS}
    done

    case "${PH_OS}" in \
        "linux")
            case "${PH_OS_FLAVOUR}" in \
                "arch")
                ph_symlink /usr/local/mariadb-${MARIADB_VERSION_STRING}/support-files/mysql.server /etc/rc.d/mysql ${MARIADB_OVERWRITE_SYMLINKS}
                /etc/rc.d/mysql start
                ;;

                "suse")
                ph_symlink /usr/local/mariadb-${MARIADB_VERSION_STRING}/support-files/mysql.server /etc/init.d/mysql ${MARIADB_OVERWRITE_SYMLINKS}
                /etc/init.d/mysql start

                chkconfig --level 3 mysql on
                ;;

                *)
                ph_symlink /usr/local/mariadb-${MARIADB_VERSION_STRING}/support-files/mysql.server /etc/init.d/mysql ${MARIADB_OVERWRITE_SYMLINKS}
                /etc/init.d/mysql start
            esac
        ;;

        "mac")
            ph_mkdirs /Library/LaunchAgents

            ph_cp_inject ${PH_INSTALL_DIR}/modules/mariadb/org.mysql.mysqld.plist /Library/LaunchAgents/org.mysql.mysqld.plist \
                "##MARIADB_VERSION_STRING##" "${MARIADB_VERSION_STRING}"

            chown root:wheel /Library/LaunchAgents/org.mysql.mysqld.plist
            launchctl load -w /Library/LaunchAgents/org.mysql.mysqld.plist
        ;;

        *)
            echo "mariadb startup script not implemented for this OS... starting manually"
            /usr/local/mariadb-${MARIADB_VERSION_STRING}/bin/mysqld_safe --user=mysql >/dev/null &
    esac

    /usr/local/mariadb-${MARIADB_VERSION_STRING}/bin/mysql_secure_installation
fi

return 0 || exit 0
