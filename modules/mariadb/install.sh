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

    if ! ph_ask_yesno "Do you wish to continue with the MariaDB installation?"; then
        return 1 || exit 1
    fi
fi

read -p "Specify MariaDB version [5.5.36]: " MARIADB_VERSION_STRING
[ -z ${MARIADB_VERSION_STRING} ] && MARIADB_VERSION_STRING="5.5.36"

MARIADB_VERSION_INTEGER=`echo ${MARIADB_VERSION_STRING} | tr -d '.' | cut -c1-3`
MARIADB_VERSION_INTEGER_FULL=`echo ${MARIADB_VERSION_STRING} | tr -d '.'`
MARIADB_VERSION_MAJOR=`echo ${MARIADB_VERSION_STRING} | cut -d. -f1`
MARIADB_VERSION_MINOR=`echo ${MARIADB_VERSION_STRING} | cut -d. -f2`
MARIADB_VERSION_RELEASE=`echo ${MARIADB_VERSION_STRING} | cut -d. -f3`

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

    read -p "Specify installation directory [/usr/local/mariadb-${MARIADB_VERSION_MAJOR}.${MARIADB_VERSION_MINOR}]: " MARIADB_PREFIX
    [ -z ${MARIADB_PREFIX} ] && MARIADB_PREFIX="/usr/local/mariadb-${MARIADB_VERSION_MAJOR}.${MARIADB_VERSION_MINOR}"

    case "${PH_OS}" in \
    "linux")
        SUGGESTED_USER="mysql"
        ;;

    "mac")
        SUGGESTED_USER="_mysql"
        ;;
    esac

    if [ "${PH_OS}" != "windows" ]; then
        read -p "Specify MariaDB user [${SUGGESTED_USER}]: " MARIADB_USER
        [ -z ${MARIADB_USER} ] && MARIADB_USER="${SUGGESTED_USER}"

        read -p "Specify MariaDB group [${SUGGESTED_USER}]: " MARIADB_GROUP
        [ -z ${MARIADB_GROUP} ] && MARIADB_GROUP="${SUGGESTED_USER}"

        if ph_ask_yesno "Should I create the user and group for you?"; then
            ph_creategroup ${MARIADB_GROUP}
            ph_createuser ${MARIADB_USER}
            ph_assigngroup ${MARIADB_GROUP} ${MARIADB_USER}
        fi
    fi

    ph_install_packages\
        bison\
        cmake\
        gcc\
        m4\
        make\
        ncurses\
        openssl\
        wget

    if ph_ask_yesno "Overwrite existing symlinks in /usr/local?"; then
        MARIADB_OVERWRITE_SYMLINKS=true
    else
        MARIADB_OVERWRITE_SYMLINKS=false
    fi

    ph_cd_archive tar xzf mariadb-${MARIADB_VERSION_STRING} .tar.gz \
        http://ftp.osuosl.org/pub/mariadb/mariadb-${MARIADB_VERSION_STRING}/kvm-tarbake-jaunty-x86/mariadb-${MARIADB_VERSION_STRING}.tar.gz

    [ -f CMakeCache.txt ] && rm CMakeCache.txt
    make clean
    cmake . \
        -DCMAKE_INSTALL_PREFIX=${MARIADB_PREFIX} \
        -DMYSQL_DATADIR=${MARIADB_PREFIX}/data \
            && { make -j ${PH_NUM_THREADS} && make install; } || \
                { echo "./configure failed! Check dependencies and re-run the installer."; exit 1; }

    chown -R ${MARIADB_USER}:${MARIADB_GROUP} ${MARIADB_PREFIX}
    chmod -R 0755 ${MARIADB_PREFIX}/data

    cd ${MARIADB_PREFIX}

    # See issue #39
    ph_search_and_replace "^parse_server_arguments \`" "#parse_server_arguments \`" support-files/mysql.server

    cp support-files/my-medium.cnf /etc/my.cnf

    ph_search_and_replace "^skip-networking" "#skip-networking" /etc/my.cnf
    ph_search_and_replace "^socket" "#socket" /etc/my.cnf
    ph_search_and_replace "^#innodb" "innodb" /etc/my.cnf

    scripts/mysql_install_db --user=${MARIADB_USER}

    ph_symlink ${MARIADB_PREFIX} /usr/local/mysql ${MARIADB_OVERWRITE_SYMLINKS}

    for i in `ls -1 ${MARIADB_PREFIX}/bin`; do
        ph_symlink ${MARIADB_PREFIX}/bin/$i /usr/local/bin/$i ${MARIADB_OVERWRITE_SYMLINKS}
    done

    case "${PH_OS}" in \
    "linux")
        case "${PH_OS_FLAVOUR}" in \
        "suse")
            ph_symlink\
                ${MARIADB_PREFIX}/support-files/mysql.server\
                /etc/init.d/mariadb-${MARIADB_VERSION_STRING}\
                ${MARIADB_OVERWRITE_SYMLINKS}

            /etc/init.d/mariadb-${MARIADB_VERSION_STRING} start
            chkconfig --level 3 mariadb-${MARIADB_VERSION_STRING} on
            ;;

        "debian")
            ph_symlink\
                ${MARIADB_PREFIX}/support-files/mysql.server\
                /etc/init.d/mariadb-${MARIADB_VERSION_STRING}\
                ${MARIADB_OVERWRITE_SYMLINKS}

            /etc/init.d/mariadb-${MARIADB_VERSION_STRING} start
            update-rc.d mariadb-${MARIADB_VERSION_STRING} defaults
            ;;

        *)
            ph_symlink\
                ${MARIADB_PREFIX}/support-files/mysql.server\
                /etc/init.d/mariadb-${MARIADB_VERSION_STRING}\
                ${MARIADB_OVERWRITE_SYMLINKS}

            /etc/init.d/mariadb-${MARIADB_VERSION_STRING} start
            ;;
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
        ${MARIADB_PREFIX}/bin/mysqld_safe --user=${MARIADB_USER} >/dev/null &
        ;;
    esac

    ${MARIADB_PREFIX}/bin/mysql_secure_installation
fi

# Cleanup
echo -n "Deleting source files... "
rm -rf /usr/local/src/mariadb-${MARIADB_VERSION_STRING} \
    /usr/local/src/mariadb-${MARIADB_VERSION_STRING}.tar.gz
echo "Complete."

return 0 || exit 0
