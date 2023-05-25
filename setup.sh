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

    echo 'Ranking the mirrors'
    update_repos

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

    echo 'Chrooting into installed system'
    cp $0 /mnt/setup.sh
    arch-chroot /mnt ./setup.sh chroot

    if [ -f /mnt/setup.sh ]
    then
        echo 'ERROR: Something failed inside the chroot, not unmounting filesystems so you can investigate.'
        echo 'Make sure you unmount everything before you try to run this script again.'

}

# idk if I should put it here or once we are chrooted
update_repos() {
    cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
    mkdir /tmp/foo
    cd /tmp/foo
    git clone https://aur.archlinux.org/rate-mirrors.git
    cd rate-mirrors
    makepkg -sicr --noconfirm

    rate-mirrors arch | sudo tee /etc/pacman.d/mirrorlist

}

# -e option makes it exit if one of the functions fails
# -x option prints the trace
set -ex

setup
