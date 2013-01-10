##
# Phundamental package map
#
# This file allows for the installation of dependencies using a variety of
# package managers. The ph_install_packages() function uses this file to decide
# which packages to install.
#
# Format is colon-separated e.g. "<package-key>:<package-manager>:<package-name>"
# Lines starting with '#' or where <package-name> is ##SKIP## will be ignored.
#
# Entries should be sorted alphabetically.
#
# no bz2 for brew
autoconf:apt-cyg:autoconf
autoconf:brew:autoconf
autoconf:yum:autoconf
autoconf:zypper:autoconf
automake:apt-cyg:automake
automake:brew:automake
automake:yum:automake
automake:zypper:automake
bison:apt-cyg:bison
bison:brew:bison
bison:yum:bison
bison:zypper:bison
cmake:apt-cyg:cmake
cmake:brew:cmake
cmake:yum:cmake
cmake:zypper:cmake
curl:apt-cyg:libcurl-devel curl
curl:brew:curl
curl:yum:libcurl-devel libcurl curl
curl:zypper:libcurl-devel curl
flex:apt-cyg:flex
flex:brew:flex
flex:yum:flex
flex:zypper:flex
gcc:apt-cyg:gcc gcc-g++
gcc:brew:gcc
gcc:yum:gcc gcc-c++
gcc:zypper:gcc gcc-c++
gettext:apt-cyg:gettext-devel gettext
gettext:brew:gettext
gettext:yum:gettext-devel gettext
gettext:zypper:gettext-runtime
ghostscript:apt-cyg:ghostscript
ghostscript:brew:ghostscript
ghostscript:yum:ghostscript-devel ghostscript
ghostscript:zypper:ghostscript-mini-devel ghostscript
libbz2:apt-cyg:libbz2-devel
libbz2:yum:bzip2-devel
libbz2:zypper:libbz2-devel
libjpeg:apt-cyg:libjpeg-devel libjpeg8 jpeg
libjpeg:brew:jpeg
libjpeg:yum:libjpeg-devel libjpeg
libjpeg:zypper:libjpeg8-devel
libtiff:apt-cyg:libtiff-devel tiff
libtiff:brew:libtiff
libtiff:yum:libtiff-devel libtiff
libtiff:zypper:libtiff-devel
libtool:apt-cyg:libtool
libtool:brew:libtool
libtool:yum:libtool
libtool:zypper:libtool
libxml:apt-cyg:libxml2-devel libxml2
libxml:brew:libxml2
libxml:yum:libxml2-devel libxml2
libxml:zypper:libxml2-devel libxml2
m4:apt-cyg:m4
m4:brew:m4
m4:yum:m4
m4:zypper:m4
make:apt-cyg:make
make:brew:make
make:yum:make
make:zypper:make
mcrypt:apt-cyg:libmcrypt-devel libmcrypt mcrypt
mcrypt:brew:mcrypt
mcrypt:yum:libmcrypt-devel libmcrypt mcrypt
mcrypt:zypper:libmcrypt-devel mcrypt
mhash:apt-cyg:mhash
mhash:brew:mhash
mhash:yum:mhash-devel mhash
mhash:zypper:mhash-devel mhash
ncurses:apt-cyg:libncurses-devel ncurses
ncurses:brew:ncurses
ncurses:yum:ncurses-devel ncurses-libs ncurses
ncurses:zypper:ncurses-devel libncurses6
openldap:apt-cyg:openldap-devel libopenldap2
openldap:brew:openldap
openldap:yum:openldap-devel
openldap:zypper:openldap2-devel
openssl:apt-cyg:openssl-devel openssl
openssl:apt-get:openssl libssl-dev
openssl:brew:openssl
openssl:pacman:openssl
openssl:yum:openssl openssl-devel
openssl:zypper:openssl libopenssl-devel
pcre:apt-cyg:libpcre-devel pcre-devel pcre
pcre:apt-get:libpcre3 libpcre3-dev
pcre:brew:pcre
pcre:pacman:pcre
pcre:yum:pcre pcre-devel
pcre:zypper:libpcre1 pcre-devel
png:apt-cyg:libpng-devel libpng
png:brew:libpng
png:yum:libpng
png:zypper:libpng14-devel
python:apt-cyg:python
python:brew:python
python:yum:python
python:zypper:python
re2c:apt-cyg:##SKIP##
re2c:brew:re2c
re2c:yum:re2c
re2c:zypper:re2c
unzip:apt-cyg:unzip
unzip:brew:##SKIP##
unzip:yum:unzip
unzip:zypper:##SKIP##
wget:apt-cyg:wget
wget:apt-get:wget
wget:brew:wget
wget:pacman:wget
wget:yum:wget
wget:zypper:wget
zlib:apt-cyg:zlib-devel zlib
zlib:brew:zlib
zlib:yum:zlib
zlib:zypper:zlib-devel zlib
