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

Clone the repo to a directory on your server:

    git clone git://github.com/skl/phundamental.git

Make sure to set the `PH_INSTALL_DIR` path in `phundamental/bootstrap.sh`.

### Other resources

Expanding your Arch Linux Raspberry Pi root partition to fill the SD card: https://gist.github.com/4301393
