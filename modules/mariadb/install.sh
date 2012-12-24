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
    /usr/local/src \
    /usr/local/mysql/data

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
    -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
    -DMYSQL_DATADIR=/usr/local/mysql/data

make -j ${PH_NUM_CPUS} && make install

chown -R mysql:mysql /usr/local/mysql
chmod -R 0755 /usr/local/mysql/data

cd /usr/local/mysql
scripts/mysql_install_db --user=mysql

if $MARIADB_OVERWRITE_SYMLINKS ; then
    for i in `ls -1 /usr/local/mysql/bin`; do
        ph_symlink /usr/local/mysql/bin/$i /usr/local/bin/$i
    done
fi

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
            i/etc/init.d/mysql start

            chkconfig --level 3 mysql on
            ;;

            *)
            ph_symlink /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql
            /etc/init.d/mysql start
        esac
    ;;

    *)
        echo "mariadb startup script not implemented for this OS... starting manually"
        bin/mysqld_safe --user=mysql >/dev/null &
esac

echo ""
echo "mariadb ${MARIADB_VERSION_STRING} has been installed!"
