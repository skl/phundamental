#!/bin/bash
###############################################################################
#                                                                             #
#                                                                             #
###############################################################################

PH_NGINX_INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PH_INSTALL_DIR="$( cd "${PH_NGINX_INSTALL_DIR}" && cd ../../ && pwd )"
. ${PH_INSTALL_DIR}/bootstrap.sh

if ph_is_installed nginx ; then
    echo "nginx is already installed!"
    ls -l `which nginx` | awk '{print $9 $10 $11}'
    nginx -v

    read -p "Do you wish to continue with the nginx installation? [y/n] " REPLY
    [ $REPLY == "n" ] && { return 1 || exit 1; }
fi

read -p "Specify nginx version (e.g. 1.4.1): " NGINX_VERSION_STRING


ph_install_packages\
    gcc\
    make\
    openssl\
    pcre\
    wget\
    zlib

read -p "Overwrite existing symlinks in /usr/local? (recommended) [y/n]: " REPLY
[ "$REPLY" == "y" ] && NGINX_OVERWRITE_SYMLINKS=true || NGINX_OVERWRITE_SYMLINKS=false

ph_mkdirs \
    /usr/local/src \
    /etc/nginx-${NGINX_VERSION_STRING} \
    /var/log/nginx-${NGINX_VERSION_STRING} \
    /etc/nginx-${NGINX_VERSION_STRING}/global \
    /etc/nginx-${NGINX_VERSION_STRING}/sites-available \
    /etc/nginx-${NGINX_VERSION_STRING}/sites-enabled \
    /var/www/localhost/public

ph_creategroup www-data
ph_createuser www-data
ph_assigngroup www-data www-data

cd /usr/local/src

if [ ! -f nginx-${NGINX_VERSION_STRING}.tar.gz ]; then
    wget http://nginx.org/download/nginx-${NGINX_VERSION_STRING}.tar.gz

    if [ ! -f nginx-${NGINX_VERSION_STRING}.tar.gz ]; then
        echo "nginx source download failed!"
        return 1 || exit 1
    fi
fi

tar xzf nginx-${NGINX_VERSION_STRING}.tar.gz
cd nginx-${NGINX_VERSION_STRING}

CONFIGURE_ARGS=("--prefix=/usr/local/nginx-${NGINX_VERSION_STRING}" \
    "--pid-path=/usr/local/nginx-${NGINX_VERSION_STRING}/logs/nginx.pid" \
    "--error-log-path=/var/log/nginx-${NGINX_VERSION_STRING}/error.log" \
    "--http-log-path=/var/log/nginx-${NGINX_VERSION_STRING}/access.log" \
    "--conf-path=/etc/nginx-${NGINX_VERSION_STRING}/nginx.conf" \
    "--with-pcre" \
    "--with-http_ssl_module" \
    "--with-http_realip_module");

if [[ "${PH_PACKAGE_MANAGER}" == "brew" ]]; then
    # Add homebrew include directories
    CONFIGURE_ARGS=("${CONFIGURE_ARGS[@]}" \
        "--with-cc-opt=-I/usr/local/include" \
        "--with-ld-opt=-L/usr/local/lib")
fi

./configure ${CONFIGURE_ARGS[@]} && { make -j ${PH_NUM_THREADS} && make install; } || \
    { echo "./configure failed! Check dependencies and re-run the installer."; exit 1; }

cp ${PH_INSTALL_DIR}/modules/nginx/nginx.conf /etc/nginx-${NGINX_VERSION_STRING}/nginx.conf
cp ${PH_INSTALL_DIR}/modules/nginx/restrictions.conf /etc/nginx-${NGINX_VERSION_STRING}/global/restrictions.conf
cp ${PH_INSTALL_DIR}/modules/nginx/localhost.conf /etc/nginx-${NGINX_VERSION_STRING}/sites-available/localhost
cp ${PH_INSTALL_DIR}/modules/nginx/000-catchall.conf /etc/nginx-${NGINX_VERSION_STRING}/sites-available/000-catchall

ph_cp_inject ${PH_INSTALL_DIR}/modules/nginx/index.html /var/www/localhost/public/index.html\
    "##NGINX_VERSION_STRING##" "${NGINX_VERSION_STRING}"

# Patch nginx config files for windows
if [ "${PH_OS}" == "windows" ]; then
    ph_search_and_replace "^user" "#user" /etc/nginx-${NGINX_VERSION_STRING}/nginx.conf
    ph_search_and_replace "worker_connections  1024" "worker_connections  64" /etc/nginx-${NGINX_VERSION_STRING}/nginx.conf
fi

ph_symlink /etc/nginx-${NGINX_VERSION_STRING} /etc/nginx ${NGINX_OVERWRITE_SYMLINKS}
ph_symlink /usr/local/nginx-${NGINX_VERSION_STRING} /usr/local/nginx ${NGINX_OVERWRITE_SYMLINKS}
ph_symlink /usr/local/nginx-${NGINX_VERSION_STRING}/logs /var/log/nginx ${NGINX_OVERWRITE_SYMLINKS}
ph_symlink /usr/local/nginx-${NGINX_VERSION_STRING}/sbin/nginx /usr/local/bin/nginx ${NGINX_OVERWRITE_SYMLINKS}
ph_symlink /etc/nginx-${NGINX_VERSION_STRING}/sites-available/localhost /etc/nginx-${NGINX_VERSION_STRING}/sites-enabled/localhost ${NGINX_OVERWRITE_SYMLINKS}
ph_symlink /etc/nginx-${NGINX_VERSION_STRING}/sites-available/000-catchall /etc/nginx-${NGINX_VERSION_STRING}/sites-enabled/000-catchall ${NGINX_OVERWRITE_SYMLINKS}

case "${PH_OS}" in \
    "linux")
        case "${PH_OS_FLAVOUR}" in \
            "arch")
            ph_cp_inject ${PH_INSTALL_DIR}/modules/nginx/nginx.in /etc/rc.d/nginx-${NGINX_VERSION_STRING} \
                "##NGINX_VERSION_STRING##" "${NGINX_VERSION_STRING}"

            /etc/rc.d/nginx-${NGINX_VERSION_STRING} start
            ;;

            "suse")
            ph_cp_inject ${PH_INSTALL_DIR}/modules/nginx/nginx.in /etc/init.d/nginx-${NGINX_VERSION_STRING} \
                "##NGINX_VERSION_STRING##" "${NGINX_VERSION_STRING}"

            chkconfig nginx-${NGINX_VERSION_STRING} on
            /etc/init.d/nginx-${NGINX_VERSION_STRING} start
            ;;

            *)
            ph_cp_inject ${PH_INSTALL_DIR}/modules/nginx/nginx.in /etc/init.d/nginx-${NGINX_VERSION_STRING} \
                "##NGINX_VERSION_STRING##" "${NGINX_VERSION_STRING}"

            /etc/init.d/nginx-${NGINX_VERSION_STRING} start
            update-rc.d nginx-${NGINX_VERSION_STRING} defaults
        esac
    ;;

    "mac")
        ph_cp_inject ${PH_INSTALL_DIR}/modules/nginx/org.nginx.nginx.plist /Library/LaunchAgents/org.nginx.nginx.plist \
            "##NGINX_VERSION_STRING##" "${NGINX_VERSION_STRING}"

        chown root:wheel /Library/LaunchAgents/org.nginx.nginx.plist
        launchctl load -w /Library/LaunchAgents/org.nginx.nginx.plist
    ;;

    *)
        echo "nginx startup script not implemented for this OS... starting manually"
        /usr/local/nginx-${NGINX_VERSION_STRING}/sbin/nginx
esac

# Cleanup
echo -n "Deleting source files... "
rm -rf /usr/local/src/nginx-${NGINX_VERSION_STRING} \
    /usr/local/src/nginx-${NGINX_VERSION_STRING}.tar.gz
echo "Complete."

return 0 || exit 0
