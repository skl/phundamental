# phundamental

phundamental is a collection of bash scripts designed to help ease the creation of lightweight
web servers. You're encouraged to delve into the various `install.sh` files and customise them
to suit your particular server(s) and personal preferences.

## Prerequisites

You'll need git installed before you can clone this repo on your server, pick the appropriate
command for your operating system and environment:

    apt-get install git
    brew install git
    pacman -S git
    yum install git
    zypper install git

## Instructions

Clone the repo to a directory on your server and execute `install.sh` as root:

    git clone https://github.com/skl/phundamental.git && sudo phundamental/install.sh

If you'd like add the optional modules, execute the following in your
phundamental installation directory:

    git submodule update --init

You can update all submodules in future by executing:

    git submodule foreach git pull origin master

## Upcoming modules

* postfix (MariaDB backend) + roundcube client

### Other resources

Expanding your Arch Linux Raspberry Pi root partition to fill the SD card: https://gist.github.com/4301393
