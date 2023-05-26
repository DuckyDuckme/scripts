#!/bin/bash
#
# This small script will setup the Arch installation on a virtual machine. It follows the instructions from the 
# Arch Wiki. The arch_install.sh by Tom Wambold is used as a rough template to help me get started.

# The drive we are installing to
DRIVE='/dev/sda'

# Hostname of the machine
HOSTNAME='arch-vm'

# Timezone
TIMEZONE='Europe/Amsterdam'

setup() {
    echo 'Setting the timezone'
    timedatectl set-timezone "$TIMEZONE"

    echo 'Updating the keyring'
    pacman -S --noconfirm archlinux-keyring

    echo 'Creating partitions'
    # creates 200MB swap partition and the rest is root
    echo -e ',200M,S\n,+,\n' | sfdisk /dev/sda

    echo 'Formatting filesystems'
    mkfs.ext4 /dev/sda2
    mkswap /dev/sda1

    echo 'Mounting filesystems'
    mount /dev/sda2 /mnt
    swapon /dev/sda1

    echo 'Installing base system'
    pacstrap -K /mnt base linux base-devel

    echo 'Generate fstab'
    genfstab -U /mnt >> /mnt/etc/fstab
}

# -e option makes it exit if one of the functions fails
# -x option prints the trace
set -ex

setup
