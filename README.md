# phundamental [![Build Status](https://travis-ci.org/skl/phundamental.png?branch=master)](https://travis-ci.org/skl/phundamental)

phundamental is a collection of bash scripts designed to help ease the creation of lightweight
web servers. You're encouraged to delve into the various `install.sh` files and customise them
to suit your particular server(s) and personal preferences.

## Prerequisites

### Linux

You're already there.

### Mac

Install [homebrew](http://mxcl.github.com/homebrew/).

### Windows

1. Windows users require [cygwin](http://www.cygwin.com/) to use phundamental
1. Install the `subversion` and `ca-certificates` packages using cygwin's `setup.exe`
1. Install `apt-cyg` as below:

```
svn --force export http://apt-cyg.googlecode.com/svn/trunk/ /bin/
chmod +x /bin/apt-cyg
```

#### General

It is recommended that you add `/usr/local/bin` to your path. Add the following to your `.profile` or `.bashrc`:

    export PATH=/usr/local/bin:$PATH

## Instructions

Clone the repo to a directory on your server:

    git clone https://github.com/skl/phundamental.git /usr/local/src/phundamental

Edit `phundamental/etc/phundamental.conf.sh` and update `PH_INSTALL_DIR` to point to your cloned
repository path if you changed the path above. Then execute the installer as root (unless you're
running cygwin, which doesn't have sudo):

    sudo /path/to/your/phundamental/install.sh

**N.B.** You must execute the top-level ``phundament/install.sh`` and not the ``module/.../install.sh`` files. The
top-level installer will ask you which modules to install.

## Modules

phundamental is based on modules. The current out-of-the-box modules are as follows:

* **build-tools** - Uses your package manager to install autoconf, make, libtool etc. for compilation tasks
* **mariadb** - An open-source drop-in replacement for MySQL
* **nginx** - A fast and lightweight alternative to Apache
* **nodejs** - Server-side JavaScript. Recent versions include `npm`
* **php** - PHP with FPM if you choose to install v5.3.3+

Each module is designed to allow for the installation of multiple concurrent versions. For example you could
run both PHP versions 5.3.20 and 5.4.10 and have nginx use a different version of PHP per virtual host.
Configuration examples are included in the modules and are installed at the same time as the binaries.

Source code and binaries will be downloaded and compiled at installation time. This allows phundamental to
stay small and portable. A full git clone currently weighs in at about 2 MiB (including all git ojects).

### Optional modules

* Oracle Instant Client [oic](https://github.com/skl/phundamental-oic)

If you'd like add the optional modules, execute the following in your phundamental
installation directory *prior* to executing `install.sh`:

    git submodule update --init

You can update all submodules in future by executing:

    git submodule foreach git pull origin master

### Upcoming modules

* postfix (MariaDB backend) + roundcube client

## Other resources

Expanding your Arch Linux Raspberry Pi root partition to fill the SD card: https://gist.github.com/4301393
