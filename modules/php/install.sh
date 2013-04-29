#!/bin/bash
###############################################################################
#                                                                             #
# This install script allows for multiple concurrent versions of PHP to be    #
# installed using php-fpm.                                                    #
#                                                                             #
# Installation directory:                                                     #
# /usr/local/php-<version>                                                    #
#                                                                             #
# Configuration directory:                                                    #
# /etc/php-<version>                                                          #
#                                                                             #
# nginx configuration location:                                               #
# /etc/nginx/global/php-<version>.conf                                        #
#                                                                             #
# PHP-FPM init script location:                                               #
# /etc/init.d/php-<version>-fpm                                               #
#                                                                             #
# PHP-FPM will listen on:                                                     #
# 127.0.0.1:9<version>  e.g. 127.0.0.1:9547 for PHP 5.4.7                     #
#                                                                             #
###############################################################################

PH_PHP_INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PH_INSTALL_DIR="$( cd "${PH_PHP_INSTALL_DIR}" && cd ../../ && pwd )"
. ${PH_INSTALL_DIR}/bootstrap.sh

if ph_is_installed php ; then
    echo "PHP is already installed!"
    ls -l `which php` | awk '{print $9 $10 $11}'
    php -v

    read -p "Do you wish to continue with the PHP installation? [y/n] " REPLY
    [ $REPLY == "n" ] && { return 1 || exit 1; }
fi

read -p "Specify PHP version (e.g. 5.4.14): " PHP_VERSION_STRING

case "${PH_OS}" in \
    "windows" | \
    "linux")
        HOMEDIRS="/home"
    ;;

    "mac")
        HOMEDIRS="/Users"
    ;;
esac

if [ -f /root/.pearrc ]; then
    read -p ".pearrc detected in /root/.pearrc - delete? (recommended) [y/n] "
    [ $REPLY == "y" ] && rm -f /root/.pearrc
fi

for i in `ls -1 ${HOMEDIRS}`; do
    if [ -f "${HOMEDIRS}/${i}/.pearrc" ]; then
        read -p ".pearrc detected in ${HOMEDIRS}/${i} - delete? (recommended) [y/n] "
        [ $REPLY == "y" ] && rm -f ${HOMEDIRS}/${i}/.pearrc
    fi
done

ph_mkdirs \
    /usr/local/src \
    /etc/php-${PHP_VERSION_STRING}

cd /usr/local/src

ph_creategroup www-data
ph_createuser www-data
ph_assigngroup www-data www-data

ph_install_packages\
    autoconf\
    automake\
    bison\
    curl\
    flex\
    gcc\
    gettext\
    libjpeg\
    libtool\
    libxml\
    libxsl\
    make\
    mcrypt\
    mhash\
    openldap\
    openssl\
    pcre\
    png\
    re2c\
    wget\
    zlib

if [ "${PH_OS}" == "windows" ]; then
    # Manually install re2c
    if ! ph_is_installed re2c ; then
        if [ ! -f re2c.zip ]; then
            wget "http://downloads.sourceforge.net/project/gnuwin32/re2c/0.9.4/re2c-0.9.4-bin.zip?r=&ts=1356710822&use_mirror=netcologne" -O re2c.zip

            if [ ! -f re2c.zip ]; then
                echo "re2c download failed!"
                return 1 || exit 1
            fi
        fi

        ph_install_packages unzip

        unzip re2c.zip -d re2c
        cp re2c/bin/re2c.exe /bin
    fi

    # Fix ldap library paths for PHP configure script
    if [ ! -f /usr/lib/libldap.so ]; then
        cp /usr/lib/libldap.dll.a /usr/lib/libldap.so
    fi

    if [ ! -f /usr/lib/libldap_r.so ]; then
        cp /usr/lib/libldap_r.dll.a /usr/lib/libldap.so
    fi
fi

read -p "Overwrite existing symlinks in /usr/local? (recommended) [y/n]: " REPLY
[ "$REPLY" == "y" ] && PHP_OVERWRITE_SYMLINKS=true || PHP_OVERWRITE_SYMLINKS=false

# e.g. 531 (truncated to three characters in order to construct a valid port number for fpm)
# So for PHP 5.4.7,  php-fpm will bind to 127.0.0.1:9547
# .. for PHP 5.3.17, php-fpm will bind to 127.0.0.1:9531
PHP_VERSION_INTEGER=`echo ${PHP_VERSION_STRING} | tr -d '.' | cut -c1-3`

PHP_VERSION_MAJOR=`echo ${PHP_VERSION_STRING} | cut -d. -f1`
PHP_VERSION_MINOR=`echo ${PHP_VERSION_STRING} | cut -d. -f2`
PHP_VERSION_RELEASE=`echo ${PHP_VERSION_STRING} | cut -d. -f3`

# Retrieve source code from php.net
if [ ! -f php-${PHP_VERSION_STRING}.tar.gz ]; then
    wget http://www.php.net/distributions/php-${PHP_VERSION_STRING}.tar.gz

    if [ ! -f php-${PHP_VERSION_STRING}.tar.gz ]; then
        echo "PHP source download failed!"
        return 1 || exit 1
    fi
fi

tar xzf php-${PHP_VERSION_STRING}.tar.gz
cd php-${PHP_VERSION_STRING}
make clean

case "${PH_OS_FLAVOUR}" in \
    "debian")
        if [ -d /usr/lib/x86_64-linux-gnu ]; then
            LIBDIR='lib/x86_64-linux-gnu'
        elif [ -d /usr/lib/i386-linux-gnu ]; then
            LIBDIR='lib/i386-linux-gnu'
        else
            LIBDIR='lib'
        fi
    ;;

    "suse")
        test "${PH_ARCH}" == "32bit" && LIBDIR='lib' || LIBDIR='lib64'
    ;;

    *)
        LIBDIR='lib'
esac

CONFIGURE_ARGS=("--prefix=/usr/local/php-${PHP_VERSION_STRING}" \
    "--with-config-file-path=/etc/php-${PHP_VERSION_STRING}" \
    "--enable-bcmath" \
    "--enable-calendar" \
    "--enable-exif" \
    "--enable-ftp" \
    "--enable-mbstring" \
    "--enable-pcntl" \
    "--enable-pdo" \
    "--enable-zip" \
    "--with-curl" \
    "--with-gd" \
    "--with-jpeg-dir" \
    "--with-ldap" \
    "--with-libxml-dir" \
    "--with-xsl" \
    "--with-mcrypt" \
    "--with-mhash" \
    "--with-openssl" \
    "--with-regex=system" \
    "--with-zlib");

if [[ "${PH_OS}" == "mac" ]]; then
    CONFIGURE_ARGS=(${CONFIGURE_ARGS[@]} \
        "--with-gettext=`find /usr/local/Cellar/gettext -depth 1 | sort | tail -1`")
else
    CONFIGURE_ARGS=(${CONFIGURE_ARGS[@]} \
        "--with-gettext" \
        "--with-libdir=${LIBDIR}")

    # Compilation will not work without this option when RAM <= 512 MiB
    if [ ${PH_RAM_MB} -le 512 ]; then
        CONFIGURE_ARGS=(${CONFIGURE_ARGS[@]} \
            "--disable-fileinfo")
    fi
fi

# Enable FPM for 5.3.3+
if [ ${PHP_VERSION_MAJOR} -eq 5 ] && \
   [ ${PHP_VERSION_MINOR} -ge 3 ] && \
   [ ${PHP_VERSION_RELEASE} -ge 3 ] ; then
    CONFIGURE_ARGS=(${CONFIGURE_ARGS[@]} \
        "--enable-fpm")
fi

# PHP4 MySQL is enabled by default, so only deal with 5
if [ ${PHP_VERSION_MAJOR} -eq 5 ] ; then

    # MySQLi for 5.0.x, 5.1.x, 5.2.x
    if [ ${PHP_VERSION_MINOR} -le 2 ]; then
        if ph_is_installed mysql_config ; then
            CONFIGURE_ARGS=(${CONFIGURE_ARGS[@]} \
                "--with-mysqli=`which mysql_config`" \
                "--with-pdo-mysql=/usr/local/mysql")
        else
            echo "mysql_config binary not found: you need to setup MySQL first if installing PHP <= 5.2.x"
            return 1
        fi

    # MySQL native driver for 5.3.x
    elif [ ${PHP_VERSION_MINOR} -eq 3 ]; then
        ph_install_packages libmysql

        CONFIGURE_ARGS=(${CONFIGURE_ARGS[@]} \
            "--with-mysql" \
            "--with-mysqli=mysqlnd" \
            "--with-pdo-mysql=mysqlnd")

    # MySQL native driver 5.4+
    else
        CONFIGURE_ARGS=(${CONFIGURE_ARGS[@]} \
            "--with-mysqli" \
            "--with-pdo-mysql=mysqlnd")
    fi
fi

# Add Oracle support if sqlplus binary found
if ph_is_installed sqlplus ; then
    case "${PH_OS}" in \
        "linux")
            CONFIGURE_ARGS=(${CONFIGURE_ARGS[@]} \
                "--with-pdo-oci=instantclient,/usr,10.2.0.5" \
                "--with-oci8")
        ;;

        "mac")
            CONFIGURE_ARGS=(${CONFIGURE_ARGS[@]} \
                "--with-oci8=instantclient,/usr/local/instantclient")
        ;;
    esac
fi

if [[ "${PH_PACKAGE_MANAGER}" == "brew" ]]; then
    # Add homebrew include directories
    CONFIGURE_ARGS=("${CONFIGURE_ARGS[@]}" \
        "--with-png-dir=/usr/X11" \
        "--with-cc-opt=-I/usr/local/include" \
        "--with-ld-opt=-L/usr/local/lib")
fi

# Build!
CFLAGS='-O2 -DEAPI'
./configure ${CONFIGURE_ARGS[@]} && { make -j ${PH_NUM_THREADS} && make install; } || \
    { echo "./configure failed! Check dependencies and re-run the installer."; exit 1; }

ph_symlink /usr/local/php-${PHP_VERSION_STRING} /usr/local/php $PHP_OVERWRITE_SYMLINKS

for i in `ls -1 /usr/local/php-${PHP_VERSION_STRING}/bin`; do
    ph_symlink /usr/local/php-${PHP_VERSION_STRING}/bin/$i /usr/local/bin/$i $PHP_OVERWRITE_SYMLINKS
done

# Install nginx config files
if [ -d /etc/nginx ]; then
    ph_cp_inject ${PH_INSTALL_DIR}/modules/php/www.example.com /etc/nginx/sites-available/www.example.com\
        "##PHP_VERSION_STRING##" "${PHP_VERSION_STRING}"

    ph_cp_inject ${PH_INSTALL_DIR}/modules/php/nginx.conf /etc/nginx/global/php-${PHP_VERSION_STRING}.conf\
        "##PHP_VERSION_INTEGER##" "${PHP_VERSION_INTEGER}"

    ph_search_and_replace "##PHP_VERSION_STRING##" "${PHP_VERSION_STRING}" /etc/nginx/global/php-${PHP_VERSION_STRING}.conf
fi

# Install PHP config files
ph_cp_inject ${PH_INSTALL_DIR}/modules/php/php.ini /etc/php-${PHP_VERSION_STRING}/php.ini\
    "##PHP_VERSION_INTEGER##" "${PHP_VERSION_INTEGER}"

ph_cp_inject ${PH_INSTALL_DIR}/modules/php/php-fpm.conf /etc/php-${PHP_VERSION_STRING}/php-fpm.conf\
    "##PHP_VERSION_INTEGER##" "${PHP_VERSION_INTEGER}"


ph_search_and_replace "##PHP_VERSION_STRING##" "${PHP_VERSION_STRING}" /etc/php-${PHP_VERSION_STRING}/php.ini
ph_search_and_replace "##PHP_VERSION_STRING##" "${PHP_VERSION_STRING}" /etc/php-${PHP_VERSION_STRING}/php-fpm.conf

PHP_BIN_DIR=/usr/local/php-${PHP_VERSION_STRING}/bin

# Set PHP extension_dir
PHP_EXTENSION_API=`${PHP_BIN_DIR}/php -i | grep "PHP Extension =>" | awk '{print $4}'`
ph_search_and_replace "##PHP_EXTENSION_API##" "${PHP_EXTENSION_API}" /etc/php-${PHP_VERSION_STRING}/php.ini

# Setup PEAR/PECL
${PHP_BIN_DIR}/pear config-set php_ini /etc/php-${PHP_VERSION_STRING}/php.ini
${PHP_BIN_DIR}/pear config-set preferred_state beta
${PHP_BIN_DIR}/pear config-set auto_discover 1

read -p "Install APC and xdebug? [y/n] " REPLY
if [ "$REPLY" == "y" ]; then
    # PECL installs need to be done one at a time so that it doesn't mess up php.ini
    ${PHP_BIN_DIR}/pecl install --alldeps apc
    ${PHP_BIN_DIR}/pecl install --alldeps xdebug

    # Fix xdebug.so ini directive
    ph_search_and_replace\
        "extension=\"xdebug.so\""\
        "zend_extension=\/usr\/local\/php-${PHP_VERSION_STRING}\/lib\/php\/extensions\/no-debug-non-zts-${PHP_EXTENSION_API}\/xdebug.so"\
        /etc/php-${PHP_VERSION_STRING}/php.ini
fi

read -p "Install PHPUnit? [y/n] " REPLY
if [ "$REPLY" == "y" ]; then
    ${PHP_BIN_DIR}/pear install --alldeps pear.phpunit.de/PHPUnit
    ph_symlink ${PHP_BIN_DIR}/phpunit /usr/local/bin/phpunit ${PHP_OVERWRITE_SYMLINKS}
fi

read -p "Install phpDocumentor? [y/n] " REPLY
if [ "$REPLY" == "y" ]; then
    ${PHP_BIN_DIR}/pear channel-discover pear.phpdoc.org
    ${PHP_BIN_DIR}/pear install phpdoc/phpDocumentor-alpha
    ph_symlink ${PHP_BIN_DIR}/phpdoc /usr/local/bin/phpunit ${PHP_OVERWRITE_SYMLINKS}
fi

read -p "Install Composer? [y/n] " REPLY
if [ "$REPLY" == "y" ]; then
    curl -sS https://getcomposer.org/installer | php
    mv -i composer.phar /usr/local/bin/composer
fi

NGINX_SBIN=`which nginx`

case "${PH_OS}" in \
    "linux")
        case "${PH_OS_FLAVOUR}" in \
            "arch")
                ph_cp_inject ${PH_INSTALL_DIR}/modules/php/php-fpm.in /etc/rc.d/php-${PHP_VERSION_STRING}-fpm\
                    "##PHP_VERSION_INTEGER##" "${PHP_VERSION_INTEGER}"

                ph_search_and_replace "##PHP_VERSION_STRING##" "${PHP_VERSION_STRING}" /etc/rc.d/php-${PHP_VERSION_STRING}-fpm

                /etc/rc.d/php-${PHP_VERSION_STRING}-fpm start
                [ -x ${NGINX_SBIN} ] && ${NGINX_SBIN} -s reload
            ;;

            "suse")
                ph_cp_inject ${PH_INSTALL_DIR}/modules/php/php-fpm.in /etc/init.d/php-${PHP_VERSION_STRING}-fpm\
                    "##PHP_VERSION_INTEGER##" "${PHP_VERSION_INTEGER}"

                ph_search_and_replace "##PHP_VERSION_STRING##" "${PHP_VERSION_STRING}" /etc/init.d/php-${PHP_VERSION_STRING}-fpm

                chkconfig php-${PHP_VERSION_STRING}-fpm on

                /etc/init.d/php-${PHP_VERSION_STRING}-fpm start
                [ -x ${NGINX_SBIN} ] && ${NGINX_SBIN} -s reload
            ;;

            *)
                ph_cp_inject ${PH_INSTALL_DIR}/modules/php/php-fpm.in /etc/init.d/php-${PHP_VERSION_STRING}-fpm\
                    "##PHP_VERSION_INTEGER##" "${PHP_VERSION_INTEGER}"

                ph_search_and_replace "##PHP_VERSION_STRING##" "${PHP_VERSION_STRING}" /etc/init.d/php-${PHP_VERSION_STRING}-fpm

                /etc/init.d/php-${PHP_VERSION_STRING}-fpm start
                update-rc.d php-${PHP_VERSION_STRING}-fpm defaults

                [ -x ${NGINX_SBIN} ] && ${NGINX_SBIN} -s reload
        esac
    ;;

    "mac")
        ph_cp_inject ${PH_INSTALL_DIR}/modules/php/org.php.php-fpm.plist \
            /Library/LaunchAgents/org.php.php-fpm.plist \
            "##PHP_VERSION_STRING##" "${PHP_VERSION_STRING}"

        chown root:wheel /Library/LaunchAgents/org.php.php-fpm.plist
        launchctl load -w /Library/LaunchAgents/org.php.php-fpm.plist
    ;;

    *)
        echo "PHP-FPM startup script not implemented for this OS! Starting manually..."
        /usr/local/php-${PHP_VERSION_STRING}/sbin/php-fpm --fpm-config /etc/php-${PHP_VERSION_STRING}/php-fpm.conf
esac

# Cleanup
echo -n "Deleting source files... "
rm -rf /usr/local/src/php-${PHP_VERSION_STRING} \
    /usr/local/src/php-${PHP_VERSION_STRING}.tar.gz
echo "Complete."

if [ -d /etc/nginx ]; then
    echo ""
    echo "Check out the example configuration file: /etc/nginx/sites-available/www.example.com"
    echo "To enable Graph generation in phpDocumentor install Graphviz: http://graphviz.org/Download.php"
fi

return 0 || exit 0
