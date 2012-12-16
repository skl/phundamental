#!/bin/bash
###############################################################################
#                                                                             #
#                                                                             #
###############################################################################

[ -z "$1" ] && read -p "Specify nginx version (e.g. 1.2.6): " NGINX_VERSION_STRING

exit

# e.g. 1.2.3
NGINX_VERSION_STRING=$1

read -p "Install nginx dependencies? [y/n]: " REPLY
[ "$REPLY" == "y" ] && ph_install_packages pcre-devel openssl-devel

ph_mkdir /etc/nginx
ph_mkdir /var/log/nginx

cd /usr/local/src

wget http://nginx.org/download/nginx-${NGINX_VERSION_STRING}.tar.gz
[ -f nginx-${NGINZ_VERSION_STRING}.tar.gz ] || echo "nginx source download failed!"; exit

tar xzf nginx-${NGINX_VERSION_STRING}.tar.gz
cd nginx-${NGINX_VERSION_STRING}
./configure \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --conf-path=/etc/nginx/nginx.conf \
    --with-pcre \
    --with-http_ssl_module \
    --with-http_realip_module

make -j ${PH_NUM_CPUS} && make install

ln -s /usr/local/nginx/logs /var/log/nginx

ph_mkdir /etc/nginx/global
ph_mkdir /etc/nginx/sites-available
ph_mkdir /etc/nginx/sites-enabled

cp ${WHEREAMI}/nginx/nginx.conf /etc/nginx/nginx.conf
cp ${WHEREAMI}/nginx/restrictions.conf /etc/nginx/global/restrictions.conf

ph_mkdir /var/www

case "${PH_OS}" in \
    "linux")
        case "${PH_OS_FLAVOUR}" in \
            "arch")
            cp ${WHEREAMI}/nginx/nginx.in /etc/rc.d/nginx
            /etc/rc.d/nginx start
            ;;

            *)
            cp ${WHEREAMI}/nginx/nginx.in /etc/init.d/nginx
            /etc/init.d/nginx start
        esac
    ;;

    *)
        echo "nginx startup script not implemented for this OS..."
esac

echo ""
echo "nginx ${NGINX_VERSION_STRING} has been installed."
