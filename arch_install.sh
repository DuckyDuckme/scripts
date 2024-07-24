#!/bin/bash
#
# This small script will setup the Arch installation on a VMWare. It follows the instructions from the 
# Arch Wiki. The arch_install.sh by Tom Wambold is used as a rough template to help me get started.

DRIVE='/dev/sda'

HOSTNAME='arch-vm'

TIMEZONE='Europe/Amsterdam'

GREEN='\033[0;32m'
NC='\033[0m'

setup() {
    echo -e '${GREEN}Setting the timezone'
    timedatectl set-timezone "$TIMEZONE"

    echo -e '${GREEN}Updating the keyring'
    pacman -S --noconfirm archlinux-keyring

    echo -e '${GREEN}Creating partitions'
    # creates 1GB swap partition and the rest is root
    echo -e ',1G,S\n,+,\n' | sfdisk /dev/sda

    echo -e '${GREEN}Formatting filesystems'
    mkfs.ext4 /dev/sda2
    mkswap /dev/sda1

    echo -e '${GREEN}Mounting filesystems'
    mount /dev/sda2 /mnt
    swapon /dev/sda1

    echo -e '${GREEN}Installing base system'
    pacstrap -K /mnt base linux base-devel

    echo -e '${GREEN}Generate fstab'
    genfstab -U /mnt >> /mnt/etc/fstab

    echo -e '${GREEN}Copying more config to the /mnt in case we want to install more'
    cp ./chroot.sh /mnt/chroot.sh
    chmod +x /mnt/chroot.sh
}

# -e option makes it exit if one of the functions fails
set -e

setup
