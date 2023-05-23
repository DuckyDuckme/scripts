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
    local swap="$DRIVE"1
    local root="$DRIVE"2

    echo 'Setting the timezone'
    timedatectl set-timezone "$TIMEZONE"

    echo 'Updating the keyring'
    pacman -S archlinux-keyring

    echo 'Creating partitions'
    # creates 200MB swap partition and the rest is root
    echo -e ',200M,S\n,+,\n' | sfdisk /dev/sda

    echo 'Formatting filesystems'
    mkfs.ext4 /dev/sda2
    mkswap /dev/sda1

    echo 'Mounting filesystems'
    mount /dev/sda2
    swapon /dev/sda1

    echo 'Installing base system'
    pacstrap -K /mnt base linux linux-firmware base-devel

    echo 'Chrooting into installed system'
    cp $0 /mnt/setup.sh
    arch-chroot /mnt ./setup.sh chroot

    if [ -f /mnt/setup.sh ]
    then
        echo 'ERROR: Something failed inside the chroot, not unmounting filesystems so you can investigate.'
        echo 'Make sure you unmount everything before you try to run this script again.'
    else
        echo 'Unmounting filesystems'
	umount /mnt
	swapoff /dev/sda1
        echo 'Done! Reboot system.'
    fi

}

configure() {
    echo 'Installing packages'
    install_extra

    echo 'Set hostname and timezone'
    echo "$HOSTNAME" > /etc/hostname
    ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime

    echo 'Set locale'
    echo 'LANG="en_US.UTF-8"' >> /etc/locale.conf
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
    locale-gen

    echo 'Configure networkd'
    echo -e "[Match]\nName=ens33\n\n[Network]\nDHCP=yes" >> /etc/systemd/network/20-wired.network
    systemctl enable networkd.service resolved.service

    echo 'Configure GRUB'
    grub-install --target=i386-pc /dev/sda
    grub-mkconfig -o /boot/grub/grub.cfg

    echo 'Create the root password'
    set_root_password

    echo 'Create the ducky'
    create_ducky

    echo 'Configure xorg'

}

install_extra() {
    local packages=''

    # Man pages
    packages+=' man-db man-pages texinfo'

    # Development
    packages+=' python rsync vim'
    # Internet
    packages+=' firefox openssh wget'

    # Files
    packages+=' sudo doas unzip zip'

    # Xserver
    packages+=' xorg xf86-video-vmware'

    # Fonts
    #packages+=' ttf

    # Misc
    packages+=' grub'

    # XFCE4
    packages+=' xfce4 xfce4-goodies'

    pacman -Sy --noconfirm $packages
}

set_root_password() {
    local password="$1"; shift

    echo -en "$password\n$password" | passwd
}

create_ducky() {
    local password="$1"; shift

    useradd -m -G wheel ducky
    echo -en "$password\n$password" | passwd ducky
}

# -e option makes it exit if one of the functions fails
# -x option prints the trace
set -ex

if [ "$1" == "chroot" ]
then
    configure
else
    setup
fi
