#!/bin/bash
###############################################################################
#                                                                             #
#                                                                             #
###############################################################################

NGINX_VERSION_STRING=$1
[ -z "$1" ] && read -p "Specify nginx version (e.g. 1.2.6): " NGINX_VERSION_STRING

read -p "Install nginx dependencies? [y/n]: " REPLY
[ "$REPLY" == "y" ] && ph_install_packages pcre openssl

read -p "Overwrite existing symlinks? [y/n]: " REPLY
[ "$REPLY" == "y" ] && NGINX_OVERWRITE_SYMLINKS=true || NGINX_OVERWRITE_SYMLINKS=false

ph_mkdirs \
    /usr/local/src \
    /etc/nginx-${NGINX_VERSION_STRING} \
    /var/log/nginx-${NGINX_VERSION_STRING} \
    /etc/nginx-${NGINX_VERSION_STRING}/global \
    /etc/nginx-${NGINX_VERSION_STRING}/sites-available \
    /etc/nginx-${NGINX_VERSION_STRING}/sites-enabled \
    /var/www/localhost/public

cd /usr/local/src

if [ ! -f nginx-${NGINX_VERSION_STRING}.tar.gz ]; then
    wget http://nginx.org/download/nginx-${NGINX_VERSION_STRING}.tar.gz

    if [ ! -f nginx-${NGINX_VERSION_STRING}.tar.gz ]; then
        echo "nginx source download failed!"
        return 1
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

if [[ "${PH_OS}" == "mac" ]]; then
    # Add homebrew include directories
    CONFIGURE_ARGS=("${CONFIGURE_ARGS[@]}" \
        "--with-cc-opt=-I/usr/local/include" \
        "--with-ld-opt=-L/usr/local/lib")
fi

./configure ${CONFIGURE_ARGS[@]} && make -j ${PH_NUM_CPUS} && make install

cp ${PH_INSTALL_DIR}/nginx/nginx.conf /etc/nginx-${NGINX_VERSION_STRING}/nginx.conf
cp ${PH_INSTALL_DIR}/nginx/restrictions.conf /etc/nginx-${NGINX_VERSION_STRING}/global/restrictions.conf
cp ${PH_INSTALL_DIR}/nginx/localhost.conf /etc/nginx-${NGINX_VERSION_STRING}/sites-available/localhost
cp ${PH_INSTALL_DIR}/nginx/index.html /var/www/localhost/public/index.html

if $NGINX_OVERWRITE_SYMLINKS ; then
    ph_symlink /etc/nginx-${NGINX_VERSION_STRING} /etc/nginx
    ph_symlink /usr/local/nginx-${NGINX_VERSION_STRING} /usr/local/nginx
    ph_symlink /usr/local/nginx-${NGINX_VERSION_STRING}/logs /var/log/nginx
    ph_symlink /usr/local/nginx-${NGINX_VERSION_STRING}/sbin/nginx /usr/local/bin/nginx
    ph_symlink /etc/nginx-${NGINX_VERSION_STRING}/sites-available/localhost /etc/nginx-${NGINX_VERSION_STRING}/sites-enabled/localhost
fi

case "${PH_OS}" in \
    "linux")
        case "${PH_OS_FLAVOUR}" in \
            "arch")
            cp ${PH_INSTALL_DIR}/nginx/nginx.in /etc/rc.d/nginx-${NGINX_VERSION_STRING}
            /etc/rc.d/nginx-${NGINX_VERSION_STRING} start
            ;;

            *)
            cp ${PH_INSTALL_DIR}/nginx/nginx.in /etc/init.d/nginx-${NGINX_VERSION_STRING}
            /etc/init.d/nginx-${NGINX_VERSION_STRING} start
        esac
    ;;

    *)
        echo "nginx startup script not implemented for this OS... starting manually"
        /usr/local/nginx-${NGINX_VERSION_STRING}/sbin/nginx
esac

echo ""
echo "nginx ${NGINX_VERSION_STRING} has been installed."
