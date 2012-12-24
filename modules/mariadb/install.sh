#!/bin/bash
###############################################################################
#                                                                             #
#                                                                             #
###############################################################################

MARIADB_VERSION_STRING=$1
[ -z "$1" ] && read -p "Specify mariadb version (e.g. 5.5.28): " MARIADB_VERSION_STRING

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
        return 1
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
scripts/mysql_install_db --user=mysql

if $MARIADB_OVERWRITE_SYMLINKS ; then
    ph_symlink /usr/local/mariadb-${MARIADB_VERSION_STRING} /usr/local/mysql

    for i in `ls -1 /usr/local/mariadb-${MARIADB_VERSION_STRING}/bin`; do
        ph_symlink /usr/local/mariadb-${MARIADB_VESION_STRING}/bin/$i /usr/local/bin/$i
    done
fi

cp my-medium.cnf /etc/my.cnf

ph_search_and_replace "#skip-networking" "skip-networking" /etc/my.cnf
ph_search_and_replace "^socket" "#socket" /etc/my.cnf
ph_search_and_replace "^#innodb" "innodb" /etc/my.cnf

cd /usr/local/mysql/lib/plugin/
for file in ha_*.so
do
    plugin_name=`echo $file | sed 's/ha_//g' | sed 's/\.so//g' | sed 's/_plugin//g'`
    case $plugin_name in
        "example"|"federatedx"|"xtradb")
            echo "Skipping install of MariaDB plugin $plugin_name"
            ;;

        *)
            echo "Installing MariaDB plugin $plugin_name"
            mysql -u root -e "install plugin $plugin_name soname '$file';"
            ;;
    esac
done

case "${PH_OS}" in \
    "linux")
        case "${PH_OS_FLAVOUR}" in \
            "arch")
            ph_symlink /usr/local/mysql/support-files/mysql.server /etc/rc.d/mysql
            /etc/rc.d/mysql start
            ;;

            "suse")
            ph_symlink /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql
            /etc/init.d/mysql start

            chkconfig --level 3 mysql on
            ;;

            *)
            ph_symlink /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql
            /etc/init.d/mysql start
        esac
    ;;

    *)
        echo "mariadb startup script not implemented for this OS... starting manually"
        /usr/local/mysql/bin/mysqld_safe --user=mysql >/dev/null &
esac

echo ""
echo "mariadb ${MARIADB_VERSION_STRING} has been installed!"
