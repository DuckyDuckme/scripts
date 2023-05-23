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

    echo 'Creating partitions'
    partition_drive "$DRIVE"

    echo 'Formatting filesystems'
    format_filesystem "$root"

    echo 'Mounting filesystems'
    mount_filesystems "$swap" "$root"

    echo 'Installing base system'
    install_base

    echo 'Chrooting into installed system'
    cp $0 /mnt/setup.sh
    arch-chroot /mnt ./setup.sh chroot

    if [ -f /mnt/setup.sh ]
    then
        echo 'ERROR: Something failed inside the chroot, not unmounting filesystems so you can investigate.'
        echo 'Make sure you unmount everything before you try to run this script again.'
    else
        echo 'Unmounting filesystems'
        unmount_filesystems
        echo 'Done! Reboot system.'
    fi

}

partition_drive() {
    #TODO
}

format_filesystem() {
    #TODO
}

mount_filesystem() {
    #TODO
}

install_base() {
    pacstrap -K /mnt base linux linux-firmware base-devel
}
