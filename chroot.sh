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
    echo -e "[Match]\nName=ens33\n\n[Network]\nDHCP=yes" >> /etc/systemd/network/20-wired.network
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
    rm /root/xorg.conf.new

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
    packages+=' xorg xf86-video-vmware'

    # Fonts
    #packages+=' ttf

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
    cat > /etc/sudoers <<EOF
## sudoers file.
##
## This file MUST be edited with the 'visudo' command as root.
## Failure to use 'visudo' may result in syntax or file permission errors
## that prevent sudo from running.
##
## See the sudoers man page for the details on how to write a sudoers file.
##

##
## Host alias specification
##
## Groups of machines. These may include host names (optionally with wildcards),
## IP addresses, network numbers or netgroups.
# Host_Alias    WEBSERVERS = www1, www2, www3

##
## User alias specification
##
## Groups of users.  These may consist of user names, uids, Unix groups,
## or netgroups.
# User_Alias    ADMINS = millert, dowdy, mikef

##
## Cmnd alias specification
##
## Groups of commands.  Often used to group related commands together.
# Cmnd_Alias    PROCESSES = /usr/bin/nice, /bin/kill, /usr/bin/renice, \
#                           /usr/bin/pkill, /usr/bin/top

##
## Defaults specification
##
## You may wish to keep some of the following environment variables
## when running commands via sudo.
##
## Locale settings
# Defaults env_keep += "LANG LANGUAGE LINGUAS LC_* _XKB_CHARSET"
##
## Run X applications through sudo; HOME is used to find the
## .Xauthority file.  Note that other programs use HOME to find   
## configuration files and this may lead to privilege escalation!
# Defaults env_keep += "HOME"
##
## X11 resource path settings
# Defaults env_keep += "XAPPLRESDIR XFILESEARCHPATH XUSERFILESEARCHPATH"
##
## Desktop path settings
# Defaults env_keep += "QTDIR KDEDIR"
##
## Allow sudo-run commands to inherit the callers' ConsoleKit session
# Defaults env_keep += "XDG_SESSION_COOKIE"
##
## Uncomment to enable special input methods.  Care should be taken as
## this may allow users to subvert the command being run via sudo.
# Defaults env_keep += "XMODIFIERS GTK_IM_MODULE QT_IM_MODULE QT_IM_SWITCHER"
##
## Uncomment to enable logging of a command's output, except for
## sudoreplay and reboot.  Use sudoreplay to play back logged sessions.
# Defaults log_output
# Defaults!/usr/bin/sudoreplay !log_output
# Defaults!/usr/local/bin/sudoreplay !log_output
# Defaults!/sbin/reboot !log_output

##
## Runas alias specification
##

##
## User privilege specification
##
root ALL=(ALL) ALL

## Uncomment to allow members of group wheel to execute any command
%wheel ALL=(ALL) ALL

## Same thing without a password
# %wheel ALL=(ALL) NOPASSWD: ALL

## Uncomment to allow members of group sudo to execute any command
# %sudo ALL=(ALL) ALL

## Uncomment to allow any user to run sudo if they know the password
## of the user they are running the command as (root by default).
# Defaults targetpw  # Ask for the password of the target user
# ALL ALL=(ALL) ALL  # WARNING: only use this together with 'Defaults targetpw'

%rfkill ALL=(ALL) NOPASSWD: /usr/sbin/rfkill

## Read drop-in files from /etc/sudoers.d
## (the '#' here does not indicate a comment)
#includedir /etc/sudoers.d
EOF

    chmod 440 /etc/sudoers
}

set_doas() {
    echo "permit persist :wheel\n" > /etc/doas.conf
    ln -s $(which doas) /usr/bin/sudo
}

configure
