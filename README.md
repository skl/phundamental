Arch Linux
==========

Raspberry Pi Model B
--------------------

### Expanding the root parition of the SD card

Whilst booted into Arch on the pi:

    fdisk /dev/mmcblk0

Delete the second partition /dev/mmcblk0p2:

    d
    2

Create a new primary partition and use default sizes prompted. This will then create a partiton that fills the disk:

    n
    p
    2
    enter
    enter

Save and exit fdisk:

    w

Now reboot. Once rebooted:

    resize2fs /dev/mmcblk0p2

Source:
http://archlinuxarm.org/forum/viewtopic.php?p=18160&sid=7daca906d1d8b7d3728c1a748ae7f6a3#p18160

### Prerequisites

    pacman -S git
    git clone git://github.com/skl/featherweight-pi.git /usr/local/src/featherweight-pi
