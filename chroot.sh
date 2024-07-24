#!/bin/bash

configure() {
    local ROOT_PASSWORD=''
    local DUCKY_PASSWORD=''
    local HOSTNAME='archvm'

    echo 'Installing packages'
    install_extra

    echo 'Set hostname and timezone'
    echo "$HOSTNAME" > /etc/hostname
    ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
    hwclock --systohc

    echo 'Set locale'
    echo 'LANG="en_US.UTF-8"' >> /etc/locale.conf
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
    locale-gen

    echo 'Configure networkd'
    echo -e "[Match]\nName=en*\n\n[Network]\nDHCP=yes" >> /etc/systemd/network/20-wired.network
    systemctl enable systemd-networkd.service systemd-resolved.service

    echo 'Configure GRUB'
    grub-install --target=i386-pc /dev/sda
    grub-mkconfig -o /boot/grub/grub.cfg

    echo 'Enter the root password:'
    stty -echo
    read ROOT_PASSWORD
    stty echo
    set_root_password "$ROOT_PASSWORD"

    echo "Enter the password for ducky"
    stty -echo
    read DUCKY_PASSWORD
    stty echo
    create_ducky "$DUCKY_PASSWORD"

    echo 'Configure doas and sudo'
    set_sudoers
    set_doas

    #echo 'Setup AUR and update repos'
    #setup_AUR
    #update_repos

    echo 'Configure Xorg'
    Xorg :0 -configure
    mv /root/xorg.conf.new /etc/X11/xorg.conf

    echo 'Set up complete, you can reboot now'
}

install_extra() {
    local packages=''

    # Man pages
    packages+=' man-db man-pages texinfo'

    # Development
    packages+=' python rsync vim nano neovim git'

    # Internet
    packages+=' firefox openssh wget curl'

    # Files
    packages+=' doas unzip zip'

    # Xserver
    packages+=' xorg xf86-video-vmware virtualbox-guest-utils'

    # Misc
    packages+=' grub pkgstats rfkill'

    # XFCE4
    packages+=' xfce4 xfce4-goodies xorg-xinit'

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

set_sudoers() {
    echo "ducky   ALL=(ALL:ALL) ALL"> /etc/sudoers
    chmod 440 /etc/sudoers
}

set_doas() {
    echo -e "permit persist setenv {PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin} :wheel\n" > /etc/doas.conf
    ln -s $(which doas) /usr/bin/sudo
}

configure
