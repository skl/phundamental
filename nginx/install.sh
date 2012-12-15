#!/bin/bash
###############################################################################
#                                                                             #
#                                                                             #
###############################################################################

if test -z "$1"
then
    echo "nginx version must be specified! e.g. ./install.sh 1.2.3"
    exit
fi

# e.g. 1.2.3
NGINX_VERSION_STRING=$1

# Used to set number of threads during compilation
NUM_CPUS=`cat /proc/cpuinfo | grep processor | wc -l`


mkdir /etc/nginx
mkdir -p /var/log/nginx

cd /usr/local/src

wget http://nginx.org/download/nginx-${NGINX_VERSION_STRING}.tar.gz
tar xzf nginx-${NGINX_VERSION_STRING}.tar.gz
cd nginx-${NGINX_VERSION_STRING}
./configure \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --conf-path=/etc/nginx/nginx.conf \
    --with-pcre \
    --with-http_ssl_module \
    --with-http_realip_module

make -j ${NUM_CPUS} && make install

ln -s /usr/local/nginx/logs /var/log/nginx

mkdir /etc/nginx/global
mkdir /etc/nginx/sites-available
mkdir /etc/nginx/sites-enabled

cp /usr/local/src/build/nginx/nginx.conf /etc/nginx/nginx.conf
cp /usr/local/src/build/nginx/restrictions.conf /etc/nginx/global/restrictions.conf
cp /usr/local/src/build/nginx/nginx.in /etc/init.d/nginx

/etc/init.d/nginx start
chkconfig --set nginx on

echo ""
echo "nginx ${NGINX_VERSION_STRING} has been installed."
